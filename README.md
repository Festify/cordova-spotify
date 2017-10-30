# Cordova Spotify SDK Plugin

[![Greenkeeper badge](https://badges.greenkeeper.io/Festify/cordova-spotify.svg)](https://greenkeeper.io/) [![Travis](https://img.shields.io/travis/Festify/cordova-spotify.svg)](https://travis-ci.org/Festify/cordova-spotify)

An [Apache Cordova](https://cordova.apache.org/) plugin providing access to the Spotify SDK for iOS and Android.

[API documentation](https://festify.github.io/cordova-spotify/)

## Features

This plugin provides a very simple and atomic layer over playback functionality of the Spotify SDK. It allows you to play Spotify tracks via their URI. Metadata and authentication functionality has deliberately been left out in favor of the [Web API](https://developer.spotify.com/web-api/) and our Spotify OAuth 2 plugin [cordova-spotify-oauth](https://github.com/Festify/cordova-spotify-oauth).

## Installation

```bash
cordova plugin add cordova-spotify
```

Note: Make sure your installation path doesn't contain any spaces.

## Examples

The plugin is very simple to use. All methods can be called at any time and there is no initialization step. The plugin performs all necessary state changes automatically. All methods documented in the API documentation are exported under the global `cordova.plugins.spotify`-object.

### Play some good music
```js
cordova.plugins.spotify.play("spotify:track:0It6VJoMAare1zdV2wxqZq", { 
  clientId: "<YOUR SPOTIFY CLIENT ID",
  token: "<YOUR VALID SPOTIFY ACCESS TOKEN WITH STREAMING SCOPE>"
})
  .then(() => console.log("Music is playing 🎶"));
```

### React to user pressing pause button
```js
cordova.plugins.spotify.pause()
  .then(() => console.log("Music is paused ⏸"));
```

### Display current playing position
```js
cordova.plugins.spotify.getPosition()
  .then(pos => console.log(`We're currently ${pos}ms into the track.`))
  .catch(() => console.log("Whoops, no track is playing right now.");
```

## Contributing

Pull requests are very welcome! Please use the [gitmoji](https://gitmoji.carloscuesta.me/) style for commit messages.
