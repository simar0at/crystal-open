<ca-use-keywords-dialog class="ca-use-keywords-dialog">
    <div if={selection.length}>
        <div class="chip" each={seedWord in selection}>
            <i class="close material-icons" onclick={onItemDeselect}>close</i>
            {seedWord}
        </div>
    </div>
    <div class="row">
        <div class="col s12 m6 relative" style="min-height: 300px;">
            <div if={!k_refCorpname}>
                <h5 class="grey-text">{_("kw.keywordsNotAvailable")}</h5>
            </div>
            <div if={k_isLoading}>
                <preloader-spinner center=1></preloader-spinner>
            </div>
            <div if={k_isError}>
                <br>
                <h5 class="grey-text">{_("somethingWentWrong")}</h5>
                <br>
            </div>
            <ui-filtering-list if={k_allOptions.length}
                    name="keywords"
                    riot-value=""
                    options={k_listOptions}
                    size=8
                    show-all=1
                    full-height=1
                    on-change={onItemSelect}></ui-filtering-list>
            <div if={!k_isLoading && !k_isError && !k_allOptions.length}>
                <br>
                <h5 class="grey-text">{_("noKeywordsFound")}</h5>
                <br>
            </div>
        </div>
        <div class="col s12 m6 relative" style="min-height: 300px;">
            <div if={!k_refCorpname}>
                <h5 class="grey-text">{_("kw.termsNA")}</h5>
            </div>
            <div if={t_isLoading}>
                <preloader-spinner center=1></preloader-spinner>
            </div>
            <div if={t_isError}>
                <br>
                <h5 class="grey-text">{_("somethingWentWrong")}</h5>
                <br>
            </div>
            <ui-filtering-list if={t_allOptions.length}
                    name="terms"
                    riot-value=""
                    options={t_listOptions}
                    size=8
                    show-all=1
                    full-height=1
                    on-change={onItemSelect}></ui-filtering-list>
            <div if={!t_isLoading && !t_isError && !t_allOptions.length}>
                <br>
                <h5 class="grey-text">{_("noTrendsFound")}</h5>
                <br>
            </div>
        </div>
    </div>

    <script>
        const {Connection} = require("core/Connection.js")
        const {CAStore} = require("ca/castore.js")

        this.selection = []
        this.k_isError = false
        this.k_allOptions = []
        this.k_listOptions = []
        this.t_isError = false
        this.t_allOptions = []
        this.t_listOptions = []
        this.k_refCorpname = CAStore.corpus.refKeywordsCorpname
        this.termsCheckInterval = 2000
        this.seed_words = []
        CAStore.get("filesets").forEach(fileset => {
            fileset.web_crawl && fileset.web_crawl.seed_words && fileset.web_crawl.seed_words.forEach(word => {
                this.seed_words.push(word.toLowerCase())
            }, this)
        }, this)

        onItemSelect(value, name, label){
            this.selection.unshift(value)
            this.update()
        }

        onItemDeselect(evt){
            this.selection.splice(this.selection.indexOf(evt.item.seedWord), 1)
            evt.stopPropagation()
        }

        optionGenerator(option){
            return '<b>' + option.label + '</b><span class="badge small teal">' + _("alreadyUsed") +'</span>'
        }

        getListOptions(allOptions){
            return allOptions.filter(option => {
                return !this.selection.includes(option.value)
            }, this).map(option => {
                if(this.seed_words.includes(option.value.toLowerCase())){
                    option.generator = this.optionGenerator
                }
                return option
            }, this)
        }

        updateOptionLists(){
            this.k_listOptions = this.getListOptions(this.k_allOptions)
            this.t_listOptions = this.getListOptions(this.t_allOptions)
        }

        loadKeywords(){
            this.k_isLoading = true
            this.k_activeRequest = Connection.get({
                url: window.config.URL_BONITO + "extract_keywords",
                data: {
                    minfreq: 1,
                    max_keywords: 150,
                    simple_n: 1,
                    alnum: true,
                    onealpha: true,
                    attr: "lemma",
                    format: "json",
                    keywords: true,
                    corpname: CAStore.corpus.corpname,
                    ref_corpname: this.k_refCorpname,
                    wlpat: ".*"
                },
                done: (payload) => {
                    if(payload.error){
                        this.k_isError = true
                        return
                    }
                    if(payload.keywords){
                        this.k_allOptions = payload.keywords.map((item, idx) => {
                            return {
                                value: item.item,
                                label: item.item
                            }
                        })
                    }
                    this.k_isLoading = false
                },
                fail: payload => {
                    this.k_isLoading = false
                    this.k_isError = true
                    SkE.showError("Could not load keywords.", getPayloadError(payload))
                },
                always: () => {
                    this.update()
                }
            })
        }

        loadTerms(){
            this.t_isLoading = true
            this.t_activeRequest = Connection.get({
                url: window.config.URL_BONITO + "extract_keywords",
                data: {
                    minfreq: 1,
                    max_keywords: 150,
                    simple_n: 1,
                    alnum: true,
                    onealpha: true,
                    attr: "TERM",
                    terms: true,
                    corpname: CAStore.corpus.corpname,
                    ref_corpname: this.k_refCorpname,
                    wlpat: ".*"
                },
                done: (payload) => {
                    if(payload.jobid){
                        this.chekTermsHandle = setTimeout(this.loadTerms.bind(this), this.termsCheckInterval)
                        if(this.termsCheckInterval < 15000){
                            this.termsCheckInterval += 2000
                        }
                        return
                    } else {
                        this.chekTermsHandle = null
                        this.termsCheckInterval = 2000
                        this.t_bgjob = null
                    }
                    if(payload.error){
                        this.t_isError = true
                        return
                    }
                    if(payload.keywords){
                        this.t_allOptions = payload.keywords.map((item, idx) => {
                            return {
                                value: item.item,
                                label: item.item
                            }
                        })
                    }
                    this.t_isLoading = false
                },
                fail: payload => {
                    this.t_isLoading = false
                    this.t_isError = true
                    SkE.showError("Could not load terms.", getPayloadError(payload))
                },
                always: () => {
                    this.update()
                }
            })
        }

        this.k_refCorpname && this.loadKeywords()
        this.k_refCorpname && this.loadTerms()

        this.on("update", this.updateOptionLists)

        this.on("unmount", () => {
            this.k_activeRequest && Connection.abortRequest(this.k_activeRequest)
            this.t_activeRequest && Connection.abortRequest(this.t_activeRequest)
            this.chekTermsHandle && clearTimeout(this.chekTermsHandle)
        })

    </script>
</ca-use-keywords-dialog>
