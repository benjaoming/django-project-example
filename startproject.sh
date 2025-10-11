#!/bin/bash

# This script is intentionally very simple and 'dumb'.

if [ "$1" == "" ]
then
  echo "This creates a new django project in a subfolder. It requires django-admin command to be available."
  echo ""
  echo "Usage:"
  echo "  ./example.sh folder_name/"
  exit
fi

# Remove if exists (TODO: warning)
rm -rf $1

# We use uv to create a package
uv init $1 --package

cd $1

uv add django
uv add --dev pytest

django-admin startproject $1
mv $1/$1 src/project/
mv $1/manage.py src/
mkdir src/project/settings/
touch src/project/settings/__init__.py
mv src/project/settings.py src/project/settings/base.py

rmdir $1

mkdir src/apps
touch src/apps/__init__.py

cd src/apps
django-admin startapp users
cd -

mkdir tests
touch tests/__init__.py


cd ../
