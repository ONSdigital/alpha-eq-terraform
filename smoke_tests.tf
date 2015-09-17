# Simplistic smoke test run
# A little bit of a hack to execute.

resource "template_file" "smoke_test" {
    filename = "smokey.sh"
    vars {
        noop = "This test may take a while for dynamos to spin up..."
    }

    provisioner "local-exec" {
      command = "./smokey.sh ${heroku_app.eq_surveyrunner.web_url} ${heroku_app.eq_author.web_url}"
      }
}
