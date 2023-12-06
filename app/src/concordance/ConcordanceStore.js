const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {AppStore} = require("core/AppStore.js")
const {Router} = require("core/Router.js")
const {AsyncResults} = require("core/asyncresults.js")
const {TextTypesStore} = require('common/text-types/TextTypesStore.js')
const {Connection} = require('core/Connection.js')
const {Auth} = require('core/Auth.js')


class ConcordanceStoreClass extends FeatureStoreMixin {

    constructor(){
        super()
        this.feature = "concordance"
        this.data = $.extend(this.data, {
            attr_allpos: "all",
            show_as_tooltips: false,
            iquery: "",
            queryselector: "iquery",
            keyword: "",
            cql: "",
            cb: "",
            searchdesc: "",
            lpos: "",
            wpos: "",
            qmcase: 0,
            attrs: "word",
            ctxattrs: "word",
            default_attr: "",
            structs: "",
            refs: "#",
            fc_lemword_window_type: "both",
            fc_lemword_wsize: 5,
            fc_lemword: "",
            fc_lemword_type: "all",
            fc_pos_window_type: "both",
            fc_pos_wsize: 5,
            fc_pos: [],
            fc_pos_type: "all",
            usesubcorp: "",
            errcorr_switch: "err",
            cup_err_code: "",
            cup_err: "",
            cup_corr: "",
            cup_hl: "q",
            viewmode: "kwic",
            page: 1,
            linenumbers: 1,
            checkboxes: 1,
            fullcontext: 0,
            glue: 1,
            refs_up: 0,
            shorten_refs: 1,
            ref_size: 15,
            gdex_enabled: 0,
            gdexcnt: 300,
            gdexconf: "",
            show_gdex_scores: 0,
            sort: [],
            selection: [],
            random: 0,
            results_screen: "concordance",
            act_opts: "", // opened result options
            itemsPerPage: 20,
            operations: [], // operations of operations - shown in breadcrumbs
            operations_annotconc: [],
            isCountLoading: false,
            showcontext: "none", // "none" | "lemma" | "pos"
            showTBL: false,
            tbl_template: "",
            ///// frequency
            f_items: [],
            f_tab: "basic",
            f_freqml: [{
                attr: "word",
                ctx: "0",
                base: "kwic"
            }],
            f_showrelfrq: 1,
            f_mode: "multilevel",
            f_sort: "freq",
            f_itemsPerPage: 20,
            f_page: 1,
            f_texttypes: [],
            f_isEmpty: false,
            f_isError: false,
            f_group: null,
            ///// collocations
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
            c_showresults: false,
            c_isEmpty: false,
            c_isError: false,
            annotconc: "",
            annotation_group: "",
            storedconcs: [],
            labels: {},
            annotLabels: []
        })

        this.isConc = true
        this.isFreq = false
        this.isColl = false
        this.f_hasBeenLoaded = false
        this.c_hasBeenLoaded = false
        this.asyncResults = new AsyncResults()
        this.defaults = this._copy(this.data)
        this.preloadedData = {}
        this.validEmptyOptions = ["refs"]
        this.selectedLines = []

        this.urlOptions = ["queryselector", "keyword", "lpos", "wpos", "attrs", "viewmode",
                "attr_allpos", "linenumbers", "refs_up", "shorten_refs", "fc_lemword_window_type",
                "fc_lemword_wsize", "fc_lemword", "fc_lemword_type", "glue", "fc_pos_window_type",
                "fc_pos_window_type", "fc_pos_wsize", "fc_pos_type", "fc_pos", "gdex_enabled",
                "gdexcnt", "show_gdex_scores", "page", "itemsPerPage", "random", "structs",
                "refs", "attrs", "qmcase", "default_attr", "cql", "searchdesc", "sort",
                "selection", "usesubcorp", "showresults", "tab", "showcontext", "cup_err",
                "cup_hl", "cup_corr", "cup_err_code", "errcorr_switch", "results_screen", "act_opts",
                "tts", "showTBL", "tbl_template", "gdexconf", "checkboxes", "cb", "fullcontext",
                //frequency
                "f_freqml", "f_tab", "f_showrelfrq", "f_mode", "f_itemsPerPage",
                "f_page", "f_sort", "f_texttypes", "f_group",
                // collocations
                "c_funlist", "c_cattr", "c_cminfreq", "c_cminbgr", "c_cfromw", "c_ctow",
                "c_cbgrfns", "c_csortfn", "c_page", "c_itemsPerPage", "c_showresults", "c_customrange",
                // annotations
                "annotconc"]

        this.xhrOptions = ["reload", "lpos", "wpos", "default_attr", "attrs", "refs",
                "ctxattrs", "attr_allpos", "usesubcorp", "viewmode", "cup_hl", "cup_err",
                "cup_corr", "cup_err_code", "structs", "annotconc",
                "annotation_group"]

        this.c_xhrOptions = ["c_cattr", "c_cfromw", "c_ctow", "c_cbgrfns", "c_cminfreq",
                "c_cminbgr", "c_csortfn"]

        this.searchOptions = [
                ["iquery", "cc.iquery"],
                ["queryselector", "cc.queryselector"],
                ["keyword", "keyword"],
                ["cql", "cql"],
                ["lpos", "pos"],
                ["wpos", "pos"],
                ["qmcase", "ignoreCase"],
                ["default_attr", "cc.default_attr"],
                ["fc_lemword_window_type", "cc.fc_lemword_window_type"],
                ["fc_lemword_wsize", "cc.fc_lemword_wsize"],
                ["fc_lemword", "cc.fc_lemword"],
                ["fc_lemword_type", "cc.fc_lemword_type"],
                ["fc_pos_window_type", "cc.fc_pos_window_type"],
                ["fc_pos_wsize", "cc.fc_pos_wsize"],
                ["fc_pos", "cc.fc_pos"],
                ["fc_pos_type", "cc.fc_pos_type"],
                ["usesubcorp", "subcorpus"],
                ["showcontext", "showcontext"],
                //frequency
                ["f_freqml", ""],
                ["f_group", "group"],
                ["f_showrelfrq", ""],
                ["f_texttypes", "textTypes"],
                //collocations
                ["c_cattr", "attribute"],
                ["c_cminfreq", "col.cminfreq"],
                ["c_cminbgr", "col.cminbgr"],
                ["c_cfromw", ""],
                ["c_ctow", ""],
                ["c_cbgrfns", "functions"],
                ["c_csortfn", "sort"]
        ]

        this.userOptionsToSave = ["tab", "viewmode", "attrs", "attr_allpos",
                "structs", "glue", "itemsPerPage", "ref_size", "refs", "refs_up",
                "shorten_refs", "show_as_tooltips", "showTBL", "tbl_template",
                "c_customrange", "f_tab", "c_tab"]

        this.linkIcons = {
            audio: "play_circle_outline",
            video: "ondemand_video",
            image: "image",
            unknown: "open_in_new"
        }
    }

