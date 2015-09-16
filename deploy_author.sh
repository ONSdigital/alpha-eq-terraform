#!/bin/bash
AUTHOR_REPO_URL=https://github.com/ONSdigital/eq-author
BRANCH=create-django-project-skeleton

echo $AUTHOR_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $AUTHOR_REPO_URL
cd ./eq-author
git fetch
git checkout $BRANCH
heroku git:remote -a $1
git push heroku $BRANCH:master
