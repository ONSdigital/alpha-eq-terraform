#!/bin/bash
SRUNNER_REPO_URL=https://github.com/ONSdigital/eq-survey-runner
BRANCH=master

echo $SRUNNER_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $SRUNNER_REPO_URL
cd ./eq-survey-runner
git fetch
git checkout $BRANCH
heroku git:remote -a $1
git push heroku $BRANCH:master
