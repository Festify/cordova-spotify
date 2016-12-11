#!/usr/bin/env bash

AUTH_INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/android/spotify-auth"
AUTH_DOWNLOAD_PATH="https://github.com/spotify/android-auth/archive/1.0.tar.gz"
SDK_INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/android/spotify-sdk"
SDK_DOWNLOAD_PATH="https://github.com/spotify/android-sdk/archive/24-noconnect-2.20b.tar.gz"

if [ ! -d $AUTH_INSTALL_PATH ]; then
    mkdir -p $AUTH_INSTALL_PATH
    curl -LsS $AUTH_DOWNLOAD_PATH | tar -xz -C $AUTH_INSTALL_PATH --strip 1
fi

if [ ! -d $SDK_INSTALL_PATH ]; then
    mkdir -p $SDK_INSTALL_PATH
    curl -LsS $SDK_DOWNLOAD_PATH | tar -xz -C $SDK_INSTALL_PATH --strip 1
fi

echo "Android install successful."
