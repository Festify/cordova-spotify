#!/usr/bin/env bash

INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/ios/spotify-sdk"
DOWNLOAD_PATH="https://github.com/spotify/ios-sdk/archive/beta-25.tar.gz"

if [ ! -d $INSTALL_PATH ]; then
    mkdir -p $INSTALL_PATH
    curl -LsS $DOWNLOAD_PATH | tar -xzv -C $INSTALL_PATH --strip 1
fi
