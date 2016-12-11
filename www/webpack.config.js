var config = require('webpack-es6-config');

module.exports = config({
  filename: './build/cordova-spotify.js',
  libraryName: 'CordovaSpotify',
  entry: './cordova-spotify.js',
});