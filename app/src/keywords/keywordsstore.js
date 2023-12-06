const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {Connection} = require('core/Connection.js')
const {AppStore} = require("core/AppStore.js")

class KeywordsStoreClass extends FeatureStoreMixin {
    constructor() {
        super()
        this.feature = "keywords"
        this.data = $.extend(this.data, {
            alnum: 1,
            attr: "lemma",
            max_keywords: 1000,
            max_terms: 1000,
            minfreq: 1,
            onealpha: 1,
            showLineNumbers: 1,
            showcounts: 0,
            showresults: 0,
            showscores: 0,
            showwikisearch: 0,
            showrelfrq: 0,
            simple_n: 1,
            tab: "basic",
            ktab: "keywords",
            usesubcorp: '',
            do_wipo: 0,
            k_activeRequest: null,
            k_isLoading: false,
            k_items: [],
            k_itemsPerPage: 50,
            k_page: 1,
            k_ref_corpname: '',
            k_ref_subcorp: '',
            k_showItems: [],
            k_wlpat: '.*',
            t_activeRequest: null,
            t_isLoading: false,
            t_items: [],
            t_itemsPerPage: 50,
            t_notAvailable: false,
            t_page: 1,
            t_ref_corpname: '',
            t_ref_subcorp: '',
            t_showItems: [],
            t_wlpat: '.*',
            w_activeRequest: null,
            w_isLoading: false,
            w_single: false,
            w_items: [],
            w_itemsPerPage: 50,
            w_page: 1,
            w_ref_corpname: '',
            w_showItems: [],
            wlblacklist: ""
        })
        this.defaults = this._copy(this.data)

        this.urlOptions = ["alnum", "attr", "k_itemsPerPage", "k_page", "k_ref_corpname",
                "k_ref_subcorp", "k_wlpat", "max_keywords", "max_terms", "minfreq",
                "onealpha", "orderBy", "page", "showcounts", "showLineNumbers",
                "showresults", "showscores", "simple_n", "sort", "t_itemsPerPage",
                "t_page", "t_ref_corpname", "t_ref_subcorp", "t_wlpat", "tab", "usesubcorp",
                "tts", "showrelfrq", "ktab", "w_ref_corpname",
                "w_itemsPerPage", "do_wipo", "w_single", "showwikisearch"]

        this.xhrOptions = [ "minfreq", "max_terms", "usesubcorp", "max_keywords",
                "simple_n", "alnum", "onealpha", "attr"]

        this.userOptionsToSave = ["tab", , "showscores", "showrelfrq",
                "showcounts", "k_itemsPerPage", "t_itemsPerPage", "ktab",
                "w_itemsPerPage", "showwikisearch"]

        this.searchOptions = [
            ["alnum", "kw.alnum"],
            ["attr", "kw.attr"],
            ["minfreq", "minFreq"],
            ["onealpha", "kw.onealpha"],
            ["simple_n", "kw.simple_n"],
            ["usesubcorp", "subcorpus"],
            ["t_wlpat", "wlpat"],
            ["t_ref_subcorp", "t_ref_subcorp"],
            ["t_ref_corpname", "kw.termsRefCorpname"],
            ["k_ref_subcorp", "kw.k_ref_subcorp"],
            ["k_ref_corpname", "kw.keywordsRefCorpname"],
            ["k_wlpat", "wlpat"]
        ]
    }

