const {StoreMixin} = require("core/StoreMixin.js")
const OptionsConnector = require("core/OptionsConnector.js")
const {AppStore} = require("core/AppStore.js")
const {Auth} = require("core/Auth.js")


class UserDataStoreClass extends StoreMixin {
    constructor(){
        super()

        this.CORPORA_HISTORY_SIZE = 15
        this.CQLS_SIZE = 50
        this.PAGES_SIZE = {
            pages_history: 200,
            pages_favourites: 50
        }
        this.PAGES_LABEL_SIZE = 200
        this._reset()

        AppStore.on("corpusChanged", this._onCorpusChange.bind(this))
        Dispatcher.on("APP_ON_LOGIN", this._loadAll.bind(this))
        Dispatcher.on("CORPUS_DELETED", this._onCorpusDeleted.bind(this))
    }

    removeCorpusFromHistory(corpname){
        let options = {}
        let idx = this.data.corpora.findIndex(c => c.corpname === corpname)
        if(idx != -1){
            this.data.corpora.splice(idx, 1)
            options[`corpora[${idx}]|__delete`] = ""
            this.trigger("corporaChange")
            this._save(options)
        }
    }

    addPageToHistory(page){
        this._onPageAdd(page, "pages_history")
    }

    removePageFromHistory(page){
        this._onPageRemove(page, "pages_history")
    }

    togglePageFavourites(favourite, page){
        if(favourite){
            this._onPageAdd(page, "pages_favourites")
            SkE.showToast(_("addedToFavourites"))
        } else{
            this._onPageRemove(page, "pages_favourites")
            SkE.showToast(_("removedFromFavourites"))
        }
    }

    getFeatureOptions(corpname, feature){
        return this.data.corporaData[corpname] ? this.data.corporaData[corpname].features[feature] : null
    }

    getCorpusData(corpname, key){
        return this.data.corporaData[corpname] ? this.data.corporaData[corpname][key] : null
    }

    getCQLs(){
        return this.data.cqls
    }

    addCQL(cqlObj){
        let idx = this.data.cqls.findIndex(c => {return c.cql == cqlObj.cql})
        let options = {}
        this.data.cqls.push(cqlObj)
        if(idx != -1){
            //already in array -> remove it. It will be added to begin of the array
            options[`cqls[${idx}]|__delete`] = ""
            this.data.cqls.splice(idx, 1)
        }
        let i = 0
        let aboveLimit = this.data.cqls.length - this.CQLS_SIZE
        while(aboveLimit > 0){ // remove all pages overlaping limit
            aboveLimit--
            options[`cqls[${aboveLimit}]|__delete`] = ""
            this.data.cqls.shift()
        }
        options['cqls|__append'] = cqlObj // __append - command to append item to array on server

        this._save(options)
        this.trigger("cqlsChange")
    }

    saveFeatureOptions(store, optionList){
        // save given feature options
        let feature = store.feature
        let corpname = store.corpus.corpname
        let options = {}
        optionList.forEach(option => {
            options[option] = copy(store.get(option))
        })
        let loadedOptions = this.getFeatureOptions(corpname, feature) || {}
        let toSave = Object.assign({}, loadedOptions, options)
        if(!objectEquals(toSave, loadedOptions)){
            this._save({
                ["features|" + feature]: toSave
            }, corpname)
            // for open crystal allow to store data at least in javascript for actual session
            if(!this.data.corporaData[corpname]){
                this.data.corporaData[corpname] = {
                    features: {}
                }
            }
            this.data.corporaData[corpname].features[feature] = toSave
        }
        return toSave
    }

    saveLabel(page, label){
      // save label only to favourites
      let options = {}
      let id = this._getGetPageIndexInHistory(page, "pages_favourites")
      let newPage = {...page, label: label}

      if(id < 0){
        this.togglePageFavourites(true, page)
        id = this._getGetPageIndexInHistory(page, "pages_favourites")
      }
      this.data.pages_favourites[id] = newPage
      options[`pages_favourites[${id}]`] = newPage
      this._save(options)
    }

    getGlobalData(key){
        return this._getData("global", key)
    }

    saveGlobalData(options){
        return this._saveData("global", options)
    }

