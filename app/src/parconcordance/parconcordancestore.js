const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {AppStore} = require("core/AppStore.js")
const {Connection} = require('core/Connection.js')
const {Router} = require("core/Router.js")
const {TextTypesStore} = require('common/text-types/TextTypesStore.js')

class ParconcordanceStoreClass extends FeatureStoreMixin {
    constructor(){
        super()
        this.feature = "parconcordance"
        this.data = $.extend(this.data, {
            attrs: "word",
            ctxattrs: "word",
            structs: "g",
            refs: "",
            glue: 1,
            refs_up: 0,
            attr_allpos: "all",
            itemsPerPage: 10,
            linenumbers: 0,
            viewmode: "align",
            usesubcorp: '',
            gdex_enabled: 0,
            gdexcnt: 300,
            gdexconf: "",
            formValue: {
                queryselector: 'iquery',
                keyword: '',
                lpos: '',
                wpos: '',
                default_attr: '',
                qmcase: '',
                cql: ''
            },
            formparts: [{
                corpname: "",
                formValue: {
                    queryselector: 'iquery',
                    keyword: '',
                    lpos: '',
                    wpos: '',
                    default_attr: '',
                    qmcase: '',
                    cql: '',
                    filter_nonempty: true,
                    pcq_pos_neg: true
                }
            }],
            operations: [], // breadcrumbs
            defaultattr: "word",
              // ... and the rest
            total: 0,
            aligned: [],
//            aligned_props: {},
            corplist: [],
            results_screen: "parconcordance",
            frompage: 1, // determines from which page the store has data
            sort: [/*{attr:"word", ctx:"0"*/],
            activeRequest: null,
            // filter
            filterTab: "basic",
            filterFrom: -5,
            filterTo: 5,
            filterInclKwic: true,
            pnfilter: "p",
            // frequency
            f_tab: "basic",
            f_items: [],
            f_group: null,
            f_texttypes: [],
            freqShowRel: true,
            freqSort: "freq",
            alignedCorpname: "",
            freqDesc: "",
            freqml: [{
                attr: "word",
                ctx: "0",
                base: "kwic"
            }],
            f_mode: "multilevel",
            f_itemsPerPage: 10,
            //collocations
            c_items: [],
            c_tab: "basic",
            c_funlist: ["t", "m", "3", "l", "s", "d", "p"],
            c_cattr: "word",
            c_cminfreq: 5,
            c_cminbgr: 3,
            c_cfromw: -3,
            c_ctow: 3,
            c_customrange: false,
            c_cbgrfns: ["t", "m", "d"],
            c_csortfn: "d",
            c_onecolumn: 0,
            c_itemsPerPage: 20,
            c_page: 1,
            c_isEmpty: false,
            c_isError: false,
            sortml: [{attr:"word", ctx:"0"}],
        })
        this.isConc = true
        this.isFreq = false
        this.c_hasBeenLoaded = false
        this.defaults = this._copy(this.data)
        this.translations = {
            isLoading: false,
            loaded: false,
            found: false,
            requests: {}
        }
        this.preloadedData = {}
        this.validEmptyOptions = ["refs"]

        this.urlOptions = ["formValue", "attrs", "ctxattrs", "structs", "refs",
                "page", "itemsPerPage", "linenumbers", "viewmode", "formparts",
                "attr_allpos", "tab", "operations", "f_texttypes", "freqSort",
                "freqDesc", "showresults", "f_itemsPerPage", "glue","results_screen",
                "alignedCorpname", "refs_up", "freqml", "f_mode", "f_group", "f_texttypes",
                "gdex_enabled", "gdexcnt", "show_gdex_scores", "usesubcorp"]

        this.xhrOptions = ["attrs", "structs", "refs", "ctxattrs", "viewmode", "usesubcorp", "freqml"]

        this.c_xhrOptions = ["c_cattr", "c_cfromw", "c_ctow", "c_cbgrfns", "c_cminfreq",
                "c_cminbgr", "c_csortfn"]

        this.searchOptions = [
            ["formValue", "pc.formValue"],
            ["refs", "pc.refs"],
            ["page", "pc.page"],
            ["formparts", "pc.formparts"],
            ["viewmode", "pc.viewmode"],
            ["f_texttypes", "textTypes"],
            ["freqSort", "pc.freqSort"],
            ["alignedCorpname", "pc.alignedCorpname"],
            ["freqml", ""],
            ["f_texttypes", "textTypes"],
            ["f_group", "group"]
        ]

        this.userOptionsToSave = ["tab", "attrs", "attr_allpos",
                "structs", "glue", "itemsPerPage", "refs", "refs_up"]
    }

