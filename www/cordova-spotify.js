require('es6-promise/auto');

const platform = require('./platforms');
const exec = require('./lib/execPromise.js');
const conf = require('./lib/const.js');

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

exports.authenticate = function (options) {
    if (!options.urlScheme || !options.clientId || !options.scopes ||
        !options.tokenSwapUrl || !options.tokenRefreshUrl) {
        throw new Error("Missing parameters");
    }

    return platform.authenticate(options)
        .then(function (authData) {
            return new Session(authData);
        });
};
