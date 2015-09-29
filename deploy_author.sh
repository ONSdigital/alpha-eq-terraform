#!/bin/bash
AUTHOR_REPO_URL=https://github.com/ONSdigital/eq-author
BRANCH=master

echo $AUTHOR_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $AUTHOR_REPO_URL
cd ./eq-author
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
   git branch --track ${branch#remotes/origin/} $branch
done
git checkout $BRANCH
git pull
heroku git:remote -a $1
git push heroku $BRANCH:master
heroku run python manage.py migrate
