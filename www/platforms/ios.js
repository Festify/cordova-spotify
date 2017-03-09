const exec = require('../lib/execPromise.js');
const Promise = require('es6-promise');

module.exports = {
    authenticate: function (options) {
        if (!options.urlScheme || !options.clientId || !options.scopes ||
            !options.tokenSwapUrl || !options.tokenRefreshUrl) {
            return Promise.reject("Missing parameters");
        }

        return exec('authenticate', [
            options.urlScheme,
            options.clientId,
            options.scopes,
            options.tokenSwapUrl,
            options.tokenRefreshUrl
        ]);
    }
};