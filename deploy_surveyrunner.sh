#!/bin/bash
SRUNNER_REPO_URL=https://github.com/ONSdigital/eq-survey-runner

mkdir -p tmp
cd ./tmp
git clone $SRUNNER_REPO_URL
cd ./eq-survey-runner
heroku git:remote -a $1
git push heroku master
