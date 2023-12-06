const Polyglot = require('node-polyglot')
const {LocalizationMeta, GetLangMeta} = require('core/Meta/Localization.meta.js')
const {SettingsStore} = require('core/SettingsStore.js')
const {Connection} = require('core/Connection.js')


class LocalizationClass extends Polyglot{

    constructor() {
        super()

        this.resources = {
            en: require('locale/en.json')
        }

        riot.observable(this)
        this._setDefaultPhrases()
        this._setLocale("en", this.resources.en)

        SettingsStore.on("change", this._onChangeLocaleSettings.bind(this))
    }

    getLocale(){
        return this.currentLocale
    }

    setLocale(locale){
        if(locale != this.currentLocale){
            if(this.resources[locale]){
                this._setLocale(locale, this.resources[locale])
                Dispatcher.trigger("LOCALIZATION_CHANGE", this.currentLocale)
            } else {
                let base = window.location.href.split("?")[0].split("#")[0]
                Connection.get({
                    loadingId: "locale",
                    url: `${base}/locale/${locale}.json`,
                    done: function(locale, payload) {
                        this.resources[locale] = typeof payload == "object" ? payload : JSON.parse(payload)
                        this.setLocale(locale)
                    }.bind(this, locale),
                    fail: (payload) => {
                        SkE.showError(_("localeLoadFailed"))
                    }
                })
            }
        }
    }

    getDirection(){
        return this.langMeta.dir || "ltr" // direction ltr || rtl
    }

    translate(key, options){
        if(key){
            if(isDef(this.phrases[key]) || this.currentLocale == "en"){
                return this.t(key, options)
            } else{
                console.log(`Missing translation for key: "${key}"`)
                // show english text when translation is not available
                return this.t(key, Object.assign({
                    "_": this._defaultPhrases[key]}, options))
            }

        } else{
            console.log(`Localization.translate: Undefined key`)
        }
    }

    _setDefaultPhrases(){
        this._defaultPhrases = {}
        this._extend(this.resources.en)
    }

    _extend(phrases, prefix){
        let phrase;
        for (let key in phrases) {
            phrase = phrases[key];
            if (prefix) {
                key = prefix + '.' + key;
            }
            if (typeof phrase === 'object') {
                this._extend(phrase, key);
            } else {
                this._defaultPhrases[key] = phrase;
            }
        }
    }

    _onChangeLocaleSettings(){
        let locale = SettingsStore.get("language")
        this.setLocale(locale)
    }

    _setLocale(locale, dictionary){
        this.locale(locale)
        this.replace(dictionary);
        this._setLangMeta();
    }

    _setLangMeta(){
        this.langMeta = GetLangMeta(this.currentLocale)
    }
}

export let Localization = new LocalizationClass();


window._ = Localization.translate.bind(Localization);
