window.stores = {}

if(window.config.NO_CA){
    window.config.URL_CA = window.config.URL_BONITO
}
// add missing trailing slashes
;["URL_CA", "URL_BONITO", "URL_SKE_LI"].forEach(key => {
    let url = window.config[key] ? (window.config[key] + "").trim() : ""
    if(url){
        if(!url.endsWith("/")){
            url += "/"
        }
        window.config[key] = url
    }
})

require('core/Dispatcher.js')
require("misc/Misc.js");
require("core/url.js");
require('core/LocalStorage.js')
require('core/LocalStorageListener.js')
require('core/Localization.js')
require('core/cookies.js')
require('core/Formatter.js')
require("ui/ui.js");
require('common/common.js')
require('core/crystal-app.tag')
require('core/App.js');
require("core/OptionsConnector.js")
require("core/SettingsStore.js")
require('core/Hotkeys.js')
require('core/AppStyle.js')
window.stores.user = require('core/UserDataStore.js').UserDataStore
require('style.scss')
require('buttons.scss')
require('density.scss')
require('rtl.scss')
require('highcontrast.scss')
require('corpus/CorpusStore.js')
require('core/permissions.js')
window.stores.userDataStore = require('core/UserDataStore.js').UserDataStore
window.stores.app = require('core/AppStore.js').AppStore
window.stores.texttypes = require('common/text-types/TextTypesStore.js').TextTypesStore
window.stores.wordlist = require('wordlist/WordlistStore.js').WordlistStore
window.stores.keywords = require('keywords/keywordsstore.js').KeywordsStore
window.stores.concordance = require('concordance/ConcordanceStore.js').ConcordanceStore
window.stores.parconcordance = require('parconcordance/parconcordancestore.js').ParconcordanceStore
window.stores.ca = require('ca/castore.js').CAStore
window.stores.annotation = require('annotation/annotstore.js').AnnotationStore
window.stores.macro = require('common/manage-macros/macrostore.js').MacroStore
require('ca/ca.js')
require("core/TagMixins.js")
require("core/asyncresults.js")
require("core/appupdater.js")
require("core/notifier.js")
require("dialogs/dialogs.js")
require('misc/gdpr/gdpr.js')
require('misc/gdpr/gdpr.js')
require('misc/updater.js')
require('misc/browserchecker.js')
require('core/extendmaterialize.js')
require('misc/whats-new/whatsnew.js')
require('libs/cookie_consent/cookie_consent.js')

riot.mount('crystal-app')