    initResetAndSearch(options){
        this.setDefaultSearchOptions()
        Object.assign(this.data, {
            sort: [],
            page: 1,
            results_screen: "concordance"
        }, options)
        this.operationsInit()
        this.searchAndAddToHistory()
    }

    search(){ // overriden
        this.data.alignedCorpname = ""
        super.search()
        this._initPreloadedDataIfNeeded()
        this.updateRequestData(this.request[0], {
            pagesize: this.corpus.preloaded ? 10000 : 10000000,
            fromp: 1
        })
    }

    cancelPreviousRequest(){ // overriden
        super.cancelPreviousRequest()
        this._cancelTranslationRequests()
    }

    getRequestUrl(){ // overriden
        return window.config.URL_BONITO + "concordance?corpname=" + this.corpus.corpname
    }

    getRequestData(){ // overriden
        let data = super.getRequestData()
        data.fromp = this.data.page
        data.pagesize = this.data.itemsPerPage
        data.concordance_query = this.getParconcordanceQuery()
        data.structs = this.getStructs()

        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    onDataLoaded(payload){ // overriden
        super.onDataLoaded(payload)
        if(!this.data.isEmpty){
            this._checkAndLoadTranslations()
            this._checkAndPreload()
        }
    }

    onDataLoadedProcessItems(payload){ // overriden
        payload.Desc = payload.Desc.filter(item => {
            return item.op != "Switch KWIC"
        })
        this.data.items = payload.Lines
        this.data.gdex_scores = payload.gdex_scores
        this.data.aligned_rtl = payload.Aligned_rtl
        this.data.aligned_corpora = payload.Aligned
        this.data.items.forEach(item => {
            item.ref = item.Tbl_refs.join(" ● ")
            item.Align.length && item.Align.forEach((al, idx) => {
                if(this.isAlignedRtl(idx)){
                    let tmp = al.Left
                    al.Left = al.Right
                    al.Right = tmp
                }
                al.hasKwic = this.data.formparts[idx].formValue.keyword !== ""
            }, this)
        })
    }

    onSubcorpusChange(subcorpus){
        let params = {
            usesubcorp: subcorpus
        }
        this.isConc && this.searchAndAddToHistory(params)
        this.isFreq && this.f_searchAndAddToHistory(params)
        this.isColl && this.c_searchAndAddToHistory(params)
    }

    countItems(payload){ // overriden
        this.data.total =  payload.fullsize
    }

    loadKWICTranslationAndHighlight(alcorp, idx){
        let tokdata = []
        this.data.items.forEach((x, i) => {
            let hitlen = x.hitlen ? x.hitlen : 1
            tokdata.push(x.toknum + ':' + hitlen)
        })
        this.translations.requests[alcorp] = Connection.get({
            url: window.config.URL_BONITO + "translate_kwic?corpname=" + this.corpus.corpname + "&bim_corpname=" + this.prefix + alcorp,
            context: this,
            xhrParams: {
                method: "POST",
                data: "json=" + JSON.stringify({
                    corpname: AppStore.getActualCorpname(),
                    bim_corpname: alcorp,
                    data: tokdata.join('\t')
                })
            },
            done: function(payload){
                if (payload.toknum2words && payload.dict) {
                    this.translations.found = true
                    this.data.items.forEach((x) => { // concordance line
                        let hitlen = x.hitlen ? x.hitlen : 1
                        let poses = []
                        for (let h=0; h<hitlen; h++) {
                            let w = payload.toknum2words[parseInt(x.toknum) + h]
                            if (payload.dict[w]) {
                                let t = payload.dict[w]
                                let pos = this._subInArray(t, x.Align[idx].Kwic)
                                poses = poses.concat(pos)
                            }
                            if (payload.dict[w.toLowerCase()]) {
                                let t = payload.dict[w.toLowerCase()]
                                let pos = this._subInArray(t, x.Align[idx].Kwic)
                                poses = poses.concat(pos)
                            }
                        }
                        for (let p=0; p<poses.length; p++) {
                            x.Align[idx].Kwic[poses[p]].hl = true
                        }
                    })
                }
                this.translations.loaded = true
                delete this.translations.requests[alcorp]
                this.translations.isLoading = !jQuery.isEmptyObject(this.translations.requests)
                if(!this.translations.isLoading){
                    this.translations.handle = setTimeout(function(){
                        $("#parconc_translation").hide()
                    }.bind(this), 5000)
                }
                this.updatePageTag()
            }.bind(this)
        })
    }

    setCorpusDefaults(){ // overriden
        super.setCorpusDefaults()
        this.attrList = []
        this.structList = []
        this.refList = []

        let arrStruct = []
        for (let i = 0; i < this.corpus.structures.length; i++) {
            arrStruct.push(this.corpus.structures[i].name)
        }
        let structures = []
        if (arrStruct.indexOf('s') >= 0) structures.push('s')
        if (this.corpus.is_err_corpus) {
            if (arrStruct.indexOf('err') >= 0) structures.push('err')
            if (arrStruct.indexOf('corr') >= 0) structures.push('corr')
        }
        this.data.structs = structures.join(',')
        this.attrList = this.corpus.attributes.map(a => {
            return {
                value: a.name,
                label: a.label
            }
        })
        this.structList = this.corpus.structures.map(s => {
            return {
                value: s.name,
                label: s.label || s.name
            }
        })
        this.corpus.structures.forEach(s => {
            s.attributes.forEach(a => {
                this.refList.push({
                    value: s.name + "." + a.name,
                    label: a.label ? a.label : s.name + "." + a.name,
                    tt: s.name + "." + a.name + " 0"
                })
            })
        })

        this.data.aligned = []
        this.data.aligned_props = {}
        let langCount = {
            [this.corpus.language_name]: 1
        }
        if(this.corpus.aligned.length){
            this.corpus.aligned_details.forEach(item => {
                langCount[item.language_name] = langCount[item.language_name] ? langCount[item.language_name] + 1 : 1
            })

            this.corpus.aligned_details.forEach((item, idx) => {
                let corpname = this.corpus.aligned[idx]
                let lang = item.language_name
                this.data.aligned.push({
                    value: corpname,
                    label: langCount[lang] > 1 ? (lang + ', ' + item.name) : lang
                })
                this.data.aligned_props[corpname] = {
                    hasLemma: item.has_lemma,
                    hasCase: item.has_case,
                    wposlist: item.Wposlist,
                    lposlist: item.Lposlist,
                    tagsetdoc: item.tagsetdoc
                }
            })
            let sortFunc = (a, b) => {
                return a.label.localeCompare(b.label)
            }
            this.data.corplist = [{ value: this.corpus.corpname,
                    label: this.corpus.language_name
                    }].concat(this.data.aligned).sort(sortFunc)
            this.data.aligned.sort(sortFunc)
            if (!this.data.formparts[0].corpname) {
                this.data.formparts[0].corpname = this.data.aligned[0].value
            }
        }
        this.data.refs = this.corpus.shortref.split(",").reduce((result, ref) => {
            result += result ? "," : ""
            return result += (!ref.startsWith("=") && ref != "#" && ref != this.corpus.docstructure) ? ("=" + ref) : ref
        }, "")
        this.lineDetailsTextTypes = this.data.refs.replace(/=/g, '').split(',').map(ref => {
            return ref += " 0"
        })
    }

    getAllTextTypes(){
        let allTextTypes = []
        this.corpus.freqttattrs.forEach(item => { // parse weird freqttattrs format
            item.split("|").forEach(attr => {
                allTextTypes.push(attr + " 0")
            })
        })
        return allTextTypes
    }

    getStructs(){
        if (this.data.structs.length) {
            if (this.data.glue && this.data.structs.split(',').indexOf("g") < 0) {
                this.data.structs += ",g"
            }
            return this.data.structs
        } else {
            return this.data.glue ? 'g' : ''
        }
    }

    getUserOptions(){ // overriden
        let skip = [ "freqml", "formValue", "formparts", "show_gdex_scores"]
        let userOptions = {}
        this.searchOptions.forEach((option) => {
            let key = option[0]
            if(!skip.includes(key)){
                if(!this.isOptionDefault(key, this.data[key])){
                    let labelId = option[1]
                    if(labelId.startsWith("f_")){
                        labelId = labelId.substr(2)
                    }
                    userOptions[key] = {
                        label: _(labelId, {_: key}),
                        value: this.data[key]
                    }
                }
            }
        }, this)
        this.data.operations.forEach(operation => {
            if(userOptions[operation.name]){
                userOptions[operation.name].value += ", " + (operation.arg || "")
            } else{
                userOptions[operation.name] = {
                    labelId: "cc." + operation.name,
                    value: operation.arg || ""
                }
            }
        })
        if(this.isFreq){
            userOptions.view = {
                labelId: "screen",
                value: _(this.data.results_screen)
            }
            this.data.freqml.forEach((freqml, idx) => {
                userOptions["frequency_" + idx] = {
                    label: "column " + (idx + 1),
                    value: freqml.attr + ", " + freqml.ctx
                }
            })
        }
        return userOptions
    }

    getContextStr(){
        return ""
    }

    getFilterContextStr(ctx, base){
        ctx = this.corpus.righttoleft ? - ctx : ctx
        let ctxStr = ""
        let baseStr = "0"
        if(ctx == 0 && base != "first_kwic_word" && base != "last_kwic_word"){
            if(base == "kwic"){
                ctxStr = "0~0>0"
            } else{
                // nth highlighted collocation
                ctxStr = "0>" + base
            }
        } else {
            if(base == "first_kwic_word"){
                baseStr = "<0"
            } else if(base == "last_kwic_word"){
                baseStr = ">0"
            } else{
                if(base == "kwic"){
                    base = "0"
                }
                if(ctx > 0){
                    baseStr = ">" + base
                } else if(ctx < 0){
                    baseStr = "<" + base
                }
            }
            ctxStr = ctx + baseStr
        }
        return ctxStr
    }

    isAlignedRtl(idx){
        return this.data.aligned_rtl && this.data.aligned_rtl[idx]
    }

    changePage(page){ // overriden
        if(this.isConc){
            this.data.page = page
            this._usePreloadedDataOrSearch()
        }
    }

    changeItemsPerPage(itemsPerPage){ // overriden
        this._setItemsPerPageAndRecalculate(itemsPerPage)
        this._usePreloadedDataOrSearch()
        this.saveUserOptions(this.userOptionsToSave)
    }

    shuffle() {
        this.addOperationAndSearch({
            name: "shuffle",
            query: {
                q: "f"
            }
        })
    }

    randomSample(samplesize) {
        this.addOperationAndSearch({
            name: "sample",
            arg: samplesize,
            query: { q: "r" + samplesize }
        })
    }

    filter(query, description, corpname) {
        this.addOperationAndSearch({
            name: "filter",
            corpname: corpname,
            arg: description,
            query: query
        })
    }

    operationsInit() {
        this.data.operations = []
        let keyword = this.data.formValue.keyword
        let cql = this.data.formValue.cql
        let desc = keyword || cql
        let query = {
            queryselector: (this.data.formValue.queryselector || "iquery") + "row",
            sel_aligned: [],
            cql: cql
        }
        query[this.data.formValue.queryselector || "iquery"] =
                this.data.formValue.queryselector == "cql" ? cql : keyword
        for (let i=0; i<this.data.formparts.length; i++) {
            let c = this.data.formparts[i].corpname
            let f = this.data.formparts[i].formValue
            if (!c) {
                c = this.corpus.aligned[0]
            }
            query["queryselector_" + c] = (f.queryselector || "iquery")
                    + "row"
            query[(f.queryselector || "iquery") + "_" + c] = f.keyword
            if (f.queryselector == "lemma") {
                query["lpos_" + c] = f.lpos
                query["lemma_" + c] = f.keyword
            }
            else if (f.queryselector == "word") {
                query["qmcase_" + c] = f.qmcase
            }
            else if (f.queryselector == "cql") {
                query["default_attr_" + c] = f.default_attr
                query["cql_" + c] = f.cql
            }
            query["pcq_pos_neg_" + c] = f.pcq_pos_neg ? "pos" : "neg"
            query["filter_nonempty_" + c] = f.filter_nonempty ? "on" : ""
            query["sel_aligned"].push(c)
            if (f.keyword) { desc += ", " + (f.keyword || f.cql) }
        }
        this.addOperation({
            name: "iquery",
            arg: desc,
            active: true,
            query: query
        })
        return this.data.operations
    }

    addOperation(operation){
        operation.id = Math.floor((Math.random() * 10000))
        this.data.operations.push(operation)
        this.data.operations.forEach(o => o.active = true)
        this.trigger("operationsChange", this.data.operations)
    }

    addOperationAndSearch(operation){
        this.addOperation(operation)
        this._setResultScreen("concordance")
        this.searchAndAddToHistory({
            page: 1
        })
    }

    removeOperation(operation){
        this.data.operations = this.data.operations.filter(op => {
            return op.id != operation.id
        })
        this.searchAndAddToHistory()
    }

    goToOperation(operation){
        let idx = this.data.operations.findIndex(o => {
            return objectEquals(o, operation)
        })
        this.data.operations.forEach((o, i) => o.active = i <= idx)
        this.searchAndAddToHistory()
        this.trigger("operationsChange", this.data.operations)
    }

    getResultPageObject(){ // overriden
        return Object.assign(super.getResultPageObject(), {
            operations: this.data.operations,
            formparts: this.data.formparts,
            formValue: this.data.formValue
        })
    }

    getParconcordanceQuery() {
        let query = [];
        let operations = this.data.operations
        if(!operations.length){
            operations = this.operationsInit()
        }
        operations.forEach((operation, i) => {
            if(operation.active) {
                if (operation.corpname) {
                    let mycorpname = this.corpus.corpname.split('/').pop()
                    query.push({q: "x-" + operation.corpname.split('/').pop()})
                    query.push(operation.query)
                    if (i != operations.length-1 || !this.data.alignedCorpname) {
                        query.push({q: "x-" + mycorpname})
                    }
                }
                else {
                    query.push(operation.query)
                }
            }
        })
        if (this.data.alignedCorpname) {
            query.push({q: "x-" + this.data.alignedCorpname})
        }
        this.data.sort.length && query.push({
            mlsort_options: this.data.sort
        })
        if (this.data.gdex_enabled) {
            let gc = (!this.data.gdexconf || this.data.gdexconf == "__default__") ? "" : " " + this.data.gdexconf
            query.push({
                q: (this.data.show_gdex_scores ? "E" : "e") + this.data.gdexcnt + gc
            })
        }
        this._addTextTypesToQuery(query[0])
        return query
    }

    findLang(corpname) {
        if (corpname) {
            for (let i=0; i < this.data.aligned.length; i++) {
                if (this.data.aligned[i].value == corpname) {
                    return this.data.aligned[i].label
                }
            }
        }
        return ""
    }

    findUnused(options) {
        let unused = ''
        for (let i=0; i<this.data.aligned.length; i++) {
            let f = false
            if (this.data.corpname == this.data.aligned[i].value) {
                i += 1
                continue
            }
            for (let j=0; j<options.formparts.length; j++) {
                if (options.formparts[j].corpname == this.data.aligned[i].value) {
                    f = true
                    break
                }
            }
            if (!f) {
                unused = this.data.aligned[i].value
                break
            }
        }
        return unused
    }

    goBackToTheConcordance(){
        // from subfeature collocations / frequency
        Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "")
        this.request = this.Crequest
        this.changeResultScreen("concordance")
        this.updateUrl(true)
    }

