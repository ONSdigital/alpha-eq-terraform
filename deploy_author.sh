#!/bin/bash
AUTHOR_REPO_URL=https://github.com/ONSdigital/eq-author
BRANCH=master

echo $AUTHOR_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $AUTHOR_REPO_URL
cd ./eq-author
git fetch
git checkout $BRANCH
git pull
heroku git:remote -a $1
git push heroku $BRANCH:master
heroku run python manage.py migrate
