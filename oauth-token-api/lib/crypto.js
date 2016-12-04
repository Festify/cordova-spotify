'use strict';

const crypto = require('crypto');

const algo = 'aes-256-cbc';

module.exports.encrypt = (text, key) => {
    const cipher = crypto.createCipher(algo, key);
    let crypted = cipher.update(text, 'utf8', 'hex');
    crypted += cipher.final('hex');
    return crypted;
};

module.exports.decrypt = (text, key) => {
    const decipher = crypto.createDecipher(algo, key);
    let dec = decipher.update(text, 'hex', 'utf8');
    dec += decipher.final('utf8');
    return dec;
};