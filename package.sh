#!/usr/bin/env bash

echo "Starting JS build"

CWD=$(dirname $0)/www
cd $CWD

export PATH=$CWD/node_modules/.bin:$PATH

npm install
webpack

echo "JS build finished"