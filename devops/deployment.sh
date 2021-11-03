#!/bin/bash
#set -e

# Initialize Common Variables
GIT_BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
if [ "$GIT_BRANCH" == "main" ];then
ENV="production"
elif [ "$GIT_BRANCH" == "develop" ];then
ENV="develop"
GIT_BRANCH="develop"
else
ENV="staging"
GIT_BRANCH="staging"
fi

echo "${GIT_BRANCH}"
echo "${ENV}"

echo "==> Installing All the dependencies"
pip install -e .[${ENV}]
npm install

echo "==> Build Packages"
npm run build
python setup.py sdist
python setup.py install

echo "==> Go to Dash loacation"
cd ../build/lib

echo "==> Remove tar.gz if exists"
rm -r dash.tar.gz

echo "==> make tar.gz file"
tar -czvf dash.tar.gz dash 

echo "==> copy to AWS S3 bucket"
aws s3 cp dash.tar.gz s3://rheem-datascience-infa/submodule_builds/${ENV}/dash.tar.gz

   