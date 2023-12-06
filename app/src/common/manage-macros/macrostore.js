const {StoreMixin} = require("core/StoreMixin.js")
const {UserDataStore} = require('core/UserDataStore.js')
const {ConcordanceStore} = require('concordance/ConcordanceStore.js')
const {Auth} = require("core/Auth.js")
const {AppStore} = require("core/AppStore.js")
const {Router} = require("core/Router.js")


class MacroStoreClass extends StoreMixin {
    constructor(){
        super()
        this.data = {
            id: "",
            macros: [],
            macro: null,
            locked: ""
        }
        this.corpname = AppStore.getActualCorpname()
        this._setDataFromUserDataStore()

        UserDataStore.on("corpusDataLoaded", this._onCorpusDataLoaded.bind(this))
        AppStore.on("corpusChanged", this._onCorpusChange.bind(this))
    }

    getMacro(id){
        return this.data.macros.find(m => m.id == id)
    }

    getDefaultMacro(){
        if(this.data.id && this.data.locked){
            return this.data.macro
        }
        return null
    }

    hasAnyMacro(){
        return !!this.data.macros.length
    }

    hasMacro(id){
        return !!this.getMacro(id)
    }

    changeMacro(id){
        this._setMacro(id)
        this.setLocked(false)
    }

    isNameTaken(name){
        return this.data.macros.findIndex(m => m.name == name) != -1
    }

    createMacro(name){
        let operations = ConcordanceStore.data.operations.slice(1).filter(o => o.name != "context")
        let operationsStr = JSON.stringify(operations)
        let options = {};
        ["results_screen", "fc_lemword_window_type", "fc_lemword_wsize", "fc_lemword",
        "fc_lemword_type",  "fc_pos_window_type", "fc_pos_window_type",
        "fc_pos_wsize", "fc_pos_type", "fc_pos", "gdex_enabled", "gdexcnt",
        "random", "sort", "showcontext", "tts", "gdexconf",
        "f_freqml", "f_tab", "f_showrelfrq", "f_mode", "f_itemsPerPage",
        "f_page", "f_sort", "f_texttypes", "f_group", "f_showperc", "f_showreldens",
        "f_showreltt",
        "c_funlist", "c_cattr", "c_cminfreq", "c_cminbgr", "c_cfromw", "c_ctow",
        "c_cbgrfns", "c_csortfn", "c_page", "c_itemsPerPage", "c_customrange"].forEach(key => {
            if(typeof ConcordanceStore.data[key] == "object"){
                options[key] = copy(ConcordanceStore.data[key])
            } else {
                options[key] = ConcordanceStore.data[key]
            }
        })
        this.data.macros.unshift({
            id: Date.now(),
            name: name,
            options: Object.assign(options, {operations: operationsStr})
        })
        UserDataStore.saveCorpusData(this.corpname, "macros", this.data.macros)
                .done(SkE.showToast.bind(null, _("macroCreated", [truncate(name, 50)])))
        this.data.macros[0].options.operations = operations
        this.trigger("listChange", this.data.macros)
    }

    updateMacroName(id, name){
        let macro = this.getMacro(id)
        if(macro){
            macro.name = name
            this.trigger("listChange")
        }
    }

    deleteMacro(id){
        let macro = this.getMacro(id)
        if(macro){
            if(this.data.macro && this.data.macro.id == id){
                this._setMacro("")
            }
            if(UserDataStore.getCorpusData(this.corpname, "defaultMacro") == id){
                this.setLocked(false)
            }
            this.data.macros = this.data.macros.filter(m => m.id != id)
            UserDataStore.saveCorpusData(this.corpname, "macros", this.data.macros)
                    .done(SkE.showToast.bind(null, _("macroDeleted", [truncate(macro.name, 50)])))
            this.trigger("listChange", this.data.macros)
        }
    }

    setLocked(locked){
        if(Auth.isFullAccount()){
            this.data.locked = locked
            UserDataStore.saveCorpusData(this.corpname, "defaultMacro", locked ? this.data.id : "")
            this.trigger("lockedChange", this.data.locked)
        }
    }

    reset(){
        this.data.macros = []
        this.data.macro = null
        this.data.id = ""
    }

    _setMacro(id){
        let macro = this.getMacro(id)
        this.data.id = id
        this.data.macro = macro
        this.trigger("macroChange", this.data.macro)
    }

    _setDataFromUserDataStore(){
        this.data.macros = UserDataStore.getCorpusData(this.corpname, "macros") || []
        this.data.id = UserDataStore.getCorpusData(this.corpname, "defaultMacro") || ""
        this.data.macros.forEach(m => {
            if(m.options.operations && typeof m.options.operations == "string"){
                m.options.operations = JSON.parse(m.options.operations)
            }
        })
        if(this.data.id){
            this._setMacro(this.data.id)
            this.data.locked = true
        } else {
            this.data.macro = null
        }
    }

    _onCorpusChange(){
        this.corpname = AppStore.getActualCorpname()
    }


    _onCorpusDataLoaded(corpname){
        this._setDataFromUserDataStore()
        this.trigger("listChange", this.data.macros)
    }
}

export let MacroStore = new MacroStoreClass()
