const {Connection} = require('core/Connection.js')
const {StoreMixin} = require("core/StoreMixin.js")
const {Auth} = require("core/Auth.js")
const {Url} = require("core/url.js")

class AppStoreClass extends StoreMixin {
    constructor(){
        super()

        this.EMPTY = "EMPTY"
        this.CHECKING = "CHECKING"
        this.READY = "READY"
        this.COMPILED = "COMPILED"
        this.COMPILING = "COMPILING"
        this.TAGGING = "TAGGING"
        this.CANCELLING = "CANCELLING"
        this.TO_BE_COMPILED = "TO_BE_COMPILED"
        this.COMPILATION_FAILED = "COMPILATION_FAILED"

        // refrenece corpora compatibility level
        this.FEATURE_NA = 0
        this.FEATURE_PART_COMPATIBILITY = 1
        this.FEATURE_FULL_COMPATIBILITY = 2

        this._reset()

        Dispatcher.on("CA_CORPUS_PROGRESS", this._onCorpusProgressChange.bind(this))
        Dispatcher.on("ON_LOGIN_AS_DONE", this._onLoginAsDone.bind(this))
        Dispatcher.on("LOCALIZATION_CHANGE", this._onLocalizationChange.bind(this))
    }

    getActualFeatureStore(){
        return this.data.actualFeatureStore
    }

    getActualCorpus(){
        return this.data.corpus
    }

    getActualCorpname(){
        return this.data.corpus && this.data.corpus.corpname ? this.data.corpus.corpname : ""
    }

    getCorpusByCorpname(corpname){
        return this.data.corpusList.find((corpus) => {
            return corpus.corpname == corpname
        })
    }

    getCorpusById(corpus_id){
        // admins does not have user corpora in this.data.corpusList -> use active this.data.corpus
        return (this.data.corpus && this.data.corpus.id == corpus_id)
                ? this.data.corpus
                : this.data.corpusList.find((corpus) => {
                    return corpus.id == corpus_id
                })
    }

    getSubcorpus(subcname){
        return this.data.subcorpora.find(s => {
            return s.value == subcname
        })
    }

    getLatestCorpusVersion(corpus){
        let latest = corpus
        while(latest && latest.new_version){
            latest = this.getCorpusByCorpname(latest.new_version)
        }
        return latest || corpus
    }

    getAttributeByName(name) {
        const attributes = this.get("corpus.attributes")
        if (attributes) {
            return attributes.find((attr) => {
                return attr.name == name
            })
        }
        return null
    }

    getLposByValue(lpos) {
        // lpos: "-N", "-j",...
        // returns ["adjective", "-j"] etc
        const lposlist = this.get("corpus.lposlist")
        if(lposlist) {
            return lposlist.find((item) => {
                return item.value == lpos
            })
        }
        return null
    }

    getLanguage(languageId){
        return this.data.languageList.find(l => {
            return l.id == languageId
        })
    }

    getWlsortLabelId(attr){
        attr = attr.split(":")[0]
        if(this.data.corpus && this.data.corpus.hasStarAttr){
            if(attr == "docf"){
                return "mr"
            } else if(attr == "reldocf"){
                return "relmr"
            } else if(attr == "star"){
                return "asr"
            }
        }
        if(attr == "frq"){
            return "frequency"
        }
        return attr
    }

    getFirstWlattr(){
        let wlattr = AppStore.get("corpus.subcorpattrs.0") || null
        if(!wlattr && this.data.corpus && this.data.corpus.structures){
            for(let i = 0; i < this.data.corpus.structures.length; i++){
                let structure = this.data.corpus.structures[i]
                let attributes = structure.attributes
                if(attributes && attributes.length){
                    return `${structure.name}.${attributes[0].name}`
                }
            }
        }
        return wlattr
    }

    hasCorpusFeature(feature){
        return !!this.data.features[feature]
    }

