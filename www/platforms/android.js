require('es6-promise/auto');
require('isomorphic-fetch');

const conf = require('../lib/const.js');
const exec = require('../lib/execPromise.js');
const qs = require('qs');

function decode(msg) {
    return response => {
        if (!response.ok) {
            throw new Error(response.statusText + ": " + msg);
        }
        return response.json();
    };
}

module.exports = {
    authenticate: function (options) {
        return exec('authenticate', [
            options.urlScheme,
            options.clientId,
            options.scopes
        ])
            .then(res => {
                return fetch(options.tokenSwapUrl, {
                    body: qs.stringify({
                        code: res.code
                    }),
                    method: 'POST'
                }).then(decode("Token service did not return a successful response code."));
            })
            .then(authData => {
                return fetch(conf.SPOTIFY_WEB_API + '/me', {
                    headers: {
                        "Authorization": "Bearer " + authData.access_token
                    }
                })
                .then(decode("Spotify API did not return a successful response code."))
                .then(me => {
                    authData.canonicalUsername = me.id;
                    return authData;
                });
            })
            .then(authData => {
                authData.expirationDate = Date.now() + (authData.expires_in * 1000);
                return exec("initSession", [
                    authData.access_token,
                    authData.refresh_token,
                    authData.canonicalUsername,
                    authData.expirationDate,
                    options.tokenRefreshUrl
                ]).then(() => authData);
            });
    }
};