    changeResultScreen(results_screen){
        if(this.data.results_screen != results_screen){
            this._setResultScreen(results_screen)
            this.updatePageTag()
            if(this.isConc && this.data.showresults && !this.hasBeenLoaded){
                this.search()
            }
        }
    }

    onPrimaryCorpusChange(corpname){
        AppStore.checkAndChangeCorpus(this.addPrefixTocorpname(corpname))
    }

    addPrefixToCorpname(corpname){
        if(!corpname.startsWith("preloaded") && !corpname.startsWith("user")){
            let actFullCorpname = AppStore.getActualCorpname() // get preloaded/user prefix
            return actFullCorpname.substr(0, actFullCorpname.lastIndexOf("/") + 1) + corpname
        }
        return corpname
    }

    _setResultScreen(results_screen){
        this.data.results_screen = results_screen
        this.isConc = results_screen == "concordance"
        this.isFreq = results_screen == "frequency"
        this.isColl = results_screen == "collocations"
    }

    // function taken from Bonito misc.js
    _subInArray(item, list) {
        let retlist = []
        let ranklist = []
        let minj = 100
        for (let i=0; i<list.length; i++) {
            if(list[i].str){ //  there could be only strc
                let llitem = list[i].str.toLowerCase()
                for (let j=0; j<item.length; j++) {
                    if (item[j].length < 3) { // skip short translations (I, in, on)
                        continue
                    }
                    let lpos = llitem.indexOf(item[j].toLowerCase())
                    if (lpos > -1) {
                        if (j < minj) minj = j
                        retlist.push(i)
                        ranklist.push(j)
                        break
                    }
                }
            }
        }
        // remove all but the highest-scored translations
        let finallist = []
        for (let i=0; i<retlist.length; i++) {
            if (ranklist[i] == minj) {
                finallist.push(retlist[i]);
            }
        }
        return finallist
    }