    loadBgJobs() {
        if(Auth.isAnonymous()){
            return
        }
        let self = this
        this.data.bgJobsRequest && this.data.bgJobsRequest.xhr.abort()
        clearTimeout(this.data.bgJobsTimer)
        this.data.bgJobsTimer = null
        Dispatcher.trigger('BGJOBS_LOADING')
        this.data.bgJobsRequest = Connection.get({
            url: window.config.URL_BONITO + 'jobs?format=json&finished=true',
            done: (payload) => {
                let isOnBGJobPage = Url.getPage() == "bgjobs"
                self.data.bgJobsTimer = null
                clearTimeout(this.data.bgJobsTimer)
                self.data.bgJobs = payload.jobs || []
                self.data.bgJobs.sort((a, b) => {
                    return new Date(b.starttime) - new Date(a.starttime)
                })
                let someRunning = false
                for (let i=0; i<self.data.bgJobs.length; i++) {
                    let stat = self.data.bgJobs[i].status[0]
                    let jid = self.data.bgJobs[i].jobid
                    let previ = self.data.bgJobsPrev.indexOf(jid)
                    let isJobRunnig = ["R", "D", "S"].includes(stat)
                    if (previ >= 0) {
                        if (!isJobRunnig) {
                            self.data.bgJobsNotify = !isOnBGJobPage
                            SkE.showToast(_("bj.notifyFinish"), 10000)
                            self.data.bgJobsPrev.splice(previ, 1)
                        }
                    } else if (isJobRunnig) {
                        self.data.bgJobsPrev.push(jid)
                    }
                    someRunning = someRunning || isJobRunnig
                    self.data.bgJobs[i].options = []
                    let feature = Url.getPage(self.data.bgJobs[i].url)
                    let store = window.stores[feature]
                    if(store){
                        self.data.bgJobs[i].feature = feature
                        let options = Url.getQuery(self.data.bgJobs[i].url)
                        store.searchOptions.forEach(o => {
                            if(isDef(options[o[0]]) && !store.isOptionDefault(o[0], options[o[0]])){
                                self.data.bgJobs[i].options.push([o[1], options[o[0]]])
                            }
                        })
                    }
                }
                self.data.bgJobsRequest = null
                Dispatcher.trigger('BGJOBS_UPDATED', self.data.bgJobs)
                if (someRunning || isOnBGJobPage) {
                    self.data.bgJobsTimer = setTimeout(self.loadBgJobs.bind(self), (isOnBGJobPage  ? 10 : 60) * 1000)
                }
            },
            fail: payload => {
                SkE.showError("Could not load computations.", getPayloadError(payload))
            }
        })
    }

    loadAnyCorpus(corpname) {
        Connection.get({
            url: window.config.URL_BONITO + "corp_info",
            data: {
                subcorpora: 1,
                corpname: corpname
            },
            done: (payload) => {
                Dispatcher.trigger('ANY_CORPUS_LOADED', this._processCorpusBonitoData(payload))
            },
            fail: payload => {
                SkE.showError("Could not load corpus.", getPayloadError(payload))
            }
        })
    }

    loadCorpus(corpname){
        if(!corpname){
            console.log("AppStore: Tried to load corpus info with undefined corpname.")
            return
        }
        this.data.corpus = null
        this.data.canBeCompiledLoaded = false
        !window.config.NO_CA && this._loadCorpusCA(corpname)
        this._loadCorpusBonito(corpname)
    }

