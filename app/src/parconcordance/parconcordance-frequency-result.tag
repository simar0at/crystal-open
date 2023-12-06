<pcfreq-result-block class="pcfreq-result-block dividerTop">
    <div class="inlineBlock freq-block-div">
        <table class="material-table frequency-block">
            <thead>
                <tr>
                    <th></th>
                    <th each={h in opts.head} class="freq-th">
                        <table-label label={h.n}
                                order-by={h.s}
                                actual-order-by={data.freqSort}
                                actual-sort="desc"
                                desc-allowed={true}
                                on-sort={parent.parent.sortBy.bind(this, String(h.s))}>
                        </table-label>
                    </th>
                    <th if={data.freqShowRel} class="freq-th">
                        <table-label label={_("freqPerMillion")}
                                order-by="freq"
                                actual-order-by={data.freqSort}
                                actual-sort="desc"
                                desc-allowed={true}
                                on-sort={parent.sortBy.bind(this, "freq")}>
                        </table-label>
                    </th>
                    <th></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr each={item, idx in opts.items}
                        if={(idx >= fromline) && (idx <= toline)}>
                    <td class="col-tab-num">{window.Formatter.num(idx + 1)}</td>
                    <td each={w in item.Word}>{w.n}</td>
                    <td class="tab-num">{window.Formatter.num(item.freq)}</td>
                    <td if={item.rel} class="tab-num">
                            {window.Formatter.num(item.rel, {minimumFractionDigits: 1, maximumFractionDigits: 1})}</td>
                    <td if={data.freqShowRel} class="tab-num">
                            {window.Formatter.num(item.freq * 1000000 / corpsize, {minimumFractionDigits: 1, maximumFractionDigits: 1})}</td>
                    <td class="freqBar">
                        <div class="progress"
                                style={"height: " + (item.freqbar ? (item.freqbar + 1) : 6) +"px;"}>
                            <div class="determinate"
                                    style={"width: " + (item.fbar / 3) + "%;"}>
                            </div>
                        </div>
                    </td>
                    <td>
                        <a class="waves-effect waves-light btn btn-flat btn-floating {small: opts.details}"
                                onclick={onOpenMenuClick}>
                            <i class="material-icons menuIcon">more_horiz</i>
                        </a>
                    </td>
                </tr>
            </tbody>
        </table>

        <interfeature-menu ref="interfeatureMenu"
                links={interFeatureMenuLinks}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>


        <ui-pagination if={opts.items.length > 10}
                count={opts.items.length}
                items-per-page={itemsPerPage}
                actual={page}
                on-change={onPageChange}
                on-items-per-page-change={onItemsPerPageChange}
                show-prev-next={true}>
        </ui-pagination>
    </div>

    <script>
        this.mixin("feature-child")
        this.page = 1
        this.itemsPerPage = this.data.f_itemsPerPage
        this.corpsize = this.store.corpus.sizes.tokencount
        this.fromline = 0
        this.toline = this.fromline + this.itemsPerPage - 1

        onPageChange(page) {
            this.page = page
            this.fromline = (page-1) * this.itemsPerPage
            this.toline = page * this.itemsPerPage - 1
            this.update()
        }

        onItemsPerPageChange(itemsPerPage) {
            itemsPerPage = itemsPerPage * 1
            let actualPosition = this.itemsPerPage * (this.page - 1) + 1
            let newPage = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
            this.itemsPerPage = itemsPerPage
            this.onPageChange(newPage)
        }

        this.interFeatureMenuLinks = [{
            name: "parconcordance",
            feature: "parconcordance",
            labelId: "positiveFilter",
            pn: "p"
        }, {
            name: "parconcordanceNeg",
            feature: "parconcordance",
            labelId: "negativeFilter",
            pn: "n"
        }]

        onOpenMenuClick(evt){
            this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, evt.item.item)
        }

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let operations = copy(this.data.operations)
            rowData.Word.forEach((w, i) => {
                operations.push({
                    id: Math.floor((Math.random() * 10000)),
                    name: "filter",
                    arg: (featureParams.pn == "n" ? "not, " : "") + " " + w.n, // TODO add context
                    corpname: this.data.alignedCorpname,
                    query: {
                        q: featureParams.pn + rowData.pfilter_list[i].substring(1)
                    },
                    active: true
                })
            }, this)

            let params = {}
            this.store.urlOptions.forEach(option => {
                params[option] = this.data[option]
            })
            Object.assign(params, {
                tab: "advanced",
                page: 1,
                results_screen: "concordance",
                corpname: this.data.corpname,
                operations: operations
            })

            return params
        }
    </script>
</pcfreq-result-block>

<parconcordance-frequency-result class="frequency-result">
    <div class="content card">
        <div class="card-content">
            <div if={!data.freq_error}>
                <h4 class="header">
                    {_("frequency")}
                    <span style="font-size: 17px" class="grey-text"
                            if={data.freqDesc || data.alignedCorpname}>
                        (<virtual if={data.freqDesc}>{data.freqDesc}</virtual>
                        <span if={data.alignedCorpname}>
                        &mdash; {data.alignedCorpname}
                        </span>)
                    </span>
                    <span class="headerButtons">
                        &nbsp;
                        <a id="btnBackToConcordance" class="btn contrast" onclick={store.goBackToTheConcordance.bind(store)}>
                            {_("backToConcordance")}
                        </a>
                    </span>
                </h4>
                <pcfreq-result-block each={block in data.f_items}
                        if={!data.isLoading}
                        items={block.Items}
                        head={block.Head}>
                </pcfreq-result-block>
            </div>
            <result-error if={data.freq_error}
                    error={data.freq_error}
                    page="parconcordance"
                    button-label={_("backToConcordance")}>
            </result-error>
        </div>
    </div>

    <script>
        this.mixin("feature-child")

        sortBy(key) {
            this.data.freqSort = key
            this.store.f_search()
        }

        this.on("mount", () => {
            if(!this.data.f_hasBeenLoaded){
                this.store.f_search()
            }
        })
    </script>
</parconcordance-frequency-result>