    _addTextTypesToQuery(query) {
        let s = TextTypesStore.get('selection')
        for (let tt in s) {
            query["sca_" + tt] = s[tt]
        }
    }

    _setDataFromUrl(query){ // overriden
        super._setDataFromUrl(query)
        if(query.operations){
            this.data.operations = JSON.parse(query.operations)
        }
        this._setResultScreen(query.results_screen || "concordance")
    }

    _getQueryObject(dataIn){ // overriden
        let data = dataIn || this.data
        let queryObject = super._getQueryObject(data)
        if(data.operations){
            queryObject.operations = JSON.stringify(data.operations)
        }
        if(this.data.formparts){
            queryObject.formparts = JSON.stringify(data.formparts)
        }
        if(this.data.formValue){
            queryObject.formValue = JSON.stringify(data.formValue)
        }
        return queryObject
    }

    _onCorpusChange(){ // overriden
        this._setResultScreen("concordance")
        super._onCorpusChange()
        if(this.corpus){
            this.prefix = this.corpus.preloaded ? "preloaded/" : (this.corpus.corpname.split('/', 2).join('/') + '/')
            this.pageTag && this.pageTag.isMounted && this.updateUrl(true)
            this.trigger("change")
        }
    }

    _onPageChange(pageId, query) { // overriden
        if (this._isActualFeature()) {
            this._cancelRequestResetOptions()
            if(query){
                this._setDataFromUrl(query)
                this.trigger("change")
            }
            AppStore.changeActualFeatureStore(this)
            if(this._isShowingResults()){
                // user navigated to the result page -> load results
                this.isConc && this.search()
            }
        } else{
            this.cancelPreviousRequest()
        }
    }

