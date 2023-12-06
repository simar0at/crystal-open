<collocations-result class="collocations-result">
    <h4 class="header">{_("collocations")}</h4>
    <a if={feature == "concordance"}
            id="btnNewSearch"
            class="btn contrast"
            onclick={onToggleShowFormClick}>
        {_("newSearch")}
    </a>
    <a id="btnBackToConcordance" class="btn contrast" onclick={store.goBackToTheConcordance.bind(store)}>
        {_("backToConcordance")}
    </a>
    <bgjob-card if={data.jobid} data={data}></bgjob-card>
    <div if={!data.c_error && !data.isLoading && store.c_hasBeenLoaded && data.c_showItems}>
        <div if={!data.c_isEmpty} class="hasItemsContent">
            <br>
            <column-table ref="table"
                items={data.c_showItems}
                col-meta={colMeta}
                max-column-count={data.c_onecolumn ? 1 : 0}
                start-index={data.c_showResultsFrom}
                order-by={data.c_csortfn}
                sort="desc"
                on-sort={onSort}></column-table>
            <interfeature-menu ref="interfeatureMenu"
                links={interFeatureMenuLinks}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>
        </div>

        <div if={data.c_isEmpty} class="nothingFound">
            <h3>{_("nothingFound")}</h3>
        </div>

        <ui-pagination
            if={data.c_items.length > 10 || !data.c_lastpage}
            items-per-page={data.c_itemsPerPage}
            count={data.c_lastpage ? data.c_total : 0}
            actual={data.c_page}
            on-change={store.c_changePage.bind(store)}
            on-items-per-page-change={store.c_changeItemsPerPage.bind(store)}
            show-prev-next={true}></ui-pagination>

        <div if={data.c_error}>
            <h3>{_("somethingWentWrong")}</h3>
            <div>
                <a if={!showErrorDetails && data.c_error} onclick={onShowErrorDetailsClick} class="link">{_("moreDetails")}</a>
                <br><br>
            </div>
            <div if={showErrorDetails} class="errorDetails">{data.c_error}</div>
        </div>
    </div>

    <script>
        require("./collocations-result.scss")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.feature = this.store.feature
        this.data = this.store.data

        this.interFeatureMenuLinks = [{
            name: this.feature,
            feature: this.feature,
            labelId: "positiveFilter",
            pn: "p"
        }, {
            name: this.feature + "Neg",
            feature: this.feature,
            labelId: "negativeFilter",
            pn: "n"
        }]

        formatNum(val){
            return window.Formatter.num(parseFloat(Math.round(val * 100) / 100).toFixed(2), {minimumFractionDigits: 2})
        }

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let operations = copy(this.data.operations)
            let operation = {
                id: Math.floor((Math.random() * 10000)),
                name: "filter",
                arg: rowData.str + " " + this.data.c_cfromw + ", " + this.data.c_ctow,
                query: {
                    pnfilter: featureParams.pn,
                    queryselector: "cqlrow",
                    filfpos: this.data.c_cfromw,
                    filtpos: this.data.c_ctow,
                    cql: `[${this.data.c_cattr}="${rowData.str}"]`
                },
                active: true
            }
            if(this.feature == "parconcordance"){
                operation.corpname = this.data.alignedCorpname
            }
            operations.push(operation)

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


        setColMeta(){
            let attr = AppStore.getAttributeByName(this.data.c_cattr)
            this.colMeta = [{
                id: "str",
                "class": "word",
                label: attr ? attr.label : this.data.c_cattr
            }, {
                id: "freq",
                labelId: "col.cooccurrences",
                tooltip: "t_id:conc_r_coll_cooccurrences",
                num: true,
                formatter: window.Formatter.num.bind(Formatter),
                sort: {
                    orderBy: "f",
                    descAllowed: true,
                    ascAllowed: false
                }
            }, {
                id: "coll_freq",
                labelId: "col.candidates",
                tooltip: "t_id:conc_r_coll_candidates",
                num: true,
                formatter: window.Formatter.num.bind(Formatter),
                sort: {
                    orderBy: "F",
                    descAllowed: true,
                    ascAllowed: false
                }
            }]

            this.data.c_funlist.forEach(fun => { // maintain order of columns
                if(this.data.c_cbgrfns && this.data.c_cbgrfns.includes(fun)){
                    this.colMeta.push({
                        id: fun,
                        label: this.store.c_getFunLabel(fun),
                        num: true,
                        selector: (item, colMeta) => {
                            return this.formatNum(item.Stats.find(itm => {return itm.n == fun}).s)
                        },
                        sort: {
                            orderBy: fun,
                            descAllowed: true,
                            ascAllowed: false
                        }
                    })
                }
            })

            this.colMeta.push({
                id: "menu",
                "class": "menuColumn",
                generator: () => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt) {
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, item)
                }.bind(this)
            })
        }

        onSort(sort){
            this.store.c_searchAndAddToHistory({
                c_page: 1,
                c_csortfn: sort.orderBy
            })
        }

        onChangeItemsPerPage(itemsPerPage){
            // items per page has changed i have to recalculate actual page -> to show first item on screen with new settings
            itemsPerPage = itemsPerPage * 1
            let actualPosition = this.data.c_itemsPerPage * (this.data.c_page - 1) + 1// position of first visible item
            this.store.c_searchAndAddToHistory({
                c_itemsPerPage: itemsPerPage,
                c_page: Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
            })
        }

        prevPage(){
            if(!this.data.activeRequest && this.data.c_page > 1){
                this.store.c_changePage(this.data.c_page -= 1)
            }
        }

        nextPage(){
            if(!this.data.activeRequest && (!this.data.c_lastpage || (this.data.c_total > this.data.c_page * this.data.c_itemsPerPage))){
                this.store.c_changePage(this.data.c_page += 1)
            }
        }

        onToggleShowFormClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", this.data.act_opts == "collocations" ? null : "collocations")
        }

        onShowErrorDetailsClick(){
            this.showErrorDetails = true
        }

        this.on("update", () => {
            this.data = this.store.data
            this.setColMeta()
        })

        this.on("mount", () => {
            if(!this.c_hasBeenLoaded){
                this.store.c_search()
            }
            Dispatcher.on("RESULT_PREV_PAGE", this.prevPage.bind(this))
            Dispatcher.on("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        })

        this.on("unmount", () => {
            Dispatcher.off("RESULT_PREV_PAGE", this.prevPage.bind(this))
            Dispatcher.off("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        })
    </script>
</collocations-result>
