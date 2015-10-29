resource "aws_route53_record" "runner" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-survey.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elb.ecs_lb.dns_name}"]
}

resource "aws_route53_record" "author" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-author.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${heroku_app.eq_author.heroku_hostname}"]
}
