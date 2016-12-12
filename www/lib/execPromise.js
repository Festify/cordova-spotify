require('es6-promise/auto');

const _exec = cordova.exec;

module.exports = function (methodName, args) {
    if (!methodName) {
        throw new Error("Missing method or class name argument (1st).");
    }

    return new Promise((res, rej) => _exec(res, rej, 'SpotifyConnector', methodName, args || []));
}