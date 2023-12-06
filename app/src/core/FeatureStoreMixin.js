const {StoreMixin} = require("core/StoreMixin.js")
const {Router} = require("core/Router.js")
const {AppStore} = require("core/AppStore.js")
const {UserDataStore} = require("core/UserDataStore.js")
const {TextTypesStore} = require('common/text-types/TextTypesStore.js')
const {Connection} = require('core/Connection.js')


class FeatureStoreMixin extends StoreMixin{

    constructor(){
        super()
        this.corpus = AppStore.getActualCorpus()
        this.data = {
            items: [],
            tts: {}, // selected text types
            total: 0,
            error: '',
            jobid: null,
            isEmpty: true,
            isError: false,
            page: 1,
            tab: "basic",
            activeRequest: null, // actual pending ajax call to get result data
            showresults: false // should displayed result screen?
        }
        this.hasBeenLoaded = false
        this.savedState = {}
        this.defaults = {}
        this.userOptions = {} // user options loaded from server
        this.userOptionsToSave = ["tab"] // user options to save after data is loaded
        this.searchOptions = []
        this.pageTag = null // reference to page-xxx.tag component
        this.validEmptyOptions = []
        this.bgJobTimeoutHandle = null
        this.bgJobWaitTime = 2000

        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))
        Dispatcher.on("RESET_STORE", this._onResetStore.bind(this))
        Dispatcher.on("SHOW_FEATURE_SEARCH_FORM", this._onShowFeatureSearchForm.bind(this))
        Dispatcher.on("RESULT_PREV_PAGE", this.prevPage.bind(this))
        Dispatcher.on("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        Dispatcher.on("FEATURE_HOTKEY", this._onHotkey.bind(this))
        AppStore.on("corpusChanged", this._onCorpusChange.bind(this))
        UserDataStore.on("featureDataLoaded", this._onUserDataLoaded.bind(this))
    }

    resetSearchAndAddToHistory(options){
        this.setDefaultSearchOptions()
        this.searchAndAddToHistory(options)
    }

    searchAndAddToHistory(options, params){
        this._setNonEmptyOptions(options)
        // save view on input form -> hitting browser back shows correct settings
        !this.data.showresults && this.updateUrl()
        this._stopBgJobInterval()
        this.search(params)
        this.updateUrl(true, true)
    }

    search(params){
        this.cancelPreviousRequest()
        this.data.isLoading = true
        this.data.showresults = true
        this.updatePageTag()

        this.data.activeRequest = Connection.get({
            url: this.getRequestUrl(params),
            query: this.getRequestQuery(params),
            xhrParams: Object.assign({
                method: "POST",
                data: this.getRequestData(params)
            }, this.getRequestXhrParams(params)),
            done: this.onDataLoadDone.bind(this),
            fail: this.onDataLoadFail.bind(this),
            always: this.onDataLoadAlways.bind(this)
        })
        this.request = [this.data.activeRequest]
    }

    getRequestUrl(){
        throw "FeatureStoreMixin.getRequestUrl: Not implemented"
    }

    getRequestQuery(){
        return {
            corpname: this.corpus.corpname
        }
    }

    getRequestXhrParams(){
        return {}
    }

    getRequestData(){
        let data = {}
        this.xhrOptions.forEach(attr => {
            if(isDef(this.data[attr])){
                data[attr] = this.data[attr]
            }
        })
        this._addTextTypesToData(data)
        return data
    }

    onDataLoadDone(payload){
        if(!this._isActualFeature()){
            return // request was send and then user navigated to another feature
        }
        this.onDataLoaded(payload)
    }

    onDataLoadFail(payload){}

    onDataLoadAlways(payload){
        this.data.activeRequest = null
        this.data.isLoading = false
        this.data.keepFeatureToolbar = false
        this.saveState()
        this.updatePageTag()
    }

    onDataLoaded(payload){
        this.data.items = []
        this.data.total = 0
        this.data.error = ''
        this.data.jobid = null
        this.data.isEmpty = true
        this.data.isError = false
        this.data.raw = payload
        this.onDataLoadedProcessBGJob(payload)
        this.onDataLoadedProcessError(payload)
        if(!this.data.isError && !this.data.jobid){
            this.onDataLoadedProcessItems(payload)
            this.countItems(payload)
            this.data.isEmpty = this.data.total == 0
            this.calculatePagination() // after data.total is computed
            if(!this.data.isEmpty){
                this.hasBeenLoaded = true
                this.addResultToHistory()
                this.saveUserOptions(this.userOptionsToSave)
            } else {
                this.showEmptyResultMessage()
            }
        }
        if(!this.data.isError && !this.data.keepFeatureToolbar){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
        }
    }

    onDataLoadedProcessBGJob(payload){
        if(payload.jobid){
            this.data.jobid = payload.jobid
            if (!this.bgJobTimeoutHandle) {
                AppStore.loadBgJobs()
            }
            this.bgJobTimeoutHandle = setTimeout(this.search.bind(this), this.bgJobWaitTime)
            if(this.bgJobWaitTime < 30000){
                this.bgJobWaitTime += 2000
            }
        } else {
            this._stopBgJobInterval()
        }
    }

    onDataLoadedProcessError(payload){
        if(payload.error){
            this.data.error = payload.error
            this.data.isError = true
            this.showError(payload.error)
        }
    }

    onDataLoadedProcessItems(){
        throw "FeatureStoreMixin.onDataLoadedProcessItems: Not implemented"
    }

    countItems(){
        if(Array.isArray(this.data.items)){
            this.data.total = this.data.items.length
        } else if(typeof this.data.items == "object"){
            this.data.total = Object.keys(this.data.items).length
        }
    }

    cancelPreviousRequest() {
        if (this.data.activeRequest) {
            Connection.abortRequest(this.data.activeRequest)
            this.data.isLoading = null
            this.data.activeRequest = null
        }
    }

    isOptionDefault(key, value){
        return JSON.stringify(this.defaults[key]) === JSON.stringify(value)
    }

    setDefaultSearchOptions() {
        for (let item of this.searchOptions){
            if(typeof this.defaults[item[0]] == "object"){
                // new object, so one in defaults is not used (by reference)
                this.data[item[0]] = copy(this.defaults[item[0]])
            } else{
                this.data[item[0]] = this.defaults[item[0]]
            }
        }
        this.data.tts = {}
    }

    getUrlToResultPage(options){
        let data = Object.assign({showresults: 1}, options)
        return Router.createUrl(this.feature, this._getQueryObject(data))
    }

    getResultPageObject(){
        // return object representing all necessary result page data
        let data = {}
        this.urlOptions.forEach(name => {
            data[name] = this.data[name]
        })
        return {
            corpname: this.corpus.corpname,
            corpus: this.corpus.name,
            feature: this.feature,
            data: data,
            userOptions: this.getUserOptions()
        }
    }

    getUserOptions(){
        let userOptions = {}
        this.searchOptions.forEach(option => {
            let optionName = option[0]
            let labelId = option[1]
            let value = this.data[optionName]
            if(!this.isOptionDefault(optionName, value)){
                userOptions[optionName] = {
                    labelId: labelId,
                    value: value
                }
            }
        })
        this._addTextTypesToUserOptions(userOptions)

        return userOptions
    }

    setCorpusDefaults(){
        this.data.wsposlist = this.corpus ? this.corpus.wsposlist : []
    }

    resetGivenOptions(options){
        for(let key in options){
            if(isDef(this.defaults[key])){
                if(typeof this.defaults[key] == "object"){
                    // new object, so one in defaults is not used (by reference)
                    options[key] = copy(this.defaults[key])
                } else{
                    options[key] = this.defaults[key]
                }
            }
        }
    }

    changeValue(value, name){
        Object.assign(this.data, {
            [name]: value
        })
        this.updatePageTag()
    }

    changePage(page){
        this.data.page = page
        this.calculatePagination()
        this.updateUrl()
        this.updatePageTag()
    }

    changeItemsPerPage(itemsPerPage) {
        this._setItemsPerPageAndRecalculate(itemsPerPage)
        this.calculatePagination()
        this.updateUrl()
        this.saveUserOptions(["itemsPerPage"])
        this.updatePageTag()
    }

    addResultToHistory(){
        UserDataStore.addPageToHistory(this.getResultPageObject())
    }

    saveUserOptions(optionList){
        this.userOptions = UserDataStore.saveFeatureOptions(this, optionList)
    }

    updateUrl(addToHistory, forceUpdate) {
        Router.updateUrlQuery(this._getQueryObject(), addToHistory, forceUpdate)
    }

    saveState(){
        this.savedState = this._copy(this.data)
    }

    restoreState(){
        if(this.savedState){
            for(let key in this.savedState){
                // TODO realy?
                // just copy values, so this.data object is not changed - unlike this.data = this.savedState
                this.data[key] = this.savedState[key]
            }
            this.updateUrl()
        }
    }

    showEmptyResultMessage(){
        Dispatcher.trigger("openDialog", {
            id: "searchEmptyDialog",
            title: _("nothingFound"),
            small: true,
            content: _("nothingFoundDesc")
        })
    }

    showError(errorMessage){
        Dispatcher.trigger("openDialog", {
            id: "searchErrorDialog",
            title: _("somethingWentWrong"),
            small: true,
            type: "error",
            content: errorMessage
        })
    }

    updateRequestData(request, data){
        // update data in serialized xhrParams.data. Used for export/download requests
        let oldData = this._parseRequestData(request)
        let newData = Object.assign(oldData, data)
        request.xhrParams.data = "json=" + encodeURIComponent(JSON.stringify(newData))
    }

    _onHotkey(args){
        if(this._isActualFeature()){
            if(isFun(this[args.method])){
                this[args.method].apply(this, args.params)
            } else{
                SkE.showToast("Wrong shortcut")
            }
        }
    }

    _parseRequestData(request){
        return JSON.parse(decodeURIComponent(request.xhrParams.data.substring(5)))
    }

    _setItemsPerPageAndRecalculate(itemsPerPage){
        itemsPerPage = itemsPerPage * 1
        let actualPosition = this.data.itemsPerPage * (this.data.page - 1) + 1
        let newPage = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
        this.data.itemsPerPage = itemsPerPage
        this.data.page = newPage
    }

    onLoadingCancel(){
        // user hit Cancel on result loading screen
        this.cancelPreviousRequest()
        this.restoreState()
        this.updatePageTag()
    }

    updatePageTag(){
        this.pageTag && this.pageTag.isMounted && this.pageTag.update()
    }

    prevPage(){
        if(this._isShowingResults() && this.data.page > 1){
            this.changePage(this.data.page -= 1)
        }
    }

    nextPage(){
        if(this._isShowingResults() && !this.isLastPage()){
            this.changePage(this.data.page += 1)
        }
    }

    isLastPage(){
        return this.data.page >= Math.ceil(this.data.total / this.data.itemsPerPage)
    }

    calculatePagination() {
        if(Array.isArray(this.data.items)){
            this.data.showResultsFrom = (this.data.page - 1) * this.data.itemsPerPage
            this.data.showItems = this.data.items.slice((this.data.page - 1) * this.data.itemsPerPage, this.data.page * this.data.itemsPerPage)
            this.data.pageCount = Math.ceil(this.data.total / this.data.itemsPerPage)
        }
    }

    _isActualFeature(){
        // return true if actual displaz
        return Router.getActualFeature() == this.feature
    }

    _isShowingResults(){
        return this._isActualFeature() && this.data.showresults && this.pageTag && this.pageTag.isMounted
    }

    _onResetStore(feature){
        if(feature == this.feature){
            this._cancelRequestResetOptions()
        }
    }

    _onPageChange(pageId, query){
        // navigated to page of this feature -> initialize store data acording to url (if provided)

        this._stopBgJobInterval()
        if (this._isActualFeature()) {
            this._cancelRequestResetOptions()
            if(query){
                this._setDataFromUrl(query)
                this.trigger("change")
            }
            AppStore.changeActualFeatureStore(this)
            if(this.pageTag && this.pageTag.isMounted && this.data.showresults){
                // user navigated to the result page -> load results
                this.search()
            }
        } else{
            this.cancelPreviousRequest()
        }
    }

    _onShowFeatureSearchForm(feature){
        if(feature == this.feature){
            this._cancelRequestResetOptions()
            Dispatcher.trigger("closeAllDialogs")
            Dispatcher.trigger("ROUTER_GO_TO", feature, {corpname: this.corpus.corpname})
        }
    }

    _onUserDataLoaded(){
        this.userOptions = this._copy(UserDataStore.getFeatureOptions(this.feature)) // if there is an object in user data saving does not work - change is not detected
        let tab = this.userOptions.tab
        if(this._isActualFeature()){
            if(this.pageTag){
                // user changed corpus from open feature -> feature is already mounted -> update feature
                this._setDataFromUserOptions()
                this.updatePageTag()
            }
        } else{
            if(tab && this.data.tab != tab){
                // set default only to non-active features. In active features is tab set acording url
                this.data.tab = tab
            }
        }
    }

    _onCorpusChange(){
        let oldCorpus = this.corpus ? this.corpus.corpname : null
        this.corpus = AppStore.getActualCorpus()
        if(this.corpus && oldCorpus != this.corpus.corpname){
            this.userOptions = {}
            this._cancelRequestResetOptions()
            this.pageTag && this.pageTag.isMounted && this.updateUrl()
            this.trigger("change")
        }
    }

    _cancelRequestResetOptions(){
        this.cancelPreviousRequest()
        this._resetOptions()
    }

    _resetOptions() {
        this.data = this._copy(this.defaults)
        this.hasBeenLoaded = false
        this.corpus && this.setCorpusDefaults()
        this._setDataFromUserOptions()
        if(this.pageTag && this.pageTag.isMounted){
            // replace old reference // TODO? Delete?
            this.pageTag.data = this.data
        }
        this.updatePageTag()
    }

    _getQueryObject(data){
        data = data || this.data
        let queryObj = {
            corpname: data.corpname || this.corpus.corpname,
            tab: this.data.tab
        }
        for (let i in this.urlOptions) {
            let option = this.urlOptions[i]
            let value = data[option]
            if(this.isOptionDefault(option, value)){
                continue
            }
            if (typeof value == "object") {
                queryObj[option] = JSON.stringify(value)
            } else if (typeof value != "undefined"){
                queryObj[option] = value
            }
        }
        return queryObj
    }

    _getOptionType(option){
        return typeof this.data.defaults[option]
    }

    _addTextTypesToData(data){
        if(!$.isEmptyObject(this.data.tts)){
            Object.assign(data, TextTypesStore.getSelectionQuery())
            data.instantSubCorp = 1
        }
    }

    _addTextTypesToUserOptions(userOptions){
        if(!$.isEmptyObject(this.data.tts)){
            let value = ""
            for(let textType in this.data.tts){
                value += value ? ", " : ""
                value += textType + ":" + this.data.tts[textType].join("|")
            }
            userOptions.tts = {
                labelId: "textTypes",
                value: value
            }
        }
    }

    _setNonEmptyOptions(options){
        for(let key in options){
            if(options[key] !== "" || this.validEmptyOptions.includes(key)){
                this.data[key] = options[key]
            } else {
                this.data[key] = this.defaults[key]
            }
        }
    }

    _setDataFromUrl(query){
        for (let option in query) {
            let type = typeof this.defaults[option]
            if(type == "object"){
                this.data[option] = JSON.parse(query[option])
            } else if (type == "number") {
                this.data[option] = Number(query[option])
            } else if (type == "boolean") {
                this.data[option] = Boolean(Number(query[option]))
            } else {
                this.data[option] = query[option]
            }
        }
        query.tts && TextTypesStore.setSelection(this.data.tts)
    }

    _setDataFromUserOptions(){
        for(let key in this.userOptions){
            this.data[key] = this.userOptions[key]
        }
    }

    _stopBgJobInterval(){
        if(this.bgJobTimeoutHandle){
            clearTimeout(this.bgJobTimeoutHandle)
            this.bgJobTimeoutHandle = null
        }
        this.bgJobWaitTime = 2000
    }
}

export {FeatureStoreMixin}
