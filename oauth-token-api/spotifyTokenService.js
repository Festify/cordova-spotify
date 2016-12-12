'use strict';

require('es6-promise/auto');
const request = require('request');
const qs = require('qs');
const crypto = require('./lib/crypto.js');

// load config from .env file
require('dotenv').config();

const API_URL = "https://accounts.spotify.com/api/token";
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const CLIENT_CALLBACK_URL = process.env.CLIENT_CALLBACK_URL;
const ENCRYPTION_SECRET = process.env.ENCRYPTION_SECRET;

const spotifyRequest = params => {
    return new Promise((resolve, reject) => {
        request.post(API_URL, {
            form: params,
            headers: {
                "Authorization": "Basic " + new Buffer(CLIENT_ID + ":" + CLIENT_SECRET).toString('base64')
            }
        }, (err, resp) => err ? reject(err) : resolve(resp));
    })
        .then(resp => {
            if (resp.statusCode != 200) {
                return Promise.reject({
                    statusCode: resp.statusCode,
                    body: resp.body
                });
            }

            const session = JSON.parse(resp.body);
            return Promise.resolve(session);
        })
        .catch(err => {
            console.error(err);
            return Promise.reject({
                statusCode: 500,
                body: JSON.stringify({})
            });
        });
};

module.exports.exchangeCode = (event, context, callback) => {
    const params = qs.parse(event.body);

    if (!params.code) {
        callback(null, {
            statusCode: 400,
            body: JSON.stringify({
                "error" : "Parameter missing"
            })
        });
        return;
    }

    spotifyRequest({
        grant_type: "authorization_code",
        redirect_uri: CLIENT_CALLBACK_URL,
        code: params.code
    })
        .then(session => {
            return Promise.resolve({
                statusCode: 200,
                body: JSON.stringify({
                    "access_token" : session.access_token,
                    "expires_in" : session.expires_in,
                    "refresh_token" : crypto.encrypt(session.refresh_token, ENCRYPTION_SECRET)
                })
            });
        })
        .catch(response => {
            return Promise.resolve(response);
        })
        .then(response => {
           callback(null, response);
        });
};

module.exports.refreshToken = (event, context, callback) => {
    const params = qs.parse(event.body);

    if (!params.refresh_token) {
        callback(null, {
            statusCode: 400,
            body: JSON.stringify({
                "error" : "Parameter missing"
            })
        });
        return;
    }

    spotifyRequest({
        grant_type: "refresh_token",
        refresh_token: crypto.decrypt(params.refresh_token, ENCRYPTION_SECRET)
    })
        .then(session => {
            return Promise.resolve({
                statusCode: 200,
                body: JSON.stringify({
                    "access_token" : session.access_token,
                    "expires_in" : session.expires_in
                })
            });
        })
        .catch(response => {
            return Promise.resolve(response);
        })
        .then(response => {
            callback(null, response);
        });
};
