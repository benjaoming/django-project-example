#!/bin/bash

# This script is intentionally very simple and 'dumb'.

if [ "$1" == "" ]
then
  echo "This creates a new django project in a subfolder. It requires django-admin command to be available."
  echo ""
  echo "Usage:"
  echo "  ./startproject.sh folder_name/"
  exit 1
fi

set -e

if [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then

  echo "Invalid slug: $1 - please use a valid Python package name"
  exit 1

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

# Use settings.development as default
# TOOD: Should the pattern be different to ensure that development settings are
#   never used in a production shell?
sed -i "s/$1.settings/$1.settings.development/" src/manage.py

mkdir src/project/settings/
touch src/project/settings/__init__.py
mv src/project/settings.py src/project/settings/base.py

echo "from .base import *\n\nDEBUG=False" > src/project/settings/production.py
echo "from .base import *\n\nDEBUG=True" > src/project/settings/development.py

rmdir $1

mkdir src/apps
touch src/apps/__init__.py

cd src/apps
django-admin startapp users
cd -

mkdir tests
touch tests/__init__.py

cp ../.pre-commit-config.yaml .

pre-commit autoupdate

cd ../
