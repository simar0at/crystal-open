const {AppStore} = require('core/AppStore.js')
const {SettingsStore} = require('core/SettingsStore.js')
const {Auth} = require('core/Auth.js')


class AppClass{
    constructor(){
        riot.observable(this)
        this._status = {}
        this._resetStatus()
    }

    init(){
        // TODO: mabye simplify
        // we need to react on every login - user can log in and log out multiple
        // times on one page load
        Dispatcher.on("AUTH_LOGIN", this._onLogin.bind(this))
        Dispatcher.on("AUTH_ANONYMOUS_LOGIN", this._onAnonymousLogin.bind(this))
        AppStore.one("corpusListChanged", this._updateStatus.bind(this, "corpusListLoaded", true))
    }

    isReady(){
        return this._status.ready // logged and has loaded corpus - if needed
    }

    _onAnonymousLogin(){
        AppStore.loadCorpusList()
        AppStore.loadLanguageList()
        let corpname = this._getCorpnameFromUrl()
        this._setCorpus(corpname)
        this._updateStatus("logged", true)
        this._updateStatus("settingsLoaded", true)
        this._updateStatus("userDataLoaded", true)
    }

    _onLogin(){
        AppStore.loadCorpusList()
        AppStore.loadLanguageList()
        AppStore.loadBgJobs()
        Dispatcher.trigger("APP_ON_LOGIN")
        SettingsStore.one("loaded", this._updateStatus.bind(this, "settingsLoaded", true))
        let corpname = this._getCorpnameFromUrl() || this._getCorpnameFromLocalStorage()
        this._setCorpus(corpname)
        this._updateStatus("logged", true)
    }

    _updateStatus(key, value){
        this._status[key] = value
        this.checkAndTriggerReady()
    }

    _resetStatus(){
        this._status = {
            ready: false,
            logged: false,
            selectedCorpus: null,
            corpusLoaded: false,
            settingsLoaded: false,
            corpusListLoaded: false,
            userDataLoaded: false
        }
        Dispatcher.trigger("APP_READY_CHANGED", false)
    }

    checkAndTriggerReady(){
        let ready = this._status.logged
                    && this._status.settingsLoaded
                    && (!this._status.selectedCorpus || this._status.corpusLoaded)
                    && (!this._status.selectedCorpus || this._status.userDataLoaded)
        if(this._status.ready != ready){
            this._status.ready = ready
            Dispatcher.trigger("APP_READY_CHANGED", ready)
        }
    }

    _setCorpus(corpname){
        if(corpname){
            this._updateStatus("selectedCorpus", corpname)
            let actualCorpus = AppStore.getActualCorpus()
            if(!actualCorpus || actualCorpus.corpname != corpname){
                // corpus is not loaded -> load and then trigger ready
                AppStore.one("corpusChanged", function(){
                    this._updateStatus("selectedCorpus", AppStore.getActualCorpname() || null) //in case in local storage is invalid corpname
                    this._updateStatus("corpusLoaded", true)
                }.bind(this))
                if(Auth.isFullAccount()){
                    // is full account -> once corpus is load we need to load corpus
                    // user data. In anonymous mode data are not loaded
                    Dispatcher.one("USER_DATA_CORPUS_LOADED", this._updateStatus.bind(this, "userDataLoaded", true))
                }
                AppStore.changeCorpus(corpname);
            }
        }
    }

    _getCorpnameFromUrl(){
        let tmp = window.location.href.split("corpname=")[1]
        let corpname = tmp ? decodeURIComponent(tmp.split("&")[0]) : null
        return corpname == "undefined" ? null : corpname
    }

    _getCorpnameFromLocalStorage(){
        return LocalStorage.get("corpname")
    }
}

// make it global
window.App = new AppClass();
