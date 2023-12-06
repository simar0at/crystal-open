<wiki-dialog class="wiki-dialog">
    <h5 class="grey-text">{_("kw.wikisearchInfo")}</h5>
    <ol>
        <li each={wl in opts.items}>
            <a href={"https://" + opts.language_id + '.wikipedia.org/wiki/' + wl.title.replace(' ', '_')}
                    target="_blank">{wl.title} <i class="material-icons tiny">open_in_new</i></a>
        </li>
    </ol>
</wiki-dialog>

<wipo-tab class="wipo-tab">
    <div if={!data.w_isLoading && !data.w_isError && data.w_showItems.length}>
        <div class="resultOptions mb-4">
            <result-filter-chip></result-filter-chip>
            <ui-switch name="w_single"
                    label-id="kw.single"
                    inline=1
                    on-change={onWOptionChange}
                    riot-value={store.data.w_single}>
            </ui-switch>
            <ui-input-file name="wipo_blacklist"
                    inline=1
                    label-id={"blacklist"}
                    on-change={handleFileSelect}
                    multiple={false}>
            </ui-input-file>
        </div>
        <column-table ref="table-wipo"
                class="resultsWithRefCorpname {hasRefValues: data.showrefvalues}"
                show-line-nums={data.showLineNumbers}
                items={data.w_showItems}
                col-meta={colMeta}
                thead-meta={theadMeta}
                start-index={data.w_showResultsFrom}>
        </column-table>
        <ui-pagination
                if={data.w_items.length > 10}
                count={data.w_items.length}
                items-per-page={data.w_itemsPerPage}
                actual={data.w_page}
                on-change={store.changePage.bind(store)}
                on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                show-prev-next={true}>
        </ui-pagination>
    </div>
    <div if={!data.w_isLoading && !data.w_showItems.length && !data.w_jobid} class="resultsDataNA">
        {_("na")}
    </div>
    <bgjob-card if={data.w_jobid}
            is-loading={data.w_isBgJobLoading}
            desc={data.w_raw.desc}
            progress={data.w_raw.processing}></bgjob-card>
    <div class="center-align pt-32">
        <preloader-spinner if={data.w_isLoading} big={1} show-academic-warning=1></preloader-spinner>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        this.store = this.parent.parent.store

        handleFileSelect(files) {
            let reader = new FileReader()
            reader.readAsText(files[0], "UTF-8")
            reader.onload = function(e) {
                this.store.data.wlblacklist = e.target.result
                this.store.search(true)
            }.bind(this)
        }

        onWOptionChange(val, name) {
            this.store.data[name] = val
            this.store.updateUrl()
            this.store.search(true)
        }

        updateAttributes(){
            this.data = this.parent.parent.data
            this.colMeta = this.parent.parent.getColMeta("w")
            this.theadMeta = this.parent.parent.getTheadMeta("w")
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</wipo-tab>





<keywords-tab class="keywords-tab">
    <span class="tooltipped warn"
            data-tooltip={_("kw.wrongKeywordsRef")}
            if={data.ref_corpname == store.corpus.corpname && data.ref_usesubcorp == store.data.usesubcorp}>
        <i class="material-icons orange-text">warning</i>
    </span>
    <div if={!data.k_isLoading && !data.k_isError && data.k_showItems.length && !data.k_jobid}>
        <div class="resultOptions">
            <swap-corpora url={store.getSwapUrl(data.ref_corpname, data.ref_usesubcorp)}
                    corpus-name={data.k_raw.reference_corpus_name}
                    subcorpus-name={data.ref_usesubcorp}></swap-corpora>
            <span class="totalItems color-blue-200">
                ({_("wl.items")}:&nbsp;<b>{window.Formatter.num(data.k_totalcnt)}</b>)
            </span>
            <result-filter-chip></result-filter-chip>
        </div>
        <column-table ref="table-keywords"
                class="resultsWithRefCorpname {hasRefValues: data.showrefvalues}"
                show-line-nums={data.showLineNumbers}
                items={data.k_showItems}
                col-meta={colMeta}
                thead-meta={theadMeta}
                start-index={data.k_showResultsFrom}>
        </column-table>
        <ui-pagination
                if={data.k_items.length > 10}
                count={data.k_items.length}
                items-per-page={data.k_itemsPerPage}
                actual={data.k_page}
                on-change={store.changePage.bind(store)}
                on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                show-prev-next={true}>
        </ui-pagination>
    </div>
    <result-error
            if={data.k_error && !data.k_isLoading}
            error={data.k_error}
            page="keywords">
    </result-error>
    <div if={!data.k_isLoading && (data.k_isEmpty || data.k_isEmptySearch) && !data.k_isError && !data.k_jobid} class="resultsDataNA">
        {_("kw.emptyResult")}
    </div>
    <bgjob-card if={data.k_jobid}
            is-loading={data.k_isBgJobLoading}
            desc={data.k_raw.desc}
            progress={data.k_raw.processing}></bgjob-card>
    <div class="center-align pt-32">
        <preloader-spinner if={data.k_isLoading} big={1} show-academic-warning=1></preloader-spinner>
    </div>

    <script>
        this.store = this.parent.parent.store

        updateAttributes(){
            this.data = this.parent.parent.data
            this.colMeta = this.parent.parent.getColMeta("k")
            this.theadMeta = this.parent.parent.getTheadMeta("k")
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</keywords-tab>





<terms-tab class="terms-tab">
    <span class="tooltipped warn"
            data-tooltip={_("kw.wrongTermsRef")}
            if={data.ref_corpname == store.corpus.corpname && data.ref_usesubcorp == store.data.usesubcorp}>
        <i class="material-icons orange-text">warning</i>
    </span>
    <div if={!data.t_isLoading && !data.t_isError && data.t_showItems.length && !data.t_jobid}>
        <div class="resultOptions">
            <swap-corpora url={store.getSwapUrl(data.ref_corpname, data.ref_usesubcorp)}
                    corpus-name={data.t_raw.reference_corpus_name}
                    subcorpus-name={data.ref_usesubcorp}></swap-corpora>
            <span class="totalItems color-blue-200">
                ({_("wl.items")}:&nbsp;<b>{window.Formatter.num(data.t_totalcnt)}</b>)
            </span>
            <result-filter-chip></result-filter-chip>
        </div>
        <column-table ref="table-terms"
                class="resultsWithRefCorpname {hasRefValues: data.showrefvalues}"
                show-line-nums={data.showLineNumbers}
                items={data.t_showItems}
                col-meta={colMeta}
                thead-meta={theadMeta}
                start-index={data.t_showResultsFrom}>
        </column-table>
        <ui-pagination
                if={data.t_items.length > 10}
                count={data.t_items.length}
                items-per-page={data.t_itemsPerPage}
                actual={data.t_page}
                on-change={store.changePage.bind(store)}
                on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                show-prev-next={true}>
        </ui-pagination>
    </div>
    <result-error
            if={data.t_error && !data.t_isLoading && !data.t_notAvailable && data.ref_corpname}
            error={data.t_error}
            page="keywords">
    </result-error>
    <div if={!data.t_isLoading && !data.t_jobid && (data.t_notAvailable || !data.ref_corpname)} class="resultsDataNA">
        {_("kw.termsNA")}
    </div>
    <div if={!data.t_isLoading && (data.t_isEmpty || data.t_isEmptySearch) && !data.t_notAvailable && data.ref_corpname && !data.t_error && !data.t_jobid} class="resultsDataNA">
        {_("kw.emptyResult")}
    </div>
    <bgjob-card if={data.t_jobid}
            is-loading={data.t_isBgJobLoading}
            desc={data.t_raw.desc}
            progress={data.t_raw.processing}></bgjob-card>
    <div class="center-align pt-32">
        <preloader-spinner if={data.t_isLoading} big={1} show-academic-warning=1></preloader-spinner>
    </div>

    <script>
        this.store = this.parent.parent.store

        updateAttributes(){
            this.data = this.parent.parent.data
            this.colMeta = this.parent.parent.getColMeta("t")
            this.theadMeta = this.parent.parent.getTheadMeta("t")
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</terms-tab>





<ngrams-tab class="ngrams-tab">
    <div if={!data.n_isLoading && !data.n_isError && data.n_showItems.length && !data.n_jobid}>
        <div class="resultOptions">
            <span class="tooltipped"
                    if={tokencount > 1000000000 || refTokencount > 1000000000}
                    data-tooltip={_("ng.warn2G")}
                    style="vertical-align: middle;">
                <i class="material-icons red-text" style="font-size: 45px;">
                    error
                </i>
            </span>
            <swap-corpora url={store.getSwapUrl(data.ref_corpname, data.ref_usesubcorp)}
                    corpus-name={data.n_raw.reference_corpus_name}
                    subcorpus-name={data.ref_usesubcorp}></swap-corpora>
            <span class="totalItems color-blue-200">
                ({_("wl.items")}:&nbsp;<b>{window.Formatter.num(data.n_totalcnt)}</b>)
            </span>
            <result-filter-chip></result-filter-chip>
        </div>
        <column-table ref="table-terms"
                class="resultsWithRefCorpname {hasRefValues: data.showrefvalues}"
                show-line-nums={data.showLineNumbers}
                items={data.n_showItems}
                col-meta={colMeta}
                thead-meta={theadMeta}
                start-index={data.n_showResultsFrom}>
        </column-table>
        <ui-pagination
                if={data.n_items.length > 10}
                count={data.n_items.length}
                items-per-page={data.n_itemsPerPage}
                actual={data.n_page}
                on-change={store.changePage.bind(store)}
                on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                show-prev-next={true}>
        </ui-pagination>
    </div>
    <result-error
            if={data.n_error && !data.n_isLoading && data.ref_corpname}
            error={data.n_error}
            page="keywords">
    </result-error>
    <div if={!data.n_isLoading && (data.n_isEmpty || data.n_isEmptySearch) && data.ref_corpname && !data.n_error && !data.n_jobid} class="resultsDataNA">
        {_("kw.emptyResult")}
    </div>
    <bgjob-card if={data.n_jobid}
            is-loading={data.n_isBgJobLoading}
            desc={data.n_raw.desc}
            progress={data.n_raw.processing}></bgjob-card>
    <div class="center-align pt-32">
        <preloader-spinner if={data.n_isLoading} big={1} show-academic-warning=1></preloader-spinner>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")
        this.store = this.parent.parent.store

        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.data = this.parent.parent.data
            this.colMeta = this.parent.parent.getColMeta("n")
            this.theadMeta = this.parent.parent.getTheadMeta("n")
            this.focusTokencount = AppStore.data.corpus.sizes.tokencount
            let refCorpus = stores.app.getCorpusByCorpname(this.data.ref_corpname)
            this.refTokencount = refCorpus ? refCorpus.sizes.tokencount : null
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</ngrams-tab>





<keywords-result class="keywords-result">
    <ui-tabs ref="tabs"
            tabs={tabs}
            active={store.data.ktab}
            on-tab-change={onTabChange}>
    </ui-tabs>
    <screen-overlay event-name="WIKI_SEARCH_LOADING"></screen-overlay>

    <interfeature-menu ref="interfeatureMenu"
            is-feature-link-active={isFeatureLinkActive}
            links={interFeatureMenuLinks}
            get-feature-link-params={getFeatureLinkParams}>
    </interfeature-menu>

    <script>
        const {Auth} = require('core/Auth.js')

        this.tooltipPosition = "top"
        this.mixin("tooltip-mixin")
        this.mixin("feature-child")

        getTabs(){
            let tabs = []
            if(!this.data.onlywipo){
                this.data.usekeywords && tabs.push({
                    tabId: "keywords",
                    labelId: "kw.singlewords",
                    tag: "keywords-tab",
                    icon: "timelapse"
                })
                this.data.useterms && tabs.push({
                    tabId: "terms",
                    labelId: "kw.multiwordsTerms",
                    tag: "terms-tab",
                    icon: "timelapse"
                })
                this.data.usengrams && tabs.push({
                    tabId: "ngrams",
                    labelId: "ngrams",
                    tag: "ngrams-tab",
                    icon: "timelapse"
                })
            }
            if (Auth.isWIPO()) {
                tabs.push({
                    tabId: "wipo",
                    labelId: "kw.wipo",
                    tag: "wipo-tab",
                    icon: "timelapse"
                })
            }
            return tabs
        }
        this.tabs = this.getTabs()

        getColMeta(prefix){
            let colMeta = [{
                id: "item",
                label: _("word"),
                word: true,
                class: "_t"
            }]
            if (this.data.showcounts) {
                colMeta.push({
                    id: "frq1",
                    class: "frq1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" : "frequency"),
                    formatter: window.Formatter.num.bind(Formatter)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "frq2",
                    class: "frq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter)
                })
            }
            if (this.data.showrelfrq) {
                colMeta.push({
                    id: "rel_frq1",
                    class: "rel_frq1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" :  "relfreq"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "rel_frq2",
                    class: "rel_frq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
            }

            if(this.data.showdocf){
                colMeta.push({
                    id: "docf1",
                    class: "docf1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" : (this.store.corpus.hasStarAttr ? "mr" : "wl.docf")),
                    formatter: window.Formatter.num.bind(Formatter)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "docf2",
                    class: "docf2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter)
                })
            }

            if(this.data.showreldocf){
                colMeta.push({
                    id: "rel_docf1",
                    class: "rel_docf1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" : (this.store.corpus.hasStarAttr ? "relmr" : "reldocf")),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "rel_docf2",
                    class: "rel_docf2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
            }

            if(this.data.showarf){
                colMeta.push({
                    id: "arf1",
                    class: "arf1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" : "arf"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "arf2",
                    class: "arf2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
            }

            if(this.data.showaldf){
                colMeta.push({
                    id: "aldf1",
                    class: "aldf1",
                    num: 1,
                    label: _(this.data.showrefvalues ? "focus" : "aldf"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
                this.data.showrefvalues && colMeta.push({
                    id: "aldf2",
                    class: "aldf2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.columnTableValueFormatter.bind(this, 2)
                })
            }

            if(this.data.showavgstar){
                colMeta.push({
                    id: "star1",
                    class: "star1",
                    num: 1,
                    label: _("focus"),
                    formatter: this.store.starFormatter
                })
                this.data.showrefvalues && colMeta.push({
                    id: "star2",
                    class: "star2",
                    num: 1,
                    label: _("reference"),
                    formatter: this.store.starFormatter
                })
            }

            if (this.data.showscores) {
                colMeta.push({
                    id: "score",
                    class: "score",
                    label: _("kw.score"),
                    num: 1,
                    tooltip: "t_id:kw_r_k_score",
                    formatter: window.columnTableValueFormatter.bind(this, 1)
                })
            }
            if (this.data.showwikisearch) {
                colMeta.push({
                    id: "wikisearch",
                    class: "wikisearch",
                    num: 0,
                    generator: function (item, colMeta) {
                        return "<a javascript=\"void(0);\" title=\"" +
                                _("kw.wikisearch") +
                                "\" class=\"iconButton btn btn-flat btn-floating serif\">W</a>"
                    },
                    onclick: function(item, colMeta, evt) {
                        this.getWikiLinks(item.item)
                    }.bind(this)
                })
            }
            colMeta.push({
                id: 'menu',
                class: 'col-tab-menu',
                menu: 1,
                generator: (item, colMeta) => {
                    return "<a class=\"iconButton btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, {
                        item: item,
                        coltype: prefix
                    })
                }.bind(this)
            })
            return colMeta
        }

        getTheadMeta(prefix){
            let theadMeta = null
            if(this.data.showrefvalues && (this.data.showcounts || this.data.showrelfrq
                || this.data.showdocf || this.data.showreldocf
                || this.data.showarf || this.data.showaldf
                || this.data.showavgstar)){
                theadMeta = [{}]
                this.data.showLineNumbers && theadMeta.push({})
                if(this.data.showcounts){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_frq\">" + _("frequency") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showrelfrq){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_relfrq\">" + _("relfreq") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showdocf){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"" + (this.store.corpus.hasStarAttr ? "t_id:mr" : "t_id:docf") + "\">"
                                + _(this.store.corpus.hasStarAttr ? "mr" : "wl.docf")
                                + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showreldocf){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"" + (this.store.corpus.hasStarAttr ? "t_id:relmr" : "t_id:reldocf") + "\">"
                                + _(this.store.corpus.hasStarAttr ? "relmr" : "reldocf")
                                + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showarf){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:arf\">"
                                + _("arf")
                                + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showaldf){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:aldf\">"
                                + _("aldf")
                                + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showavgstar){
                    theadMeta.push({
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:star\">" + _("star") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }

                theadMeta.push({})
                this.data.showwikisearch && theadMeta.push({})
                this.data.showscores && theadMeta.push({})
            }
            return theadMeta
        }

        getWikiLinks(query) {
            $.ajax({
                xhrFields: {
                    withCredentials: true
                },
                url: window.config.URL_BONITO + "wikisearch",
                beforeSend: function () {
                    Dispatcher.trigger("WIKI_SEARCH_LOADING", true)
                },
                data: {
                    corpname: this.store.corpus.corpname,
                    query: query,
                    langid: this.store.corpus.language_id
                }
            })
            .done((payload) => {
                Dispatcher.trigger("WIKI_SEARCH_LOADING", false)
                Dispatcher.trigger("openDialog", {
                    tag: "wiki-dialog",
                    fixedFooter: true,
                    opts: {
                        language_id: this.store.corpus.language_id,
                        items: payload.query.search,
                        total: payload.query.searchinfo.totalhits
                    }
                })
                this.update()
            })
            .fail(()=>{
                console.log("ERROR")
            })
        }

        onTabChange(tabId) {
            this.store.data.ktab = tabId
            this.store.updateUrl()
            this.store.saveUserOptions(["ktab"])
            if(this[tabId + "_needUpdate"]){
                this[tabId + "_needUpdate"] = false
                this.store.filterResults()
                this.refs.tabs.refs["content-" + tabId].update()
            }
        }

        this.interFeatureMenuLinks = []
        if(this.data.attr == "lemma"){
            this.interFeatureMenuLinks = [{
                name: "wordsketch",
                feature: "wordsketch",
                labelId: "kw.wordsketchFocus"
            }, {
                name: "wordsketchRef",
                feature: "wordsketch",
                labelId: "kw.wordsketchRef",
                prefix: "ref_"
            }]
        }

        this.interFeatureMenuLinks = this.interFeatureMenuLinks.concat([{
            name: "concordance",
            feature: "concordance",
            labelId: "kw.concordanceFocus",
            prefix: ""
        }, {
            name: "concordanceMacro",
            feature: "concordance",
            labelId: "concordanceMacro",
            prefix: ""
        }, {
            name: "concordanceRef",
            feature: "concordance",
            labelId: "kw.concordanceRef",
            prefix: "ref_"
        }])

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let params = {
                tab: 'advanced',
                corpname: featureParams.prefix == "ref_" ? this.store.data.ref_corpname : this.store.corpus.corpname,
                usesubcorp: featureParams.prefix == "ref_" ? this.data.ref_usesubcorp : this.store.data.usesubcorp
            }
            if(feature == "concordance"){
                let query = rowData.item.query.substr(1)
                Object.assign(params, {
                    queryselector: 'cql',
                    cql: query,//rowData.coltype == 'k' ? query : '[term(2,' + query + ')]',
                    selection: featureParams.prefix == "ref_" ? {} : this.store.data.tts
                })
            } else if(feature == "wordsketch") {
                Object.assign(params, {
                    lemma: rowData.item.item,
                    tts: featureParams.prefix == "ref_" ? {} : this.store.data.tts
                })
            }
            return params
        }

        isFeatureLinkActive(feature, item, event, link) {
            return link.prefix != 'ref_' || item.item.frq2
        }

        refreshTabs(){
            // update tabs only when needed - prevent results flickering due to
            // repeated redrawing. Once data in tab is loaded, tab icon should be
            // updated. Updating icon in this.tabs would invoke ui-tabs content to re-render.
            let tabs = this.getTabs()
            if(!objectEquals(tabs, this.tabs)){
                this.tabs = tabs
            }
        }

        getTabIcon(prefix){
            if (this.data[prefix + "isError"]
                    || this.data[prefix + "isEmpty"]
                    || ((prefix == "t_" || prefix == "w_") && this.data.t_notAvailable)){
                return "clear"
            } else if(this.data[prefix + "isLoading"] || this.data[prefix + "jobid"]){
                return "timelapse"
            }
            return "check"
        }

        refreshIcons(){
            ["keywords", "terms", "ngrams", "wipo"].forEach(feature => {
                $("#tab-link-" + feature + " i").html(this.getTabIcon(feature[0] + "_"))
            })
        }

        this.on('update', this.refreshTabs)
        this.on('updated', this.refreshIcons)
    </script>
</keywords-result>
