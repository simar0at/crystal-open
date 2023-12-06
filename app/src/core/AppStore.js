const {Connection} = require('core/Connection.js')
const {StoreMixin} = require("core/StoreMixin.js")

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

        this._reset()

        Dispatcher.on("CA_CORPUS_PROGRESS", this._onCorpusProgressChange.bind(this))
        Dispatcher.on("ON_LOGIN_AS_DONE", this._onLoginAsDone.bind(this))
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
        return this.data.corpusList.find((corpus) => {
            return corpus.id == corpus_id
        })
    }

    getSubcorpus(subcname){
        return this.data.subcorpora.find(s => {
            return s.value == subcname
        })
    }

    getLatestCorpusVersion(corpus){
        let latest = typeof corpus == "object" ? corpus : this.getCorpusByCorpname(corpus)
        while(latest.new_version){
            latest = this.getCorpusByCorpname(latest.new_version)
        }
        return latest
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

    getScript(){
        return this.data.corpus ? this.data.scripts[this.data.corpus.language_id] : null
    }

    hasCorpusFeature(feature){
        return !!this.data.features[feature]
    }

    loadBgJobs() {
        let self = this
        this.data.bgJobsRequest && this.data.bgJobsRequest.xhr.abort()
        this.data.bgJobsRequest = Connection.get({
            url: window.config.URL_BONITO + 'jobs?format=json&finished=true',
            done: (payload) => {
                self.data.bgJobs = payload.jobs || []
                self.data.bgJobs.sort((a, b) => {
                    return new Date(b.starttime) - new Date(a.starttime)
                })
                let someRunning = false
                for (let i=0; i<self.data.bgJobs.length; i++) {
                    let stat = self.data.bgJobs[i].status[0]
                    let jid = self.data.bgJobs[i].jobid
                    let previ = self.data.bgJobsPrev.indexOf(jid)
                    if (previ >= 0) {
                        if (stat != "R" && stat != "D" && stat != "S") {
                            self.data.bgJobsNotify = true
                            SkE.showToast(_("bj.notifyFinish"), 10000)
                            self.data.bgJobsPrev.splice(previ, 1)
                        }
                    }
                    else if (stat == "R" || stat == "D" || stat == "S") {
                        someRunning = true
                        self.data.bgJobsPrev.push(jid)
                    }
                }
                self.data.bgJobsRequest = null
                Dispatcher.trigger('BGJOBS_UPDATED', self.data.bgJobs)
                if (someRunning) {
                    if (!self.data.bgJobsPeriodic) {
                        self.data.bgJobsPeriodic = setInterval(self.loadBgJobs.bind(self), 60*1000)
                    }
                }
                else {
                    self.data.bgJobsPeriodic && clearInterval(self.data.bgJobsPeriodic)
                }
            }
        })
    }

    loadAnyCorpus(corpname) {
        Connection.get({
            url: window.config.URL_BONITO + "corp_info",
            query: {
                subcorpora: 1,
                corpname: corpname
            },
            done: (payload) => {
                Dispatcher.trigger('ANY_CORPUS_LOADED', this._processCorpusBonitoData(payload))
            }
        })
    }

    loadCorpus(corpname){
        if(!corpname){
            console.log("AppStore: Tried to load corpus info with undefined corpname.")
            return
        }
        this.data.corpus = {}
        this.data.canBeCompiledLoaded = false
        !window.config.NO_CA && this._loadCorpusCA(corpname)
        this._loadCorpusBonito(corpname)
    }

    loadCorpusList(){
        this.data.corpusListLoaded = false
        Connection.get({
            url: window.config.URL_CA + "/corpora",
            query: null,
            done: this._onCorpusListLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadLanguageList(){
        Connection.get({
            url: window.config.URL_CA + "/languages",
            query: null,
            done: this._onLanguageListLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }


    loadCanBeCompiled(){
        Connection.get({
            url: window.config.URL_CA + "/corpora/" + this.data.corpus.id + "/can_be_compiled",
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
            }.bind(this)
        })
    }

    loadGDEXConfs(){
        !this.data.gdexConfsLoaded && Connection.get({
            url: window.config.URL_CA + "/gdexconfs",
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
            if(!corpus.user_can_read){
                if(corpus.access_on_demand) {
                    if(corpus.terms_of_use) {
                        Dispatcher.trigger("openDialog", {
                            content: corpus.terms_of_use,
                            small: true,
                            buttons: [{
                                label: _("agree"),
                                onClick: function(corpus){
                                    Connection.get({
                                        xhrParams: {
                                            method: "POST",
                                            data: JSON.stringify({}),
                                            contentType: "application/json"
                                        },
                                        url: window.config.URL_CA + "/corpora/" + corpus.corpname + "/agree_to_terms",
                                        done: function(corpus){
                                            this.loadCorpusList()
                                            this.loadCorpus(corpus.corpname)
                                        }.bind(this, corpus)
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
                this.loadCorpus(corpname)
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
                        url: window.config.URL_CA + "/corpora/" + corpus_id,
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
            url: window.config.URL_CA + "/corpora/" + corpus_id,
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

    createSubcorpus(subcname, params) {
        let ttQuery = ""
        let struct = ""
        let q = ""

        for(let ttName in params.textTypes){
            let ttValue = params.textTypes[ttName]
            ttValue = Array.isArray(ttValue) ? ttValue : [ttValue]
            ttQuery = ttValue.reduce((query, val) => { return query += `&${ttName}=${encodeURIComponent(val)}`}, ttQuery)
        }
        if(params.struct){
            struct = "&struct=" + params.struct
        }
        if(params.q){
            q = "&" + params.q
        }

        let request = Connection.get({
            url: `${window.config.URL_BONITO}subcorp?corpname=${this.getActualCorpname()}`,
            query: `&create=True&format=json&subcname=${subcname}${q}${struct}${ttQuery}`,
            skipDefaultCallbacks: true,
            done: function(subcname, payload){
                if(payload.error){
                    SkE.showToast(_("subcorpusCreateFail", [payload.error]), {duration: 10000})
                } else{
                    SkE.showToast(_("subcorpusCreated", [subcname]))
                    this._loadCorpusBonito(this.getActualCorpname())
                }
            }.bind(this, subcname)
        })

        delay(function(request){
            if(request.xhr.state() == "pending"){
                SkE.showToast(_("suborpusCreating"), {duration: 8000})
            }
        }.bind(this, request), 1500)
    }


    deleteSubcorpus(subcname){
        Connection.get({
            url: window.config.URL_BONITO + "subcorp",
            query: {
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

    changeActualFeatureStore(store){
        this.data.actualFeatureStore = store
    }

    _loadCorpusCA(corpname){
        this.data.corpusCALoaded = false
        Connection.get({
            loadingId: "corpus",
            url: window.config.URL_CA + "/corpora/" + corpname,
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
        this.data.corpusBonitoLoaded = false
        Connection.get({
            loadingId: "corp_info",
            url: window.config.URL_BONITO + "corp_info",
            query: {
                subcorpora: 1,
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
            scripts: {},
            availableLanguageList: [], // languages with at least one corpus actually loaded
            compTermsCorpList: [],
            compKeywordsCorpList: [],
            actualFeatureStore: null,
            refKeywordsCorpname: '',
            refTermsCorpname: '',
            bgJobs: [],
            bgJobsPrev: [],
            bgJobsNotify: false,
            bgJobsPeriodic: null,
            features: {},
            wattrs: ['word', 'lc', 'lemma', 'lemma_lc'],
            gdexConfs: [],
            gdfexConfsLoaded: false
        }
    }

    _formatWsposlist(data) {
        let wsposlist = data.wsposlist
        if (!wsposlist || !wsposlist.length) {
            return []
        }
        var l = []
        if (wsposlist.length) {
            l.push({value: '', label: 'auto'})
        }
        for (let i=0; i<wsposlist.length; i++) {
            l.push({value: wsposlist[i][1], label: wsposlist[i][0]})
        }
        return l
    }

    _formatPoslist(poslist) {
        return poslist.map(w => {
            let label = _(w[0], {_: w[0]})
            return {
                value: w[1],
                label: label,
                labelP: _(w[0] + "P", {_: label})
            }
        }).sort(this._sortByList.bind(this, ["noun", "verb", "adjective", "adverb", "pronoun", "conjunction", "preposition"]))
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
        if (!a.sizes) return 1
        if (!b.sizes) return -1
        if (a.sizes.tokens > b.sizes.tokens) return -1
        if (a.sizes.tokens < b.sizes.tokens) return 1
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
        return Object.assign(data, {
            corpname: data.request.corpname,
            language_name: data.lang, // temporary, reading lang from bonito instead language_name form CA
            attributes: this._attributesComputeValues(data),
            wposlist: this._formatPoslist(data.wposlist),
            lposlist: this._formatPoslist(data.lposlist),
            diachronic: this._formatPeriods(data),
            references: this._getReferences(data),
            wsattr: data.wsattr || "word",
            preloaded: data.request.corpname.indexOf('preloaded') == 0,
            wsposlist: this._formatWsposlist(data)
        })
    }

    _onCorpusCALoaded(payload){
        SkE.hideNotification("oldCorpus")
        if(payload.error){
            // TODO: what next?
            SkE.showError(payload.error)
            return
        }
        if (payload.data) {
            this.data.corpusCALoaded = true;

            ["is_featured", "user_can_read", "language_name", "is_shared",
                    "access_on_demand", "reference_corpus", "user_can_manage",
                    "tagset_id", "language_id", "corpname", "tags",
                    "term_reference_corpus", "is_sgdev",
                    "owner_id", "owner_name", "can_be_upgraded", "id",
                    "available_structures", "expert_mode","file_structure",
                    "onion_structure", "sketch_grammar_id", "term_grammar_id",
                    "docstructure", "terms_of_use", "progress", "new_version",
                    "needs_recompiling", "document_count", "use_all_structures"].forEach(key => {
                this.data.corpus[key] = payload.data[key]
            })
            this.data.corpus.refKeywordsCorpname = payload.data.reference_corpus != payload.data.corpname ? payload.data.reference_corpus : ""
            this.data.corpus.refTermsCorpname = payload.data.term_reference_corpus != payload.data.corpname ? payload.data.term_reference_corpus : ""
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

    _calculateStatus(){
        let corpus = this.data.corpus
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
                    if(corpus.document_count == 0){
                        status = this.EMPTY
                    } else{
                        status = this.READY
                    }
                }
            } else {
                status = this.COMPILING
            }

            corpus.status = status
            corpus.isEmpty = corpus.document_count == 0
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
            SkE.showError(payload.error)
            return
        } else {
            if(!this.data.corpus){
                //loading corpus info from CA failed
                return
            }
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
                    label: sl[i].n,
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
        this.trigger("corpusChanged")
    }

    _onCorpusBonitoLoadFail(payload) {
        this.data.subcorpora = [{label: _("fullCorpus"), value: ''}]
        this.trigger("subcorporaChanged", {})
    }

    _filterCompatibleCorporaLists() {
        let tc = this.data.corpus
        if (!this.data.corpusList.length || $.isEmptyObject(tc)) {
            return;
        }
        this.data.compTermsCorpList = []
        this.data.compKeywordsCorpList = []
        if (window.config.NO_CA) {
            this.data.corpusList.forEach(c => {
                if (c.language_name.toUpperCase() == tc.language_name.toUpperCase()) {
                    this.data.compKeywordsCorpList.push({
                        label: c.name,
                        value: c.corpname,
                        featured: c.is_featured,
                        tokens: c.sizes ? c.sizes.tokencount : 0
                    })
                }
                if (c.language_name.toUpperCase() == tc.language_name.toUpperCase()) {
                    this.data.compTermsCorpList.push({
                        label: c.name,
                        value: c.corpname,
                        featured: c.is_featured,
                        tokens: c.sizes ? c.sizes.tokencount : 0
                    })
                }
            }, this)
        } else {
            let ti = tc.tagset_id
            this.data.corpusList.forEach(c => {
                if (!c.user_can_read) return
                if ((ti && ti == c.tagset_id) || c.language_id == tc.language_id) {
                    this.data.compKeywordsCorpList.push({
                        label: c.name,
                        value: c.corpname,
                        featured: c.is_featured,
                        tokens: c.sizes ? c.sizes.tokencount : 0
                    })
                }
                if (ti && ti == c.tagset_id) {
                    this.data.compTermsCorpList.push({
                        label: c.name,
                        value: c.corpname,
                        featured: c.is_featured,
                        tokens: c.sizes ? c.sizes.tokencount : 0
                    })
                }
            }, this)
        }
        this.data.compTermsCorpList.sort(this._cmpCompCorp)
        this.data.compKeywordsCorpList.sort(this._cmpCompCorp)
        if (!this.data.corpus.refTermsCorpname && this.data.compTermsCorpList.length) {
            this.data.corpus.refTermsCorpname = this.data.compTermsCorpList[0].value
        }
        if (!this.data.corpus.refKeywordsCorpname && this.data.compKeywordsCorpList.length) {
            this.data.corpus.refKeywordsCorpname = this.data.compKeywordsCorpList[0].value
        }
        this.trigger("compatibleCorporaListChanged", {
            t: this.data.compTermsCorpList,
            k: this.data.compKeywordsCorpList
        })
    }

    _onCorpusListLoaded(payload) {
        this.data.corpusListLoaded = true
        this.data.corpusList = payload.data
        this._filterCompatibleCorporaLists()
        this._refreshAvailableLanguageList()
        this.trigger("corpusListChanged", this.data.corpusList)
    }

    _onLanguageListLoaded(payload){
        this.data.languageListLoaded = true
        this.data.languageList = payload.data.sort((a, b) => {
            return a.name.localeCompare(b.name)
        })
        this._refreshScripts()
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
            attr.label = _(label, {_: label})
            attr.labelP = _(label + "P", {_: label}) // try to translate or keep label
            if(attr.isLc && attr.lcFrom){
                attr.labelP += " (" + _("lowercase") + ")"
                attr.label += " (" + _("lowercase") + ")"
            }
            attr.ignoreCaseAllowed = !data.unicameral && !!attr.lc
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

    _refreshScripts(){
        this.data.scripts = {}
        this.data.languageList.forEach(l => {
            this.data.scripts[l.id] = l.script
        }, this)
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
            ocd: ready
        }
    }

    _removeCorpusFromList(corpus_id){
        this.data.corpusList = this.data.corpusList.filter(corpus => {
            return corpus.id != corpus_id
        })
        this.trigger("corpusListChanged")
    }

    _defaultOnFail(payload, request){
        payload.error && SkE.showError(payload.error)
    }
}

export let AppStore = new AppStoreClass()

