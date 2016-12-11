const exec = require('../lib/execPromise.js');
const qs = require('qs');

mod = {};

function decode(msg) {
    return function (response) {
        if (!response.ok) {
            throw new Error(response.statusText + ": " + msg);
        }
        return response.json();
    };
}

mod.authenticate = function(options) {
    return exec('authenticate', [
        options.urlScheme,
        options.clientId,
        options.scopes
    ])
        .then(function (res) {
            return fetch(options.tokenSwapUrl, {
                body: qs.stringify({
                    code: res.code
                }),
                method: 'POST'
            }).then(decode("Token service did not return a successful response code."));
        })
        .then(function (authData) {
            return fetch(SPOTIFY_WEB_API + '/me', {
                headers: {
                    "Authorization": "Bearer " + authData.access_token
                }
            })
            .then(decode("Spotify API did not return a successful response code."))
            .then(function (me) {
                authData.canonicalUsername = me.id;
                return authData;
            });
        })
        .then(function (authData) {
            authData.expirationDate = Date.now() + (authData.expires_in * 1000);
            return exec("initSession", [
                authData.access_token,
                authData.refresh_token,
                authData.canonicalUsername,
                authData.expirationDate,
                options.tokenRefreshUrl
            ]).then(function () {
                return authData;
            });
        });
};

module.exports = mod;