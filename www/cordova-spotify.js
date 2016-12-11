require('es6-promise/auto');
require('isomorphic-fetch');
const qs = require('qs');

var _exec = cordova.exec;

var SPOTIFY_WEB_API = "https://api.spotify.com/v1";

function decode(msg) {
    return function (response) {
        if (!response.ok) {
            throw new Error(response.statusText + ": " + msg);
        }
        return response.json();
    };
}

function exec(methodName, args) {
    if (!methodName) {
        throw new Error("Missing method or class name argument (1st).");
    }

    return new Promise(function (resolve, reject) {
        return _exec(resolve, reject, 'SpotifyConnector', methodName, args);
    });
}

function Session(sessionObject) {
    if (!(this instanceof Session)) {
        return new Session(sessionObject);
    }
    if (!sessionObject) {
        throw new Error("Missing native session object.");
    }

    for (var key in sessionObject) {
        if (sessionObject.hasOwnProperty(key)) {
            this[key] = sessionObject[key];
        }
    }
}

Session.prototype.logout = function () {
    return exec('logout', []);
};

Session.prototype.play = function (trackLink) {
    return exec('play', [trackLink]);
};

Session.prototype.pause = function () {
    return exec('pause', []);
};

Session.prototype.setVolume = function (volume) {
    return exec('setVolume', [volume]);
};

exports.authenticate = function (options) {
    if (!options.urlScheme || !options.clientId || !options.scopes) {
        throw new Error("Missing urlScheme, scopes or clientId parameter.");
    }
    if (!options.tokenSwapUrl || !options.tokenRefreshUrl) {
        throw new Error("Missing tokenSwapUrl or tokenRefreshUrl parameter.");
    }

    return exec('authenticate', [options.urlScheme, options.clientId, options.scopes])
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
                authData.user_name = me.id;
                return authData;
            });
        })
        .then(function (authData) {
            var expiresAt = Date.now() + (authData.expires_in * 1000);
            return exec("initSession", [
                authData.access_token,
                authData.refresh_token,
                authData.user_name,
                expiresAt,
                options.tokenRefreshUrl
            ]).then(function () {
                return new Session(authData);
            });
        });
};
