var _exec = require('cordova/exec');
var Promise = require('es6-promise').Promise;

function exec(methodName, className) {
    if (!methodName) {
        throw new Error("Missing method name argument (1st).");
    }
    if (!className) {
        className = "SpotifyConnector";
    }

    return new Promise(function (resolve, reject) {
        _exec(resolve, reject, className, methodName);
    });
}

exports.coolMethod = function() {
    return exec("coolMethod");
};
