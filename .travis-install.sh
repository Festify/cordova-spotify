#!/usr/bin/env bash

set -ev

if [ "$APP_TARGET" -eq "android" ]; then
    brew update;
    brew install android-sdk;
    export PATH=$PATH:/usr/local/opt/android-sdk/tools:/usr/local/opt/android-sdk/platform-tools;
    export ANDROID_HOME=/usr/local/opt/android-sdk;
    export ANDROID_SDK_ROOT=$ANDROID_HOME;
    (while sleep 3; do echo "y"; done) | android update sdk --no-ui --all --filter platform-tools,tools,build-tools-24.0.2,build-tools-25.0.2,android-24,android-25,extra-android-m2repository;
fi