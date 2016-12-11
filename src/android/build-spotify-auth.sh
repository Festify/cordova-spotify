#!/usr/bin/env bash

CWD=$(dirname $0)/spotify-auth

cd $CWD

echo "include ':auth-lib'" > settings.gradle

./gradlew clean build