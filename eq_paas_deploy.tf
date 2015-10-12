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
        # Kludge to get around cyclic issue. BEWARE. @TOFIX
        SURVEY_RUNNER_URL ="http://${aws_elb.ecs_lb.dns_name}/"
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



#output "SurveyRunner" {
#    value = "${heroku_app.eq_surveyrunner.web_url}"
#}
output "AuthorTool" {
    value = "${heroku_app.eq_author.web_url}"
}
