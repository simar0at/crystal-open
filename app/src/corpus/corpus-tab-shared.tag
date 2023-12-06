<corpus-tab-shared class="corpus-tab-shared">
    <preloader-spinner if={!corpusListLoaded}></preloader-spinner>
    <div class="tab-content card-content">
        <div class="controlBar">
            <div class="col s12">
                <ui-input
                        class="fuzzy-input"
                        placeholder={_("cp.filterByName")}
                        inline={true}
                        white=1
                        size=15
                        ref="filter"
                        floating-dropdown={true}
                        on-input={onQueryChangeDebounced}
                        suffix-icon={searchQuery !== "" ? "close" : ""}
                        on-suffix-icon-click={onSuffixIconClick}>
                </ui-input>
                <a href="#ca-create" if={window.permissions["ca-create"]}
                        class="btn btn-primary tooltipped right"
                        data-tooltip={_("ca.newCorpusDesc")}>
                    {_("newCorpus")}
                </a>
            </div>
        </div>
        <table if={corpusListLoaded} class="table material-table highlight myseltab">
            <thead>
                <tr>
                    <th class="sc-lang">
                        <table-label
                            label={_("language")}
                            desc-allowed={true}
                            asc-allowed={true}
                            order-by="lang"
                            actual-sort={sort.sort}
                            actual-order-by={sort.orderBy}
                            on-sort={onSort}>
                        </table-label>
                    </th>
                    <th>
                        <table-label
                            label={_("name")}
                            desc-allowed={true}
                            asc-allowed={true}
                            order-by="name"
                            actual-sort={sort.sort}
                            actual-order-by={sort.orderBy}
                            on-sort={onSort}>
                        </table-label>
                    </th>
                    <th class="sc-size">
                        <table-label
                            align-right=1
                            label={_("wordP")}
                            desc-allowed={true}
                            asc-allowed={true}
                            order-by="size"
                            actual-sort={sort.sort}
                            actual-order-by={sort.orderBy}
                            on-sort={onSort}>
                        </table-label>
                    </th>
                    <th style="width: 1px;"></th>
                </tr>
            </thead>
            <tbody if={!visibleCorpora.length}>
                <tr>
                    <td colspan="4">{_("cp.emptyList")}</td>
                </tr>
            </tbody>
            <tbody if={visibleCorpora.length}>
                <tr class="{actual: corpus.corpname == actCorp} row_{idx}"
                        each={corpus, idx in visibleCorpora}
                        if={idx < showLimit }
                        ref="{idx}_r">
                    <td onclick={onSelectCorpus} ref="{idx}_l">{corpus.language_name}</td>
                    <td onclick={onSelectCorpus}>
                        <span ref="{idx}_n">{corpus.name}</span>
                        <span class="badge new background-color-blue-100 hide-on-small-and-down"
                            data-badge-caption="">
                            {corpus.owner_name}
                        </span>
                    </td>
                    <td onclick={onSelectCorpus} class="right-align">
                        {corpus.sizes ? window.Formatter.num(corpus.sizes.wordcount) : ""}
                    </td>
                    <td class="menuCell relative">
                        <a href="javascript:void(0);"
                                if={!config.READ_ONLY}
                                class="iconButton btn btn-flat btn-floating"
                                onclick={onShowCorpMenu} >
                            <i class="material-icons">more_horiz</i>
                        </a>
                        <a href="javascript:void(0)" if={config.READ_ONLY} onclick={SkE.showCorpusInfo.bind(this, corpus.corpname)}>
                            <i class="material-icons">info</i>
                        </a>
                    </td>
                </tr>
            </tbody>
            <tfoot ref="last">
            </tfoot>
        </table>
    </div>
    <ul id="sharedCorpMenu" class="dropdown-content horizontalDropdown">
        <li each={o in store.corpMenuItems}
                data-item={o.type}
                title={_(o.labelId)}>
            <i class="material-icons">{o.icon}</i>
        </li>
    </ul>

    <script>
        const {AppStore} = require('core/AppStore.js')
        const {CorpusStore} = require("corpus/CorpusStore.js")
        const {Auth} = require('core/Auth.js')
        const FuzzySort = require('libs/fuzzysort/fuzzysort.js')
        require("ca/ca-corpus-download-dialog.tag")

        this.store = CorpusStore
        this.data = this.store.data
        this.userid = Auth.getUserId()
        this.isFullAccount = Auth.isFullAccount()
        this.sort = {
            sort: 'asc',
            orderBy: 'name'
        }
        this.showLimit = 60

        onSuffixIconClick(evt) {
            evt.preventUpdate = true
            this.searchQuery = ""
            this.filterCorpora()
        }

        sortCorpora(){
            this.visibleCorpora = this.store.sort(this.visibleCorpora, this.sort)
        }

        onQueryChangeDebounced(query){
            clearTimeout(this.queryTimer)
            this.queryTimer = setTimeout(function(){
                this.searchQuery = query
                this.showLimit = 60
                this.filterCorpora()
            }.bind(this), 50);
        }

        filterCorpora(query){
            if(this.searchQuery !== ""){
                this.visibleCorpora = []
                let fuzzySorted = FuzzySort.go(this.searchQuery, copy(this.allCorpora), {
                    key: "corpname",
                    keys: ["language_name", "name"]
                })
                this.visibleCorpora = fuzzySorted.map(fs => {
                    if(fs.score > -Infinity){
                        let c = fs.obj
                        c.score = fs.score
                        c.h_lang = FuzzySort.highlight(fs[0], '<b class="red-text">', "</b>")
                        c.h_corp = FuzzySort.highlight(fs[1], '<b class="red-text">', "</b>")
                        return c
                    }
                }).sort(function(a, b){
                    return Math.sign(b.score - a.score)
                })
            } else{
                this.visibleCorpora = this.allCorpora
                this.sortCorpora()
            }
            this.update()
            this.highlightOccurrences()
        }

        initData(){
            this.corpusListLoaded = AppStore.data.corpusListLoaded
            this.allCorpora = AppStore.get('corpusList') || []
            this.allCorpora = this.allCorpora.filter(corpus => {
                return corpus.owner_id && corpus.owner_id != this.userid
            })
            this.visibleCorpora = this.allCorpora
            this.actCorp = AppStore.getActualCorpname()
            this.sortCorpora()
        }
        this.initData()

        onShowCorpMenu(event) {
            this.store.showCorpMenu(event, "#sharedCorpMenu")
        }

        onSort(sort) {
            this.sort = sort
            this.sortCorpora()
            this.update()
        }

        onSelectCorpus(event) {
            this.store.selectCorpus(event.item.corpus)
        }

        onCorpusListLoaded() {
            this.initData()
            this.update()
        }

        highlightOccurrences(){
            this.store.highlightOccurrences(this.visibleCorpora, this.refs)
        }

        isNearEnd(){
            var rect = this.refs.last.getBoundingClientRect();
            return rect.bottom <= ((window.innerHeight || document.documentElement.clientHeight) + 1000) //near end
        }

        onScrollDebounced(){
            if(this.data.tab != "shared") return
            clearTimeout(this.scrollTimer)
            this.scrollTimer = setTimeout(function(){
                if(this.isNearEnd()){
                    clearTimeout(this.scrollTimer)
                    this.showLimit += 100
                    this.update()
                    this.searchQuery !== "" && this.highlightOccurrences()
                }
            }.bind(this), 50);
        }

        this.on('mount', () => {
            $(window).on("scroll", this.onScrollDebounced)
            AppStore.on('corpusListChanged', this.onCorpusListLoaded)
        })

        this.on('unmount', () => {
            $(window).off("scroll", this.onScrollDebounced)
            AppStore.off('corpusListChanged', this.onCorpusListLoaded)
        })
    </script>
</corpus-tab-shared>