    saveCorpusData(corpname, section, data){
        if(!this.data.corporaData[corpname]){
            this.data.corporaData[corpname] = {}
        }
        this.data.corporaData[corpname][section] = data
        return this._save({
            [section]: data
        }, corpname)
    }


    clearData(what){
        // what = "pages_history" | "corpora"
        let xhr = OptionsConnector.update({
            options: {
                [what]: []
            },
            prefix: "user_data_",
            done: (payload, request) => {
                this._onDataLoaded({
                    "user": {
                        [request.what]: []
                    }
                })
            }
        })
        xhr.what = what
    }

    getOtherData(key){
        return this._getData("other", key)
    }

    saveOtherData(options){
        for(let key in options){
            this.data.other[key] = options[key]
            // add prefix "other|" to keys
            options["other|" + key] = options[key]
            delete options[key]
        }
        return this._save(options)
    }

    isCorpusDataLoading(){
        return !!this.corpusDataRequest
    }

    _getData(section, key){
        // section = global|other|...
        if(!this.data[section]){
            return null
        }
        if(isDef(key)){
            return this.data[section][key]
        } else{
            return this.data[section]
        }
    }

    _saveData(section, data){
        for(let key in data){
            this.data[section][key] = data[key]
            // add prefix [section] to keys
            data[`${section}|${key}`] = data[key]
            delete data[key]
        }
        return this._save(data)
    }

    _onCorpusDeleted(corpname){
        let options = {}
        let idx = this.data.corpora.findIndex(c => c.corpname === corpname)
        if(idx != -1){
            this.data.corpora.splice(idx, 1)
            options[`corpora[${idx}]|__delete`] = ""
            this.trigger("corporaChange")
        }
        this.data.pages_history = this.data.pages_history.filter((page, i) => {
            if(page.corpname == corpname){
                options[`pages_history[${i}]|__delete`] = ""
                return false
            }
            return true
        }, this)
        this.data.pages_favourites = this.data.pages_favourites.filter((page, i) => {
            if(page.corpname == corpname){
                options[`pages_favourites[${i}]|__delete`] = ""
                return false
            }
            return true
        }, this)
        if(!$.isEmptyObject(options)){
            this._save(options)
        }
    }

    isPageInFavourite(page){
        // page - object from feature store
        // returns true if page result is favourited
        return this._getGetPageIndexInHistory(page, "pages_favourites") != -1
    }

    _loadAll(){
        if(Auth.isFullAccount()){
            this._loadData(["global", "corpora", "pages_favourites", "pages_history", "cqls", "other"])
        }
    }

    _loadData(options){
        OptionsConnector.get({
            options: options,
            prefix: "user_data_",
            done: this._onDataLoaded.bind(this),
            fail: (payload) => {
                SkE.showToast(_("err.userDataLoad"))
            }
        })
    }

    _loadCorpusData(corpname){
        this.corpusDataRequest = OptionsConnector.get({
            options: this._getCorpusDataKeys(corpname),
            done: this._onCorpusDataLoaded.bind(this, corpname),
            fail: (payload) => {
                SkE.showToast(_("err.userDataLoad"))
            },
            always: () => {
                this.trigger("corpusDataLoadDone")
                this.corpusDataRequest = null
            }
        })
    }

    _onDataLoaded(payload){
        let data = payload.user
        for(let section in data){
            if(data[section]){
                this.data[section] = data[section]
                this.data[section + "Loaded"] = true
                this.trigger(section + "Change")
            }
        }
    }

    _onCorpusDataLoaded(corpname, payload){
        if(!this.data.corporaData[corpname]){
            this.data.corporaData[corpname] = {
                features: {},
                macros: []
            }
        }
        ;["macros", "defaultSubcorpus", "defaultMacro"].forEach(key => {
            let data = payload.user[this._getCorpusDataKey(corpname, key)]
            if(data){
                this.data.corporaData[corpname][key] = data
            }
        })
        let data = payload.user[this._getCorpusDataKey(corpname, "features")]
        if(data){
            if(typeof data == "object"){
                this.data.corporaData[corpname]["features"] = data
            } else {
                // broken data, reset it to empty object
                this._save({"features": {}}, corpname)
                this.data.corporaData[corpname].features = {}
            }
        }
        this.trigger("corpusDataLoaded", corpname)
        Dispatcher.trigger("USER_DATA_CORPUS_LOADED", corpname)
    }

