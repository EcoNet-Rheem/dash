#!/bin/bash
#set -e
apt-get update
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt -y install unzip
unzip awscliv2.zip
./aws/install
aws --version
apt -y install python3-pip
apt-get -y install nodejs 
apt-get -y install npm
pip3 --version

# Initialize Common Variables
GIT_BRANCH=git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
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

export NODE_OPTIONS=--max_old_space_size=4096

echo "==> Installing All the dependencies"
pip install -e .[testing,dev]
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
