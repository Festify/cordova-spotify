#!/usr/bin/env bash

CWD=$(dirname $0)/spotify-auth

cd $CWD
echo "include ':auth-lib'" > settings.gradle

if [ ! -f "auth-lib/build/outputs/aar/spotify-android-auth-1.0.0.aar" ]; then
    ./gradlew clean build
fi