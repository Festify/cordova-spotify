var platform = null;

switch(cordova.platformId) {
    case 'ios':
        platform = require('./ios.js');
        break;
    case 'android':
        platform = require('./android.js');
        break;
    default:
        throw new Error("Platform not supported!");
}

module.exports = platform;