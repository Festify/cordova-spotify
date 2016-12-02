var _exec = require('cordova/exec');

exports.exec = function(className, methodName, args, callback) {
    if (!methodName || !className) {
        throw new Error("Missing method or class name argument (1st).");
    }

    _exec(function (res) {
        if (callback) {
            callback(null, res);
        }
    }, function (err) {
        if (callback) {
            callback(err);
        }
    }, className, methodName, args);
};