#!/usr/bin/env bash

INSTALL_PATH="plugins/rocks.festify.cordova-spotify/src/ios"
DOWNLOAD_PATH="https://github.com/spotify/ios-sdk/archive/master.tar.gz"

mkdir -p $INSTALL_PATH
curl -L $DOWNLOAD_PATH | tar -xzv -C $INSTALL_PATH