#!/usr/bin/env bash

INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/ios/spotify-sdk"
DOWNLOAD_PATH="https://github.com/spotify/ios-sdk/archive/beta-25.tar.gz"

mkdir -p $INSTALL_PATH
curl -LsS $DOWNLOAD_PATH | tar -xz -C $INSTALL_PATH --strip 1
echo "iOS install successful."