    loadCorpusList(){
        this.data.corpusListLoaded = false
        Connection.get({
            url: window.config.URL_CA + "corpora",
            query: null,
            done: this._onCorpusListLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadLanguageList(){
        Connection.get({
            url: window.config.URL_CA + "languages",
            query: null,
            done: this._onLanguageListLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }


    loadCanBeCompiled(){
        this.data.corpus.id && Connection.get({
            url: window.config.URL_CA + "corpora/" + this.data.corpus.id + "/can_be_compiled",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify({})
            },
            done: function(payload) {
                this.data.corpus.can_be_compiled = payload.result.can_be_compiled
                this.data.corpus.compilationNotAllowedReason = payload.result.reason || ""
                this.data.canBeCompiledLoaded = true
                this._calculateStatus()
                if(this.data.corpus.isTagging){
                    if(!this.handle){
                        this.handle = setTimeout(function(){
                            this.loadCanBeCompiled()
                            if(this.handle){
                                clearTimeout(this.handle)
                                this.handle = null
                            }
                        }.bind(this), 5000)
                    }
                }
            }.bind(this),
            fail: payload => {
                SkE.showError("Could not load corpus status.", getPayloadError(payload))
            }
        })
    }

    loadGDEXConfs(){
        !this.data.gdexConfsLoaded && Connection.get({
            url: window.config.URL_CA + "gdexconfs",
            done: function (payload) {
                if (payload.data) {
                    this.data.gdexConfs = [{'label': _("cc.gdexDefault"), 'value': '__default__'}]
                    for (let i =0 ; i < payload.data.length; i++) {
                        this.data.gdexConfs.push({
                            value: payload.data[i].filename,
                            label: payload.data[i].filename
                        })
                    }
                }
                this.data.gdexConfsLoaded = true
                this.trigger("gdexConfsLoaded")
            }.bind(this),
            fail: function (payload) {
                SkE.showToast("Could not load GDEX configurations.")
            }
        })
    }

    checkAndChangeCorpus(corpname){
        let actualCorpname = this.getActualCorpname()
        if(!actualCorpname || actualCorpname != corpname){
            let corpus = this.getCorpusByCorpname(corpname)
            if(this._checkCovid19Corpus(corpus.corpname)){
                return false
            }
            if(!corpus.user_can_read){
                if(corpus.access_level == "ondemand") {
                    if(corpus.terms_of_use) {
                        Dispatcher.trigger("openDialog", {
                            content: corpus.terms_of_use,
                            small: true,
                            buttons: [{
                                label: _("agree"),
                                onClick: function(corpus){
                                    Connection.get({
                                        url: window.config.URL_CA + "corpora/" + corpus.corpname + "/agree_to_terms",
                                        xhrParams: {
                                            method: "POST",
                                            data: JSON.stringify({}),
                                            contentType: "application/json"
                                        },
                                        done: function(corpus){
                                            this.loadCorpusList()
                                            this.loadCorpus(corpus.corpname)
                                        }.bind(this, corpus),
                                        fail: payload => {
                                            SkE.showError("Could not save the data.", getPayloadError(payload))
                                        }
                                    })
                                    Dispatcher.trigger("closeAllDialogs")
                                }.bind(this, corpus)
                            }]
                        })
                    } else {
                        Dispatcher.trigger("openDialog", {
                            small: true,
                            title: _("corpusAccess1_title"),
                            content: _("corpusAccess1_text", [corpus.name,
                                '<a href="' + corpus.infohref +'" target="_blank">' + _("corpusAccess1_link") + '</a>'])
                        })
                    }
                } else {
                    Dispatcher.trigger("openDialog", {
                        small: true,
                            title: _("corpusAccess1_title"),
                            content: _("corpusAccess2_text_1", [corpus.name,
                                '<a href="' + window.config.URL_RASPI + '#register" target="_blank">' + _("corpusAccess2_link_1") + '</a>'])
                                    + "<br><br>"
                                    + _("corpusAccess2_text_2", ['<a href="' + externalLink("priceList") + 'target="_blank">' + _("corpusAccess2_link_2") + '</a>'])
                    })
                }
            } else{
                this.loadCorpus(corpname)
            }
        }
    }

    changeCorpus(corpname){
        let actualCorpname = this.getActualCorpname()
        if(!actualCorpname || actualCorpname != corpname){
            if(corpname){
                if(!this._checkCovid19Corpus(corpname)){
                    this.loadCorpus(corpname)
                }
            } else{
                this._onUnsetCorpus()
            }
        } else{
            SkE.showToast(_("corpusAlreadySelected"))
        }
    }

    shareCorpus(cid) { }

    addMetaToCorpus(cid) { }

    deleteCorpus(corpus_id) {
        let corpus = this.getCorpusById(corpus_id)
        if(!corpus) return
        Dispatcher.trigger('openDialog', {
            id: "deleteCorpus",
            content: _("ca.reallyDeleteCorpus", [corpus.name]),
            title: _("deleteCorpus"),
            type: "warning",
            small: true,
            buttons: [{
                id: "deleteCorpusDialog",
                label: _("delete"),
                onClick: function (corpus) {
                    Connection.get({
                        url: window.config.URL_CA + "corpora/" + corpus_id,
                        xhrParams: {
                            method: 'DELETE',
                        },
                        loadingId: "deleteCorpus",
                        done: function(corpus, payload) {
                            if(this.getActualCorpname() == corpus.corpname){
                                this.changeCorpus(null)
                                Dispatcher.trigger("ROUTER_GO_TO", "corpus")
                            }
                            this._removeCorpusFromList(corpus.id)
                            Dispatcher.trigger("CORPUS_DELETED", corpus.corpname)
                            Dispatcher.trigger("RELOAD_USER_SPACE")
                            delay(() => {SkE.showToast(_("corpusDeleted"))}, 500)
                        }.bind(this, corpus),
                        fail: (payload) => {
                            SkE.showToast(_("corpusDeleteFail"), 6000)
                        }
                    })
                    Dispatcher.trigger("closeAllDialogs")
                }.bind(this, corpus)
            }]
        })
    }

    updateCorpus(corpus_id, corpus){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id,
            xhrParams: {
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify(corpus)
            },
            done: function(payload){
                this.loadCorpus(payload.data.corpname)
            }.bind(this),
            fail: () => {
                SkE.showToast(_("ca.updateCorpusError"))
            }
        })
    }

    createSubcorpus(subcname, params, corpname) {
        let q = ""
        if(params.q){
            q = "?q=" + params.q.map(p => encodeURIComponent(p)) .join("&q=")
        }
        delete params.q
        let data = Object.assign({
            corpname: this.getActualCorpname(),
            create: true,
            format: "json",
            subcname: subcname
        }, params)
        if(corpname){
            data.create_subcorp_under = corpname
        }

        let request = Connection.get({
            url: `${window.config.URL_BONITO}subcorp${q}`,
            data: data,
            skipDefaultCallbacks: true,
            done: function(subcname, corpname, payload){
                if(payload.error){
                    SkE.showToast(_("subcorpusCreateFail", [payload.error]), {duration: 10000})
                } else{
                    SkE.showToast(_("subcorpusCreated", [subcname]))
                    if(!corpname || corpname == this.getActualCorpname()){
                        this._loadCorpusBonito(this.getActualCorpname())
                    }
                }
            }.bind(this, subcname, corpname),
            fail: payload => {
                SkE.showError("Could not create subcorpus.", getPayloadError(payload))
            }
        })

        delay(function(request){
            if(request.xhr.state() == "pending"){
                SkE.showToast(_("suborpusCreating"), {duration: 8000})
            }
        }.bind(this, request), 1500)
    }

    renameSubcorpus(corpname, subcorp_id, name){
        let subcorpus = this.data.corpus.subcorpora.find(s => s.n == subcorp_id)
        subcorpus.isSaving = true
        Connection.get({
            url: window.config.URL_BONITO + "subcorp_rename",
            data: {
                corpname: corpname,
                subcorp_id: subcorp_id,
                new_subcorp_name: name
            },
            done: function(subcorpus, name, payload){
                subcorpus.name = name
                this.data.subcorpora.find(s => s.value == subcorpus.n).label = name
                SkE.showToast(_("suborpusRenamed"))
            }.bind(this, subcorpus, name),
            fail: function(){
                SkE.showToast(_("suborpusRenameFail"))
            },
            always: function(subcorpus){
                delete subcorpus.isSaving
                this.trigger("subcorpusRenameDone", subcorpus)
            }.bind(this, subcorpus)
        })
    }

    deleteSubcorpus(subcname){
        Connection.get({
            url: window.config.URL_BONITO + "subcorp",
            data: {
                corpname: this.getActualCorpname(),
                delete: true,
                subcname: subcname
            },
            done: function(payload){
                SkE.showToast(_("subcorpusDeleted", [payload.subcname]))
                this._loadCorpusBonito(this.getActualCorpname())
            }.bind(this),
            fail: payload => {
                SkE.showToast(_("subcorpusDeleteFail", [payload.error]), {duration: 10000})
            }
        })
    }

    getSubcorpusName(subcorp_id){
        let subcorp = this.data.corpus.subcorpora.find(s => s.n == subcorp_id)
        return subcorp ? subcorp.name : subcorp_id
    }

    changeActualFeatureStore(store){
        this.data.actualFeatureStore = store
    }

    _checkCovid19Corpus(corpname){
        if(corpname == "preloaded/covid19" && LocalStorage.get("covid19_agreed") == null){
            Dispatcher.trigger("openDialog", {
                id: "covid19Agreement",
                title: "Terms of use",
                tag: "external-text",
                showCloseButton: false,
                dismissible: false,
                onTop: true,
                opts: {
                    text: "covid19.html"
                },
                buttons: [{
                    label: _("cancel"),
                    onClick: function(){
                        Dispatcher.trigger("closeDialog")
                        this.changeCorpus(null)
                    }.bind(this)
                }, {
                    label: _("agree"),
                    class: "btn-primary",
                    onClick: function(corpname){
                        LocalStorage.set("covid19_agreed", 1)
                        this.loadCorpus(corpname)
                        Dispatcher.trigger("closeDialog")
                    }.bind(this, corpname)
                }]
            })
            return true
        }
        return false
    }

    _loadCorpusCA(corpname){
        this.data.corpus = this.data.corpus || {}
        this.data.corpusCALoaded = false
        Connection.get({
            loadingId: "corpus",
            url: window.config.URL_CA + "corpora/" + corpname,
            done: this._onCorpusCALoaded.bind(this),
            fail: (payload, request) => {
                this._onUnsetCorpus()
                if(request.xhr.status == 403){
                    SkE.showError(_("corpusNotAllowed"))
                } else{
                    this._defaultOnFail(payload)
                }
            }
        })
    }

    _loadCorpusBonito(corpname){
        if (!corpname) {
            console.log('AppStore: Tried to load corp_info info with undefined corpname.')
            return
        }
        this.data.corpus = this.data.corpus || {}
        this.data.corpusBonitoLoaded = false
        Connection.get({
            loadingId: "corp_info",
            url: window.config.URL_BONITO + "corp_info",
            data: {
                subcorpora: 1,
                struct_attr_stats: 1,
                corpname: corpname
            },
            done: this._onCorpusBonitoLoaded.bind(this),
            fail: (payload) => {
                this._onCorpusBonitoLoadFail(payload)
                this._defaultOnFail(payload)
            }
        })
    }

    _reset(){
        this.data = {
            activeFeature: null,
            corpus: null,
            corpusListLoaded: false,
            corpusBonitoLoaded: false,
            corpusCALoaded: false,
            languageListLoaded: false,
            canBeCompiledLoaded: false,
            corpusList: [],
            subcorpora: [{label: _("fullCorpus"), value: ''}],
            languageList: [],
            availableLanguageList: [], // languages with at least one corpus actually loaded
            compRefCorpList: [],
            actualFeatureStore: null,
            refKeywordsCorpname: '',
            bgJobs: [],
            bgJobsPrev: [],
            bgJobsNotify: false,
            bgJobsTimer: null,
            features: {},
            wattrs: ['word', 'lc', 'lemma', 'lemma_lc'],
            gdexConfs: [],
            gdfexConfsLoaded: false,
            raw: {
                bonito: null,
                ca: null
            }
        }
    }

    _formatWsposlist(data) {
        let wsposlist = data.wsposlist
        if (!wsposlist || !wsposlist.length) {
            return []
        }
        var l = []
        if (wsposlist.length) {
            l.push({value: '', origLabel: 'auto'})
        }

        wsposlist.forEach(w => {
            let escaped = window.escapeCharacters(w[0], "\"\\")
            l.push({
                value: w[1],
                origLabel: w[0]
            })
        })
        return this._translatePosList(l, "wsl_")
    }

    _formatPoslist(poslist, prefix) {
        poslist = poslist.map(w => {
            return {
                value: w[1],
                origLabel: w[0]
            }
        })
        poslist.sort(this._sortByList.bind(this, ["noun", "verb", "adjective", "adverb", "pronoun", "conjunction", "preposition"]))
        return this._translatePosList(poslist, prefix)
    }

    _translatePosList(poslist, prefix){
        poslist.forEach(item => {
            let escaped = window.escapeCharacters(item.origLabel, "\"\\")
            item.label = _(prefix + escaped, {_: item.origLabel}), //try to translate or use original label
            item.labelP = _(prefix + escaped + "P", {_: item.origLabel})
        })
        return poslist
    }

    _translateStructuresAndAttributes(structures){
        structures.forEach(s => {
            s.attributes.forEach(a => {
                a.label = _(`sa_${s.name}_${a.name}`, {_: a.origLabel})
            })
        })
    }

    _formatPeriods(data) {
        let diachronic = data.diachronic
        let a = new Array()
        if (!diachronic) {
            return a
        }
        let structures = data.structures
        for (let i=0; i<diachronic.length; i++) {
            let s = diachronic[i].split('.')
            let o = new Object()
            o.name = diachronic[i]
            o.value = diachronic[i]
            o.label = ''
            for (let j=0; j<structures.length; j++) {
                if (structures[j].name == s[0]) {
                    let sa = structures[j].attributes
                    for (let k=0; k<sa.length; k++) {
                        if (sa[k].name == s[1]) {
                            o.label = sa[k].label
                            break
                        }
                    }
                    if (o.label) {
                        break
                    }
                }
            }
            o.label = o.label || o.value // label could not be find
            a.push(o)
        }
        return a
    }

    _cmpCompCorp(a, b) {
        // put featured first, then by size
        if (a.is_featured && !b.is_featured) return -1
        if (b.is_featured && !a.is_featured) return 1
        if (a.tokens > b.tokens) return -1
        if (a.tokens < b.tokens) return 1
        return 0
    }

    _getReferences(data) {
        let l = [
            {
                value: "#",
                labelId: "cc.tokenNumber"
            },
            {
                value: data.docstructure,
                labelId: "cc.documentNumber"
            }
        ]
        for (let i=0; i<data.structures.length; i++) {
            for (let j=0; j<data.structures[i].attributes.length; j++) {
                let value =  data.structures[i].name + "."
                            + data.structures[i].attributes[j].name
                l.push({
                    value: value,
                    label: data.structures[i].attributes[j].label || value
                })
            }
        }
        return l
    }

    _processCorpusBonitoData(data){
        data.structures.forEach(s => {
            s.attributes.forEach(a => {
                a.origLabel = a.label
            })
        })
        this._translateStructuresAndAttributes(data.structures)
        let attributes = this._attributesComputeValues(data)
        return Object.assign(data, {
            corpname: data.request.corpname,
            language_name: data.lang, // temporary, reading lang from bonito instead language_name form CA
            attributes: attributes,
            wposlist: this._formatPoslist(data.wposlist, "wpl_"),
            lposlist: this._formatPoslist(data.lposlist, "lpl_"),
            diachronic: this._formatPeriods(data),
            references: this._getReferences(data),
            wsattr: data.wsattr || "word",
            preloaded: data.request.corpname.indexOf('preloaded') == 0,
            wsposlist: this._formatWsposlist(data),
            hasLemma:  attributes && attributes.findIndex(attr => attr.name == "lemma") != -1,
            hasStarAttr: !!data.starattr,
            hasDocfAttr: !!data.structures.find(s => s.name == data.docstructure)
        })
    }

    _onCorpusCALoaded(payload){
        SkE.hideNotification("oldCorpus")
        if(payload.error){
            // TODO: what next?
            SkE.showError(getPayloadError(payload))
            return
        }
        if (payload.data) {
            this.data.raw.ca = payload.data
            this.data.corpusCALoaded = true;

            ["is_featured", "user_can_read", "language_name", "is_shared",
                    "access_level", "reference_corpus", "user_can_manage",
                    "tagset_id", "language_id", "corpname", "tags", "is_sgdev",
                    "owner_id", "owner_name", "can_be_upgraded", "id",
                    "available_structures", "expert_mode","file_structure",
                    "onion_structure", "sketch_grammar_id", "term_grammar_id",
                    "docstructure", "terms_of_use", "progress", "new_version",
                    "needs_recompiling", "document_count", "use_all_structures",
                    "user_can_refer", "user_can_upload"].forEach(key => {
                this.data.corpus[key] = payload.data[key]
            })
            this.data.corpus.refKeywordsCorpname = payload.data.reference_corpus != payload.data.corpname ? payload.data.reference_corpus : ""
            this._filterCompatibleCorporaLists()
            this.data.corpusBonitoLoaded && this._onCorpusLoadCompleted()
        }
    }

    _onUnsetCorpus(payload){
        this.data.corpus = null
        this.data.canBeCompiledLoaded = false
        this._refreshFeatures()
        this.trigger("corpusChanged")
    }

    _onCorpusProgressChange(corpus_id, progress){
        if(this.data.corpus
                && this.data.corpus.corpname // corpus is not {}
                && this.data.corpus.id == corpus_id
                && this.data.corpus.progress != progress){
            this.data.corpus.progress = progress
            this._calculateStatus()
            this._refreshFeatures()
            this.trigger("corpusStatusChanged")
        }
    }

    _onLoginAsDone(){
        if(this.data.corpus && this.data.corpus.id){
            this._onUnsetCorpus()
        }
    }

    _onLocalizationChange(){
        if(this.data.corpusBonitoLoaded){
            this._translatePosList(this.data.corpus.lposlist, "lpl_")
            this._translatePosList(this.data.corpus.wposlist, "wpl_")
            this._translatePosList(this.data.corpus.wsposlist, "wsl_")
            this._translateStructuresAndAttributes(this.data.corpus.structures)
        }
    }

    _calculateStatus(){
        let corpus = this.data.corpus
        let empty = !corpus.sizes || corpus.sizes.tokencount == 0
        if(corpus){
            if(!corpus.id){
                this.status = this.COMPILED
                corpus.isCompiled = true
                return
            }
            let progress = corpus.progress
            let status
            if(progress == 100){
                if(!corpus.needs_recompiling){
                    status = this.COMPILED
                } else{
                    status = this.TO_BE_COMPILED
                }
            } else if(progress == -1){
                status = this.COMPILATION_FAILED
            } else if(progress == 0){
                if(this.data.canBeCompiledLoaded && corpus.compilationNotAllowedReason == this.TAGGING){
                    status = this.TAGGING
                } else{
                    if(empty){
                        status = this.EMPTY
                    } else{
                        status = this.READY
                    }
                }
            } else {
                status = this.COMPILING
            }

            corpus.status = status
            corpus.isEmpty = empty
            corpus.hasDocuments = corpus.document_count > 0
            corpus.isReady = status == this.READY
            corpus.isCompiled = status == this.COMPILED
            corpus.isToBeCompiled = status == this.TO_BE_COMPILED
            corpus.isChecking = status == this.CHECKING
            corpus.isCompiling = status == this.COMPILING
            corpus.isTagging = status == this.TAGGING
            corpus.isCancelling = status == this.CANCELLING
            corpus.isCompilationFailed = status == this.COMPILATION_FAILED
            this.trigger("statusChange", this.status)
        }
    }

    _onCorpusBonitoLoaded(payload) {
        if (payload.error) {
            SkE.showError(getPayloadError(payload))
            this._onCorpusBonitoLoadFail(payload)
            return
        } else {
            if(!this.data.corpus){
                //loading corpus info from CA failed
                return
            }
            this.data.raw.bonito = payload
            this.data.corpusBonitoLoaded = true
            Object.assign(this.data.corpus, this._processCorpusBonitoData(payload))

            this.data.subcorpora = []
            this.data.subcorpora.push({
                label: _("fullCorpus"),
                value: ''
            })
            let sl = payload.subcorpora || []
            for (let i = 0; i < sl.length; i++) {
                this.data.subcorpora.push({
                    label: sl[i].name,
                    value: sl[i].n,
                    struct: sl[i].struct,
                    query: sl[i].query
                })
            }
            this._filterCompatibleCorporaLists();
            (window.config.NO_CA || this.data.corpusCALoaded) && this._onCorpusLoadCompleted()
            this.trigger("subcorporaChanged", this.data.subcorpora)
        }
    }

    _onCorpusLoadCompleted(){
        if(this.data.corpus.new_version){
            SkE.showNotification({
                id: "oldCorpus",
                tag: "new-corpus-notification",
                opts:{
                    corpus: this.data.corpus
                }
            })
        }
        this._calculateStatus()
        this._refreshFeatures()
        Dispatcher.trigger("CORPUS_INFO_LOADED", this.data.corpus)
        this.trigger("corpusChanged")
    }

    _onCorpusBonitoLoadFail(payload) {
        this.data.corpus = null
        this.data.subcorpora = [{label: _("fullCorpus"), value: ''}]
        this.trigger("corpusChanged", null)
        this.trigger("subcorporaChanged", {})
    }

    _filterCompatibleCorporaLists() {
        let tc = this.data.corpus
        if (!this.data.corpusList.length || $.isEmptyObject(tc)) {
            return;
        }
        this.data.compRefCorpList = []

        const addCorpIntoList = (list, corpus, kwComp, termsComp) => {
            list.push({
                label: corpus.name,
                value: corpus.corpname,
                is_featured: corpus.is_featured,
                tokens: corpus.sizes ? corpus.sizes.tokencount : 0,
                kwComp: kwComp,
                termsComp: termsComp
            })
        }
        const cmpFunc = (a, b) => {
            if (a.kwComp > b.kwComp) return -1
            if (a.kwComp < b.kwComp) return 1
            if (a.termsComp > b.termsComp) return -1
            if (a.termsComp < b.termsComp) return 1
            if (a.is_featured && !b.is_featured) return -1
            if (b.is_featured && !a.is_featured) return 1
            if (a.tokens > b.tokens) return -1
            if (a.tokens < b.tokens) return 1
            return 0
        }
        if (window.config.NO_CA) {
            this.data.corpusList.forEach(c => {
                if (c.language_name.toUpperCase() == tc.language_name.toUpperCase()) {
                    addCorpIntoList(this.data.compRefCorpList, c, this.FEATURE_FULL_COMPATIBILITY, this.FEATURE_FULL_COMPATIBILITY)
                }
            }, this)
        } else {
            let ti = tc.tagset_id
            let td = tc.termdef
            let kwComp
            let termsComp
            let sameLanguage
            let sameTagset
            let sameTermdef
            let sameSuffix
            this.data.corpusList.forEach(c => {
                if (!c.user_can_read && !c.user_can_refer) return
                kwComp = this.FEATURE_NA
                termsComp = this.FEATURE_NA
                sameLanguage = c.language_id == tc.language_id
                sameTagset = ti && ti == c.tagset_id
                sameTermdef = c.termdef && td == c.termdef
                sameSuffix = td && ((c.termdef.endsWith("wsdef.m4") && td.endsWith("wsdef.m4"))
                             || (c.termdef.endsWith("termdef.m4") && td.endsWith("termdef.m4")))

                if(sameLanguage && sameTermdef){
                    termsComp = this.FEATURE_FULL_COMPATIBILITY  // same termdefs and language
                } else if(sameTagset && sameSuffix){
                    termsComp = this.FEATURE_PART_COMPATIBILITY // same tagset and file extension
                }
                if(sameTagset){
                    kwComp = this.FEATURE_FULL_COMPATIBILITY
                } else if(sameLanguage){
                    kwComp = this.FEATURE_PART_COMPATIBILITY  // just same language
                }
                if(kwComp != this.FEATURE_NA || termsComp != this.FEATURE_NA){
                    addCorpIntoList(this.data.compRefCorpList, c, kwComp, termsComp)
                }
            }, this)
        }

        this.data.compRefCorpList.sort(cmpFunc)
        let idx
        if (!this.data.corpus.refKeywordsCorpname && this.data.compRefCorpList.length) {
            idx = (tc.corpname == this.data.compRefCorpList[0].value && this.data.compRefCorpList.length > 1) ? 1 : 0
            this.data.corpus.refKeywordsCorpname = this.data.compRefCorpList[idx].value
        }
        this.trigger("compatibleCorporaListChanged", this.data.compRefCorpList)
    }

    _onCorpusListLoaded(payload) {
        this.data.corpusListLoaded = true
        this.data.corpusList = payload.data
        this.data.corpusList.forEach(c => {
            c.tagsStr = c.tags.join(", ")
        })
        this._filterCompatibleCorporaLists()
        this._refreshAvailableLanguageList()
        this.trigger("corpusListChanged", this.data.corpusList)
    }

    _onLanguageListLoaded(payload){
        this.data.languageListLoaded = true
        this.data.languageList = payload.data.sort((a, b) => {
            return a.name.localeCompare(b.name)
        })
        this._refreshAvailableLanguageList()
        this.trigger('languageListLoaded', payload.data)
    }

    _attributesComputeValues(data){
        // adds calculated values to attributes
        // isLc - is item lowercase
        // lc - name of lowercase variant
        // label - adds name to label if label is missing
        let attributes = data.attributes
        let hasLemma_lc = attributes.findIndex(a => {return a.name == "lemma_lc"}) != -1
        attributes.forEach((attr) => {
            if(attr.name == "lemma"){
                attr.isLc = false
                attr.lcFrom = ""
                attr.lc = hasLemma_lc ? "lemma_lc" : ""
            } else if(attr.name == "lemma_lc"){
                attr.isLc = true
                attr.lcFrom = "lemma"
                attr.lc = ""
            } else {
                attr.isLc = attr.dynamic == "utf8lowercase"
                let lcAttr = attributes.find((attr2) => {
                    return attr2.dynamic == "utf8lowercase" && attr2.fromattr === attr.name
                })
                let lcFrom = attributes.find((attr2) => {
                    return attr.dynamic == "utf8lowercase" && attr.fromattr === attr2.name
                })
                attr.lc = lcAttr ? lcAttr.name : ""
                attr.lcFrom = lcFrom ? lcFrom.name : ""
            }
            attr.value = attr.name
            if(!attr.label){
                attr.label = attr.name
            }
            let label = attr.label
            if(attr.isLc && attr.lcFrom){
                label = attr.lcFrom
            }
            attr.label_en = label
            attr.label = _(label, {_: label})
            attr.labelP = _(label + "P", {_: label}) // try to translate or keep label
            if(attr.isLc && attr.lcFrom){
                attr.label_en += " (" + _("lowercase") + ")"
                attr.label += " (" + _("lowercase") + ")"
                attr.labelP += " (" + _("lowercase") + ")"
            }
        })

        attributes.sort(this._sortByList.bind(this, ["word", "lemma", "lemma_lc", "tag"]))

        return attributes
    }

    _sortByList(order, a, b){
        // compare function for array.sort, items are sorted acording to position in "order"
        let orderA = order.indexOf(a.label)
        let orderB = order.indexOf(b.label)
        orderA = orderA == -1 ? Infinity : orderA //unknown -> to the end
        orderB = orderB == -1 ? Infinity : orderB
        if(orderA < orderB){
            return -1
        } else if(orderA > orderB){
            return 1
        }
        return 0
    }

    _refreshAvailableLanguageList(){
        this.data.availableLanguageList = []
        if(this.data.languageListLoaded && this.data.corpusListLoaded){
            let usedLang = new Set()
            this.data.corpusList.forEach(c => {
                usedLang.add(c.language_id)
            })
            this.data.availableLanguageList = this.data.languageList.filter(l => {
                return usedLang.has(l.id)
            })
        }
    }

    _refreshFeatures(){
        let corpus = this.data.corpus
        let ready = corpus && (!corpus.id || corpus.progress == 100)
        this.data.ready = ready
        this.data.features = {
            wordsketch: ready && !!corpus.wsdef,
            sketchdiff: ready && !!corpus.wsdef,
            thesaurus: ready && !!corpus.wsdef,
            concordance: ready,
            parconcordance: ready && corpus.aligned.length !== 0,
            wordlist: ready,
            ngrams: ready,
            keywords: ready,
            trends: ready && corpus.diachronic.length,
            ocd: ready,
            annotation: ready
        }
    }

    _removeCorpusFromList(corpus_id){
        this.data.corpusList = this.data.corpusList.filter(corpus => {
            return corpus.id != corpus_id
        })
        this.trigger("corpusListChanged")
    }

    _defaultOnFail(payload, request){
        payload.error && SkE.showError(getPayloadError(payload))
    }
}

export let AppStore = new AppStoreClass()
