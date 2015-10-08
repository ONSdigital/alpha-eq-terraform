provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-1"
}

resource "aws_ecs_cluster" "default" {
  name = "default"
}

resource "aws_launch_configuration" "ecs" {
  image_id             = "ami-6b12271c"
  instance_type        = "${var.aws_instance_type}"
  key_name             = "${var.aws_key_pair}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=default > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "ecs-asg"
  availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = 1
  max_size             = 10
  desired_capacity     = 1

  lifecycle {
      create_before_destroy = true
  }
}


resource "aws_ecs_service" "eq-survey-runner" {
  name = "eq-survey-runner"
  cluster = "${aws_ecs_cluster.default.id}"
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

resource "aws_ecs_task_definition" "eq-survey-task" {
  family = "deq-task"
  container_definitions = "${file("task-definitions/eq-survey-runner.json")}"

}

# Create a new load balancer
resource "aws_elb" "ecs_lb" {
  name = "eq-survey-runner-elb"
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
    Name = "survey-runner-elb"
  }
}


/* ecs iam role */
resource "aws_iam_role" "ecs_role" {
  name               = "ecsRole"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

/* ecs load balancer role policy */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecsServiceRolePolicy"
  policy   = "${file("policies/ecs-service-role-policy.json")}"
  role     = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance role policy */
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name     = "ecsInstanceRolePolicy"
  policy   = "${file("policies/ecs-instance-role-policy.json")}"
  role     = "${aws_iam_role.ecs_role.id}"
}

/* Profile for auto-scaling launch configuration.*/
 resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  path = "/"
  roles = ["${aws_iam_role.ecs_role.name}"]
}

resource "aws_security_group" "ecs" {
  name = "allow_all"
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
    Name = "ecs-sg"
  }
}


output "SurveyRunner" {
    value = "${aws_elb.ecs_lb.dns_name}"
}