    _initPreloadedDataIfNeeded(){
        let data = this._parseRequestData(this.data.activeRequest)
        delete data.fromp
        delete data.pagesize
        if(!this.preloadedData.requestedData
                // preloaded request is not same (excluding fromp and pagesize) as actual request
                || !window.objectEquals(data, this.preloadedData.requestedData)){
            this.preloadedData = {
                requestedData: data
            }
        }
    }

    _checkAndPreload(){
        // check, if some data souhld be preloaded (after inital data load, or page change)
        let startIdx = (this.data.page - 1) * this.data.itemsPerPage
        let thousand = Math.floor(startIdx / 1000)
        if(!this.preloadedData[thousand]){
            this._preloadMoreData(thousand)
        }
        let treshold = Math.max(200, this.data.itemsPerPage * 3)
        if((startIdx >= 1000 && (startIdx % 1000 < treshold)) && !this.preloadedData[thousand - 1]){
            this._preloadMoreData(thousand - 1)
        }
        if((startIdx % 1000 > (1000 - treshold)) && !this.preloadedData[thousand + 1]){
            this._preloadMoreData(thousand + 1)
        }
    }

    _usePreloadedDataOrSearch(){
        let startIdx = (this.data.page - 1) * this.data.itemsPerPage
        let thousand = Math.floor(startIdx / 1000)
        let endIdx = this.data.page * this.data.itemsPerPage - 1
        if(this.preloadedData[thousand] && this.preloadedData[thousand].data){
            this.data.items = this.preloadedData[thousand].data.slice(startIdx % 1000, endIdx % 1000)
            this.translations.loaded = false
            this._cancelTranslationRequests()
            this._checkAndPreload()
            this._checkAndLoadTranslations()
            this.updatePageTag()
            this.updateUrl()
        } else{
            this.searchAndAddToHistory()
        }
    }

