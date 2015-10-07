#!/bin/sh

# Preprend upstream config for the survey runner
(echo "upstream eqsurveyrunner { server $EQ_SURVEY_RUNNER_PORT_8080_TCP_ADDR:$EQ_SURVEY_RUNNER_PORT_8080_TCP_PORT; }" && cat eq-survey-runner.conf) > eq-survey-runner.conf.new
mv eq-survey-runner.conf.new /etc/nginx/conf.d/eq-survey-runner.conf

# Start nginx
echo "daemon off;" >> /etc/nginx/nginx.conf
service nginx restart
