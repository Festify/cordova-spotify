require('es6-promise/auto');

const _exec = cordova.exec;

module.exports = function (methodName, args) {
    if (!methodName) {
        throw new Error("Missing method or class name argument (1st).");
    }

    // Delay the resolution and rejection callbacks because
    // the Spotify SDKs do not like being reinvoked from inside
    // of an event handler function.
    return new Promise((res, rej) => _exec(
        val => setTimeout(() => res(val)),
        err => setTimeout(() => rej(err)),
        'SpotifyConnector',
        methodName,
        args || []
    ));
}