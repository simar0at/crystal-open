const {Connection} = require("core/Connection.js")
const {Url} = require("core/url.js")
const {Localization} = require("core/Localization.js")

class TextLoaderClass {
    constructor(){
        this.FOLDER = "texts"
        this.origin = Url.getOrigin()
        this._cache = {}
    }

    load(file, done){
        let lang = Localization.getLocale()
        this._loadLang(file, lang, done)
    }

    loadAndInsert(file, node){
        this.load(file, (payload) => {
            if(node){ // was not removed during loading
                node.innerHTML = payload.text
            }
        })
    }

    _loadLang(file, lang, callback){
        file = file + (file.endsWith(".html") ? "" : ".html")
        if(this._cache[lang + "_" + file]){
            callback({
                text: this._cache[lang + "_" + file],
                lang: lang,
                status: "OK"
            })
            return
        }
        Connection.get({
            url: `${this.origin}${this.FOLDER}/${lang}/${file}?v=${window.version}`,
            always: function(file, lang, callback, payload){
                if(typeof payload == "string"){
                    payload = window.addLinksToTheText(payload)
                    this._cache[lang + "_" + file] = payload
                    callback({
                        text: payload,
                        lang: lang,
                        status: "OK"
                    })
                } else{
                    if(lang != "en"){
                        this._loadLang(file, "en", callback)
                    } else {
                        callback({
                            text: "Content could not be loaded.",
                            status: "FAIL",
                            error: payload && payload.statusText ? payload.statusText : ""
                        })
                    }
                }
            }.bind(this, file, lang, callback)
        })
    }
}

window.TextLoader = new TextLoaderClass()


