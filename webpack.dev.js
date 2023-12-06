const webpack = require('webpack')
const path = require('path')


let webpackConfig = {
    mode: "development",
    entry: ["./app/main.js"],
    output: {
        path: path.resolve(__dirname, '/'),
        filename: 'bundle.js',
        chunkFilename: '[name].js'
    },
    devServer: {
        contentBase: path.resolve(__dirname, 'app'),
    },
    devtool: 'source-map',
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
        })
    ],
    module: {
        "rules": [{
            test: /\.tag$/,
            exclude: /node_modules/,
            use: [{
                loader: 'riot-tag-loader',
                options: {
                    hot: true
                }
            }]
        }, {
            test: /\.scss$/,
            exclude: ['/node_modules/', '/app/styles/bundle.scss'],
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
    optimization: {
        splitChunks: {
          chunks: 'all',
          automaticNameDelimiter: '-',
          cacheGroups: {
            vendor: {
              name: 'vendors',
              chunks: 'all',
              // Dependencies for the main app
              test: /[\\/]node_modules[\\/](?!(lodash|kld.*))[\\/]/
            },
            vizVendors: {
              name: 'vendors-viz',
              chunks: 'all',
              // Dependencies only for visualizations
              test: /[\\/]node_modules[\\/](lodash|kld.*|d3-transition|d3-force|d3-quadtree|d3-request|d3-dsv|d3-easy|d3-collection|d3-timer|d3-dispatch|d3-ease)[\\/]/
            },
            viz: {
              name: 'viz',
              chunks: 'all',
              // Code of visualizations
              test: /[\\/]app[\\/]libs[\\/]ske-viz[\\/]src[\\/]/
            }
          }
        }
    }
}

module.exports = webpackConfig
