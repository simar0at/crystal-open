const {Connection} = require('core/Connection.js')
/*
    method argument args: {
        options: {key1:value1, key2: value2,...},
        prefix: "some_prefix_",
        corpus: "corpname" //optional
        done: on success callback,
        fail: on error callback
        always:on allways callback
    }

    or options in form of arrays of keys for get method
 */

const get = (args) => {
    return Connection.get({
        loadingId: args.loadingId || "",
        url: window.config.URL_BONITO + "get_user_options",
        data: _getData(args),
        method: "POST",
        done: function(args, payload){
            if(args.prefix){
                ["default", "user"].forEach(section => {
                    // remove prefix from data
                    for(let key in payload[section]){
                        payload[section][key.split(args.prefix)[1]] = payload[section][key]
                        delete payload[section][key]
                    }
                }, this)
            }
            args.done(payload)
        }.bind(this, args),
        fail: args.fail,
        always: args.always
    })
}

const update = (args) => {
    return _get(args, window.config.URL_BONITO + "set_user_options")
}

const reset = (args) => {
    return _get(args, window.config.URL_BONITO + "reset_user_options")
}

const _get = (args, url) => {
    return Connection.get({
        loadingId: args.loadingId,
        url: url,
        data: _getData(args),
        method: "POST",
        done: args.done,
        fail: args.fail,
        always: args.always
    })
}
/*
const _encodeDeep = (obj) => {
    // call encodeURIComponent on each leaf in obj tree
    return _xcodeDeep(obj, "encode")
}

const _decodeDeep = (obj) => {
    // call decodeURIComponent on each leaf in obj tree
    return _xcodeDeep(obj, "decode")
}

const _xcodeDeep = (obj, code) => {
    // code = ["encode"|"decode"]
    // walk recursively through obj tree (or elements in array) and call
    // encodeURIComponent/decodeURIComponent on each value
    if(Array.isArray(obj)){
        return obj.map(o => _xcodeDeep(o, code))
    } else if(typeof obj == "object"){
        let ret = {}
        for(let k in obj){
            ret[k] = _xcodeDeep(obj[k], code)
        }
        return ret;
    } else {
        return code == "encode" ? encodeURIComponent(obj) : decodeURIComponent(obj)
    }
}
*/
const _addPrefixToOptionsKeys = (args) => {
    if(args.prefix){
        // prefix is defined -> we wanted to save/get options with prefix:
        // key: value -> prefix_key: value, etc.
        if(Array.isArray(args.options)){
            args.options = args.options.map( o => {
                return args.prefix + o
            })
        } else{
            let options = {}
            for(let key in args.options){
                options[args.prefix + key] = args.options[key]
            }
            args.options = options
        }
    }
}

const _getData = (args) => {
    _addPrefixToOptionsKeys(args)
    let data = {
        options: args.options
    }
    if(args.corpus){
        data.corpus = args.corpus
    }
    return data
}

module.exports = {
    get,
    update,
    reset
}