    _preloadMoreData(thousand=0){
        if(this.preloadedData[thousand]){
            return
        }
        this.preloadedData[thousand] = {}
        let request = copy(this.request[0])
        this.updateRequestData(request, {
            pagesize: 1000,
            fromp: (thousand || 0) + 1
        })

        this.preloadedData[thousand].request = Connection.get({
            url: request.url,
            xhrParams: request.xhrParams,
            done: function(thousand, payload){
                payload.Lines.forEach(item => {
                    item.ref = item.Tbl_refs.join(" ● ")
                })
                this.preloadedData[thousand].data = payload.Lines
            }.bind(this, thousand)
        })
    }

    _checkAndLoadTranslations(){
        if (this.hasBeenLoaded
                && this.isConc
                && !this.translations.loaded
                && !this.isLoading
                && !this.data.formparts[0].formValue.keyword
                && !this.data.formparts[0].formValue.cql
                && jQuery.isEmptyObject(this.translations.requests)){
            this.translations.isLoading = true
            this.translations.loaded = true
            this.translations.found = false
            for (let i = 0; i < this.data.formparts.length; i++) {
                this.loadKWICTranslationAndHighlight(this.data.formparts[i].corpname, i)
            }
        }
    }

    _cancelTranslationRequests(){
        for(let key in this.translations.requests){
            this.translations.requests[key].xhr.abort()
            delete this.translations.requests[key]
        }
        this.translations.loaded = false
        this.translations.isLoading = false
        this.translations.handle && clearTimeout(this.translations.handle)
    }

