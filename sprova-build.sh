#!/bin/bash

# build script for sprova

while getopts ":t:" opt; do
  case $opt in
    t)
      echo "Building new docker image with tag $OPTARG" >&2
      TAG_VALUE=":$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

set -e
# initial dir
INIT_DIR=$PWD
# build web
cd web
npm i
npm run build
npm test
cd ..

# build server
cd server
npm i
npm test
cd ..

sudo docker build -t mjeshtri/sprova$TAG_VALUE .

