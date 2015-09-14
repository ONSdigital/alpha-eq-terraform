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
}

# Create a database, and configure the app to use it
resource "heroku_addon" "database" {
  app = "${heroku_app.eq_author.name}"
  plan = "heroku-postgresql:hobby-basic"
}

# Create our executor
resource "heroku_app" "eq-executor" {
    name = "${var.env}-ons-eq-executor"
    region = "eu"

    config_vars {
        SURVEY_REGISTRY_URL = "${heroku_app.eq_author.web_url}"
    }
}
