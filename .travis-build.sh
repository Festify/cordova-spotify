#!/usr/bin/env bash

set -ev

if [ "$APP_TARGET" == "android" ]; then
    cordova build android;
else
    xcodebuild -xcconfig /Users/travis/build/Festify/cordova-spotify/HelloCordova/platforms/ios/cordova/build-debug.xcconfig -workspace HelloCordova.xcworkspace -scheme HelloCordova -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.2' build CONFIGURATION_BUILD_DIR=/Users/travis/build/Festify/cordova-spotify/HelloCordova/platforms/ios/build/emulator CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO";
fi