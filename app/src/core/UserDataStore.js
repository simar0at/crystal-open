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
            history: 200,
            favourites: 50
        }
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
        this._onPageAdd(page, "history")
    }

    removePageFromHistory(page){
        this._onPageRemove(page, "history")
    }

    togglePageFavourites(favourite, page){
        if(favourite){
            this._onPageAdd(page, "favourites")
        } else{
            this._onPageRemove(page, "favourites")
        }
    }

    getFeatureOptions(feature){
        return this.data.features[feature] || {}
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
        let options = {}
        optionList.forEach(option => {
            options[option] = store.data[option]
        })
        let loadedOptions = this.data.features[feature] || {}
        let toSave = Object.assign({}, loadedOptions, options)
        if(!objectEquals(toSave, loadedOptions)){
            this.saveUserData({
                ["features|" + feature]: toSave
            }, this.corpus.corpname)
            this.data.features[feature] = toSave
        }
        return toSave
    }

    saveUserData(options, corpname){
        this._save(options, corpname)
    }

    clearUserData(what){
        // what = "pages" | "corpora"
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

    _onCorpusDeleted(corpname){
        let options = {}
        let idx = this.data.corpora.findIndex(c => c.corpname === corpname)
        if(idx != -1){
            //already in array -> remove it. It will be added to front
            this.data.corpora.splice(idx, 1)
            options[`corpora[${idx}]|__delete`] = ""
            this.trigger("corporaChange")
        }
        this.data.pages.history = this.data.pages.history.filter((page, i) => {
            if(page.corpname == corpname){
                options[`pages_history[${i}]|__delete`] = ""
                return false
            }
            return true
        }, this)
        this.data.pages.favourites = this.data.pages.favourites.filter((page, i) => {
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
        return this._getGetPageIndexInHistory(page, "favourites") != -1
    }

    _loadAll(){
        if(Auth.isFullAccount()){
            this._loadUserData(["global", "corpora", "pages_favourites", "pages_history", "cqls"])
        }
    }

    _loadUserData(options){
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
        OptionsConnector.get({
            options: [this._getCorpusFeaturesKey()],
            done: this._onCorpusDataLoaded.bind(this),
            fail: (payload) => {
                SkE.showToast(_("err.userDataLoad"))
            }
        })
    }

    _onDataLoaded(payload){
        let data = payload.user
        if(data.corpora){
            this.data.corpora = Array.isArray(data.corpora) ? data.corpora : []
            this.trigger("corporaChange")
        }
        if(data.global){
            this.data.global = data.global
            this.data.globalDataLoaded = true
            this.trigger("globalUserDataChange")
        }
        if(data.pages_history){
            this.data.pages.history = Array.isArray(data.pages_history) ? data.pages_history : []
        }
        if(data.pages_favourites){
            this.data.pages.favourites = Array.isArray(data.pages_favourites) ? data.pages_favourites : []
        }
        if(data.pages_favourites || data.pages_history){
            this.trigger("pagesChange")
        }
        if(data.cqls){
            this.data.cqls = data.cqls
            this.trigger("cqlsChange")
        }
    }

    _onCorpusDataLoaded(payload){
        let features = payload.user[this._getCorpusFeaturesKey()]
        if(features){
            this.data.features = features
            this.trigger("featureDataLoaded")
        }
        Dispatcher.trigger("USER_DATA_CORPUS_LOADED")
    }

    _onCorpusChange(){
        let corpus = AppStore.getActualCorpus()
        this.corpus = corpus
        this.data.features = {}
        corpus && Auth.isFullAccount() && this._loadCorpusData(corpus.corpname)
        if(!corpus || !App.isReady()){
            return
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
        // section = "history" | "favourites"
        page.timestamp = Date.now()
        let idx = this._getGetPageIndexInHistory(page, section)
        let options = {}
        this.data.pages[section].push(page)
        if(idx != -1){
            //already in array -> remove it. It will be added to front
            options[`pages_${section}[${idx}]|__delete`] = ""
            this.data.pages[section].splice(idx, 1)
        }
        let i = 0
        let aboveLimit = this.data.pages[section].length - this.PAGES_SIZE[section]
        while(aboveLimit > 0){ // remove all pages overlaping limit
            aboveLimit--
            options[`pages_${section}[${aboveLimit}]|__delete`] = ""
            this.data.pages[section].shift()
        }
        options[`pages_${section}|__append`] = page // __append - command to append item to array on server

        this._save(options)
        this.trigger("pagesChange")
    }

    _onPageRemove(page, section){
        let idx = this._getGetPageIndexInHistory(page, section)
        if(idx != -1){
            this.data.pages[section].splice(idx, 1)
            this._save({
                [`pages_${section}[${idx}]|__delete`]: ""
            })
            this.trigger("pagesChange")
        }
    }

    _getGetPageIndexInHistory(page, section){
        return this.data.pages[section].findIndex(p => {
            if(p.pageId == page.pageId && p.corpname == page.corpname){
                if(objectEquals(p.userOptions, page.userOptions)){
                    return true
                }
            }
            return false
        })
    }

    _getCorpusFeaturesKey(){
        return this.corpus.corpname + ":user_data_features"
    }

    _reset(){
        this.data = {
            globalDataLoaded: false,
            global: {},
            corpora: [],
            pages: {
                history: [],
                favourites: []
            },
            cqls: [],
            features: {} // options for actual corpus
        }
    }

    _save(options, corpname){
        if(!Auth.isFullAccount()){
            return
        }
        // options {pages: {...}} | {corpora: {...}}
        let data = {
            options: options,
            prefix: "user_data_"
        }
        if(corpname){
            data.corpus = corpname
        }
        OptionsConnector.update(data)
    }
}

export let UserDataStore = new UserDataStoreClass()
