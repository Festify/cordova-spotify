const exec = require('../lib/execPromise.js');

mod = {};

mod.authenticate = function(options) {
    return exec('authenticate', [
        options.urlScheme,
        options.clientId,
        options.scopes,
        options.tokenSwapUrl,
        options.tokenRefreshUrl
    ]);
}

module.exports = mod;