#!/bin/bash
#set -e
# Initialize Common Variables
GIT_BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
if [ "$GIT_BRANCH" == "main" ];then
ENV="production"
elif [ "$GIT_BRANCH" == "develop" ];then
ENV="develop"
else
ENV="staging"
fi

echo "${GIT_BRANCH}"
echo "${ENV}"

export NODE_OPTIONS=--max_old_space_size=4096

echo "==> Installing All the dependencies"
pip install -e .[testing,dev]
npm install

echo "==> Build Packages"
npm run build
python3 setup.py sdist
python3 setup.py install

echo "==> Go to Dash loacation"
cd ../build/lib

echo "==> Remove tar.gz if exists"
rm -r dash.tar.gz

echo "==> make tar.gz file"
tar -czvf dash.tar.gz dash 

echo "==> copy to AWS S3 bucket"
aws s3 cp dash.tar.gz s3://rheem-datascience-infa/submodule_builds/${GIT_BRANCH}/dash.tar.gz
