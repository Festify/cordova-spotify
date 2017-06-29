const conf = require('../lib/const.js');
const exec = require('../lib/execPromise.js');

module.exports = {
    authenticate: function (options) {
        if (!options.redirectUrl || !options.clientId || !options.scopes ||
            !options.tokenSwapUrl || !options.tokenRefreshUrl) {
            return Promise.reject(conf.MISSING_PARAMETERS_ERROR);
        }

        return exec('authenticate', [
            options.redirectUrl,
            options.clientId,
            options.scopes,
            options.tokenSwapUrl,
            options.tokenRefreshUrl
        ]);
    },
    login: function (options) {
        if (!options.clientId || !options.tokenRefreshUrl) {
            return Promise.reject(conf.MISSING_PARAMETERS_ERROR);
        }

        return exec('login', [
            options.clientId,
            options.tokenRefreshUrl
        ]);
    }
};
