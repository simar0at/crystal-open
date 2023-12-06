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
    <div if={!data.w_isLoading && data.w_showItems.length}>
        <div class="row">
            <div class="col s12 m6">
                <ui-checkbox name="w_single"
                        label-id="kw.single"
                        class="inlineBlock"
                        on-change={onWOptionChange}
                        tooltip="t_id:kw_a_single"
                        checked={store.data.w_single}>
                </ui-checkbox>
                <ui-input-file name="wipo_blacklist"
                        label-id={"kw.wipoBL"}
                        on-change={handleFileSelect}
                        multiple={false}>
                </ui-input-file>
            </div>
            <div class="col s12 m6">
                <ui-input name="wipomaxitems"
                        ref="wipomaxitems"
                        riot-value={1000}
                        type="number"
                        size="6"
                        inline={1}
                        label-id="kw.wipoMaxitems">
                </ui-input>
                <button class="btn" onclick={downloadWIPO}>{_("download")}</button>
            </div>
        </div>
        <column-table ref="table-wipo"
                show-line-nums={data.showLineNumbers}
                items={data.w_showItems}
                col-meta={colMetaW}
                thead-meta={theadMeta}
                max-column-count={null}
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
    <div if={!data.w_isLoading && !data.w_showItems.length}>
        <div class="row">
            <div class="col s12 center-align">{_("na")}</div>
        </div>
    </div>
    <interfeature-menu ref="interfeatureMenu"
            is-feature-link-active={parent.parent.isFeatureLinkActive}
            links={parent.parent.interFeatureMenuLinks}
            get-feature-link-params={parent.parent.getFeatureLinkParams}>
    </interfeature-menu>
    <div class="center-align">
        <preloader-spinner if={data.w_isLoading} big={1}></preloader-spinner>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        this.data = this.parent.parent.data
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

        downloadWIPO() {
            this.store.wrequest.xhrParams.data["wlmaxitems"] = this.refs.wipomaxitems.value
            Connection.download(this.store.wrequest, 'csv')
        }

        setWColMeta() {
            this.colMetaW = [
                {
                    id: "item",
                    label: _("word"),
                    word: true,
                    class: "_w",
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }
            ]
            if (this.data.showcounts) {
                this.colMetaW.push({
                    id: "frq1",
                    class: "frq1",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "frq2",
                    class: "frq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showrelfrq) {
                this.colMetaW.push({
                    id: "relfrq1",
                    class: "rfrq1",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "relfrq2",
                    class: "rfrq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showscores) {
                this.colMetaW.push({
                    id: "score",
                    class: "score",
                    label: _("kw.score"),
                    num: 1,
                    tooltip: "t_id:kw_r_k_score",
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showwikisearch) {
                this.colMetaW.push({
                    id: "wikisearch",
                    class: "wikisearch",
                    num: 0,
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    },
                    generator: function (item, colMeta) {
                        return "<a javascript=\"void(0);\" title=\"" +
                                _("kw.wikisearch") +
                                "\" class=\"iconButton waves-effect waves-light btn btn-flat btn-floating serif\">W</a>"
                    },
                    onclick: function(item, colMeta, evt) {
                        this.parent.parent.getWikiLinks(item.item)
                    }.bind(this)
                })
            }
            this.colMetaW.push({
                id: 'menu',
                class: 'col-tab-menu',
                menu: 1,
                generator: (item, colMeta) => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, {
                        item: item,
                        coltype: "w"
                    })
                }.bind(this)
            })
        }
        this.setWColMeta()

        setTheadMeta(){
            this.theadMeta = null
            if(this.data.showcounts || this.data.showrelfrq){
                this.theadMeta = [{}]
                this.data.showLineNumbers && this.theadMeta.push({})
                if(this.data.showcounts){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_freq\">" + _("frequency") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showrelfrq){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_relfreq\">" + _("relativeFreq") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                this.theadMeta.push({})
                this.data.showscores && this.theadMeta.push({})
            }
        }
        this.setTheadMeta()

        this.on("update", function () {
            this.data = this.parent.parent.data
            this.setWColMeta()
            this.setTheadMeta()
        })
    </script>
</wipo-tab>

<keywords-tab class="keywords-tab">
    <span class="tooltipped warn"
            data-tooltip={_("kw.wrongKeywordsRef")}
            if={data.k_ref_corpname == store.corpus.corpname && data.k_ref_subcorp == store.data.usesubcorp}>
        <i class="material-icons orange-text">warning</i>
    </span>
    <div if={!data.k_isLoading && data.k_showItems.length}>
        <swap-corpora url={store.getSwapUrl(data.k_ref_corpname, data.k_ref_subcorp)}
                corpus-name={data.k_raw.reference_corpus_name}
                subcorpus-name={data.k_ref_subcorp}></swap-corpora>
        <column-table ref="table-keywords"
                show-line-nums={data.showLineNumbers}
                items={data.k_showItems}
                col-meta={colMetaK}
                thead-meta={theadMeta}
                max-column-count={null}
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
    <h6 if={!data.k_isLoading && data.k_isEmpty && !data.k_isError && !data.k_jobid} class="empty">
        {_("kw.emptyResult")}
    </h6>
    <h6 if={data.k_jobid}>
        {_("kw.keywordsBGJ")}
        <br />
        <a href="#bgjobs" style="margin-top: 1rem;" class="btn">{_("bgjobs")}</a>
    </h6>
    <interfeature-menu ref="interfeatureMenu"
            is-feature-link-active={parent.parent.isFeatureLinkActive}
            links={interFeatureMenuLinks}
            get-feature-link-params={parent.parent.getFeatureLinkParams}>
    </interfeature-menu>
    <div class="center-align">
        <preloader-spinner if={data.k_isLoading} big={1}></preloader-spinner>
    </div>

    <script>
        this.data = this.parent.parent.data
        this.store = this.parent.parent.store

        this.interFeatureMenuLinks = []
        if(this.data.attr == "lemma"){
            this.interFeatureMenuLinks = [{
                name: "wordsketch",
                feature: "wordsketch",
                label: "Words Sketch"
            }]
        }
        this.interFeatureMenuLinks = this.interFeatureMenuLinks.concat(this.parent.parent.interFeatureMenuLinks)

        setKColMeta() {
            this.colMetaK = [
                {
                    id: "item",
                    label: _("word"),
                    word: true,
                    class: "_k",
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }
            ]
            if (this.data.showcounts) {
                this.colMetaK.push({
                    id: "frq1",
                    class: "frq1 narrowCol",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "frq2",
                    class: "frq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showrelfrq) {
                this.colMetaK.push({
                    id: "rel_frq1",
                    class: "rfrq1 narrowCol",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "rel_frq2",
                    class: "rfrq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showscores) {
                this.colMetaK.push({
                    id: "score",
                    class: "score",
                    label: _("kw.score"),
                    num: 1,
                    tooltip: "t_id:kw_r_k_score",
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showwikisearch) {
                this.colMetaK.push({
                    id: "wikisearch",
                    class: "wikisearch",
                    num: 0,
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    },
                    generator: function (item, colMeta) {
                        return "<a javascript=\"void(0);\" title=\"" +
                                _("kw.wikisearch") +
                                "\" class=\"iconButton waves-effect waves-light btn btn-flat btn-floating serif\">W</a>"
                    },
                    onclick: function(item, colMeta, evt) {
                        this.parent.parent.getWikiLinks(item.item)
                    }.bind(this)
                })
            }
            this.colMetaK.push({
                id: 'menu',
                class: 'col-tab-menu',
                menu: 1,
                generator: (item, colMeta) => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, {
                        item: item,
                        coltype: "k"
                    })
                }.bind(this)
            })
            return this.colMeta
        }
        this.setKColMeta()

        setTheadMeta(){
            this.theadMeta = null
            if(this.data.showcounts || this.data.showrelfrq){
                this.theadMeta = [{}]
                this.data.showLineNumbers && this.theadMeta.push({})
                if(this.data.showcounts){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_t_freq\">" + _("frequency") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showrelfrq){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_t_relfreq\">" + _("relativeFreq") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                this.theadMeta.push({})
                this.data.showwikisearch && this.theadMeta.push({})
                this.data.showscores && this.theadMeta.push({})
            }
        }
        this.setTheadMeta()

        this.on("update", function () {
            this.data = this.parent.parent.data
            this.setKColMeta()
            this.setTheadMeta()
        })
    </script>
</keywords-tab>

<terms-tab class="terms-tab">
    <span class="tooltipped warn"
            data-tooltip={_("kw.wrongTermsRef")}
            if={data.t_ref_corpname == store.corpus.corpname && data.t_ref_subcorp == store.data.usesubcorp}>
        <i class="material-icons orange-text">warning</i>
    </span>
    <div if={!data.t_isLoading && data.t_showItems.length}>
        <swap-corpora url={store.getSwapUrl(data.t_ref_corpname, data.t_ref_subcorp)}
                corpus-name={data.t_raw.reference_corpus_name}
                subcorpus-name={data.t_ref_subcorp}></swap-corpora>
        <column-table ref="table-terms"
                show-line-nums={data.showLineNumbers}
                items={data.t_showItems}
                col-meta={colMetaT}
                thead-meta={theadMeta}
                max-column-count={null}
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
            if={data.t_error && !data.t_isLoading && !data.t_notAvailable && data.t_ref_corpname}
            error={data.t_error}
            page="keywords">
    </result-error>
    <h6 if={!data.t_isLoading && (data.t_notAvailable || !data.t_ref_corpname)}>
        {_("kw.termsNA")}
    </h6>
    <h6 if={!data.t_isLoading && data.t_isEmpty && !data.t_notAvailable && data.t_ref_corpname && !data.t_error && !data.t_jobid} class="empty">
        {_("kw.emptyResult")}
    </h6>
    <h6 if={data.t_jobid}>
        {_("kw.termsBGJ")}
        <br />
        <a href="#bgjobs" style="margin-top: 1rem;" class="btn">{_("bgjobs")}</a>
    </h6>
    <interfeature-menu ref="interfeatureMenu"
            is-feature-link-active={parent.parent.isFeatureLinkActive}
            links={parent.parent.interFeatureMenuLinks}
            get-feature-link-params={parent.parent.getFeatureLinkParams}>
    </interfeature-menu>
    <div class="center-align">
        <preloader-spinner if={data.t_isLoading} big={1}></preloader-spinner>
    </div>

    <script>
        this.data = this.parent.parent.data
        this.store = this.parent.parent.store

        setTColMeta() {
            this.colMetaT = [
                {
                    id: "item",
                    label: _("word"),
                    word: true,
                    class: "_t",
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }
            ]
            if (this.data.showcounts) {
                this.colMetaT.push({
                    id: "frq1",
                    class: "frq1",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "frq2",
                    class: "frq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showrelfrq) {
                this.colMetaT.push({
                    id: "rel_frq1",
                    class: "rfrq1",
                    num: 1,
                    label: _("focus"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                }, {
                    id: "rel_frq2",
                    class: "rfrq2",
                    num: 1,
                    label: _("reference"),
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showscores) {
                this.colMetaT.push({
                    id: "score",
                    class: "score",
                    label: _("kw.score"),
                    num: 1,
                    tooltip: "t_id:kw_r_k_score",
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    }
                })
            }
            if (this.data.showwikisearch) {
                this.colMetaT.push({
                    id: "wikisearch",
                    class: "wikisearch",
                    num: 0,
                    sort: {
                        descAllowed: false,
                        ascAllowed: false
                    },
                    generator: function (item, colMeta) {
                        return "<a javascript=\"void(0);\" title=\"" +
                                _("kw.wikisearch") +
                                "\" class=\"iconButton waves-effect waves-light btn btn-flat btn-floating serif\">W</a>"
                    },
                    onclick: function(item, colMeta, evt) {
                        this.parent.parent.getWikiLinks(item.item)
                    }.bind(this)
                })
            }
            this.colMetaT.push({
                id: 'menu',
                class: 'col-tab-menu',
                menu: 1,
                generator: (item, colMeta) => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, {
                        item: item,
                        coltype: "t"
                    })
                }.bind(this)
            })
        }
        this.setTColMeta()

        setTheadMeta(){
            this.theadMeta = null
            if(this.data.showcounts || this.data.showrelfrq){
                this.theadMeta = [{}]
                this.data.showLineNumbers && this.theadMeta.push({})
                if(this.data.showcounts){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_freq\">" + _("frequency") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                if(this.data.showrelfrq){
                    this.theadMeta.push({
                        class: "tooltipped",
                        content: "<span class=\"tooltipped\" data-tooltip=\"t_id:kw_r_k_relfreq\">" + _("relativeFreq") + "<sup>?</sup></span>",
                        colspan: 2
                    })
                }
                this.theadMeta.push({})
                this.data.showscores && this.theadMeta.push({})
            }
        }
        this.setTheadMeta()

        this.on("update", function () {
            this.data = this.parent.parent.data
            this.setTColMeta()
            this.setTheadMeta()
        })
    </script>
</terms-tab>

<keywords-result>
    <ui-tabs ref="tabs" tabs={ktabs} active={store.data.ktab}
            on-tab-change={onTabChange}>
    </ui-tabs>
    <screen-overlay event-name="WIKI_SEARCH_LOADING"></screen-overlay>

    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require('core/Auth.js')

        this.tooltipPosition = "top"
        this.mixin("tooltip-mixin")
        this.mixin("feature-child")

        this.ktabs = [
            {
                tabId: "keywords",
                labelId: "kw.singlewords",
                tag: "keywords-tab",
                icon: this.data.k_isLoading ? "timelapse" : ((this.data.k_isError || this.data.k_isEmpty) ? "clear" : "check")
            },
            {
                tabId: "terms",
                labelId: "kw.multiwords",
                tag: "terms-tab",
                icon: this.data.t_isLoading ? "timelapse" : ((this.data.t_isError || this.data.w_isEmpty) ? "clear" : "check")
            }
        ]
        if (Auth.isWIPO()) {
            this.ktabs.push({
                tabId: "wipo",
                labelId: "kw.wipo",
                tag: "wipo-tab",
                icon: this.data.w_isLoading ? "timelapse" : ((this.data.w_isError || this.data.w_isEmpty) ? "clear" : "check")
            })
        }

        getWikiLinks(query) {
            $.ajax({
                xhrFields: {
                    withCredentials: true
                },
                url: window.config.URL_BONITO + "wikisearch?corpname=" + this.store.corpus.corpname,
                beforeSend: function () {
                    Dispatcher.trigger("WIKI_SEARCH_LOADING", true)
                },
                data: {
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
            this.store.updatePageTag()
        }

        this.interFeatureMenuLinks = [{
            name: "concordance",
            feature: "concordance",
            labelId: "kw.concordanceFocus",
            prefix: ""
        }, {
            name: "concordanceRef",
            feature: "concordance",
            labelId: "kw.concordanceRef",
            prefix: "ref_"
        }]

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let params = {
                tab: 'advanced',
                usesubcorp: this.store.data.usesubcorp,
            }
            if(feature == "concordance"){
                let query = rowData.coltype == 'w' ? rowData.item[featureParams.prefix + 'seek'] : rowData.item[featureParams.prefix + 'query'].substr(1)
                Object.assign(params, {
                    queryselector: 'cql',
                    corpname: featureParams.prefix == "ref_" ? (this.store.data[rowData.coltype + '_ref_corpname']) : this.store.corpus.corpname,
                    cql: rowData.coltype == 'k' ? query : '[term(2,' + query + ')]',
                    selection: this.store.data.tts
                })
            } else if(feature == "wordsketch") {
                Object.assign(params, {
                    lemma: rowData.item.item,
                    tts: this.store.data.tts
                })
            }
            return params
        }

        isFeatureLinkActive(feature, item, event, link) {
            return link.prefix != 'ref_' || item.item.frq2
        }

        this.on('update', function () {
            this.ktabs[0].icon = this.data.k_isLoading ? "timelapse" : ((this.data.k_isError || this.data.k_isEmpty) ? "clear" : "check")
            this.ktabs[1].icon = this.data.t_isLoading ? "timelapse" : ((this.data.t_isError || this.data.t_isEmpty) ? "clear" : "check")
            if (this.ktabs.length > 2) {
                this.ktabs[2].icon = this.data.w_isLoading ? "timelapse" : ((this.data.w_isError || this.data.w_isEmpty) ? "clear" : "check")
            }
        })
    </script>
</keywords-result>
