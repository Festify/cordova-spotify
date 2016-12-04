'use strict';

const crypto = require('crypto');

const algo = 'aes-256-cbc';

module.exports.encrypt = (text, key) => {
    const cipher = crypto.createCipher(algo, key);
    return cipher.update(text, 'utf8', 'hex') + cipher.final('hex');
};

module.exports.decrypt = (text, key) => {
    const decipher = crypto.createDecipher(algo, key);
    return decipher.update(text, 'hex', 'utf8') + decipher.final('utf8');
};
