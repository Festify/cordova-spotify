const exec = require('../lib/execPromise.js');

module.exports = {
    authenticate: function(options) {
        return exec('authenticate', [
            options.urlScheme,
            options.clientId,
            options.scopes,
            options.tokenSwapUrl,
            options.tokenRefreshUrl
        ]);
    }
};