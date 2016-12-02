var exec = require('./exec');

function Session(sessionObject) {
    if (!(this instanceof Session)) {
        return new Session(sessionObject);
    }
    if (!sessionObject) {
        throw new Error("Missing native session object.");
    }

    for (key in sessionObject) {
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

Session.prototype.skip = function (callback) {
    exec("SpotifyConnector", "skip", [], callback);
};

Session.prototype.setVolume = function (volume, callback) {
    exec("SpotifyConnector", "setVolume", [volume], callback);
};

exports.authenticate = function (urlScheme, clientId, scopes, callback) {
    if (!urlScheme || !clientId || !scopes) {
        throw new Error("Missing urlScheme or clientId parameter.");
    }

    exec("SpotifyConnector", "authenticate", [urlScheme, clientId, scopes], function (err, sess) {
        callback(err, !err ? new Session(sess) : null);
    });
};
