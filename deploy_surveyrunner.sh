#!/bin/bash
SRUNNER_REPO_URL=https://github.com/ONSdigital/eq-survey-runner
BRANCH=master

echo $SRUNNER_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $SRUNNER_REPO_URL
cd ./eq-survey-runner
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
   git branch --track ${branch#remotes/origin/} $branch
done
git checkout $BRANCH
git pull
heroku git:remote -a $1
git push heroku $BRANCH:master
