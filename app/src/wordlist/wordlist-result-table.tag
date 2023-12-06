<wordlist-result-table class="wordlist-result-table">
    <div class={oneColumn: data.onecolumn}>
        <column-table ref="table"
            show-line-nums={data.showLineNumbers}
            items={data.showItems}
            col-meta={colMeta}
            max-column-count={data.onecolumn ? 1 : 0}
            start-index={data.showResultsFrom}
            order-by={data.wlsort}
            sort="desc"
            on-sort={onSort}></column-table>

            <div class="row">
                <div if={data.tab != "attribute"} class="inlineBlock left">
                    <div style="margin-bottom: 10px;">
                        <div if={data.wllimit} class="align-left text-hint">
                            {_( data.wllimit > data.wlmaxitems ? "wl.limit2" : "wl.limit", {limit: window.Formatter.num(data.wllimit), screenlimit: window.Formatter.num(data.wlmaxitems)})}
                            <a href={externalLink("wl_download_limits")} target="_blank">{_("links.wl_download_limits")}</a>
                        </div>
                        <div if={!data.wllimit && data.raw.total > 20000} class="align-left text-hint">
                            {_("wl.limit3", [window.Formatter.num(data.wllimit || 20000)])}
                            <a class="btn btn-flat btn-floating" onclick={onDownloadWordlistClick}>
                                <i class="material-icons blue-text">file_download</i>
                            </a>
                        </div>
                    </div>
                </div>
                <div class="inlineBlock right">
                    <ui-pagination
                        if={data.items.length > 10}
                        count={data.items.length}
                        items-per-page={data.itemsPerPage}
                        actual={data.page}
                        on-change={store.changePage.bind(store)}
                        on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                        show-prev-next={true}></ui-pagination>
                </div>
            </div>

            <interfeature-menu ref="interfeatureMenu"
                features={interfeatureMenuFeatures}
                is-Feature-link-active={isFeatureLinkActive}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>
        </div>

    <script>
        require("./wordlist-result-table.scss")
        const Meta = require("./Wordlist.meta.js")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.interfeatureMenuFeatures = window.config.NO_SKE ? ["concordance"] : ["concordance", "ngrams", "wordsketch", "thesaurus"]

        onSort(sort){
            this.store.searchAndAddToHistory({
                wlsort: sort.orderBy,
                page: 1
            })
        }

        onDownloadWordlistClick(){
            window.scrollTo(0, 0)
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "download")
        }

        addRelFreqColumn(){
            if(this.data.relfreq){
                let totalSize
                if(this.data.usesubcorp){
                    totalSize = this.corpus.subcorpora.find(s => {return s.n == this.data.usesubcorp}, this).tokens
                } else{
                    totalSize = this.corpus.sizes ? this.corpus.sizes.tokencount : 0
                }

                let col = {
                    id: "relfreq",
                    labelId: "perMillion",
                    num: true,
                    "generator": function(item, colMeta) {
                        let relfreq = (item.freq / totalSize) * 1000000
                        return window.Formatter.num(relfreq, {maximumFractionDigits: 5})
                    }.bind(this),
                }
                if(!this.data.values){
                    // absolut frequencies are not shown -> add sorting on relative frequencies
                    col.sort = {
                        orderBy: "f",
                        descAllowed: true,
                        ascAllowed: false
                    }
                }
                this.colMeta.push(col)
            }
        }

        addMenuColumn(){
            this.colMeta.push({
                id: "menu",
                "class": "menuColumn col-tab-menu",
                label: "",
                generator: () => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, item)
                }.bind(this)
            })
        }

        getFeatureLinkParams(feature, item){
            let options = this.data
            let attr = options.viewAs == 1 ? options.find : options.wlstruct_attr1
            let lpos = this.data.lpos ? this.data.lpos : ""
            let lemma = isDef(item.str) ? item.str : item.Word[0].n
            if(attr == "lempos"){
                let idx = lemma.lastIndexOf("-")
                if(idx != -1){
                    lpos = lemma.substr(idx)
                    lemma = lemma.substr(0, idx)
                }
            }

            if(feature == "concordance"){
                let cql = ""
                let attrs = ""
                if(this.data.tab == "attribute"){
                    cql = `<${this.data.wlattr.replace(".", " ")}=="${item.str}">[]`
                } else{
                    if(item.Word){
                        if(options.wlstruct_attr1 != options.wlattr
                                    && options.wlstruct_attr2 != options.wlattr
                                    && options.wlstruct_attr3 != options.wlattr){
                            // add wlattr if its not in showed columns
                            attrs = `${options.wlattr}="${this.store.getWlpat()}"`
                        }
                        item.Word.forEach((w, i) => {
                            attrs += attrs ? " & " : ""
                            attrs += `${options["wlstruct_attr" + (i + 1)]}=="${w.n}"`
                        })
                    } else{
                        attrs = `${options.wlattr}=="${item.str}${options.lpos}"`
                    }
                    cql = `[${attrs}]`
                }
                return {
                    tab: 'advanced',
                    queryselector: "cql",
                    default_attr: "word",
                    usesubcorp: options.usesubcorp,
                    selection: options.tts,
                    cql: cql
                }
            } else if(feature == "ngrams"){
                return {
                    tab: 'advanced',
                    ngrams_n: 2,
                    ngrams_max_n: 6,
                    usesubcorp: options.usesubcorp,
                    tts: options.tts,
                    criteria: [{
                        filter: "containingWord",
                        value: lemma
                    }]
                }
            } else if(feature == "wordsketch"){
                return {
                    tab: 'advanced',
                    lemma: lemma,
                    usesubcorp: options.usesubcorp,
                    tts: options.tts,
                    lpos: lpos
                }
            } else if(feature == "thesaurus"){
                return {
                    tab: 'advanced',
                    lemma: lemma,
                    lpos: lpos
                }
            }
        }

        setColMetaSimple(){
            let label = ""
            if(this.data.tab == "attribute"){
                label = _("wl.attrValue")
            } else if(AppStore.getLposByValue(this.data.find)){
                label = _("lemma")
            }  else {
                label = this.store.getFindLabel(this.data.find)
            }
            this.colMeta = [{
                id: "str",
                label: label,
                "class": "_t word",
                sort: {
                    orderBy: "",
                    descAllowed: true,
                    ascAllowed: false
                }
            }]
            if(this.data.values){
                this.colMeta.push({
                    id: "freq",
                    class: "freq",
                    label: this.countLabel,
                    num: true,
                    formatter: window.Formatter.num.bind(Formatter),
                    tooltip: "t_id:wl_r_" + this.data.wlnums,
                    sort: {
                        orderBy: "f",
                        descAllowed: true,
                        ascAllowed: false
                    }
                })
            }

            this.addRelFreqColumn()
            this.addMenuColumn()
        }

        setColMetaFindx(){
            let formatter = (digits, num) => {
                return window.Formatter.num(num, {maximumFractionDigits: digits})
            }
            this.colMeta = [{
                id: "word",
                label: this.data.raw && this.data.raw.wsattr ? _(this.data.raw.wsattr.split("_")[0]) : "",
                "class": "_t word"
            }]
            if(this.data.values){
                this.colMeta.push({
                    id: "freq",
                    class: "freq",
                    label: _("freq"),
                    num: true,
                    formatter: window.Formatter.num.bind(Formatter)
                })
            }
            if(this.data.showratio){
                this.colMeta.push({
                    id: "ratio",
                    class: "ratio",
                    label: _("ratio"),
                    num: true,
                    formatter: formatter.bind(this, 4)
                })
            }
            if(this.data.showrank){
                this.colMeta.push({
                    id: "rank",
                    class: "rank",
                    label: _("rank"),
                    num: true,
                    formatter: formatter.bind(this, 5)
                })
            }
        }

        setColMetaStructWordlist(){
            const cols = this.data.cols
            // user selected columns - wlattrs
            cols.forEach((col) => {
                if(typeof col.s == "number"){
                    this.colMeta.push({
                        id: col.s,
                        class: $.escapeSelector(col.n.trim()),
                        label: col.n,
                        selector: (item, colMeta) => {
                            return item.Word[colMeta.id].n
                        }
                    })
                }
            })
            // column with frequencies
            if(this.data.values){
                this.colMeta.push({
                    id: "freq",
                    class: "freq",
                    label: this.countLabel,
                    num: true,
                    formatter: window.Formatter.num.bind(Formatter)
                })
            }

            // column with bars
            if(this.data.bars){
                this.colMeta.push({
                    "id": "freq",
                    "label": "",
                    "class": "barsColumn",
                    "generator": function(item, colMeta) {
                        return '<div class="progress"><div class="determinate" style="width: ' + (item.fbar / 3) + '%;"></div></div>'
                    }.bind(this)
                })
            }

            if (this.data.raw.concsize == this.data.raw.fullsize) {
                this.addRelFreqColumn()
            }
            this.addMenuColumn()
        }

        setColMeta(){
            this.colMeta = []
            if(this.data.tab == "attribute"){
                this.countLabel = _(this.data.wlnums == "frq" ? "tokens" : "wl.docf")
                this.setColMetaSimple()
            } else if (this.data.histid){
                this.countLabel = this.data.raw.hist_desc
                this.setColMetaFindx()
            } else {
                this.countLabel = getLabel(Meta.wlnumsList.find(w => {
                    return w.value == this.data.wlnums
                }))
                if(this.data.wlstruct_attr1){
                    this.setColMetaStructWordlist()
                } else{
                    this.setColMetaSimple()
                }
            }
        }
        this.setColMeta()

        isFeatureLinkActive(feature){
            let attr = this.data.viewAs == 1 ? this.data.wlattr : this.data.wlstruct_attr1
            if(feature == "concordance"){
                return true
            } else if(feature == "ngrams"){
                return attr == "word" || attr == "lc" || attr == "tag"
            } else { // thesaurus, wordsketch
                return attr == "word" || attr == "lc" || attr == "lemma"
                        || attr == "lemma_lc" || attr == "lempos" || attr == "lempos_lc"
            }
        }

        this.on("update", this.setColMeta)
    </script>
</wordlist-result-table>
