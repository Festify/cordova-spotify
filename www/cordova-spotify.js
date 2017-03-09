const EventEmitter = require('./lib/EventEmitter.js');
const exec = require('./lib/execPromise.js');
const platform = require('./platforms');
const Promise = require('es6-promise');

class Session extends EventEmitter {
    constructor(sessionObject) {
        super();

        if (!sessionObject) {
            throw new Error("Missing native session object.");
        }

        Object.assign(this, sessionObject);
    }

    getPosition() {
        return exec('getPosition');
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
        .then(authData => (new Session(authData)).registerEvents())
        // Player is not ready to play when the SDK fires the callback.
        // Therefore we introduce some delay, so apps can start playing immediately
        // when the promise resolves.
        .then(session => new Promise(resolve => setTimeout(() => resolve(session), 2000)));
};