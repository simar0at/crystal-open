const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {Connection, SSEConnection} = require('core/Connection.js')
const {AppStore} = require("core/AppStore.js")
const {Auth} = require("core/Auth.js")

class KeywordsStoreClass extends FeatureStoreMixin {
    constructor() {
        super()
        this.feature = "keywords"
        this.data = $.extend(this.data, {
            alnum: true,
            do_wipo: false,
            exclude: false,
            fromList: false,
            icase: true,
            include_nonwords: false,
            k_activeRequest: null,
            k_attr: "lemma",
            k_isLoading: false,
            k_items: [],
            k_allItems: [],
            k_itemsPerPage: 50,
            k_page: 1,
            k_showItems: [],
            k_wlpat: '.*',
            ktab: "keywords",
            max_items: 1000,
            maxfreq: 0,
            minfreq: 1,
            n_activeRequest: null,
            n_attr: "word",
            n_isLoading: false,
            n_items: [],
            n_allItems: [],
            n_itemsPerPage: 50,
            n_ngrams_max_n: 4,
            n_ngrams_n: 3,
            n_page: 1,
            n_showItems: [],
            n_wlpat: ".*",
            onealpha: true,
            ref_corpname: '',
            ref_usesubcorp: '',
            showavgstar: false,
            showcounts: false,
            showdocf: false,
            showreldocf: false,
            showarf: false,
            showaldf: false,
            showLineNumbers: true,
            showrelfrq: false,
            showresults: false,
            showscores: false,
            showwikisearch: false,
            showrefvalues: true,
            simple_n: 1,
            t_activeRequest: null,
            t_isLoading: false,
            t_items: [],
            t_allItems: [],
            t_itemsPerPage: 50,
            t_notAvailable: false,
            t_page: 1,
            t_showItems: [],
            t_wlpat: '.*',
            tab: "basic",
            usekeywords: true,
            usengrams: false,
            usesubcorp: '',
            useterms: true,
            w_activeRequest: null,
            w_isLoading: false,
            w_items: [],
            w_allItems: [],
            w_itemsPerPage: 50,
            w_page: 1,
            w_showItems: [],
            w_single: false,
            wlblacklist: "",
            wlfile: ""
        })
        this.defaults = window.copy(this.data)

        this.urlOptions = ["alnum", "do_wipo", "exclude", "fromList", "icase",
            "k_attr", "k_itemsPerPage", "k_page", "k_wlpat", "ktab", "max_keywords",
            "maxfreq", "minfreq", "n_itemsPerPage", "n_wlpat",
            "onealpha", "orderBy", "page", "ref_corpname", "ref_usesubcorp",
            "showavgstar", "showcounts", "showdocf", "showarf", "showaldf", "showreldocf", "showLineNumbers", "showrelfrq",
            "showresults", "showscores", "showwikisearch", "simple_n", "sort",
            "t_itemsPerPage", "t_page", "t_wlpat", "tab", "tts", "usekeywords",
            "usengrams", "usesubcorp", "useterms", "w_itemsPerPage", "w_single",
            "wlblacklist", "wlfile", "include_nonwords", "n_ngrams_max_n",
            "n_ngrams_n", 'search_query', 'search_mode', 'search_matchCase', 'n_attr']

        this.xhrOptions = ["alnum", "icase", "k_attr", "max_keywords",
            "maxfreq", "minfreq", "onealpha", "ref_usesubcorp", "reldocf",
            "simple_n", "usesubcorp", "wlblacklist", "wlfile", "include_nonwords",
            "ref_corpname"]

        this.userOptionsToSave = ["k_itemsPerPage", "ktab", "n_itemsPerPage",
            "showavgstar", "showcounts", "showdocf", "showarf", "showaldf", "showreldocf", "showrelfrq", "showscores",
            "showwikisearch", "t_itemsPerPage", "tab", "usekeywords", "usengrams",
            "useterms", "w_itemsPerPage", "include_nonwords"]

        this.searchOptions = [
            ["alnum", "kw.alnum"],
            ["k_attr", "k_attr"],
            ["k_wlpat", "k_wlpat"],
            ["minfreq", "minFreq"],
            ["n_wlpat", "n_wlpat"],
            ["onealpha", "kw.onealpha"],
            ["ref_corpname", "refCorpus"],
            ["ref_usesubcorp", "kw.refSubcorpus"],
            ["simple_n", "kw.simple_n"],
            ["t_wlpat", "t_wlpat"],
            ["usesubcorp", "subcorpus"],
            ["icase", "icase"],
            ["include_nonwords", "includeNonwords"]
        ]

        AppStore.on("corpusListChanged", this._onCorpusListChanged.bind(this))
    }

