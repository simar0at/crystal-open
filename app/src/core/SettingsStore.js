const OptionsConnector = require('core/OptionsConnector.js')
const {StoreMixin} = require("core/StoreMixin.js")
const {Auth} = require("core/Auth.js")

class SettingsStoreClass extends StoreMixin {

    constructor(){
        super()
        this.data = {
            default: {
                density: "medium",
                language: "en",
                highcontrast: false,
                lexonomyEmail: "",
                lexonomyApiKey: ""
            },
            user:{
            }
        }

        Dispatcher.on("APP_ON_LOGIN", this.loadAll.bind(this))
        Dispatcher.on("CHANGE_SETTINGS", this.changeSettings.bind(this)) // for hotkeys
    }

    get(key){
        return isDef(this.data.user[key]) ? this.data.user[key] : this.data.default[key]
    }

    getAll(){
        return Object.assign(window.copy(this.data.default), window.copy(this.data.user))
    }

    getSettingsList(){
        // list of all settings ["density", "language",...]
        return Object.keys(this.data.default)
    }

    hasUserSettings(){
        // user has some setting changed
        return Object.keys(this.data.user).length > 0
    }

    loadAll(){
        this.loadSettings(this.getSettingsList())
    }

    loadSettings(options){
        return OptionsConnector.get({
            loadingId: "settings",
            options: options,
            prefix: "settings_",
            done: this._onLoaded.bind(this),
            fail: (payload) => {
                this.trigger("loaded")
                SkE.showError(payload.error || _("err.loadSettings"))
            }
        })
    }

    saveSettings(options, noToast){
        return OptionsConnector.update({
            options: options,
            prefix: "settings_",
            done: function(options, payload){
                !noToast && SkE.showToast(_("saved"))
                this.trigger("settingsSaved", options)
            }.bind(this, options),
            fail: (payload) => {
                SkE.showToast(_("err.saveSettings") + ": " + payload.error)
            }
        })
    }

    resetSettings(){
        this._onReset()
        return OptionsConnector.reset({
            options: this.getSettingsList(),
            prefix: "settings_",
            fail: (payload) => {
                SkE.showToast(_("err.resetSettings") + payload.error)
            }
        })
    }

    changeSettings(options){
        let toSave = {}
        let value
        let storedValue
        for(let option in options){
            value = options[option]
            storedValue = isDef(this.data.user[option]) ? this.data.user[option] : this.data.default[option]
            if(storedValue !==  value){
                toSave[option] = value
            }
        }
        if(!$.isEmptyObject(toSave)){
            Auth.isFullAccount() && this.saveSettings(toSave, options.noToast)
            this._onChange(options)
        }
    }

    _onLoaded(payload){
        this.data.user = payload.user
        if(isDef(payload.user.highcontrast)){
            this.data.user.highcontrast = payload.user.highcontrast.toLowerCase() == "true"
        }
        this.trigger("loaded")
        this.trigger("change")
    }

    _onChange(settings){
        for(let key in settings){
            this.data.user[key] = settings[key]
        }
        this.trigger("change")
    }

    _onReset(){
        this.data.user = {}
        this.trigger("change")
    }
}

export let SettingsStore = new SettingsStoreClass()
