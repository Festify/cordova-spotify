require('es6-promise/auto');

const exec = require('./lib/execPromise.js');
const platform = require('./platforms');

class Session {
    constructor(sessionObject) {
        if (!sessionObject) {
            throw new Error("Missing native session object.");
        }

        Object.assign(this, sessionObject);
    }

    logout() {
        return exec('logout');
    }

    play(trackUri) {
        return exec('play', [trackUri]);
    }

    pause() {
        return exec('pause');
    }
}

exports.authenticate = function (options) {
    if (!options.urlScheme || !options.clientId || !options.scopes ||
        !options.tokenSwapUrl || !options.tokenRefreshUrl) {
        throw new Error("Missing parameters");
    }

    return platform.authenticate(options)
        .then(authData => new Session(authData));
};
