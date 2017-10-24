const TypeDocPlugin = require('typedoc-webpack-plugin');
const path = require('path');

module.exports = {
    entry: './cordova-spotify.ts',
    module: {
        rules: [{
            test: /(\.ts)/,
            exclude: /node_modules/,
            use: 'awesome-typescript-loader'
        }]
    },
    resolve: {
        extensions: ['.js', '.ts']
    },
    devtool: 'source-map',
    externals: [
        "cordova",
        "cordova/exec"
    ],
    output: {
        path: path.resolve(__dirname, 'build'),
        filename: 'cordova-spotify.min.js',
        library: 'spotify',
        libraryTarget: 'commonjs'
    },
    plugins: [
        new TypeDocPlugin({
            excludeExternals: true,
            excludePrivate: true,
            ignoreCompilerErrors: true,
            name: "Cordova Spotify Plugin",
            mode: 'file',
            readme: 'none',
            target: 'ES6'
        }, './cordova-spotify.ts')
    ]
};