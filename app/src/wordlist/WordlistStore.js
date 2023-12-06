const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {AppStore} = require("core/AppStore.js")
const {Connection} = require('core/Connection.js')
const Meta = require("./Wordlist.meta.js")

class WordlistStoreClass extends FeatureStoreMixin {
    constructor(){
        super()
        this.feature = "wordlist"
        this.data = $.extend(this.data, {
            onecolumn: false,
            values: true,
            bars: true,
            random: 0,
            find: "word",
            lpos: "",
            filter: "all",
            keyword: "",
            viewAs: 1,
            relfreq: false,
            showLineNumbers: true,
            wlmaxitems: 20000,
            wlsort: "f",
            subcnorm: "freq",
            usesubcorp: "",
            wlattr: "word",
            wlpat: ".*",
            wlminfreq: 5,
            wlmaxfreq: 0,
            wlfile: "",
            wlblacklist: "",
            wlnums: "frq",
            wltype: "simple",
            wlstruct_attr1: "",
            wlstruct_attr2: "",
            wlstruct_attr3: "",
            wlicase: 1,
            include_nonwords: 0,
            criteria: [],
            exclude: false,
            criteriaOperator: Meta.operators.AND, // criteria joined with AND
            itemsPerPage: 50,
            cols: [], // columns in result
            histid: "",
            findxList: [],
            showrank: false,
            showratio: true,
            findxListLoaded: false
        })
        this.defaults = this._copy(this.data)

        this.xhrOptions = ["wlmaxitems", "wlsort", "subcnorm",
                "usesubcorp", "wlattr", "wlpat", "wlminfreq", "wlicase",
                "wlmaxfreq", "wlfile", "wlblacklist", "wlnums", "wltype", "include_nonwords",
                "wlstruct_attr1", "wlstruct_attr2", "wlstruct_attr3", "random"]

        this.urlOptions = ["lpos", "find", "keyword", "filter", "viewAs", "relfreq",
            "onecolumn", "bars", "values", "wlmaxitems", "wlsort", "subcnorm",
            "usesubcorp", "wlattr", "wlminfreq", "wlicase",
            "wlmaxfreq", "wlfile", "wlblacklist", "wlnums", "wltype", "exclude",
            "wlstruct_attr1", "wlstruct_attr2", "wlstruct_attr3", "criteria",
            "include_nonwords", "criteriaOperator", "page", "itemsPerPage",
            "showLineNumbers", "tab", "showresults", "random", "tts", "histid",
            "showrank", "showratio"]

        this.searchOptions = [
            ["wlmaxitems", "wl.wlmaxitems"],
            ["wlsort", "wl.wlsort"],
            ["subcnorm", "wl.subcnorm"],
            ["usesubcorp", "wl.usesubcorp"],
            ["wlattr", "wl.wlattr"],
            ["wlpat", "wl.wlpat"],
            ["wlminfreq", "wl.wlminfreq"],
            ["wlmaxfreq", "wl.wlmaxfreq"],
            ["wlfile", "wl.wlfile"],
            ["wlblacklist", "wl.wlblacklist"],
            ["wltype", "wl.wltype"],
            ["viewAs", "wl.viewAs"],
            ["wlstruct_attr1", "wl.wlstruct_attr1"],
            ["wlstruct_attr2", "wl.wlstruct_attr2"],
            ["wlstruct_attr3", "wl.wlstruct_attr3"],
            ["wlicase", "wl.wlicase"],
            ["include_nonwords", "wl.include_nonwords"],
            ["criteria", "wl.criteria"],
            ["exclude", "wl.exclude"],
            ["criteriaOperator", "wl.criteriaOperator"],
            ["random", "random"],
            ["wlnums", "wlnums"],
            ["histid", "histid"]
        ]

        this.userOptionsToSave = ["tab", "itemsPerPage", "wlnums"]
        this.validEmptyOptions = ["wlsort"]
    }

    search(){ //overrides default
        if(this.data.tab != "attribute" && !this.data.histid){
            this.setWlattrAndLpos()
        }
        super.search()
    }

    onDataLoadedProcessItems(payload){ //overrides default
        this.data.items = payload.Blocks ? payload.Blocks[0].Items : payload.Items
        this.data.cols = payload.Blocks ? payload.Blocks[0].Head : []
        this.data.wllimit = payload.wllimit
        this.data.totalfrq = payload.totalfrq
        this.data.totalitems = payload.Blocks ? payload.Blocks[0].total : payload.total

        // used for exporting data
        this.updateRequestData(this.request[0], {
            wlmaxitems: this.data.wllimit || 10000000, // 0 means unlimited
            page: 1
        })
    }

    loadFindxList(){
        if(!this.data.findxListLoaded){
            Connection.get({
                url: window.config.URL_BONITO + "findx_list?corpname=" + this.corpus.corpname,
                done: (payload) => {
                    this.data.findxListLoaded = true
                    this.data.findxList = payload.FindxList
                    this.trigger("findxListLoaded")
                }
            })
        }
    }

    saveUserOptions(){ //overrides default
        this.data.tab != "attribute" && super.saveUserOptions(this.userOptionsToSave)
    }

    setCorpusDefaults(){ //overrides default
        let attr = AppStore.getAttributeByName("word")
        if(this.corpus && this.corpus.unicameral){
            this.data.wlicase = 0
        }
        if(attr){
            if(!attr.lc){
                this.data.wlicase = 0
            } else{
                this.data.wlattr = this.data.wlicase ? attr.lc : attr.name
            }
        }
    }

    setWlattrAndLpos(){
        let attrName = this.data.find
        if(AppStore.getLposByValue(this.data.find)){
            attrName = "lempos"
            this.data.lpos = this.data.find
        } else {
            this.data.lpos = ""
        }
        let attr = AppStore.getAttributeByName(attrName)
        this.data.wlattr = this.data.wlicase && attr.lc ? attr.lc : attrName
    }

