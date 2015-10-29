# Configure the Heroku provider
provider "heroku" {
    email = "${var.heroku_email_account}"
    api_key = "${var.heroku_api_key}"
}

# Create our authoring app
resource "heroku_app" "eq_author" {
    name = "${var.env}-ons-eq-author"
    region = "eu"

    config_vars {
        SURVEY_RUNNER_URL = "${aws_route53_record.runner.fqdn}"
    }
    provisioner "local-exec" {
       command = "./deploy_author.sh ${var.env}-ons-eq-author"
   }

}

# Create a database, and configure the app to use it
resource "heroku_addon" "database" {
  app = "${heroku_app.eq_author.name}"
  plan = "heroku-postgresql:hobby-dev"
}

# Associate a custom domain
resource "heroku_domain" "default" {
    app = "${heroku_app.eq_author.name}"
    hostname = "${aws_route53_record.author.fqdn}"
}

output "AuthorURL" {
    value = "http://${var.env}-author.eq.ons.digital/"
}
