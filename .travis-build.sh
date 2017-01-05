#!/usr/bin/env bash

set -ev

if [ "$APP_TARGET" -eq "android" ]; then
    cordova build android;
else
    xcodebuild CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" -project platforms/ios/HelloCordova.xcodeproj -configuration debug -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.2';
fi