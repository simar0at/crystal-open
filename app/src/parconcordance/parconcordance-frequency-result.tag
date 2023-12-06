<pcfreq-result-block class="pcfreq-result-block dividerTop block_{opts.idx + 1}">
    <div class="inline-block freq-block-div">
        <table class="material-table frequency-block">
            <thead>
                <tr>
                    <th></th>
                    <th each={h in opts.head} class="frq-th">
                        <table-label label={h.n}
                                order-by={h.s}
                                actual-order-by={data.freqSort}
                                actual-sort="desc"
                                desc-allowed={true}
                                on-sort={parent.parent.sortBy.bind(this, String(h.s))}>
                        </table-label>
                    </th>
                    <th if={data.freqShowRel} class="frq-th">
                        <table-label label={_("freqPerMillion")}
                                order-by="frq"
                                actual-order-by={data.freqSort}
                                actual-sort="desc"
                                desc-allowed={true}
                                on-sort={parent.sortBy.bind(this, "frq")}>
                        </table-label>
                    </th>
                    <th></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr each={item, idx in displayedItems}
                        class="itm_{idx + 1}">
                    <td class="col-tab-num">{window.Formatter.num(idx + 1 + ((page - 1) * itemsPerPage))}</td>
                    <td each={w, w_idx in item.Word} class="word_{w_idx + 1}">{w.n}</td>
                    <td class="tab-num freqColumn">{window.Formatter.num(item.frq)}</td>
                    <td if={item.rel} class="tab-num">
                        {window.valueFormatter(item.rel, 2)}
                    </td>
                    <td if={data.freqShowRel} class="tab-num">
                        {window.valueFormatter(item.frq * 1000000 / corpsize, 2)}
                    </td>
                    <td class="freqBar">
                        <div class="progress"
                                style={"height: " + (item.freqbar ? (item.freqbar + 1) : 6) +"px;"}>
                            <div class="determinate"
                                    style={"width: " + (item.fbar / 3) + "%;"}>
                            </div>
                        </div>
                    </td>
                    <td class="menuColumn">
                        <a class="btn btn-flat btn-floating {small: opts.details}"
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
        this.page = this.data.f_page
        this.itemsPerPage = this.data.f_itemsPerPage
        this.corpsize = this.store.corpus.sizes.tokencount

        updateAttributes(){
            this.displayedItems = this.opts.items.slice((this.page - 1) * this.itemsPerPage, this.page * this.itemsPerPage)
        }
        this.updateAttributes()

        onPageChange(page) {
            this.page = page
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
                    name: "filter",
                    arg: (featureParams.pn == "n" ? "not, " : "") + " " + w.n, // TODO add context
                    corpname: this.data.alignedCorpname,
                    query: {
                        q: featureParams.pn + rowData.pfilter_list[i].substring(1)
                    }
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

        updateUrl(){
            if(this.data.f_items.length == 1){ // only one result block is displayed
                this.data.f_page = this.page
                this.data.f_itemsPerPage = this.itemsPerPage
                this.store.updateUrl()
            }
        }

        this.on("update", this.updateAttributes)
        this.on("updated", this.updateUrl)
    </script>
</pcfreq-result-block>

<parconcordance-frequency-result class="frequency-result t_m-{corpIdx}">
    <div class="content card">
        <div class="card-content">
            <bgjob-card if={data.jobid}
                    is-loading={data.isBgJobLoading}
                    desc={data.raw.desc}
                    progress={data.raw.processing}></bgjob-card>
            <div if={!data.freq_error && !data.jobid}>
                <div ref="tabs" class="optsContent background-color-blue-100 z-depth-3" style="display: none">
                    <parconcordance-result-options-freq corpname={corpname}></parconcordance-result-options-freq>
                </div>
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
                        <a id="btnNewSearch" class="btn btn-primary" onclick={onToggleShowFormClick}>
                            {_("newSearch")}
                        </a>
                        <a id="btnBackToConcordance" class="btn btn-primary" onclick={store.goBackToTheConcordance.bind(store)}>
                            {_("backToConcordance")}
                        </a>
                    </span>
                </h4>
                <pcfreq-result-block each={block, idx in data.f_items}
                        if={!data.isLoading}
                        idx={idx}
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
        require("./parconcordance-result-options-freq.tag")
        this.mixin("feature-child")

        // for testing purpose
        this.corpIdx = this.data.alignedCorpname ? (this.data.formparts.findIndex(c => c.corpname == this.data.alignedCorpname) + 2) : 1
        this.corpname = this.data.alignedCorpname || this.store.corpus.corpname.split('/').pop()

        onToggleShowFormClick(evt){
            evt.preventUpdate = true
            $(this.refs.tabs).slideToggle()
        }

        hideForm(){
            $(this.refs.tabs).hide()
        }

        sortBy(key) {
            this.data.freqSort = key
            this.store.f_search()
        }

        this.on("mount", () => {
            if(!this.data.f_hasBeenLoaded){
                this.store.f_search()
            }
            this.store.on("f_dataLoaded", this.hideForm)
        })

        this.on("unmount", () => {
            this.store.off("f_dataLoaded", this.hideForm)
        })
    </script>
</parconcordance-frequency-result>
