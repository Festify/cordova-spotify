#!/usr/bin/env bash

AUTH_INSTALL_PATH="plugins/cordova-spotify/src/android/spotify-auth"
AUTH_DOWNLOAD_PATH="https://github.com/spotify/android-auth/archive/1.0.tar.gz"
SDK_INSTALL_PATH="plugins/cordova-spotify/src/android/spotify-sdk"
SDK_DOWNLOAD_PATH="https://github.com/spotify/android-sdk/archive/24-noconnect-2.20b.tar.gz"

if [ ! -d "$AUTH_INSTALL_PATH" ]; then
    mkdir -p "$AUTH_INSTALL_PATH"
    curl -LsS $AUTH_DOWNLOAD_PATH | tar -xz -C "$AUTH_INSTALL_PATH" --strip 1
else
    echo "Skipping auth library download since it's already there."
fi

if [ ! -d "$SDK_INSTALL_PATH" ]; then
    mkdir -p "$SDK_INSTALL_PATH"
    curl -LsS $SDK_DOWNLOAD_PATH | tar -xz -C "$SDK_INSTALL_PATH" --strip 1
else
    echo "Skipping streaming SDK download since it's alredy there."
fi

cd "$(dirname $0)/src/android/spotify-auth"
echo "include ':auth-lib'" > settings.gradle

if [ ! -f "auth-lib/build/outputs/aar/spotify-android-auth-1.0.0.aar" ]; then
    ./gradlew clean build
else
    echo "Skipping auth library build since the AAR is already there."
fi