    getFindLabel(find){
        if(this.data.tab == "attribute"){
            return find
        } else if(this.data.histid){
            return this.data.raw && this.data.raw.hist_desc || ""
        } else {
            let attr = AppStore.getAttributeByName(find) || AppStore.getLposByValue(find)
            return attr ? attr.label : ""
        }
    }

    getFilterList(tab){
        return Meta.filterList[tab].map((filter) => {
            return Object.assign({}, Meta.filters[filter])
        })
    }

    getUserOptions(){
        const addValueToList = (isDefault, key, labelId, value) => {
            if(!isDefault){
                userOptions.push({
                    key: key,
                    labelId: labelId,
                    value: value
                })
            }
        }
        let value
        let userOptions = []
        let options = this.data
        addValueToList(false, "find",  "show",  options.find)

        if(options.filter == "all"){
            //
        } else if(options.filter === ""){
            if(!options.criteria.length){
                addValueToList(true, "filter", "filter", options.keyword)
            }
        } else {
            let filterMeta = Meta.filters[options.filter]
            let fromList = options.filter == "fromList" ? options.wlfile : options.keyword
            addValueToList(false, "fromList", filterMeta.labelId, fromList)
        }

        if(options.criteria.length){
            options.criteria.forEach((criterion) => {
                addValueToList(false, criterion.filter, Meta.filters[criterion.filter].labelId, criterion.value)
            })
        }
        if(options.wlblacklist){
            addValueToList(false, "notFromList", "wl.notFromList", options.wlblacklist)
        }
        this._addTextTypesToUserOptions(userOptions)
        ;[
            ["usesubcorp", "subcorpus"],
            ["wlminfreq", "minFreq"],
            ["wlmaxfreq", "maxFreq"],
            ["wlicase", "ignoreCase"],
            ["include_nonwords", "includeNonwords"]
        ].forEach((option) => {
            value = options[option[0]]
            addValueToList(this.isOptionDefault(option[0], value), option[0], option[1], value)
        })
        return userOptions
    }

    getRequestUrl(){ // overrides default
        let method = "wordlist"
        if(this.data.histid){
            method = "findx"
        } else if(this.data.wlstruct_attr1){
            method = "struct_wordlist"
        } else if(this.data.lpos){
            method = "poswordlist"
        }
        return window.config.URL_BONITO + method + '?corpname=' + this.corpus.corpname
    }

    getRequestData(){ //overrides default
        let data = {}
        if(!this.data.histid){
             data = super.getRequestData()

            if(this.data.wlblacklist && this.data.lpos){
                // adding lpos to words in blacklist
                data.wlblacklist = this.data.wlblacklist.split("\n").map(word => {
                    return word + this.data.lpos
                }).join("\n")
            }
            data.wltype = "simple"
            if(this.data.wlstruct_attr1){
                data.wltype = "struct_wordlist"
            }

            data[this.data.wltype == "struct_wordlist" ? "fpage" : "wlpage"] = 1
            data.wlpat = this.getWlpat()
        } else {
            data.histid = this.data.find
            data.wlminfreq = this.data.wlminfreq
            data.wlmaxitems = this.data.wlmaxitems
        }
        data.wlfile = this._getWlfile()
        data.results_url = window.location.href + '&showresults=1'

        return "json=" + encodeURIComponent(JSON.stringify(data))
    }

    getRequestXhrParams(){
        return {
            contentType: "application/x-www-form-urlencoded"
        }
    }

    getWlpat(){
        let options = this.data
        let criteria = this._copy(options.criteria) || [];
        if(options.filter){ // value from list All, Starting with,....
            if(options.filter != "fromList" && (options.filter == "all" || options.keyword !== "")){
                // whitelist doesnt change wlpat, other options than all have to have filled keyword
                criteria.push({
                    filter: options.filter,
                    value: options.keyword
                })
            }
        }
        let wlpat = ""
        let regex
        let joinWith = options.criteriaOperator == Meta.operators.OR ? "|" : ""
        if(options.filter == "regex"){
            wlpat = options.keyword
        } else {
            // conditions to regex have to be added in specific order. Eg. startign with k and ending with a is (k.*)(.*a), not (.*a)(k.*)
            ["startingWith", "containing", "endingWith"].forEach((filter) => {
                regex = this._getFilterRegex(criteria, filter)
                if(regex){
                    wlpat += (wlpat ? joinWith : "") + regex
                }
            })
        }

        if(!wlpat) {
            wlpat = this.defaults.wlpat
        }
        let lpos = AppStore.getLposByValue(options.find)
        if(lpos){
            wlpat += lpos.value // add lempos to wlpat -N, -j,...
        }

        return wlpat
    }

    _onCorpusChange(){ // overrides default
        super._onCorpusChange()
        this._isActualFeature() && this.loadFindxList()
    }

    _getWlfile(){
        if(!this.data.wlfile){
            return ""
        }
        if(!this.data.lpos){
            return this.data.wlfile
        }
        // add lpos to wlfile
        return this.data.wlfile.split("\n").map(part => {
            part = part.trim()
            if(!part.endsWith(this.data.lpos)){
                part = part += this.data.lpos
            }
            return part
        }, this).join("\n")
    }

    _getFilterRegex(criteria, filter){
        let criterion = criteria.find((c) => {
            return c.filter == filter
        })
        if(!criterion){
            return ""
        }
        let filterMeta = Meta.filters[criterion.filter]
        return criterion.value ? `(${filterMeta.regex.replace("{key}", criterion.value)})` : filterMeta.regex
    }
}

export let WordlistStore = new WordlistStoreClass()
