# Cordova Spotify SDK Plugin (Beta)

[![Greenkeeper badge](https://badges.greenkeeper.io/Festify/cordova-spotify.svg)](https://greenkeeper.io/)

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

API documentation will be provided at a later stage when the stability has improved.

Note: Make sure your installation path doesn't contain any spaces.

## Token Exchange Service

The Spotify SDK needs some server code for the OAuth authentication because this plugin uses the authorization code flow only. This is because you probably don't want your users to have to login repeatedly every hour. Take a look at the Spotify [documentation](https://developer.spotify.com/web-api/authorization-guide/#authorization-code-flow) for more information.

To easily implement the endpoints for the token swap and token refresh service, we built a [Serverless](https://serverless.com) service for [AWS Lambda](https://aws.amazon.com/lambda/). Make sure you [install the Serverless Framework properly](https://serverless.com/framework/docs/providers/aws/guide/installation/)!

For the execution of the functions to work you need to set some environmental configuration in the file `oauth-token-api/.env`

```bash
CLIENT_ID="<Your Spotify Client ID>"
CLIENT_SECRET="<Your Spotify Client Secret>"
CLIENT_CALLBACK_URL="<The callback url of your app>" # e.g. "festify-spotify://callback"
ENCRYPTION_SECRET="<Secret used to encrypt the refresh token - please generate>"
```

You can then deploy the functions like this:

```bash
cd oauth-token-api
serverless deploy
```

Also, you need to register the client callback protocol inside the App Info.plist so that iOS knows which app to start when it is redirected when the authentication is done. Take a look at [this repository](https://github.com/Festify/festify-cordova-scheme-helper) to see how it's done.
