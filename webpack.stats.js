const webpack = require('webpack')
const path = require('path')
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
require("@babel/polyfill");



let webpackConfig = {
    mode: "development",
    entry: ["@babel/polyfill", "./app/main.js"],
    output: {
        path: path.resolve(__dirname, '/'),
        publicPath: '/',
        filename: 'bundle.js'
    },
    resolve: {
        modules: ["node_modules", "app", "app/src", "app/ui/", "app/styles/"],
        alias: {
            'core':        path.join(__dirname, '/app/src/core/'),
            'ui':          path.join(__dirname, '/app/ui/'),
            'common':      path.join(__dirname, '/app/src/common/'),
            'dialogs':     path.join(__dirname, '/app/src/dialogs/'),
            'misc':        path.join(__dirname, '/app/src/misc/'),
            'pages':       path.join(__dirname, '/app/src/pages/'),
            'thesaurus':   path.join(__dirname, '/app/src/thesaurus'),
            'wordlist':    path.join(__dirname, '/app/src/wordlist'),
            'wordsketch':  path.join(__dirname, '/app/src/wordsketch'),
            'concordance': path.join(__dirname, '/app/src/concordance'),
            'corpus':      path.join(__dirname, '/app/src/corpus'),
            'ca':          path.join(__dirname, '/app/src/ca'),
            'dashboard':   path.join(__dirname, '/app/src/dashboard'),
            'resources':   path.join(__dirname, '/app/resources/'),
            'test':        path.join(__dirname, '/app/test/'),
            'my':          path.join(__dirname, '/app/src/my')
        }
    },
    plugins: [
        new webpack.ProvidePlugin({
            riot: 'riot'
        }),
        new BundleAnalyzerPlugin()
    ],
    module: {
        "rules": [{
            test: /\.tag$/,
            exclude: /node_modules/,
            use: [{
                loader: 'babel-loader',
                options: {
                    presets: ['@babel/preset-env']
                }
            }, {
                loader: 'riot-tag-loader',
                options: {
                    sourcemap: false,
                    hot: true
                }
            }]
        }, {
            test: /\.js$/,
            exclude: /node_modules/,
            use: {
                loader: 'babel-loader',
                options: {
                    presets: ['@babel/preset-env']
                }
            }
        }, {
            test: /\.scss$/,
            exclude: /node_modules/,
            use: [{
                loader: "style-loader"
            }, {
                loader: "css-loader",
                options: {
                    url: false
                }
            }, {
                loader: "sass-loader"
            }]
        }, {
            test: /\.(png|jpg|gif)$/,
            loader: "file-loader",
            exclude: /node_modules/,
            options: {
                name: "app/images/[name].[ext]"
            }
        }]
    },
    devServer: {
        contentBase: "./app",
        watchContentBase: true
    }
}

module.exports = webpackConfig
