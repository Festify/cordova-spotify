# Cordova Spotify SDK Plugin (Beta)

An [Apache Cordova](https://cordova.apache.org/) plugin providing a thin wrapper over the Spotify SDK for iOS and Android.

## Features

This plugin provides a very thin layer over the authentication and playback functionality of the Spotify SDK. It allows your users to authenticate using OAuth 2.0 and allows you to play Spotify tracks via their URI. Metadata functionality has deliberately been left out in favor of the [Web API](https://developer.spotify.com/web-api/). After your users have been authenticated, you are given the access token, so accessing the Web API is trivial.

## Stability

This plugin is currently in beta. This means its reasonably stable but hasn't seen much production use yet. This plugin will be used in the new [Festify](https://github.com/Festify/app), so it will be production-ready once Festify is released. We will fix bugs as soon as we find them.

## Contributing

Pull requests are very welcome! Please use the [gitmoji](https://gitmoji.carloscuesta.me/) style for commit messages.

## Installation

```bash
git clone https://github.com/Festify/cordova-spotify
cd ./MyCordovaProject
cordova plugin add ../cordova-spotify
```

An npm-based installation as well as API documentation will be provided at a later stage when the stability has improved.

Note: Make sure your installation path doesn't contain any spaces.

## OAuth Code Grant Flow

The Spotify SDK needs some server code because you don't want to login your users repeatedly every hour: [Documentation](https://developer.spotify.com/technologies/spotify-ios-sdk/token-swap-refresh/)

To implement the endpoints for `tokenSwapURL` and `tokenRefreshURL` we built a [Serverless](https://serverless.com) service that you can deploy to AWS Lambda. Make sure you [install the Serverless Framework properly](https://serverless.com/framework/docs/providers/aws/guide/installation/)!

For the execution of the functions to work you need to set some environmental configuration in the file `oauth-token-api/.env`

```bash
CLIENT_ID="<Your Spotify Client ID>"
CLIENT_SECRET="<Your Spotify Client Secret>"
CLIENT_CALLBACK_URL="<The callback url of your app>" # e.g. "festify-spotify://callback"
ENCRYPTION_SECRET="<Secret used to encrypt the refresh token - please generate>"
```

You can then deploy the functions to AWS:

```bash
cd oauth-token-api
serverless deploy
```

Also, you need to register the client callback protocol inside the App Info.plist so that iOS knows which app to start when it is redirected when the authentication is done. Take a look at [this repository](https://github.com/Festify/festify-cordova-scheme-helper) to see how it's done.
