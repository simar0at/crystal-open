require('libs/webfont/webfont.js')

const {Localization} = require('core/Localization.js')
const {SettingsStore} = require('core/SettingsStore.js')
const {AppStore} = require('core/AppStore.js')


class AppStyleClass{
    constructor(){
        AppStore.on("corpusChanged", this._onCorpusChanged.bind(this))
        SettingsStore.on("change", this._refreshStyle.bind(this))
        Dispatcher.on("LOCALIZATION_CHANGE", this._refreshStyle.bind(this))

        this.loadedScripts = []

        $(document).ready(this._refreshStyle.bind(this))
    }

    _onCorpusChanged(){
        this._refreshStyle()
        this._updateFont()
    }

    _refreshStyle(){
        let direction = Localization.getDirection()
        let style = {
            direction: direction
        }
        if(Localization.langMeta.fontSize){
            style["font-size"] = Localization.langMeta.fontSize
        }
        let classes = "density-" + SettingsStore.get("density")

        let corpus = AppStore.getActualCorpus()
        if(corpus){
            classes += " " + window.getLangFontClass(corpus.language_id)
        }
        if(direction == "rtl"){
            classes += " rtl"
        }

        $("body").removeClass("density-low density-medium density-high f-eng f-cjk f-tall rtl")
                         .addClass(classes)
                         .css(style)
    }

    _updateFont(){
        /* now used fonts ["Arab", "Armn", "Beng", "Cyrl", "Deva", "Ethi", "Geor",
        "Grek", "Gujr", "Guru", "Hans", "Hant", "Hebr", "Jpan", "Khmr", "Knda",
        "Kore", "Laoo", "Latn", "Mlym", "Mymr", "Sinh", "Taml", "Telu", "Tfng",
        "Thaa", "Thai", "Tibt"]*/

        let script = AppStore.getScript()
        let classList = $("body")[0].classList
        classList.forEach(c => {
            if(c.startsWith("script-")){
                classList.remove(c)
            }
        })

        if(!script || script == "Latn"){
            return
        }

        let script2GoogleFont = {
            "Jpan": "Noto Sans JP",
            "Kore": "Noto Sans KR",
            "Hans": "Noto Sans SC",
            "Hant": "Noto Sans TC"
        }
        if(!this.loadedScripts[script]){
            this.loadedScripts.push(script)
            let options = {}
            // fonts are split into multiple files, loaded acording to renered charactes
            if(["Hans", "Hant", "Kore", "Jpan"].includes(script)){
                options = {
                    google: {
                        families: [script2GoogleFont[script]],
                        urls: [`/styles/fonts/noto/noto-${script.toLowerCase()}.css`]
                    },
                    custom: {
                        urls: ["/styles/fonts/noto/cjk-helper.css"]
                    }
                }
            } else {
                options = {
                    custom: {
                        families: [`Noto ${script}`],
                        urls: [`/styles/fonts/noto/noto-${script.toLowerCase()}.css`]
                    },
                    classes: false,
                    events: false
                }
            }
            WebFont.load(options)
        }

        classList.add("script-" + script.toLowerCase())
    }
}

export let AppStyle = new AppStyleClass();
