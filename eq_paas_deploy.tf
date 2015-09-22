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
        FOOBAR = "baz"
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

# Create our executor
resource "heroku_app" "eq_surveyrunner" {
    name = "${var.env}-ons-eq-surveyrunner"
    region = "eu"

    config_vars {
        SURVEY_REGISTRY_URL = "${heroku_app.eq_author.web_url}"
    }
    # Use local provisioner to clone and push our app.
    provisioner "local-exec" {
       command = "./deploy_surveyrunner.sh ${var.env}-ons-eq-surveyrunner"
   }
}


output "SurveyRunner" {
    value = "${heroku_app.eq_surveyrunner.web_url}"
}
output "AuthorTool" {
    value = "${heroku_app.eq_author.web_url}"
}
