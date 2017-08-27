var webpack = require('webpack');

module.exports = {
    entry: './cordova-spotify.js',
    output: {
        path: __dirname,
        filename: 'build/cordova-spotify.js',
        library: 'spotify',
        libraryTarget: 'commonjs'
    },
    module : {
        externals: [
            "cordova",
            "cordova/exec"
        ],
        loaders: [{
            test: /.js$/,
            exclude: /node_modules/,
            loader: 'babel-loader'
        }]
    }
};