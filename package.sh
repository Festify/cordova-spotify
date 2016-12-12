#!/usr/bin/env bash

echo "Starting JS build"
cd "$(dirname $0)/www"

npm install
./node_modules/.bin/webpack

echo "JS build finished"