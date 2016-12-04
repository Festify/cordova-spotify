var _exec = require('cordova/exec');

var exec = function(className, methodName, args, callback) {
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

Session.prototype.logout = function (callback) {
    exec("SpotifyConnector", "logout", [], callback);
};

Session.prototype.play = function (trackLink, callback) {
    exec("SpotifyConnector", "play", [trackLink], callback);
};

Session.prototype.pause = function (callback) {
    exec("SpotifyConnector", "pause", [], callback);
};

Session.prototype.setVolume = function (volume, callback) {
    exec("SpotifyConnector", "setVolume", [volume], callback);
};

exports.authenticate = function (options, callback) {
    if (!options.urlScheme || !options.clientId || !options.scopes) {
        throw new Error("Missing urlScheme or clientId parameter.");
    }

    var args = [options.urlScheme, options.clientId, options.scopes];
    if(options.tokenSwapURL && options.tokenRefreshURL) {
        args = args.concat([options.tokenSwapURL, options.tokenRefreshURL]);
    }

    exec("SpotifyConnector", "authenticate", args, function (err, sess) {
        callback(err, !err ? new Session(sess) : null);
    });
};
