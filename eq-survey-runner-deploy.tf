provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-1"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.env}"
}

resource "aws_launch_configuration" "ecs-lc" {
  name                 = "ecs-lc-${var.env}"
  image_id             = "ami-6b12271c"
  instance_type        = "${var.aws_instance_type}"
  key_name             = "${var.aws_key_pair}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.env} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs-ag" {
  name                 = "ecs-asg-${var.env}"
  availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  launch_configuration = "${aws_launch_configuration.ecs-lc.name}"
  min_size             = 1
  max_size             = 10
  desired_capacity     = 1

}


resource "aws_ecs_service" "eq-survey-runner" {
  name = "eq-survey-runner-${var.env}"
  cluster = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.eq-survey-task.arn}"
  desired_count = 1

  iam_role        = "${aws_iam_role.ecs_role.arn}"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  load_balancer {
   elb_name = "${aws_elb.ecs_lb.id}"
   container_name = "nginx"
   container_port = 8082
  }
}

resource "template_file" "survey_runner_task" {
  filename = "aws/task-definitions/eq-survey-runner.json"

  vars {
    survey_registry_url   = "${heroku_app.eq_author.web_url}"
  }
}

resource "aws_ecs_task_definition" "eq-survey-task" {
  family = "deq-task-${var.env}"
  container_definitions = "${template_file.survey_runner_task.rendered}"

}

# Create a new load balancer
resource "aws_elb" "ecs_lb" {
  name = "eq-survey-runner-elb-${var.env}"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  listener {
    instance_port = 8082
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8082/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "survey-runner-elb-${var.env}"
  }
}


/* ecs iam role */
resource "aws_iam_role" "ecs_role" {
  name               = "ecs-role-${var.env}"
  assume_role_policy = "${file("aws/policies/ecs-role.json")}"
}

/* ecs load balancer role policy */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecs-service-role-policy-${var.env}"
  policy   = "${file("aws/policies/ecs-service-role-policy.json")}"
  role     = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance role policy */
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name     = "ecs-instance-role-policy-${var.env}"
  policy   = "${file("aws/policies/ecs-instance-role-policy.json")}"
  role     = "${aws_iam_role.ecs_role.id}"
}

/* Profile for auto-scaling launch configuration.*/
 resource "aws_iam_instance_profile" "ecs" {
  name = "ecsInstance-profile-${var.env}"
  path = "/"
  roles = ["${aws_iam_role.ecs_role.name}"]
}

resource "aws_security_group" "ecs" {
  name = "allow_all-${var.env}"
  description = "Allow all inbound traffic"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-sg-${var.env}"
  }
}


output "SurveyURL " {
    value = "http://${var.env}-survey.eq.ons.digital/"
}
