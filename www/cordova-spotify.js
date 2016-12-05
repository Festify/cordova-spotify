var _exec = require('cordova/exec');

function exec(methodName, args, callback) {
    if (!methodName) {
        throw new Error("Missing method or class name argument (1st).");
    }

    return _exec(function (res) {
        if (callback) {
            callback(null, res);
        }
    }, function (err) {
        if (callback) {
            callback(err);
        }
    }, 'SpotifyConnector', methodName, args);
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

Session.prototype.logout = function (callback) {
    exec('logout', [], callback);
};

Session.prototype.play = function (trackLink, callback) {
    exec('play', [trackLink], callback);
};

Session.prototype.pause = function (callback) {
    exec('pause', [], callback);
};

Session.prototype.setVolume = function (volume, callback) {
    exec('setVolume', [volume], callback);
};

exports.authenticate = function (options, callback) {
    if (!options.urlScheme || !options.clientId || !options.scopes) {
        throw new Error("Missing urlScheme, scopes or clientId parameter.");
    }

    var args = [options.urlScheme, options.clientId, options.scopes];
    if (options.tokenSwapUrl && options.tokenRefreshUrl) {
        args = args.concat([options.tokenSwapUrl, options.tokenRefreshUrl]);
    }

    exec('authenticate', args, function (err, sess) {
        callback(err, !err ? new Session(sess) : null);
    });
};
