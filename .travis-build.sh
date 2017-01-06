#!/usr/bin/env bash

set -ev

if [ "$APP_TARGET" == "android" ]; then
    cordova build android;
else
    # 63A0BA5F-3911-496F-BF2E-512830B4AD7F is iPhone SE on iOS 10.2
    xcodebuild -xcconfig ./platforms/ios/cordova/build-debug.xcconfig -workspace ./platforms/ios/HelloCordova.xcworkspace -scheme HelloCordova -configuration Debug -sdk iphonesimulator -destination 'id=63A0BA5F-3911-496F-BF2E-512830B4AD7F' build  CONFIGURATION_BUILD_DIR=./platforms/ios/build/emulator HEADER_SEARCH_PATHS="$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO";
fi