    initResetAndSearch(options){
        this.setDefaultSearchOptions()
        this._setResultScreen("concordance")
        Object.assign(this.data, {
            sort: [],
            page: 1
        }, options)
        this.operationsInit()
        this.searchAndAddToHistory()
    }

    search(params){  // overriden
        this.selectedLinesDeselectAll()
        this.trigger("selectedLinesChanged")
        super.search(params)
        this._initPreloadedDataIfNeeded()
        if (this.data.annotconc) {
            AppStore.data.annotconc = this.data.annotconc
        }
        this.updateRequestData(this.request[0], {
            pagesize: this.corpus.preloaded ? 10000 : 10000000,
            fromp: 1
        })
    }

    getRequestUrl(){ // overriden
        return window.config.URL_BONITO + "concordance?corpname=" + this.corpus.corpname
    }

    getRequestData(dataIn){ // overriden
        let data = super.getRequestData()
        data.fromp = this.data.page
        data.pagesize = this.data.itemsPerPage
        data.concordance_query = this.getConcordanceQuery()
        data.kwicleftctx = "100#"
        data.kwicrightctx = "100#"
        data.ctxattrs = this.data.attr_allpos == "all" ? this.data.attrs : "word"
        data.structs = this.getStructs()
        data.annotation_group = Auth.getAnnotationGroup()
        data = Object.assign(data, dataIn || {})
        if(this.data.showTBL && this.data.tbl_template){
            data.tbl_template = this.data.tbl_template
        }
        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    onDataLoadedProcessItems(payload){ // overriden
        this.data.items = payload.Lines
        this.data.gdex_scores = payload.gdex_scores
        this.data.relsize = payload.relsize
        this.data.fullsize = payload.fullsize
        this.data.items.forEach(item => {
            item.ref = item.Refs.join(" ● ")
            item.Links.forEach(link => {
                link.icon = this.linkIcons[link.mediatype]
            })
        })
    }

    onDataLoaded(payload){ // overriden
        super.onDataLoaded(payload)
        if(!this.data.isEmpty){
            this._checkResultCount(payload)
            this._checkAndPreload()
        }
        if (this.data.annotconc) {
            this.getAnnotLabels()
        }
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

    getConcordanceQuery(){
        let query = []
        if (this.data.annotconc) {
            let operations_annotconc = this.data.operations_annotconc
            if (!operations_annotconc.length) {
                operations_annotconc = this.operationsAnnotconcInit()
            }
            operations_annotconc.forEach((o) => {
                o.active && query.push(o.query)
            })
            if (this.data.gdex_enabled) {
                let gc = ""
                if (!this.data.gdexconf || this.data.gdexconf == "__default__") {
                    gc = ""
                }
                else {
                    gc = " " + this.data.gdexconf
                }
                query.push({
                    q: (this.data.show_gdex_scores ? "E" : "e") + this.data.gdexcnt + gc
                })
            }
            return query
        }
        let operations = this.data.operations
        if(!operations.length){
            operations = this.operationsInit()
        }
        operations.forEach((operation) => {
            operation.active && query.push(operation.query)
        })
        this.data.sort.length && query.push({
            mlsort_options: this.data.sort
        })
        if (this.data.gdex_enabled) {
            let gc = ""
            if (!this.data.gdexconf || this.data.gdexconf == "__default__") {
                gc = ""
            }
            else {
                gc = " " + this.data.gdexconf
            }
            query.push({
                q: (this.data.show_gdex_scores ? "E" : "e") + this.data.gdexcnt + gc
            })
        }
        Object.assign(query[0], TextTypesStore.getSelectionQuery())
        if(this.data.random == 1){
            query[0].random = 1
        } else{
            delete query[0].random
        }

        return query
    }

    changeResultScreen(results_screen){
        if(this.data.results_screen != results_screen){
            this._setResultScreen(results_screen)
            this.selectedLinesDeselectAll()
            this.updatePageTag()
            if(this.data.showresults && !this.hasBeenLoaded){
                this.search()
            }
        }
    }

    operationsAnnotconcInit() {
        this.data.operations_annotconc = []
        let query = {
            q: 's' + this.data.annotconc
        }
        this.addOperation({
            name: "annotate",
            arg: this.data.annotconc,
            active: true,
            query: query
        })
        if (this.data.cql && this.data.cql.length) {
            this.addOperation({
                name: "word sketch",
                arg: this.data.cql,
                active: true,
                query: {
                    queryselector: "cql",
                    cql: this.data.cql
                }
            })
        }
        return this.data.operations_annotconc
    }

    operationsInit(){
        this.data.operations = []
        let queryselector = this.data.queryselector
        let val = this.data[queryselector == "cql" ? "cql" : "keyword"]
        let desc = this.data.searchdesc
        let query = {
            queryselector: queryselector + "row",
            [queryselector]: val
        }
        if(queryselector == "lemma"){
            query.lpos = this.data.lpos
        }
        if(queryselector == "lemma" || queryselector == "phrase" || queryselector == "word"){
            query.qmcase = this.data.qmcase
        }
        if(queryselector == "cql"){
            query.default_attr = this.data.default_attr
        }
        this.addOperation({
            name: queryselector,
            arg: desc ? desc : val,
            active: true,
            query: query
        })
        this._addContextToOperations()
        return this.data.operations
    }

    addOperation(operation){
        operation.id = Math.floor((Math.random() * 10000))
        if (this.data.annotconc) {
            this.data.operations_annotconc.push(operation)
            this.data.operations_annotconc.forEach(o => o.active = true)
            this.trigger("operationsChange", this.data.operations_annotconc)
        }
        else {
            this.data.operations.push(operation)
            this.data.operations.forEach(o => o.active = true)
            this.trigger("operationsChange", this.data.operations)
        }
    }

    addOperationAndSearch(operations){
        if(Array.isArray(operations)){
            operations.forEach(operation => {
                this.addOperation(operation)
            })
        } else{
            this.addOperation(operations)
        }
        this.searchAndAddToHistory({
            page: 1,
            results_screen: "concordance"
        })
    }

    removeOperation(operation){
        if (this.data.annotconc) {
            this.data.operations_annotconc = this.data.operations_annotconc.filter(op => {
                return op.id != operation.id
            })
        }
        else {
            this.data.operations = this.data.operations.filter(op => {
                return op.id != operation.id
            })
        }
        this.searchAndAddToHistory()
    }

    goToOperation(operation){
        if (this.data.annotconc) {
            let idx = this.data.operations_annotconc.findIndex(o => {
                return objectEquals(o, operation)
            })
            this.data.operations_annotconc.forEach((o, i) => o.active = i <= idx)
            this.searchAndAddToHistory()
            this.trigger("operationsChange", this.data.operations_annotconc)
        }
        else {
            let idx = this.data.operations.findIndex(o => {
                return objectEquals(o, operation)
            })
            this.data.operations.forEach((o, i) => o.active = i <= idx)
            this.searchAndAddToHistory()
            this.trigger("operationsChange", this.data.operations)
        }
    }

    getAnnotations() {
        let corpname = this.corpus.corpname
        Connection.get({
            url: window.config.URL_BONITO + 'storedconcs?corpname=' + corpname,
            xhrParams: {
                data: {
                    annotation_group: Auth.getAnnotationGroup()
                }
            },
            done: function (payload) {
                if (payload.stored_concs) {
                    this.data.storedconcs = payload.stored_concs.map(x => {
                        return x.conc
                    })
                    this.trigger("ANNOTATIONS_UPDATED")
                }
            }.bind(this),
            fail: function (data) {
                console.log('FAILED', data)
            }
        })
    }

    addLabelExample(item) {
        let l = item.Left.filter(p => { return p.str })
        let k = item.Kwic.filter(p => { return p.str })
        let r = item.Right.filter(p => { return p.str })
        let example = l.map(p => {return p.str.trim()}).join(' ') + ' '
                + k.map(p => {return p.str.trim()}).join(' ') + ' '
                + r.map(p => {return p.str.trim()}).join(' ')
        localStorage.setItem('SKEMA_NEW_EXAMPLE', JSON.stringify({
            example: example,
            annotconc: this.data.annotconc,
            corpname: this.corpus.corpname,
            toknum: item.toknum,
            label: item.linegroup
        }))
    }

    getAnnotLabels() {
        if (!this.data.annotconc) return
        Connection.get({
            url: window.config.URL_BONITO + "lngroupinfo?corpname=" + this.corpus.corpname,
            xhrParams: {
                data: {
                    annotconc: this.data.annotconc,
                    annotation_group: Auth.getAnnotationGroup(),
                }
            },
            done: function (payload) {
                if (payload.error) {
                    console.log('FAILED', payload.error)
                }
                else {
                    this.data.annotLabels = payload.labels
                    for (let i=0; i<payload.labels.length; i++) {
                        this.data.labels[payload.labels[i].id] = payload.labels[i].name
                    }
                    Dispatcher.trigger("ANNOTATION_LABELS_UPDATED")
                }
            }.bind(this),
            fail: function(payload) {
                console.log('FAILED', payload)
            }
        })
    }

    addLabel(label) {
        Connection.get({
            url: window.config.URL_BONITO + "addlngroup?corpname=" + this.corpus.corpname,
            xhrParams: {
                data: {
                    annotconc: this.data.annotconc,
                    annotation_group: Auth.getAnnotationGroup(),
                    label: label
                }
            },
            done: function (payload) {
                if (payload.error) {
                    console.log('FAILED', payload.error)
                }
                else {
                    if (payload.labels) {
                        localStorage.setItem('SKEMA_NEW_LABEL', this.data.annotconc)
                        this.data.annotLabels = payload.labels
                        for (let i=0; i<payload.labels.length; i++) {
                            this.data.labels[payload.labels[i].id] = payload.labels[i].name
                        }
                    }
                    Dispatcher.trigger("ANNOTATION_LABELS_UPDATED")
                }
            }.bind(this),
            fail: function (payload) {
                console.log('FAILED', payload)
            }
        })
    }

    initAnnotation(storeconcname) {
        Connection.get({
            url: window.config.URL_BONITO + "storeconc?corpname=" + this.corpus.corpname,
            xhrParams: {
                method: "POST",
                data: this.getRequestData({
                    concordance_query: this.getConcordanceQuery(),
                    annotation_group: Auth.getAnnotationGroup(),
                    storeconcname: storeconcname
                })
            },
            done: function(payload) {
                if (payload.error) {
                    this.showError(payload.error)
                }
                else {
                    if (payload.new) {
                        LocalStorage.set("SKEMA_NEW_QUERY", payload.stored)
                        Dispatcher.trigger("ANNOTATION_CREATED")
                    }
                    this.loadAnnotation(payload.stored)
                }
            }.bind(this),
            fail: function (payload) {
                console.log('FAILED', payload)
            }
        })
    }

    loadAnnotation(storedconc) {
        this.data.annotconc = storedconc
        AppStore.data.annotconc = storedconc
        this.data.showresults = true
        this.data.operations_annotconc = [{
            name: "annot",
            arg: storedconc,
            active: true,
            query: {q: 's' + storedconc}
        }]
        this.changeResultScreen("concordance")
        this.updateUrl(true)
        this.search()
    }

    delAnnotation(annotconc) { // called from dashboard
        Connection.get({
            url: window.config.URL_BONITO + "/delstored?corpname=" + this.corpus.corpname,
            xhrParams: {
                data: {
                    annotconc: annotconc,
                    annotation_group: Auth.getAnnotationGroup()
                }
            },
            done: function (payload) {
                if (payload.removed) {
                    LocalStorage.set("SKEMA_QUERY_REMOVED", payload.removed)
                    SkE.showToast(_("annotRemoved") + ": " + payload.removed)
                    this.data.storedconcs = this.data.storedconcs.filter(x => {
                        return x != payload.removed
                    })
                    this.trigger("ANNOTATION_REMOVED")
                }
                else {
                    console.log('FAILED', payload)
                }
            }.bind(this),
            fail: function (payload) {
                console.log('FAILED', payload)
            }
        })
        this.data.annotconc = ""
        AppStore.data.annotconc = ""
    }

    closeAnnotation() {
        this.data.annotconc = ""
        AppStore.data.annotconc = ""
        this.data.operations_annotconc = []
        Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "")
        this.data.hasBeenLoaded = false
        if (this.data.operations.length) {
            this.search()
        }
        else {
            Dispatcher.trigger("ROUTER_GO_TO", "concordance", {
                showresults: false,
                corpname: this.corpus.corpname,
                tab: this.data.tab
            })
        }
    }

    updateLabels(toknums, lid) {
        for (let i=0; i<toknums.length; i++) {
            for (let j=0; j<this.data.items.length; j++) {
                if (this.data.items[j].toknum == toknums[i]) {
                    this.data.items[j].linegroup_id = lid
                }
            }
            Object.keys(this.preloadedData).forEach((key) => {
                if (!isNaN(key)) {
                    let lines = this.preloadedData[key].data
                    for (let j=0; j<lines.length; j++) {
                        if (lines[j].toknum == toknums[i]) {
                            lines[j].linegroup_id = lid
                        }
                    }
                }
            })
        }
    }

    labelToknums(toknums, lid) {
        Connection.get({
            url: window.config.URL_BONITO + "/setlngroup?corpname=" + this.corpus.corpname,
            xhrParams: {
                data: {
                    annotconc: this.data.annotconc,
                    annotation_group: Auth.getAnnotationGroup(),
                    toknum: toknums.join(" "),
                    group: lid
                }
            },
            done: function (payload) {
                if (payload.count) {
                    this.updateLabels(toknums, lid)
                    this.getAnnotLabels()
                    Dispatcher.trigger("ANNOTATION_SUCCESSFUL", payload)
                }
            }.bind(this),
            fail: function (data) {
                console.log('FAILED', data)
            }
        })
    }

    shuffle(){
        this.addOperationAndSearch({
            name: "shuffle",
            query: {
                q: "f"
            }
        })
    }

    filter(filters){
        this.data.page = 1
        if(!Array.isArray(filters)){
            filters = [filters]
        }
        let operations = this._createOperationsFromFilters(filters)
        this.addOperationAndSearch(operations)
    }

    firstHit(){
        this.addOperationAndSearch({
            name: "filterFirstHit",
            query: {
                q: "F" + this.corpus.docstructure
            }
        })
    }

    subHits(){
        this.addOperationAndSearch({
            name: "filterSubHits",
            query: {
                q: "D"
            }
        })
    }

    definitions(){
        this.addOperationAndSearch({
            name: "definitions",
            query: {
                q: 'p 0 0>0 1 [ws(".*", "definitions", ".*")]'
            }
        })
    }

    getCQLDefaultAttr(){
        // TODO: use DEFAULTATTR of the corpus
        let attr = AppStore.getAttributeByName("lemma") || AppStore.getAttributeByName("word")
        return attr ? attr.name : ""
    }

    getContext(){
        let context = {};
        ["showcontext", "fc_lemword_type", "fc_lemword", "fc_lemword_wsize",
                    "fc_lemword_window_type", "fc_pos_type", "fc_pos",
                    "fc_pos_wsize", "fc_pos_window_type" ].forEach(key => {
                context[key] = this.data[key]
            })

        return context
    }

    getContextStr(){
        if(this.data.showcontext == "none"){
            return ""
        }
        let what = this.data.showcontext == "lemma" ? "lemword" : "pos"
        let context = ""
        let parts = what == "pos" ? this._getFcPosList() : this.data.fc_lemword.split(" ")
        let type = this.data["fc_" + what + "_type"]
        let window_type = this.data["fc_" + what + "_window_type"]
        let wsize = this.data["fc_" + what + "_wsize"]
        if(type == "none"){
            context += _("noneOf")
        }
        let conjunction = type == "all" ? _("and") : _("or")
        context += "'" + parts.join("' " + conjunction + " '") + "'"
        context += ", "

        context += "["
                + ((window_type == "left" || window_type == "both") ? ("-" + wsize) : "KWIC")
                + ", "
                + ( (window_type == "right" || window_type == "both") ?  wsize : "KWIC")
                + "]"

        return context
    }

    getUserOptions(){ // overriden
        let skip = ["queryselector", "keyword" ,"viewmode", "ref_size",
                "default_attr", "glue", "attrs", "refs", "show_gdex_scores",
                "fc_lemword_window_type", "fc_lemword_wsize", "fc_lemword", "showcontext",
                "fc_lemword_type", "glue", "fc_pos_window_type", "fc_pos_window_type",
                "fc_pos_wsize", "fc_pos_type", "fc_pos", "f_freqml", "c_cfromw", "c_ctow"]
        let userOptions = {}
        this.searchOptions.forEach((option) => {
            let key = option[0]
            if(!skip.includes(key)){
                if(!this.isOptionDefault(key, this.data[key])){
                    let labelId = option[1]
                    if(labelId.startsWith("f_") || labelId.startsWith("c_")){
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
            if(operation.name != "context"){
                userOptions[operation.name] = {
                    labelId: "cc." + operation.name,
                    value: operation.arg || ""
                }
            }
        })
        if(!$.isEmptyObject(this.data.selection)){
            let value = ""
            for(let textType in this.data.selection){
                value += value ? ", " : ""
                value += textType + ":" + this.data.selection[textType].join("|")
            }
            userOptions.selection = {
                labelId: "textTypes",
                value: value
            }
        }
        let context = this.getContextStr()
        if(context){
            userOptions.context = {
                labelId: this.data.showcontext == "pos" ? "posContext" : "lemmaContext" ,
                value: context
            }
        }
        if(!this.isConc){
            userOptions.view = {
                labelId: "screen",
                value: _(this.data.results_screen)
            }
        }
        if(this.isFreq)
            {this.data.f_freqml.forEach((freqml, idx) => {
                userOptions["frequency_" + idx] = {
                    label: "column " + (idx + 1),
                    value: freqml.attr + ", " + freqml.ctx
                }
            })
        }
        if(this.isColl){
            userOptions["range"] = {
                labelId: "range",
                value: this.data.c_cfromw + ", " + this.data.c_ctow
            }
        }
        return userOptions
    }

    getResultPageObject(){ // overriden
        let pageObj = super.getResultPageObject()
        pageObj.data.operations = this.data.operations
        return pageObj
    }

    getAllTextTypes(){
        let allTextTypes = []
        if(!this.corpus.freqttattrs.length){
            allTextTypes = TextTypesStore.get("textTypes").map(t => {return t.name + " 0"})
        } else {
            this.corpus.freqttattrs.forEach(item => { // parse weird freqttattrs format
                item.split("|").forEach(attr => {
                    allTextTypes.push(attr + " 0")
                })
            })
        }
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

    getFilterContextStr(ctx, base){
        ctx = this.corpus.righttoleft ? - ctx : ctx
        let ctxStr = ""
        let baseStr = "0"
        if(ctx == 0 && base != "first_kwic_word" && base != "last_kwic_word"){
            if(base == "kwic"){
                ctxStr = "0~0>0"
            } else{
                // nth highlighted collocation
                ctxStr = "0<" + base + "~0>" + base
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

    cancelPreviousRequest() { // overriden
        super.cancelPreviousRequest()
        this.asyncResults.stop()
    }

    resetContext(){
        let context = this.getContext()
        for(let key in context){
            this.data[key] = this.defaults[key]
        }
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
        this.data.refs = this.corpus.shortref.split(",").reduce((result, ref) => {
            result += result ? "," : ""
            return result += (!ref.startsWith("=") && ref != "#" && ref != this.corpus.docstructure) ? ("=" + ref) : ref
        }, "")

        this.lineDetailsTextTypes = this.data.refs.replace(/=/g, '').split(",").map(ref => {
            return ref += " 0"
        })
    }

    goBackToTheConcordance(){
        // from subfeature collocations / frequency
        Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "")
        this.request = this.Crequest
        this.changeResultScreen("concordance")
        this.updateUrl(true)
    }

    selectedLinesToggle(lines, add){
        lines.forEach(line => {
            let idx = this.selectedLines.findIndex(l => {
                return l.toknum == line.toknum
            })
            if(idx == -1){
                add && this.selectedLines.push(line)
            } else {
                !add && this.selectedLines.splice(idx, 1)
            }
        })
        this.trigger("selectedLinesChanged")
    }

    selectedLinesSelectPage(){
        let lines = this.data.items.map(item => {
            return {
                toknum: item.toknum,
                text: this.getLineCopyText(item)
            }
        })
        this.selectedLinesToggle(lines, true)
    }

    selectedLinesDeselectPage(){
        let lines = this.data.items.map(item => {
            return {
                toknum: item.toknum
            }
        })
        this.selectedLinesToggle(lines, false)
    }

    selectedLinesDeselectAll(){
        this.selectedLines = []
        this.trigger("selectedLinesChanged")
    }

    isLineSelected(toknum){
        return this.selectedLines.findIndex(l => {
            return l.toknum == toknum
        }) != -1
    }

    getLineCopyText(line){
        let parts = []
        let keys = ["Left", "Kwic", "Right"]
        keys.forEach(block => {
            line[block].forEach(item => {
                if(isDef(item.str)){
                    parts.push(item.str.trim())
                }
            })
        })
        let text = parts.join(" ")
        return text
    }

    _onPageChange(pageId, query){
        if (this._isActualFeature()) {
            this.selectedLinesDeselectAll()
            this._cancelRequestResetOptions()
            if(query){
                this._setDataFromUrl(query)
                this.trigger("change")
            }
            AppStore.changeActualFeatureStore(this)
            if(this.pageTag && this.pageTag.isMounted && this.data.showresults){
                // user navigated to the result page -> load results
                this.isConc && this.search()
            }
        } else{
            this.cancelPreviousRequest()
        }
    }

    _cancelPreloadRequests(){
        for(let thousand in this.preloadedData){
            let request = this.preloadedData[thousand]
            request && request.cancel && request.cancel()
        }
    }

    _initPreloadedDataIfNeeded(){
        let data = this._parseRequestData(this.data.activeRequest)
        delete data.fromp
        delete data.pagesize
        if(!this.preloadedData.requestedData
                // preloaded request is not same (excluding fromp and pagesize) as actual request
                || !window.objectEquals(data, this.preloadedData.requestedData)){
            this._cancelPreloadRequests()
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
        if(this.preloadedData[thousand] && this.preloadedData[thousand].data){
            this.data.items = this.preloadedData[thousand].data.slice(startIdx % 1000, (startIdx  % 1000) + this.data.itemsPerPage)
            this._checkAndPreload()
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
                    item.ref = item.Refs.join(" ● ")
                })
                this.preloadedData[thousand].data = payload.Lines
            }.bind(this, thousand)
        })
    }

    _createOperationsFromFilters(filters){
        return filters.map(filter => {
            let selector = filter.queryselector.substr(0, filter.queryselector.length - 3) //lemmarow -> lemma, cqlrow -> cql
            let pn = filter.pnfilter == "n" ? "not, " : ""
            let fpos = filter.filfpos
            let tpos = filter.filtpos
            let kwic = ""
            if(fpos == 0 || tpos == 0 || Math.sign(fpos) != Math.sign(tpos)){
                kwic = `,${filter.inclkwic ? "+" : "-"}KWIC`
            }
            let range = `${fpos}..${tpos}${kwic}`
            return {
                name: filter.name || "filter",
                arg: filter.desc ? filter.desc : `${filter[selector]} (${pn}${range})`,
                query: filter
            }
        })
    }

    _getQueryObject(dataIn){ // overriden
        let data = dataIn || this.data
        let queryObject = super._getQueryObject(data)
        if(data.operations){
            queryObject.operations = JSON.stringify(data.operations)
        }
        return queryObject
    }

    _addContextToOperations(){
        function addContextFilter(filters, pn, cql, position, size){
            filters.push({
                name: "context",
                pnfilter: pn,
                queryselector: "cqlrow",
                filfpos: position == "right" ? 1 : -size,
                filtpos: position == "left" ? -1 : size,
                cql: cql
            })
        }

        function append_filter (filters, attrname, items, ctxtype, position, size){
            if (items.length){
                let cql = `[${attrname}="${items.join("|")}"]`
                if(ctxtype == 'any'){
                    addContextFilter(filters, "p", cql, position, size)
                } else if(ctxtype == 'none'){
                    addContextFilter(filters, "n", cql, position, size)
                } else if(ctxtype == 'all'){
                    items.forEach(item => {
                        addContextFilter(filters, "p", `[${attrname}="${item}"]`, position, size)
                    })
                }
            }
        }

        let filters = []
        if(this.data.showcontext == "lemma"){
            append_filter (filters,
                            this.data.default_attr || this.corpus.defaultattr,
                            this.data.fc_lemword.split(" "),
                            this.data.fc_lemword_type,
                            this.data.fc_lemword_window_type,
                            this.data.fc_lemword_wsize)
        }
        if(this.data.showcontext == "pos"){
            append_filter (filters,
                            "tag",
                            this.data.fc_pos,
                            this.data.fc_pos_type,
                            this.data.fc_pos_window_type,
                            this.data.fc_pos_wsize)
        }

        this._createOperationsFromFilters(filters).forEach(this.addOperation.bind(this))
    }

    _setDataFromUrl(query){
        super._setDataFromUrl(query)
        if(query.operations){
            this.data.operations = JSON.parse(query.operations)
        }
        if(query.selection){
            TextTypesStore.setSelection(JSON.parse(query.selection))
        }
        this._setResultScreen(query.results_screen || "concordance")
        this._checkAndFixData()
    }

    _setDataFromUserOptions(){
        // gdex_enabled was saved in user options, now the value is not kept ->
        // delete values stored earlier
        delete this.userOptions.gdex_enabled
        delete this.userOptions.show_gdex_scores
        super._setDataFromUserOptions()
        this._checkAndFixData()
    }

    _checkAndFixData(){
        if(["kwic","sen"].indexOf(this.data.viewmode) == -1){ // do not allow other than kwic/sen
            this.data.viewmode = "kwic"
        }
    }

    _checkResultCount(payload){
        let data = this.getRequestData({
            fromp: 1,
            pagesize: 1
        })
        this.asyncResults.check({
            url: window.config.URL_BONITO + "concordance?corpname=" + this.corpus.corpname,
            xhrParams: {
                method: "POST",
                data: data
            },
            isFinished: (data) => {
                return data.finished !== 0
            },
            onBegin: this._onCountDataLoaded.bind(this, true, null),
            onData: this._onCountDataLoaded.bind(this, true),
            onComplete: this._onCountDataLoaded.bind(this, false)
        }, payload)
    }

    _onCountDataLoaded(loading, data){
        if(data){
            this.data.raw.Desc = data.Desc
        }
        this.data.total = data ? data.concsize : 0
        this.data.fullsize = data ? data.fullsize : 0
        this.data.isCountLoading = loading
        this.data.relsize =  data ? data.relsize : 0
        this.trigger("countChange", this.data.total)
    }

    _setResultScreen(results_screen){
        this.data.results_screen = results_screen
        this.isConc = results_screen == "concordance"
        this.isFreq = results_screen == "frequency"
        this.isColl = results_screen == "collocations"
    }

    _isShowingResults(){ // overriden
        return super._isShowingResults() && this.isConc
    }

    _getFcPosList(){
        // for fc_pos (eg. ["N.*"]) returns descriptive variation (eg. ["noun"])
        let list = []
        this.data.fc_pos.forEach(pos => {
            let idx = this.corpus.wposlist.findIndex(p => {
                return p.value == pos
            })
            if(idx != -1){
                list.push(this.corpus.wposlist[idx].label)
            }
        })
        return list
    }

    _onCorpusChange(){
        this._setResultScreen("concordance")
        super._onCorpusChange()
        Auth.getAnnotationGroup() && this.corpus && this.getAnnotations()
    }

    //////////// FREQUENCY

    f_searchAndAddToHistory(options, params){
        this._setNonEmptyOptions(options)
        this.f_search(params)
        this.updateUrl(true, true)
    }

    f_search(block){
        this.changeResultScreen("frequency")
        this.cancelPreviousRequest()
        this.data.isLoading = true
        this.updatePageTag()
        this.data.activeRequest = Connection.get({
            url: window.config.URL_BONITO + (this.data.f_mode == "texttypes" ? "freqs" : "freqml") + '?corpname=' + this.corpus.corpname,
            xhrParams: {
                method: "POST",
                data: this.f_getRequestData(block)
            },
            done: this.f_onDataLoadDone.bind(this),
            fail: this.onDataLoadFail.bind(this),
            always: this.onDataLoadAlways.bind(this)
        })
        this.Crequest = this.request
        this.request = [this.data.activeRequest]
    }

    f_getRequestData(block){
        let data = {
            corpname: this.corpus.corpname,
            format: "json",
            concordance_query: this.getConcordanceQuery(),
            usesubcorp: this.data.usesubcorp,
            fmaxitems: 5000,
            fpage: block ? block.page : this.data.f_page,
            freq_sort: (block ? block.sort : this.data.f_sort) + "",
            blockId: block ? block.id : "",
            group: this.data.f_group
        }
        if(this.data.f_mode == "texttypes"){
            data.fcrit = []
            if(block){
                data.fcrit.push(block.id + " 0")
            } else{
                data.fcrit = this.data.f_texttypes
            }
        } else if(this.data.f_mode == "multilevel"){
            data.freqlevel = 0
            this.data.f_freqml.forEach((freq, idx) => {
                data.freqlevel++
                data["ml" + (idx + 1) + "attr"] = freq.attr
                data["ml" + (idx + 1) + "ctx"] = this.getFilterContextStr(freq.ctx, freq.base)
            })
        }
        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    f_onDataLoadDone(payload){
        if(this.isFreq){
            this.data.total = payload.concsize
            this.data.fullsize = payload.fullsize
            if(payload.request.blockId){ // one block reloaded (sort,..)
                let block =  this.data.f_items.find(b => {
                    return b.id == payload.request.blockId
                })
                Object.assign(block, payload.Blocks[0])
            } else{
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
                    this.f_onDataLoadedProcessItems(payload)
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
    }

    f_onDataLoadedProcessItems(payload){
        this.data.f_items = payload.Blocks.map(block => {
            return Object.assign(block, {
                id: block.Head[0].id,
                page: 1,
                itemsPerPage: this.data.f_mode == "texttypes" ? 10 : this.data.f_itemsPerPage,
                showResultsFrom: 0,
                orderBy: "freq",
                sort: "freq"
            })
        })
    }

    f_getLink(data, mode, f_tab){
        let concQueryObj = this._getQueryObject(Object.assign({}, this.data, {
            f_tab: f_tab,
            f_texttypes: [],
            f_freqml: [],
            f_page: 1,
            f_mode: mode
        }, data))
        concQueryObj.results_screen = "frequency"
        return Router.createUrl("concordance", concQueryObj)
    }

    f_getContextLink(ctx, base, attr, f_tab){
        return this.f_getLink({
            f_freqml: [{
                attr: attr,
                base: base,
                ctx: ctx
            }]
        }, "multilevel", f_tab)
    }

    f_getLineDetailsTextTypes(){
        let texttypes = this.data.refs.split(",").filter(ref => {
            return ref !== "" && ref != "#" && ref != this.corpus.docstructure
        }, this).map(ref => {
            return (ref.startsWith("=") ? ref.substr(1) : ref) + " 0"
        }).join(" ")
        return texttypes !== "" ? [texttypes] : []
    }

    //////////// COLLOCATIONS

    c_searchAndAddToHistory(options){
        this._setNonEmptyOptions(options)
        this.c_search()
        this.updateUrl(true, true)
    }

    c_search(){
        this.changeResultScreen("collocations")
        this.cancelPreviousRequest()
        this.data.isLoading = true
        this.data.c_showresults = true
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
            "concordance_query": this.getConcordanceQuery(),
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

    onSubcorpusChange(subcorpus){
        let params = {
            usesubcorp: subcorpus
        }
        this.isConc && this.searchAndAddToHistory(params)
        this.isFreq && this.f_searchAndAddToHistory(params)
        this.isColl && this.c_searchAndAddToHistory(params)
    }

    openFrequencyResults(what){
        let link = ""
        if(what == "textTypes"){
            let textTypes = this.getAllTextTypes()
            if(textTypes.length){
                link = this.f_getLink({
                    f_texttypes: textTypes
                }, "texttypes", "advanced")
            }
        } else if(what == "lineDetails"){
            let lineDetails = this.f_getLineDetailsTextTypes()
            if(lineDetails.length){
                link = this.f_getLink({
                    f_texttypes: lineDetails
                }, "texttypes", "advanced")
            }
        } else{
            link = this.f_getContextLink(0, "kwic", what, "advanced")
        }
        if(link){
            window.location.href = link
        }
    }
}

export let ConcordanceStore = new ConcordanceStoreClass()
