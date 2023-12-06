require('libs/webfont/webfont.js')

const {Localization} = require('core/Localization.js')
const {SettingsStore} = require('core/SettingsStore.js')
const {AppStore} = require('core/AppStore.js')


class AppStyleClass{
    constructor(){
        riot.observable(this)
        AppStore.on("corpusChanged", this._onCorpusChanged.bind(this))
        SettingsStore.on("change", this._refreshStyle.bind(this))
        Dispatcher.on("LOCALIZATION_CHANGE", this._onLocalizationChange.bind(this))
        AppStore.on("languageListLoaded", this._onLanguageListLoaded.bind(this))
        AppStore.on("corpusListChanged", this._onCorpusListChanged.bind(this))

        this.scripts = {}
        this.loadedScripts = []
        this.corpnameQueue = []

        $(document).ready(this._refreshStyle.bind(this))

        if(window.config.CUSTOM_STYLE){
            $('head').append('<link rel="stylesheet" type="text/css" href="' + window.config.CUSTOM_STYLE + '">')
        }
    }

    getCorpusScript(corpname){
        let corpus = AppStore.getCorpusByCorpname(corpname)
        return corpus ? this.scripts[corpus.language_id] : null
    }

    getLangFontClass(language_id){
        if(["ja", "ko", "zh-CN", "zh-HK", "zh-TW" ,"zh-Hant", "zh-Hans", "bo"].includes(language_id)){
            // dense font
            return "f-cjk"
        }
        if(["vi", "ur", "th", "te", "ta", "si", "pa", "ne", "my", "mr", "ml", "lo", "kn", "km", "hi", "gu", "fa", "bn", "ar"].includes(language_id)){
            // tall font
            return "f-tall"
        }
        // english like
        return "f-eng"
    }

    loadCorpusFont(corpname){
        /* now used fonts ["Arab", "Armn", "Beng", "Cyrl", "Deva", "Ethi", "Geor",
        "Grek", "Gujr", "Guru", "Hans", "Hant", "Hebr", "Jpan", "Khmr", "Knda",
        "Kore", "Laoo", "Latn", "Mlym", "Mymr", "Sinh", "Taml", "Telu", "Tfng",
        "Thaa", "Thai", "Tibt"]*/
        if(AppStore.data.corpusListLoaded){
            let script = this.getCorpusScript(corpname)
            script && this.loadScriptFont(script)
        } else {
            // not possible to load font now, wait until corpus list is loaded
            this.corpnameQueue.push(corpname)
        }
    }

    loadScriptFont(script){
        let script2GoogleFont = {
            "Jpan": "Noto Sans JP",
            "Kore": "Noto Sans KR",
            "Hans": "Noto Sans SC",
            "Hant": "Noto Sans TC"
        }
        if(!this.loadedScripts.includes(script)){
            this.loadedScripts.push(script)
            let options = {}
            // fonts are split into multiple files, loaded acording to renered charactes
            if(script2GoogleFont[script]){
                options = {
                    google: {
                        families: [script2GoogleFont[script]],
                        urls: [`styles/fonts/noto/noto-${script.toLowerCase()}.css`]
                    },
                    custom: {
                        urls: ["styles/fonts/noto/cjk-helper.css"]
                    }
                }
            } else {
                options = {
                    custom: {
                        families: [`Noto ${script}`],
                        urls: [`styles/fonts/noto/noto-${script.toLowerCase()}.css`]
                    },
                    classes: false,
                    events: false
                }
            }
            WebFont.load(options)
        }
    }

    _onCorpusChanged(){
        this._refreshStyle()
        this._updateCorpusFont()
    }

    _onCorpusListChanged(){
        if(AppStore.data.corpusListLoaded){
            // corpuslist is loaded -> load previously requested fonts
            while(this.corpnameQueue.length){
                this.loadCorpusFont(this.corpnameQueue.pop())
            }
        }
    }

    _onLocalizationChange(){
        this._refreshStyle()
        this._updateInterfaceFont()
    }

    _onLanguageListLoaded(){
        this.scripts = {}
        AppStore.data.languageList.forEach(l => {
            this.scripts[l.id] = l.script
        }, this)
        this._updateCorpusFont()
        this._updateInterfaceFont()
    }

    _refreshStyle(){
        let corpus = AppStore.getActualCorpus()
        let direction = Localization.getDirection()
        let style = {
            direction: direction
        }
        if(Localization.langMeta.fontSize){
            style["font-size"] = Localization.langMeta.fontSize
        }
        let classes = ["density-" + SettingsStore.get("density")];
        corpus && classes.push(this.getLangFontClass(corpus.language_id));
        (direction == "rtl") && classes.push("rtl")
        SettingsStore.get("highcontrast") && classes.push("highContrast")

        $("body").removeClass("density-low density-medium density-high f-eng f-cjk f-tall rtl highContrast")
                         .addClass(classes.join(" "))
                         .css(style)
    }

    _updateCorpusFont(){
        let corpus = AppStore.getActualCorpus()
        if(!corpus){
            return
        }
        this._loadFontSetClass(corpus.language_id, "script-")
    }

    _updateInterfaceFont(){
        this._loadFontSetClass(Localization.getLocale(), "interface-script-")
    }

    _loadFontSetClass(language_id, prefix){
        let script = this.scripts[language_id] || "Latn"
        let classList = $("body")[0].classList
        classList.forEach(c => {
            if(c.startsWith(prefix)){
                classList.remove(c)
            }
        })
        this.loadScriptFont(script)
        $("body").addClass(prefix + script.toLowerCase())
    }
}

export let AppStyle = new AppStyleClass();
