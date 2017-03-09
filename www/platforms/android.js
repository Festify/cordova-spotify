require('isomorphic-fetch');

const conf = require('../lib/const.js');
const exec = require('../lib/execPromise.js');
const qs = require('qs');

const MISSING_PARAMETERS_ERROR = "Missing parameters!";
const TOKEN_SERVICE_ERROR = "Token swap service did not return a successful response code.";

function decode(msg) {
    return response => {
        if (!response.ok) {
            throw new Error(response.statusText + ": " + msg);
        }
        return response.json();
    };
}

function initSession(clientId, authData) {
    return fetch(conf.SPOTIFY_WEB_API + '/me', {
        headers: {
            "Authorization": "Bearer " + authData.access_token
        }
    })
        .then(decode("Spotify API did not return a successful response code."))
        .then(me => {
            authData.canonicalUsername = me.id;
            authData.expirationDate = Date.now() + (authData.expires_in * 1000);

            return exec("initSession", [clientId, authData.access_token]);
        })
        .then(() => authData);
}

module.exports = {
    authenticate: function (options) {
        if (!options.urlScheme || !options.clientId || !options.scopes ||
            !options.tokenSwapUrl || !options.tokenRefreshUrl) {
            return Promise.reject(MISSING_PARAMETERS_ERROR);
        }

        return exec('authenticate', [
            options.urlScheme,
            options.clientId,
            options.scopes
        ])
            .then(res => fetch(options.tokenSwapUrl, {
                body: qs.stringify({ code: res.code }),
                method: 'POST'
            }))
            .then(decode(TOKEN_SERVICE_ERROR))
            .then(authData => initSession(options.clientId, authData))
            .then(authData => {
                localStorage.setItem(conf.REFRESH_TOKEN_LS_NAME, authData.refresh_token);

                return authData;
            });
    },
    login: function (options) {
        if (!options.clientId || !options.tokenRefreshUrl) {
            return Promise.reject(MISSING_PARAMETERS_ERROR);
        }

        const refreshToken = localStorage.getItem(conf.REFRESH_TOKEN_LS_NAME);
        if (!refreshToken) {
            return Promise.resolve(null);
        }

        return fetch(options.tokenRefreshUrl, {
            body: qs.stringify({ refresh_token: refreshToken }),
            method: 'POST'
        })
            .then(decode(TOKEN_SERVICE_ERROR))
            .then(authData => initSession(options.clientId, authData));
    }
};