    search(onlywipo) {
        this.cancelPreviousRequest()
        this.data.showresults = true
        this.request = []

        if (!onlywipo) { // only WIPO form changed, do not run key/terms
            this.k_search()
            this.t_search()
            this.n_search()
        }
        this.w_search()
        if(this.data.ktab != "wipo" && !this.data["use" + this.data.ktab]){ //active tab is now not selected, choose new one
            if(this.data.usekeywords){
                this.data.ktab = "keywords"
            } else if(this.data.useterms){
                this.data.ktab = "terms"
            } else if(this.data.usengrams){
                this.data.ktab = "ngrams"
            }
            this.pageTag.refs.results && this.pageTag.refs.results.refs.tabs.setTab(this.data.ktab)
        }
        this.pageTag.refs.options && this.pageTag.refs.options.update()
        this.updatePageTag()
    }

    updateAllResultTags(){
        ["k", "t", "n", "w"].forEach(this.updateResultTag, this)
    }

    updateResultTag(prefix){
        prefix = prefix || this.data.ktab.substring(0, 1)
        let resultTag = this.pageTag.refs.results
        if(resultTag){
            let tabsTag = resultTag.refs.tabs
            let feature = {
                "k": "keywords",
                "t": "terms",
                "n": "ngrams",
                "w": "wipo"
            }[prefix];
            resultTag.refreshIcons()
            if(tabsTag.tab == feature){
                let contentTag = tabsTag.refs["content-" + feature]
                contentTag && contentTag.update()
            } else {
                resultTag[feature + "_needUpdate"] = true
            }
        }
    }