    _onCorpusChange(){
        let corpus = AppStore.getActualCorpus()
        this.corpus = corpus
        corpus && Auth.isFullAccount() && this._loadCorpusData(corpus.corpname)
        if(!corpus || !App.isReady()){
            return
        }
        this.data.corporaData[corpus.corpname] = {
            features: {}
        }
        // corpus has change -> push it corpus history
        let idx = this.data.corpora.findIndex(c => c.corpname === corpus.corpname)
        let options = {}
        let corpora = {
            corpname: corpus.corpname,
            name: corpus.name,
            language: corpus.language_name,
            size: corpus.sizes ? corpus.sizes.wordcount : 0
        }
        if(idx != -1){
            //already in array -> remove it. It will be added to front
            this.data.corpora.splice(idx, 1)
            options[`corpora[${idx}]|__delete`] = ""
        }
        this.data.corpora.push(corpora)
        while(this.data.corpora.length > this.CORPORA_HISTORY_SIZE){ // remove all corpora overlaping limit
            options[`corpora[0]|__delete`] = "" // on server we remove one after another, so we can always send index 0
            this.data.corpora.shift()
        }
        if(this.data.corpora.length > this.CORPORA_HISTORY_SIZE){
            this.data.corpora.pop() // exceeded size -> remove last
        }
        options[`corpora|__append`] = corpora // __append - command to append item to array on server
        this._save(options)
        this.trigger("corporaChange")
    }

    _onPageAdd(page, section){
        // section = "pages_history" | "pages_favourites"
        page.timestamp = Date.now()
        if(Auth.isLoggedAs()){
            page.wasLoggedAs = 1
        } else {
            delete page.wasLoggedAs
        }
        let idx = this._getGetPageIndexInHistory(page, section)
        let options = {}
        this.data[section].push(page)
        if(idx != -1){
            //already in array -> remove it. It will be added to front
            options[`${section}[${idx}]|__delete`] = ""
            this.data[section].splice(idx, 1)
        }
        let i = 0
        let aboveLimit = this.data[section].length - this.PAGES_SIZE[section]
        while(aboveLimit > 0){ // remove all pages overlaping limit
            aboveLimit--
            options[`${section}[${aboveLimit}]|__delete`] = ""
            this.data[section].shift()
        }
        options[`${section}|__append`] = page // __append - command to append item to array on server

        this._save(options)
        this.trigger(section + "Change")
    }

    _onPageRemove(page, section){
        let idx = this._getGetPageIndexInHistory(page, section)
        if(idx != -1){
            this.data[section].splice(idx, 1)
            this._save({
                [`${section}[${idx}]|__delete`]: ""
            })
            this.trigger(section + "Change")
        }
    }

    _getGetPageIndexInHistory(page, section){
        return this.data[section].findIndex(p => {
            if(p.pageId == page.pageId && p.corpname == page.corpname){
                if(objectEquals(p.userOptions, page.userOptions)){
                    return true
                }
            }
            return false
        })
    }

    _getCorpusDataKeys(corpname){
        return ["features", "defaultSubcorpus", "macros", "defaultMacro"].map(key => {
            return this._getCorpusDataKey(corpname, key)
        }, this)
    }

    _getCorpusDataKey(corpname, key){
        return corpname + ":user_data_" + key
    }

    _reset(){
        this.data = {
            globalDataLoaded: false,
            global: {},
            corporaData: {},
            corpora: [],
            pages_history: [],
            pages_favourites: [],
            cqls: [],
            other: {}
        }
    }

    _save(options, corpname){
        if(!Auth.isFullAccount()){
            return
        }
        // options {pages_history: {...}} | {corpora: {...}}
        let data = {
            options: options,
            prefix: "user_data_"
        }
        if(corpname){
            data.corpus = corpname
        }
        return OptionsConnector.update(data).xhr
    }
}

export let UserDataStore = new UserDataStoreClass()
