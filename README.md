# Cordova Spotify SDK Plugin (Beta)

[![Greenkeeper badge](https://badges.greenkeeper.io/Festify/cordova-spotify.svg)](https://greenkeeper.io/)

An [Apache Cordova](https://cordova.apache.org/) plugin providing access to the Spotify SDK for iOS and Android.

[API documentation](#api-docs)

## Features

This plugin provides a very simple and atomic layer over playback functionality of the Spotify SDK. It allows you to play Spotify tracks via their URI. Metadata and authentication functionality has deliberately been left out in favor of the [Web API](https://developer.spotify.com/web-api/) and other authentication solutions.

## Stability

This plugin is currently in beta. This means its reasonably stable but hasn't seen much production use yet. This plugin will be used in the new [Festify](https://github.com/Festify/app), so it will be production-ready once Festify is released. We will fix bugs as soon as we find them.

## Contributing

Pull requests are very welcome! Please use the [gitmoji](https://gitmoji.carloscuesta.me/) style for commit messages.

## Installation

```bash
cordova plugin add cordova-spotify
```

Note: Make sure your installation path doesn't contain any spaces.

## <a name="api-docs"></a>API Documentation

### General 

The plugin has an extremely simple API that is focused just on playback. It consists of six functions clobbered onto `cordova.plugins.spotify`. In the following, treat all paths relative to that. The plugin handles all internal state and SDK initialization aspects automatically and hides these aspects from the developer.

All functions are asynchronous and return promises. The plugin automatically polyfills promise support through `es6-promise-plugin`.

If the parameters have invalid values, an appropriate `Error` will be thrown immediately instead of returning a rejected promise. This is because invalid arguments are bugs and not runtime errors.

### `getEventEmitter(): Promise<EventEmitter>`

Obtains an event emitter that relays the events fired by the native SDKs. The emitter will be created once and then returned on subsequent invocations.

The events emitted are the following:
- `connectionmessage`
- `loggedin`
- `loggedout`
- `loginfailed`
- `playbackerror`
- `playbackevent`
- `temporaryerror`

In the case of `loginfailed`, `playbackevent` and `playbackerror`, the event contains a payload that describes what happened exactly. The payload is simply the name of the discriminant of the enum in the native SDK without the prefix (usually `kSp` or `kSpError`). See the offical documentation [here](https://spotify.github.io/android-sdk/player/com/spotify/sdk/android/player/Error.html) and [here](https://spotify.github.io/android-sdk/player/com/spotify/sdk/android/player/PlayerEvent.html) for all variants.

### `getPosition(): Promise<number>`

Obtains the players position in _milliseconds_. If no track is currently loaded, returns 0.

### `play(trackUri: string, authOptions: object[, position: number]): Promise`

Plays the track with the given Spotify URI.

#### Parameters

- `trackUri`: The Spotify URI of the track to play. E.g. `spotify:track:6nTiIhLmQ3FWhvrGafw2z`. May not be null.
- `authOptions`: An object containing two keys:
    - `token: string`: A valid Spotify access token with the `streaming` scope. May not be null.
    - `clientId: string`: Your application's client ID as obtained from https://developer.spotify.com. May not be null.
- `position`: Optional. The position (in _milliseconds_) to start playing the track from. Must be >= 0.

`token` and `clientId` may change freely during runtime. The plugin will handle the required login / logout processes automatically when a new track is played.

### `pause(): Promise`

Pauses playback. If no track is loaded, returns normally.

### `resume(): Promise`

Resumes playback. If no track is loaded, the returned promise will be rejected with an error of type `not_playing`.

### `seekTo(position: number): Promise`

Sets the playback position to the given value. If no track is loaded, the returned promise will be rejected with an error of type `not_playing`.

#### Parameters

- `position`: The position (in _milliseconds_) to seek to. Must be >= 0.