    k_search(){
        if(this.data.usekeywords){
            this.data.k_isLoading = true
            this.data.k_activeRequest = Connection.get({
                url: this.getRequestUrl(),
                data: this.getKeywordsRequestData(),
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "k")
            })
            this.request.push(this.data.k_activeRequest)
        }
    }

    t_search(){
        if(this.data.useterms && !this.data.t_notAvailable && !window.config.NO_SKE){
            this.data.t_isLoading = true
            this.data.t_activeRequest = Connection.get({
                url: this.getRequestUrl(),
                data: this.getTermsRequestData(),
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "t")
            })
            this.request.push(this.data.t_activeRequest)
        }
    }

    n_search(){
        if(this.data.usengrams && !window.config.NO_SKE){
            this.data.n_isLoading = true
            this.data.n_activeRequest = Connection.get({
                url: this.getRequestUrl(),
                data: this.getNgramsRequestData(),
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "n")
            })
            this.request.push(this.data.n_activeRequest)
        }
    }

    w_search(){
        if (this.data.do_wipo && !this.data.t_notAvailable) {
            this.data.w_isLoading = true
            this.data.w_activeRequest = Connection.get({
                url: window.config.URL_BONITO + 'wipo',
                data: {
                    corpname: this.corpus.corpname,
                    ref_corpname: this.data.ref_corpname,
                    single: this.data.w_single ? "1" : "0",
                    addfreqs: this.getAddfreqs()
                },
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "w")
            })
            this.request.push(this.data.w_activeRequest)
        }
    }

    getRequestUrl(){
        return window.config.URL_BONITO + "extract_keywords"
    }

    getKeywordsRequestData(){
        return Object.assign(this.getRequestData(), {
            keywords: 1,
            ref_corpname: this.data.ref_corpname,
            attr: this.data.k_attr,
            wlpat: this.data.k_wlpat,
            max_keywords: this.data.max_items,
            addfreqs: this.getAddfreqs(),
            reldocf: this.data.showreldocf
        })
    }

    getTermsRequestData(){
        return Object.assign(this.getRequestData(), {
            terms: 1,
            ref_corpname: this.data.ref_corpname,
            attr: "TERM",
            wlpat: this.data.t_wlpat,
            max_keywords: this.data.max_items,
            addfreqs: this.getAddfreqs(),
            reldocf: this.data.showreldocf
        })
    }

    getNgramsRequestData(){
        return Object.assign(this.getRequestData(), {
            ngrams: true,
            ref_corpname: this.data.ref_corpname,
            usengrams: true,
            attr: this.data.n_attr,
            ngrams_n: this.data.n_ngrams_n,
            ngrams_max_n: this.data.n_ngrams_max_n,
            wlpat: this.data.n_wlpat,
            max_keywords: this.data.max_items,
            addfreqs: this.getAddfreqs(),
            wlfile: this.data.wlfile.replaceAll(" ", "\t"),
            wlblacklist: this.data.wlblacklist.replaceAll(" ", "\t"),
            reldocf: this.data.showreldocf
        })
    }


    getSwapUrl(corpname, usesubcorp){
        return this.getUrlToResultPage(Object.assign(this._getQueryObject(), {
            corpname: corpname,
            usesubcorp: usesubcorp,
            ref_corpname: this.corpus.corpname,
            ref_usesubcorp: this.data.usesubcorp,
            tts: {}
        }))
    }

    getAddfreqs(){
        let freqs = [];
        (this.data.showdocf || this.data.showreldocf) && freqs.push("docf")
        this.data.showavgstar && freqs.push("star:f")
        this.data.showarf && freqs.push("arf")
        this.data.showaldf && freqs.push("aldf")
        return freqs.join(",")
    }

    onDataLoaded(payload){
        if(this._isActualFeature()){
            let wasLoaded = this.hasBeenLoaded
            let prefix = payload.request.keywords && "k"
                    || payload.request.terms && "t"
                    || payload.request.ngrams && "n"
                    || payload.request.single && "w"
            this._onDataLoaded(prefix, payload)
            if(prefix == "t"){
                if(payload.error && payload.error.indexOf('Terms are not compiled') == 0) {
                    // TODO: use codes in the future
                    this.data.t_notAvailable = true
                }
            }
            if(payload.jobid){
                this.onDataLoadedProcessBGJob(prefix, payload, this[prefix + "_search"].bind(this))
            }
            this.filterResults()
            if(!this.data.k_isEmpty || !this.data.t_isEmpty || !this.data.n_isEmpty || !this.data.w_isEmpty) {
                if(!wasLoaded){
                    this.hasBeenLoaded = true
                    this.addResultToHistory()
                    this.saveUserOptions(this.userOptionsToSave)
                }
            }
        }
    }

    _onDataLoaded(prefix, payload) {
        this.data[prefix + "_items"] = []
        this.data[prefix + "_error"] = ''
        this.data[prefix + "_jobid"] = ''
        this.data[prefix + "_isEmpty"] = true
        this.data[prefix + "_isEmptySearch"] = false
        this.data[prefix + "_isError"] = false
        this.data[prefix + "_raw"] = payload
        this.data[prefix + "_totalcnt"] = payload.total
        this.data[prefix + "_totalfrq1"] = payload.totalfrq1
        this.data[prefix + "_totalfrq2"] = payload.totalfrq2
        if(payload.error){
            this.data[prefix + "_error"] = payload.error
            this.data[prefix + "_isError"] = true
            this.showError(getPayloadError(payload))
        } else if (payload.request.corpname == payload.request.ref_corpname
                && payload.request.ref_usesubcorp == payload.request.usesubcorp) {
            this.data[prefix + "_error"] = _("kw.refIsEqual")
        } else if (payload.jobid) {
            this.data[prefix + "_jobid"] = payload.jobid
        } else{
            this.data[prefix + "_items"] = payload.keywords
            this.data[prefix + "_isEmpty"] = this.data[prefix + "_items"].length == 0
            this.calculatePagination(prefix)
        }
    }

    onDataLoadAlways(prefix, payload){
        this.data[prefix + "_activeRequest"] = null
        this.data[prefix + "_isLoading"] = false
        this.saveState()
        this.updateResultTag(prefix)
        this.pageTag.refs.results && this.pageTag.refs.results.refreshIcons()
        this.pageTag.refs.options && this.pageTag.refs.options.update()
    }

    setCorpusDefaults(){
        super.setCorpusDefaults()
        this.data.ref_corpname = this.corpus.refKeywordsCorpname || ""
        this.data.t_notAvailable = !this.corpus.termdef
    }

    prevPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w, n
        if(this._isShowingResults() && this.data[p + "_page"] > 1){
            this.changePage(this.data[p + "_page"] -= 1)
        }
    }

    nextPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w, n
        if(this._isShowingResults() && !this.isLastPage()){
            this.changePage(this.data[p + "_page"] += 1)
        }
    }

    isLastPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w, n
        return this.data[p + "_page"] >= Math.ceil(this.data[p + "_items"].length / this.data[p + "_itemsPerPage"])
    }

    changeValue(value, name){
        Object.assign(this.data, {
            [name]: value
        })
        this.updateResultTag()
    }

    changePage(page){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w, n
        this.data[p + "_page"] = page
        this.calculatePagination()
        this.updateUrl()
        this.updateResultTag()
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
            this.data.k_page = 1
            this.data.t_page = 1
            this.data.n_page = 1
            this.data.w_page = 1
            this.filterResults()
            this.updateAllResultTags()
            this.updateUrl()
        }
    }

    filterResults(){
        if(this.data.search_query !== ""){
            let p = this.data.ktab.substring(0, 1)
            if(!this.data[p + "_allItems"].length){
                this.data[p + "_allItems"] = copy(this.data[p + "_items"])
            }
            let re = this.getFilterRegEx()
            if(p == "n"){
                re = new RegExp(re.source.replaceAll(" ", "\t"), this.data.search_matchCase ? "" : "i");
            }
            this.data[p + "_items"] = this.data[p + "_allItems"].filter(item => this.filterTestItem(re, item))
            this.data[p + "_isEmptySearch"] = !this.data[p + "_items"].length
            this.calculatePagination(p)
        }
    }

    filterTestItem(re, item){
        return re.test(item.item)
    }

    cancelFilter(){
        if(this.data.search_query !== ""){
            let p = this.data.ktab.substring(0, 1)
            this.data.search_query = ""
            this.data.search_mode = this.defaults.search_mode
            ;["k", "t", "n", "w"].forEach(p => {
                if(this.data[p + "_allItems"].length){
                    this.data[p + "_items"] = copy(this.data[p + "_allItems"])
                }
                this[p + "_isEmptySearch"] = false
                this.calculatePagination(p)
            })
            this.updateAllResultTags()
            this.updateUrl()
        }
    }

    calculatePagination(p){
        p = p || this.data.ktab.substring(0, 1) // -> k, t, w, n
        this.data[p + "_showResultsFrom"] = (this.data[p + "_page"] - 1) * this.data[p + "_itemsPerPage"]
        this.data[p + "_pageCount"] = Math.ceil(this.data[p + "_items"].length / this.data[p + "_itemsPerPage"])
        let sliceFrom = (this.data[p + "_page"] - 1) * this.data[p + "_itemsPerPage"]
        let sliceTo = this.data[p + "_page"] * this.data[p + "_itemsPerPage"]
        this.data[p + "_showItems"] = this.data[p + "_items"].slice(sliceFrom, sliceTo)
    }

    changeItemsPerPage(itemsPerPage) {
        itemsPerPage = itemsPerPage * 1
        let p = this.data.ktab.substring(0, 1) // -> k, t, w, n
        let actualPosition = this.data[p + "_itemsPerPage"] * (this.data[p + "_page"] - 1) + 1
        let newPage = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
        this.data[p + "_itemsPerPage"] = itemsPerPage
        this.data[p + "_page"] = newPage
        this.calculatePagination()
        this.updateResultTag()
        this.updateUrl()
    }

    cancelPreviousRequest(){
        ["k", "t", "n", "w"].forEach(prefix => {
            this.data[prefix + "_activeRequest"] && Connection.abortRequest(this.data[prefix + "_activeRequest"])
            this.data[prefix + "_isLoading"] = false
            this.data[prefix + "_activeRequest"] = null
        }, this)
    }

    starFormatter(avgstar){
        return avgstar == -1 ? "-" : avgstar.toPrecision(3)
    }

    onDataLoadedProcessBGJob(prefix, payload, searchMethod){
        this.data[prefix + "_jobid"] = null
        if(payload.jobid){
            this.data[prefix + "_jobid"] = payload.jobid
            if(Auth.isFullAccount()){
                !this[prefix + "_bgJobEventSource"] && AppStore.loadBgJobs()
                this._checkBgJob(prefix, searchMethod || this.search.bind(this), payload.jobid)
            }
        } else {
            this._stopBgJobInterval(prefix)
        }
    }

    _onCorpusChange(){  // overrides default
        super._onCorpusChange()
        this._refreshRecompileWarning()
    }

    _onCorpusListChanged(){
        this._refreshRecompileWarning()
    }

    _refreshRecompileWarning(){
        let corpus = AppStore.get("corpus")
        if(corpus && AppStore.get("corpusListLoaded")){
            let corpusList = AppStore.get("corpusList")
            let refCorpus = corpusList.find(c => c.corpname == corpus.reference_corpus)
            let wasRecompile = this.showRecompileWarning
            this.showRecompileWarning = corpus.id && ((refCorpus && refCorpus.termdef && refCorpus.termdef != corpus.termdef)
                || (corpusList.findIndex(c => c.termdef != corpus.termdef) == -1))
            wasRecompile != this.showRecompileWarning && this.updatePageTag()
        }
    }

    _setDataFromUrl(query){ // overrides default
        if(query.k_ref_corpname){
            query.ref_corpname = query.k_ref_corpname
            delete query.k_ref_corpname
        }
        if(query.k_ref_subcorp){
            query.ref_uesubcorp = query.k_ref_subcorp
            delete query.k_ref_subcorp
        }
        if(query.max_keywords){
            query.max_items = query.max_keywords
            delete query.max_keywords
        }
        super._setDataFromUrl(query)
    }

    _checkBgJob(prefix, searchMethod, jobid){ // overrides default
        this[prefix + "_bgJobEventSource"] = SSEConnection.get({
            url: window.config.URL_BONITO + "jobproxy",
            data: {
                task: "job_progress",
                jobid: jobid,
                sse: 1
            },
            message: function(prefix, payload){
                if (payload.error) {
                    this._stopBgJobInterval(prefix)
                    SkE.showError(_("bj.bgJobFailedToRun", [payload.error]))
                } else if (payload.signal) {
                    let signal = JSON.parse(payload.signal)[0]
                    if(payload.signal == "[]" || (signal.progress == 100 && signal.status[0] != "err")){
                        this._stopBgJobInterval(prefix)
                        searchMethod()
                    } else if (signal.status[0] == "err"){
                        delete this.data[prefix + "_jobid"]
                        this._stopBgJobInterval(prefix)
                        let superUserError = signal.stderr ? ("\n\n" + signal.stderr) : ""
                        SkE.showError(_("bj.bgJobFailed"), signal.status[1] + superUserError)
                        this.updateResultTag(prefix)
                    } else {
                        if(this.data[prefix + "_raw"]){
                            this.data[prefix + "_raw"].processing = signal.progress
                        }
                    }
                } else {
                    SkE.showError(_("somethingWentWrong"))
                }
                this.updateResultTag(prefix)

            }.bind(this, prefix),
            fail: payload => {
                SkE.showToast("Could not check computation progress.", getPayloadError(payload))
            }
        })
        this.updateResultTag(prefix)
    }


    _stopBgJobInterval(prefix){ // overrides default
        let prefixes = prefix ? [prefix] : ["k", "t", "n", "w"]
        prefixes.forEach(p => {
            if(this[p + "_bgJobEventSource"]){
                SSEConnection.abortRequest(this[p + "_bgJobEventSource"])
            }
        })
    }
}

export let KeywordsStore = new KeywordsStoreClass()