    search(onlywipo) {
        this.cancelPreviousRequest()
        this.data.showresults = true
        if (this.data.do_wipo) {
            this.data.w_isLoading = true
            this.data.w_activeRequest = Connection.get({
                url: window.config.URL_BONITO + `wipo?corpname=${this.corpus.corpname}&ref_corpname=${this.data.w_ref_corpname}`,
                xhrParams: {
                    method: "POST",
                    data: {
                        single: this.data.w_single ? "1" : "0",
                        wlblacklist: this.data.wlblacklist
                    }
                },
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "wipo")
            })
            this.wrequest = this.data.w_activeRequest
        }
        if (onlywipo) { // only WIPO form changed, do not run key/terms
            this.updatePageTag()
            return
        }
        this.data.k_isLoading = true
        if(this.data.k_ref_corpname){
            this.data.k_activeRequest = Connection.get({
                url: this.getKeywordsRequestUrl(),
                xhrParams: {
                    method: "POST",
                    data: this.getKeywordsRequestData()
                },
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "keywords")
            })
        }
        if(this.data.t_ref_corpname && !this.data.t_notAvailable && !window.config.NO_SKE){
            this.data.t_isLoading = true
            this.data.t_activeRequest = Connection.get({
                url: this.getTermsRequestUrl(),
                xhrParams: {
                    method: "POST",
                    data: this.getTermsRequestData()
                },
                done: this.onDataLoadDone.bind(this),
                fail: this.onDataLoadFail.bind(this),
                always: this.onDataLoadAlways.bind(this, "terms")
            })
        }
        this.request = [this.data.k_activeRequest, this.data.t_activeRequest]
        this.updatePageTag()
    }

    getKeywordsRequestUrl(){
        return window.config.URL_BONITO + `extract_keywords?corpname=${this.corpus.corpname}&ref_corpname=${this.data.k_ref_corpname}`
    }

    getTermsRequestUrl(){
        return window.config.URL_BONITO + `extract_terms?corpname=${this.corpus.corpname}&ref_corpname=${this.data.t_ref_corpname}`
    }

    getKeywordsRequestData(){
        return "json=" + encodeURIComponent(JSON.stringify(Object.assign(this.getRequestData(), {
                keywords: 1,
                results_url: window.location.href + '&showresults=1',
                ref_usesubcorp: this.data.k_ref_subcorp,
                wlpat: this.data.k_wlpat
            })
        ))
    }

    getTermsRequestData(){
        return "json=" + encodeURIComponent(JSON.stringify(Object.assign(this.getRequestData(), {
                terms: 1,
                results_url: window.location.href + '&showresults=1',
                ref_usesubcorp: this.data.t_ref_subcorp,
                wlpat: this.data.t_wlpat
            })
        ))
    }

    getSwapUrl(corpname, usesubcorp){
        return this.getUrlToResultPage(Object.assign(window.copy(this.data), {
            corpname: corpname,
            usesubcorp: usesubcorp,
            k_ref_corpname: this.corpus.corpname,
            k_ref_subcorp: this.data.usesubcorp,
            t_ref_corpname: this.corpus.corpname,
            t_ref_subcorp: this.data.usesubcorp,
            w_ref_corpname: this.corpus.corpname
        }))
    }

    onDataLoaded(payload){
        if(this._isActualFeature()){
            let wasLoaded = this.hasBeenLoaded
            payload.request.keywords && this.onKeywordsDataLoaded(payload)
            payload.request.terms && this.onTermsDataLoaded(payload)
            payload.request.single && this.onWipoDataLoaded(payload)
            if(!this.data.k_isEmpty || !this.data.t_isEmpty || !this.data.w_isEmpty) {
                if(!wasLoaded){
                    this.hasBeenLoaded = true
                    this.addResultToHistory()
                    this.saveUserOptions(this.userOptionsToSave)
                }
            }
            !payload.error && Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
        }
    }

    onWipoDataLoaded(payload) {
        this.data.w_items = []
        this.data.w_error = ''
        this.data.w_jobid = ''
        this.data.w_isEmpty = true
        this.data.w_isError = false
        if (payload.error) {
            this.data.w_error = payload.error
            this.data.w_isError = true
            this.showError(payload.error)
        } else if (payload.request.corpname == payload.request.ref_corpname) {
            this.data.wipo_error = _("kw.refIsEqual")
        } else if (payload.jobid) {
            this.data.w_jobid = payload.jobid
        } else{
            this.data.w_items = payload.Keyterms
            this.data.w_isEmpty = this.data.w_items.length == 0
            this.calculatePagination('w')
        }
    }

    onKeywordsDataLoaded(payload){
        this.data.k_items = []
        this.data.k_error = ''
        this.data.k_jobid = ''
        this.data.k_isEmpty = true
        this.data.k_isError = false
        this.data.k_raw = payload
        if(payload.error){
            this.data.k_error = payload.error
            this.data.k_isError = true
            this.showError(payload.error)
        } else if (payload.request.corpname == payload.request.ref_corpname
                && payload.request.ref_usesubcorp == payload.request.usesubcorp) {
            this.data.keywords_error = _("kw.refIsEqual")
        } else if (payload.jobid) {
            this.data.k_jobid = payload.jobid
        } else{
            this.data.k_items = payload.keywords
            this.data.k_isEmpty = this.data.k_items.length == 0
            this.calculatePagination('k')
        }
    }

    onTermsDataLoaded(payload) {
        this.data.t_items = []
        this.data.t_error = ''
        this.data.t_jobid = ''
        this.data.t_isEmpty = true
        this.data.t_isError = false
        this.data.t_raw = payload
        if(payload.error){
            this.data.t_error = payload.error
            this.data.t_isError = true
             if (payload.error.indexOf('Terms are not compiled') == 0) {
                // TODO: use codes in the future
                this.data.t_notAvailable = true
            }
            this.showError(payload.error)
        } else if (payload.request.corpname == payload.request.ref_corpname
                && payload.request.ref_usesubcorp == payload.request.usesubcorp) {
            this.data.terms_error = _("kw.refIsEqual")
        } else if (payload.jobid) {
            this.data.t_jobid = payload.jobid
        } else{
            this.data.t_items = payload.terms
            this.data.t_isEmpty = this.data.t_items.length == 0
            this.calculatePagination('t')
        }
    }

    onDataLoadAlways(what, payload){
        if(what == "keywords"){
            this.data.k_activeRequest = null
            this.data.k_isLoading = false
        } else if(what == "terms"){
            this.data.t_activeRequest = null
            this.data.t_isLoading = false
        } else if(what == "wipo"){
            this.data.w_activeRequest = null
            this.data.w_isLoading = false
        }
        this.saveState()
        this.updatePageTag()
    }

    setCorpusDefaults(){
        super.setCorpusDefaults()
        this.data.k_ref_corpname = this.corpus.refKeywordsCorpname || ""
        this.data.t_ref_corpname = this.corpus.refTermsCorpname || ""
        this.data.w_ref_corpname = this.corpus.refTermsCorpname || ""
        this.compTermsCorpList = AppStore.data.compTermsCorpList
    }

    prevPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w
        if(this._isShowingResults() && this.data[p + "_page"] > 1){
            this.changePage(this.data[p + "_page"] -= 1)
        }
    }

    nextPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w
        if(this._isShowingResults() && !this.isLastPage()){
            this.changePage(this.data[p + "_page"] += 1)
        }
    }

    isLastPage(){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w
        return this.data[p + "_page"] >= Math.ceil(this.data[p + "_items"].length / this.data[p + "_itemsPerPage"])
    }

    changePage(page){
        let p = this.data.ktab.substring(0, 1) // -> k, t, w
        this.data[p + "_page"] = page
        this.calculatePagination()
        this.updateUrl()
        this.updatePageTag()
    }

    calculatePagination(p){
        p = p || this.data.ktab.substring(0, 1) // -> k, t, w
        this.data[p + "_showResultsFrom"] = (this.data[p + "_page"] - 1) * this.data[p + "_itemsPerPage"]
        this.data[p + "_pageCount"] = Math.ceil(this.data[p + "_items"].length / this.data[p + "_itemsPerPage"])
        let sliceFrom = (this.data[p + "_page"] - 1) * this.data[p + "_itemsPerPage"]
        let sliceTo = this.data[p + "_page"] * this.data[p + "_itemsPerPage"]
        this.data[p + "_showItems"] = this.data[p + "_items"].slice(sliceFrom, sliceTo)
    }

    changeItemsPerPage(itemsPerPage) {
        itemsPerPage = itemsPerPage * 1
        let p = this.data.ktab.substring(0, 1) // -> k, t, w
        let actualPosition = this.data[p + "_itemsPerPage"] * (this.data[p + "_page"] - 1) + 1
        let newPage = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
        this.data[p + "_itemsPerPage"] = itemsPerPage
        this.data[p + "_page"] = newPage
        this.calculatePagination()
        this.updatePageTag()
        this.updateUrl()
    }

    cancelPreviousRequest(){
        this.data.k_activeRequest && Connection.abortRequest(this.data.k_activeRequest)
        this.data.t_activeRequest && Connection.abortRequest(this.data.t_activeRequest)
        this.data.w_activeRequest && Connection.abortRequest(this.data.w_activeRequest)
        this.data.k_isLoading = false
        this.data.t_isLoading = false
        this.data.w_isLoading = false
        this.data.k_activeRequest = null
        this.data.t_activeRequest = null
        this.data.w_activeRequest = null
    }
}

export let KeywordsStore = new KeywordsStoreClass()
