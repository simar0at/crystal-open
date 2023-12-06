window.stores = {}
if(window.config.NO_CA){
    window.config.URL_CA = window.config.URL_BONITO
}

require('core/Dispatcher.js')
require("misc/Misc.js");
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
require('core/UserDataStore.js')
require('style.scss')
require('density.scss')
require('rtl.scss')
require('corpus/CorpusStore.js')
require('core/permissions.js')
window.stores.app = require('core/AppStore.js').AppStore
window.stores.texttypes = require('common/text-types/TextTypesStore.js').TextTypesStore
window.stores.wordlist = require('wordlist/WordlistStore.js').WordlistStore
window.stores.keywords = require('keywords/keywordsstore.js').KeywordsStore
window.stores.concordance = require('concordance/ConcordanceStore.js').ConcordanceStore
window.stores.parconcordance = require('parconcordance/parconcordancestore.js').ParconcordanceStore
window.stores.ca = require('ca/castore.js').CAStore
require('ca/ca.js')
require("core/TagMixins.js")
require("core/asyncresults.js")
require("core/appupdater.js")
require("core/notifier.js")
require("dialogs/dialogs.js")
require("elexis/elexis.js")
require('misc/gdpr/gdpr.js')
require('misc/gdpr/gdpr.js')
require('misc/updater.js')
require('misc/browserchecker.js')
require('core/extendmaterialize.js')

riot.mount('crystal-app')
