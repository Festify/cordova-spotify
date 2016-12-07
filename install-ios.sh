#!/usr/bin/env bash

INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/ios/spotify-sdk"
DOWNLOAD_PATH="https://github.com/spotify/ios-sdk/archive/beta-25.tar.gz"

mkdir -p $INSTALL_PATH
curl -L $DOWNLOAD_PATH | tar -xzv -C $INSTALL_PATH --strip 1
