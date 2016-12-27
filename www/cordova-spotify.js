require('es6-promise/auto');

const EventEmitter = require('./lib/EventEmitter.js');
const exec = require('./lib/execPromise.js');
const platform = require('./platforms');

class Session extends EventEmitter {
    constructor(sessionObject) {
        super();

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
        .then(authData => (new Session(authData)).registerEvents());
};
