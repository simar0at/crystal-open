const {StoreMixin} = require("core/StoreMixin.js")
const {Url} = require("core/url.js")
const {Router} = require("core/Router.js")
const {AppStore} = require("core/AppStore.js")
const {Auth} = require("core/Auth.js")
const {UserDataStore} = require("core/UserDataStore.js")
const {TextTypesStore} = require('common/text-types/TextTypesStore.js')
const {Connection, SSEConnection} = require('core/Connection.js')


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
            showresults: false,
            allItems: [],  // all loaded items, data.items might be filtered
            search_query: "",
            search_mode: "containing",
            search_matchCase: false,
            isEmptySearch: false
        }
        this.hasBeenLoaded = false
        this.savedState = {}
        this.defaults = {}
        this.userOptions = {} // user options loaded from server
        this.userOptionsToSave = ["tab"] // user options to save after data is loaded
        this.searchOptions = []
        this.pageTag = null // reference to page-xxx.tag component
        this.validEmptyOptions = []
        this.bgJobEventSource = null

        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))
        Dispatcher.on("RESET_STORE", this._onResetStore.bind(this))
        Dispatcher.on("SHOW_FEATURE_SEARCH_FORM", this._onShowFeatureSearchForm.bind(this))
        Dispatcher.on("RESULT_PREV_PAGE", this.prevPage.bind(this))
        Dispatcher.on("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        Dispatcher.on("FEATURE_HOTKEY", this._onHotkey.bind(this))
        AppStore.on("corpusChanged", this._onCorpusChange.bind(this))
        UserDataStore.on("corpusDataLoaded", this._onUserDataLoaded.bind(this))
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

        this.data.activeRequest = Connection.get(Object.assign({
            url: this.getRequestUrl(params),
            data: this.getRequestData(params),
            done: this.onDataLoadDone.bind(this),
            fail: this.onDataLoadFail.bind(this),
            always: this.onDataLoadAlways.bind(this)
        }, this.getSearchOptions()))
        this.request = [this.data.activeRequest]
        this.trigger("search")
    }

    getRequestUrl(){
        throw "FeatureStoreMixin.getRequestUrl: Not implemented"
    }

    getSearchOptions(){
        return {}
    }

    getRequestData(){
        let data = {
            corpname: this.corpus.corpname,
            results_url: window.location.href + '&showresults=1'
        }
        this.xhrOptions.forEach(attr => {
            if(isDef(this.data[attr])){
                data[attr] = this.data[attr]
            }
        })
        this._addTextTypesToData(data)
        return data
    }

    getDownloadRequest(idx){
        return this.request[idx]
    }

    onDataLoadDone(payload){
        if(!this._isActualFeature()){
            return // request was send and then user navigated to another feature
        }
        this.onDataLoaded(payload)
        this.trigger("onDataLoadDone")
    }

    onDataLoadFail(payload){
        this.trigger("onDataLoadFail")
    }

    onDataLoadAlways(payload){
        this.data.activeRequest = null
        this.data.isLoading = false
        this.data.closeFeatureToolbar = false
        this.saveState()
        this.updatePageTag()
        this.trigger("onDataLoadAlways")
    }

    onDataLoaded(payload){
        this.data.items = []
        this.data.allItems = []
        this.data.total = 0
        this.data.error = ''
        this.data.isEmpty = true
        this.data.isEmptySearch = false
        this.data.isError = false
        this.data.raw = payload
        this.onDataLoadedProcessBGJob(payload)
        this.onDataLoadedProcessError(payload)
        if(!this.data.isError && !this.data.jobid){
            this.onDataLoadedProcessItems(payload)
            this.countItems(payload)
            this.filterResults()
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
        if(!this.data.isError && !this.data.isEmpty && this.data.closeFeatureToolbar){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
        }
    }

    onDataLoadedProcessBGJob(payload, searchMethod){
        this.data.jobid = null
        if(payload.jobid){
            this.data.jobid = payload.jobid
            if(Auth.isFullAccount()){
                !this.bgJobEventSource && AppStore.loadBgJobs()
                this._checkBgJob(searchMethod || this.search.bind(this), payload.jobid)
            }
        } else {
            this._stopBgJobInterval()
        }
    }

    _checkBgJob(searchMethod, jobid){
        this.bgJobEventSource = SSEConnection.get({
            url: window.config.URL_BONITO + "jobproxy",
            data: {
                task: "job_progress",
                jobid: jobid,
                sse: 1
            },
            message: function(payload){
                if (payload.error) {
                    this._stopBgJobInterval()
                    SkE.showError(_("bj.bgJobFailedToRun", [`<a href="mailto:${window.config.links.supportMail}">${_("bj.contactTheSupport")}</a>`]) + "<br><br>" + payload.error)
                } else if (payload.signal) {
                    let signal = JSON.parse(payload.signal)[0]
                    if(payload.signal == "[]" || (signal.progress == 100 && signal.status[0] != "err")){
                        this._stopBgJobInterval()
                        searchMethod()
                    } else if (signal.status[0] == "err"){
                        delete this.data.jobid
                        this._stopBgJobInterval()
                        let superUserError = signal.stderr ? ("\n\n" + signal.stderr) : ""
                        SkE.showError(_("bj.bgJobFailed", [`<a href="mailto:${window.config.links.supportMail}">${_("bj.contactTheSupport")}</a>`]) + "<br><br>" + signal.status[1] + superUserError)
                        this.updatePageTag()
                    } else {
                        if(this.data.raw){
                            this.data.raw.processing = signal.progress
                        }
                    }
                } else {
                    SkE.showError(_("somethingWentWrong"))
                }
                this.updatePageTag()

            }.bind(this),
            fail: payload => {
                SkE.showToast("Could not check computation progress.", getPayloadError(payload))
            }
        })
        this.updatePageTag()
    }

    onDataLoadedProcessError(payload){
        if(payload.error){
            this.data.error = payload.error
            this.data.isError = true
            this.showError(getPayloadError(payload))
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
        ;["search_query", "search_mode", "search_matchCase"].forEach(key => {
            this.data[key] = this.defaults[key]
        })
    }

    getUrlToResultPage(options){
        let data = Object.assign({showresults: 1}, options)
        return Url.create(this.feature, this._getQueryObject(data))
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
            // usesubcorp is locked, do not reset
            if(key == "usesubcorp" && UserDataStore.getCorpusData(this.corpus.corpname, "defaultSubcorpus")){
                continue
            }
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
        Url.setQuery(this._getQueryObject(), addToHistory, forceUpdate)
    }

    saveState(){
        this.savedState = {}
        this.urlOptions.forEach(key => {
            if(isDef(this.data[key])){
                this.saveState[key] = window.copy(this.data[key])
            }
        }, this)
    }

    restoreState(){
        if(this.savedState){
            for(let key in this.savedState){
                // just copy values, so this.data object is not changed - unlike this.data = this.savedState
                this.data[key] = this.savedState[key]
            }
            this.updateUrl()
        }
    }

    showEmptyResultMessage(message, title){
        Dispatcher.trigger("openDialog", {
            id: "searchEmptyDialog",
            title: title || _("nothingFound"),
            small: true,
            content: message || _("nothingFoundDesc"),
            onClose: () => {
                $(".mainFormField:visible")
                    .find("input[type=text], input[type=file], textarea, select, .ui-list-list")
                    .first()
                    .focus()
            }
        })
    }

    showError(errorMessage){
        SkE.showError(_("searchError"), errorMessage, {
            id: "t_searchErrorDialog",
            small: true,
            type: "error"
        })
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

    changeFilter(search_query, search_mode, search_matchCase){
        if(search_query === this.data.search_query
                && this.data.search_mode == search_mode
                && this.data.search_matchCase == search_matchCase){
            return
        }
        if(search_query === ""){
            this.cancelFilter()
        } else {
            this.data.search_query = search_query
            this.data.search_mode = search_mode
            this.data.search_matchCase = search_matchCase
            this.data.page = 1
            this.filterResults()
            this.updatePageTag()
            this.updateUrl()
        }
    }

    filterResults(){
        if(this.data.search_query !== ""){
            if(!this.data.allItems.length){
                this.data.allItems = copy(this.data.items)
            }
            let re = this.getFilterRegEx()
            this.data.items = this.data.allItems.filter(item => this.filterTestItem(re, item))
            this.data.isEmptySearch = !this.data.items.length
            this.countItems()
            this.calculatePagination()
        }
    }

    filterTestItem(re, item){
        throw "FeatureStoreMixin.filterTestItem: Not implemented"
    }

    cancelFilter(){
        if(this.data.search_query !== ""){
            this.data.search_query = ""
            this.data.search_mode = this.defaults.search_mode
            this.data.items = copy(this.data.allItems)
            this.data.isEmptySearch = false
            this.countItems()
            this.calculatePagination()
            this.updatePageTag()
            this.updateUrl()
        }
    }

    getFilterRegEx(){
        let re = null
        let reStr = this.data.search_mode == "matchingRegex"
                ? this.data.search_query
                : window.escapeRE(this.data.search_query)
        if(this.data.search_mode == "exactMatch"){
            reStr = "^" + reStr + "$"
        } else if(this.data.search_mode == "startingWith"){
            reStr = "^" + reStr
        } else if (this.data.search_mode == "endingWith"){
            reStr = reStr + "$"
        }
        try{
            re = new RegExp(reStr, this.data.search_matchCase ? "" : "i")
        } catch(e){
            re = new RegExp()
            SkE.showToast(_("regexInvalid"))
        }
        return re
    }

    stringifyValue(value, name){
        if(value === ""){
            return _("none")
        }
        if(typeof value == "boolean" || (name && typeof this.defaults[name] == "boolean")){
            return `"${value ? _("yes") : _("no")}"`
        }
        if(Array.isArray(value)){
            return value.map(v => {
                return this.stringifyValue(v)
            }).join(", ")
        }
        if(typeof value == "object"){
            return Object.keys(value).map(key => {
                return `${key}: ${this.stringifyValue(value[key])}`
            }).join(", ")
        }
        if(name == "usesubcorp"){
            return AppStore.getSubcorpusName(value)
        }
        return value + ""
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
                if(UserDataStore.isCorpusDataLoading()){
                    // Corpus data are being loaded now, wait for it and then search.
                    // Without wait params from url will overwritten by corpus data
                    UserDataStore.one("corpusDataLoadDone", this.search.bind(this))
                } else {
                    this.search()
                }
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
        let userOptions = UserDataStore.getFeatureOptions(this.corpus.corpname, this.feature)
        if(userOptions){
            this.userOptions = window.copy(userOptions) // if there is an object in user data saving does not work - change is not detected
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
        this.data = window.copy(this.defaults)
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
            //  keep all options from userOptionsToSave in URL so stored user_options will not
            //  override default values when opening link
            if(!this.userOptionsToSave.includes(option) && this.isOptionDefault(option, value)){
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
            Object.assign(data, TextTypesStore.getQueryFromTextTypes(this.data.tts))
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
    }

    _setDataFromUserOptions(){
        if(this.corpus && isDef(this.data.usesubcorp)){
            // subcorp is locked -> set
            this.data.usesubcorp = UserDataStore.getCorpusData(this.corpus.corpname, "defaultSubcorpus") || ""
        }
        for(let key in this.userOptions){
            this.set(key, this.userOptions[key])
        }
    }

    _stopBgJobInterval(){
        if(this.bgJobEventSource){
            SSEConnection.abortRequest(this.bgJobEventSource)
        }
    }
}

export {FeatureStoreMixin}