    f_searchAndAddToHistory(options, params){
        this._setNonEmptyOptions(options)
        this.f_search(params)
        this.updateUrl(true, true)
    }

    f_search(){
        this.changeResultScreen("frequency")
        this.cancelPreviousRequest()
        this.data.isLoading = true
        this.updatePageTag()
        this.data.activeRequest = Connection.get({
            url: window.config.URL_BONITO + (this.data.f_mode == "texttypes" ? "freqs" : "freqml") + '?corpname=' + this.corpus.corpname,
            xhrParams: {
                method: 'POST',
                data: this.f_getRequestData()
            },
            done: this.f_onDataLoadDone.bind(this),
            fail: this.onDataLoadFail.bind(this),
            always: this.onDataLoadAlways.bind(this)
        })
        this.Crequest = this.request
        this.request = [this.data.activeRequest]
    }

    f_getRequestData() {
        let data = {
            corpname: this.corpus.corpname,
            format: "json",
            freq_sort: this.data.freqSort,
            fmaxitems: 5000, // TODO: user data without limit?
            concordance_query: this.getParconcordanceQuery(),
            group: this.data.f_group
        }
        if(this.data.f_mode == "texttypes") {
            data.fcrit = this.data.f_texttypes
        } else if(this.data.f_mode == "multilevel"){
            let ctxStr
            data.freqlevel = 0
            this.data.freqml.forEach((freq, idx) => {
                data.freqlevel++
                data["ml" + (idx + 1) + "attr"] = freq.attr
                data["ml" + (idx + 1) + "ctx"] = this.getFilterContextStr(freq.ctx, freq.base)
            })
        }
        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    f_onDataLoadDone(payload){
        if(this.isFreq){
            this.f_hasBeenLoaded = false
            this.data.f_items = []
            this.data.f_error = ''
            this.data.f_isEmpty = true
            this.data.f_isError = false
            if(payload.error){
                this.data.f_error = payload.error
                this.data.f_isError = true
                this.showError(payload.error)
            } else{
                this.data.f_items = payload.Blocks
                this.data.f_isEmpty = this.data.f_items.length == 0
                if(!this.data.f_isEmpty){
                    this.f_hasBeenLoaded = true
                    this.addResultToHistory()
                    this.saveUserOptions(this.userOptionsToSave)
                } else {
                    this.showEmptyResultMessage()
                }
            }
            if(!this.data.f_isError){
                Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
            }
        }
    }

    f_getLink(data, mode, f_tab){
        let concQueryObj = this._getQueryObject(Object.assign({}, this.data, {
            f_tab: f_tab,
            f_texttypes: [],
            freqml: [{
                attr: "word",
                ctx: "0",
                base: "kwic"
            }],
            f_page: 1,
            f_mode: mode
        }, data))
        concQueryObj.results_screen = "frequency"
        return Router.createUrl("parconcordance", concQueryObj)
    }

    f_getContextLink(ctx, base, attr, alignedCorpname, f_tab){
        let data = {
            freqml: [{
                attr: attr,
                ctx: ctx,
                base: base
            }],
            freqDesc: attr + " " + ctx
        }
        if(alignedCorpname){
            data.alignedCorpname = alignedCorpname
        }
        return this.f_getLink(data, "multilevel", f_tab)
    }

    f_getLineDetailsTextTypes(){
        let texttypes = this.data.refs.split(",").filter(ref => {
            return ref !== "" && ref != "#" && ref != this.corpus.docstructure
        }, this).map(ref => {
            return (ref.startsWith("=") ? ref.substr(1) : ref) + " 0"
        }).join(" ")
        return texttypes !== "" ? [texttypes] : []
    }


    c_searchAndAddToHistory(options){
        this._setNonEmptyOptions(options)
        this.c_search()
        this.updateUrl(true, true)
    }

    c_search(){
        this.changeResultScreen("collocations")
        this.cancelPreviousRequest()
        this.data.isLoading = true
        this.updatePageTag()

        this.data.activeRequest = Connection.get({
            url: window.config.URL_BONITO + "collx?corpname=" + this.corpus.corpname,
            xhrParams: {
                method: "POST",
                data: this.c_getRequestData()
            },
            done: this.c_onDataLoadDone.bind(this),
            fail: this.onDataLoadFail.bind(this),
            always: this.onDataLoadAlways.bind(this)
        })
        this.Crequest = this.request
        this.request = [this.data.activeRequest]
    }

    c_getRequestData(cmaxitems, collpage) {
        let page = isDef(collpage) ? collpage : this.data.collpage
        if(!isDef(cmaxitems)){
            // calculate page and cmaxitems, so at least MIN_ITEMS rows are loaded
            let MIN_ITEMS = 2000;
            let middleIndex = Math.round((this.data.c_page - 0.5) * this.data.c_itemsPerPage) // index of item in the middle of displayed data
            let min = middleIndex - MIN_ITEMS / 2
            if(min < 0){min = 0}
            let remainderToDivide = min % MIN_ITEMS
            let fullSpansCount = Math.floor(min / MIN_ITEMS)
            let restPart = Math.floor(remainderToDivide / (fullSpansCount * 2 + 1))
            cmaxitems = MIN_ITEMS + restPart * 2
            page = Math.floor(min / cmaxitems) + 1
        }

        let data = {
            "corpname": AppStore.getActualCorpname(),
            "format": "json",
            "usesubcorp": this.data.usesubcorp,
            "concordance_query": this.getParconcordanceQuery(),
            "cmaxitems": cmaxitems,
            "collpage": page,
        }
        this.data.c_loadedFrom = (page - 1) * cmaxitems
        this.c_xhrOptions.forEach(attr => {
            if(isDef(this.data[attr])){
                data[attr.substr(2)] = this.data[attr]
            }
        })
        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    c_onDataLoadDone(payload){
        if(this.isColl){
            this.request[0].xhrParams.data = this.c_getRequestData(payload.wllimit || 10000000, 1)
            this.c_hasBeenLoaded = false
            this.data.c_items = []
            this.data.c_error = ''
            this.data.c_isEmpty = true
            this.data.c_isError = false
            if(payload.error){
                this.data.c_error = payload.error
                this.data.c_isError = true
                this.showError(payload.error)
            } else{
                this.data.c_items = payload.Items
                this.data.c_lastpage = payload.lastpage
                this.data.c_isEmpty = this.data.c_items.length == 0
                this.data.c_total = this.data.c_items.length + this.data.c_loadedFrom
                this.c_calculatePagination()
                if(!this.data.c_isEmpty){
                    this.c_hasBeenLoaded = true
                    this.addResultToHistory()
                    this.saveUserOptions(this.userOptionsToSave)
                } else {
                    this.showEmptyResultMessage()
                }
            }
            if(!this.data.c_isError){
                Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
            }
        }
    }

    c_changePage(page){
        if(!this.data.activeRequest){
            this.data.c_page = page
            this.c_calculatePagination()
            this.updateUrl()
            this.updatePageTag()
        }
    }

    c_changeItemsPerPage(itemsPerPage) {
        this.c_setItemsPerPageAndRecalculate(itemsPerPage)
        this.c_calculatePagination()
        this.updateUrl()
        this.saveUserOptions(["c_itemsPerPage"])
        this.updatePageTag()
    }

    c_calculatePagination() {
        if(Array.isArray(this.data.c_items)){
            let actualPosition = (this.data.c_page - 1) * this.data.c_itemsPerPage
            let cFrom = actualPosition - this.data.c_loadedFrom
            let cTo = (actualPosition + this.data.c_itemsPerPage) - this.data.c_loadedFrom
            this.data.c_showResultsFrom = actualPosition
            this.data.c_showItems = this.data.c_items.slice(cFrom, cTo)
            if((!this.data.c_lastpage && ((actualPosition + this.data.c_itemsPerPage) > this.data.c_total))
                || (actualPosition < this.data.c_loadedFrom)){
                this.c_search()
            }
        }
    }

    c_setItemsPerPageAndRecalculate(itemsPerPage){
        itemsPerPage = itemsPerPage * 1
        let actualPosition = this.data.c_itemsPerPage * (this.data.c_page - 1) + 1
        let newPage = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
        this.data.c_itemsPerPage = itemsPerPage
        this.data.c_page = newPage
    }

    c_getFunLabel(fun){
        return {
            "3": "MI3",
            "d": "logDice",
            "l": "log likelihood",
            "m": "MI",
            "p": "MI.log_f",
            "s": "min. sensitivity",
            "t": "T-score"
        }[fun] || ""
    }
}

export let ParconcordanceStore = new ParconcordanceStoreClass()
