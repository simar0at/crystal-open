<corpus-tab-advanced class="corpus-tab-advanced">
    <preloader-spinner if={!corpusListLoaded}> </preloader-spinner>
    <div class="tab-content card-content" if={corpusListLoaded}>
        <div class="controlBar">
            <ui-input
                    class="fuzzy-input"
                    placeholder={_("cp.filterByName")}
                    inline={true}
                    riot-value={data.query}
                    white=1
                    size=12
                    ref="filter"
                    floating-dropdown={true}
                    on-input={onQueryChangeDebounced}
                    suffix-icon={data.query !== "" ? "close" : ""}
                    on-suffix-icon-click={onSuffixIconClick}>
            </ui-input>
            <ui-switch
                    if={data.cat != 'parallel' && !window.config.NO_SKE}
                    class="hide-on-med-and-down tighter inline-block sketches"
                    label-id="cp.hasSketches"
                    name="sketches"
                    disabled={!visibleCorpora.length || !someHasSketches}
                    on-change={onOnlySketchesChange}
                    riot-value={data.sketches == "1" ? true : false}>
            </ui-switch>
            <div class="chip catchip" if={data.cat != 'all'}>
                {_("cp." + (data.cat || "all"))}
                <i class="material-icons" onclick={onRemoveSelCat}>close</i>
            </div>
            <div class="chip langchip" if={data.lang}>
                <b>{langMap[data.lang]}</b>
                <b if={data.lang2}>{langMap[data.lang2]}</b>
                <i if={langMap[data.lang]}
                        class="material-icons"
                        onclick={onRemoveSelLang}>close</i>
            </div>
            <a if={!window.config.NO_SKE && !window.config.NO_CA}
                    class='dropdown-button btn hide-on-xlarge'
                    id="catDropdown-button"
                    href='javascript: void(0)'
                    data-target='catDropdown'>{_("cp.categories")}:
                    {_("cp." + data.cat)}</a>
            <ui-filtering-list
                    options={langList}
                    floating-dropdown={true}
                    value-in-search={true}
                    riot-value={data.lang}
                    label={data.cat == 'parallel' ? "primary" : ""}
                    white=1
                    size={12}
                    class="hide-on-large-and-down plainField"
                    inline={true}
                    autocomplete={false}
                    open-on-focus=1
                    placeholder={data.cat == "parallel" ? "cp.filterByL1" : "cp.filterByLanguage"}
                    on-change={onLangChange}>
            </ui-filtering-list>
            <ui-filtering-list
                    if={data.cat == 'parallel'}
                    label="aligned"
                    floating-dropdown={true}
                    value-in-search={true}
                    open-on-focus={true}
                    options={langList}
                    riot-value={data.lang2}
                    white=1
                    size={12}
                    class="selectL hide-on-large-and-down plainField"
                    inline={true}
                    autocomplete={false}
                    placeholder="cp.filterByL2"
                    on-change={onLang2Change}>
            </ui-filtering-list>
            <a href="#ca-create" if={window.permissions["ca-create"]}
                    id="btnAdvCreateCorpus"
                    class="btn btn-primary tooltipped right"
                    data-tooltip={_("ca.newCorpusDesc")}>
                {_("newCorpus")}
            </a>
            <a href="#compare-corpora" if={window.permissions["compare-corpora"]}
                    class="btn tooltipped right btn-flat"
                    data-tooltip={_("compareCorporaDesc")}>
                {_("compareCorpora")}
            </a>
            <div style="font-size: 0.8em; color: grey;opacity: 0.8; position: relative; top: -13px;" class="hide-on-small-only">
                <span>
                    <b>{visibleCorpora.length}</b>
                    {_("cp.corpora")}
                </span>
                <span if={!data.lang}>
                    <b>{Object.keys(presentLangs).length}</b> {_("cp.languages")}
                </span>
            </div>
        </div>
        <div class="clearfix"></div>
        <div style="display: flex">
            <div style="flex-grow: 1">
                <table class="table material-table highlight advseltab">
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
                            <th>
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
                        <tr class="selcorp {notAvailable: !corpus.user_can_read, actual: corpus.corpname == actCorp}"
                                each={corpus, idx in visibleCorpora}
                                if={idx < showLimit}
                                ref="a_{idx}_r">
                            <td onclick={onSelectCorpus} ref="a_{idx}_l">
                                {corpus.language_name}
                            </td>
                            <td onclick={onSelectCorpus}>
                                <i class="material-icons shared tooltipped" data-tooltip={_("iShareCorpus")} if={corpus.is_shared}>group</i>
                                <span ref="a_{idx}_n">{corpus.name}</span>
                                <span class="badge new background-color-blue-100 hide-on-small-and-down"
                                    if={corpus.owner_id}
                                    data-badge-caption="">
                                    {corpus.owner_id == userid ? _("cp.myCorpus") : corpus.owner_name}
                                </span>
                                <i class="material-icons" style="vertical-align: bottom;"
                                        if={!corpus.user_can_read}>
                                    lock
                                </i>
                            </td>
                            <td onclick={onSelectCorpus} class="right-align">
                                {corpus.sizes ? window.Formatter.num(corpus.sizes.wordcount) : (corpus.size && window.Formatter.num(corpus.size) || '')}
                            </td>
                            <td class="menuCell" if={!config.READ_ONLY}>
                                <a href="javascript:void(0);"
                                        class="iconButton btn btn-flat btn-floating"
                                        onclick={onShowCorpMenu}>
                                    <i class="material-icons">more_horiz</i>
                                </a>
                            </td>
                            <td if={config.READ_ONLY}>
                                <a href="javascript:void(0)" onclick={SkE.showCorpusInfo.bind(this, corpus.corpname)}>
                                    <i class="material-icons">info</i>
                                </a>
                            </td>
                        </tr>
                    </tbody>

                    <tbody if={visibleCorporaOld.length}>
                        <tr>
                            <td colspan="4" onclick={onClickShowOldCorpora}
                                    class="old-corpora-td">
                                <i class="material-icons">keyboard_arrow_{data.showOld ? "up" : "down"}</i>
                                {_("cp.showOldCorpora")}
                                (<b>{visibleCorporaOld.length}</b>)
                            </td>
                        </tr>
                    </tbody>

                    <tbody if={data.showOld}>
                        <tr class="selcorp {notAvailable: !corpus.user_can_read, actual: corpus.corpname == actCorp}"
                                each={corpus, idx in visibleCorporaOld}
                                if={idx < showLimit}
                                ref="{o_idx}_r">
                            <td onclick={onSelectCorpus} ref="{o_idx}_l">
                                {corpus.language_name}
                            </td>
                            <td onclick={onSelectCorpus}>
                                <span ref="{o_idx}_n">{corpus.name}</span>
                                <span class="badge new background-color-blue-100 hide-on-small-and-down"
                                    if={corpus.owner_id}>
                                    {corpus.owner_id == userid ? _("cp.myCorpus") : corpus.owner_name}
                                </span>
                                <i class="material-icons" style="vertical-align: bottom;"
                                        if={!corpus.user_can_read}>
                                    lock
                                </i>
                            </td>
                            <td onclick={onSelectCorpus} class="right-align">
                                {corpus.sizes ? window.Formatter.num(corpus.sizes.wordcount) : (corpus.size && window.Formatter.num(corpus.size) || '')}
                            </td>
                            <td if={!config.READ_ONLY} class="menuCell" onclick={onShowCorpMenu}><i class="material-icons">more_horiz</i></td>
                            <td if={config.READ_ONLY}>
                                <a href="javascript:void(0)" onclick={SkE.showCorpusInfo.bind(this, corpus.corpname)}>
                                    <i class="material-icons">info</i>
                                </a>
                            </td>
                        </tr>
                    </tbody>
                    <tfoot ref="last">
                    </tfoot>
                </table>
            </div>
            <virtual if={!window.config.NO_SKE && !window.config.NO_CA}>
                <ul id='catDropdown' class='dropdown-content'>
                    <li class={active: data.cat == cat, disabled: !catSizes[cat]}
                            each={cat in categories} onclick={onSelectCat}>
                        <a>{_("cp." + cat)} <span class="right">{window.Formatter.num(catSizes[cat])}</span></a>
                    </li>
                </ul>
                <div class="hide-on-large-and-down" style="margin-left: 10px">
                    <h5>{_("cp.corpusCategory")}</h5>
                    <ul class="tabs">
                        <li class={active: data.cat == cat, tab: true, disabled: !catSizes[cat]}
                                each={cat in categories} onclick={onSelectCat}>
                            <a><span>{_("cp." + cat)}</span>
                                <i class="material-icons tooltipped"
                                        data-tooltip={_("cp." + cat + "Desc")}>info_outline</i>
                                <span>{catSizes[cat]}</span></a>
                        </li>
                    </ul>
                </div>
            </virtual>
        </div>
    </div>
    <ul id="corpMenu" class="dropdown-content horizontalDropdown">
        <li each={o in store.corpMenuItems}
                data-item={o.type}
                title={_(o.labelId)}>
            <i class="material-icons">{o.icon}</i>
        </li>
    </ul>

    <script>
        require("./corpus-tab-advanced.scss")
        const {Connection} = require('core/Connection.js')
        const {Url} = require('core/url.js')
        const {AppStore} = require('core/AppStore.js')
        const {CorpusStore} = require("corpus/CorpusStore.js")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {Auth} = require('core/Auth.js')
        const FuzzySort = require('libs/fuzzysort/fuzzysort.js')

        this.mixin('tooltip-mixin')

        this.store = CorpusStore
        this.isFullAccount = Auth.isFullAccount()
        this.userid = Auth.getUserId()
        this.actCorp = AppStore.getActualCorpname()
        this.data = this.store.data

        this.categories = ["all", "recent", "my", "shared", "featured",
                "general", "web", "non-web", "parallel", "spoken",
                "specialized", "diachronic", "multimedia", "learner",
                "error-annotated", "gramdev"]
        this.presentLangs = {}
        this.langList = []
        this.showLimit = 60
        this.someHasSketches = false
        this.corpusListLoaded = false
        this.catSizes = {}
        this.oldCatSizes = {}
        this.sort = {
            sort: UserDataStore.getOtherData("corpus_select_sort") || 'asc',
            orderBy: UserDataStore.getOtherData("corpus_select_order_by") || 'name'
        }

        sortCorpora(){
            this.visibleCorpora = this.store.sort(this.visibleCorpora, this.sort)
        }

        onQueryChangeDebounced(query){
            clearTimeout(this.queryTimer)
            this.queryTimer = setTimeout(function(){
                this.data.query = query
                this.showLimit = 60
                this.filterCorpora()
            }.bind(this), 50);
        }

        onSuffixIconClick(evt) {
            evt.preventUpdate = true
            this.data.query = ""
            this.filterCorpora()
        }

        onOnlySketchesChange(value, name) {
            this.data.sketches = value ? "1" : "0"
            this.filterCorpora()
        }

        onSelectCat(event) {
            if (!this.catSizes[event.item.cat] && !this.oldCatSizes[event.item.cat]) return
            if (event.item.cat != 'parallel') {
                this.data.lang2 = ''
            } else{
                this.data.sketches = 0
            }
            this.data.cat = event.item.cat
            this.filterCorpora()
        }

        onRemoveSelCat() {
            this.data.cat = 'all'
            this.filterCorpora()
        }

        onRemoveSelLang() {
            this.data.lang = ''
            this.data.lang2 = ''
            this.filterCorpora()
        }

        onLangChange(value, name, label) {
            this.data.lang = value
            this.filterCorpora()
        }

        onLang2Change(value, name, label) {
            this.data.lang2 = value
            this.filterCorpora()
        }

        onSort(sort) {
            this.sort = sort
            this.sortCorpora()
            this.update()
            UserDataStore.saveOtherData({
                    'corpus_select_sort': sort.sort,
                    'corpus_select_order_by': sort.orderBy
                })
        }

        onClickShowOldCorpora() {
            this.data.showOld = !this.data.showOld
        }

        onShowCorpMenu(event) {
            this.store.showCorpMenu(event, "#corpMenu")
        }

        onSelectCorpus(event) {
            this.store.selectCorpus(event.item.corpus)
        }

        filterCorpora() {
            this.data.showOld = false
            this.someHasSketches = false
            this.presentLangs = {}
            this.matchingCorpora = {}
            this.categories.forEach(cat => {
                this.catSizes[cat] = 0
                this.oldCatSizes[cat] = 0
            })

            let lowestScore = 0
            if(this.data.query !== ""){
                let fuzzySorted = FuzzySort.go(this.data.query, copy(this.corpusList), {
                    key: "corpname",
                    keys: ["language_name", "name"]
                })
                fuzzySorted.forEach(fs => {
                    let score = fs.score
                    if(fs.obj.new_version){
                        score *= 3 // penalty for old corpora
                    } else if(fs.obj.sort_to_end){
                        score *= 2
                    } else if(fs.obj.id || fs.obj.is_featured){
                        score *= 0.5
                    }
                    if(score < lowestScore){
                        lowestScore = score
                    }
                    let obj = {score: score}
                    obj.h_lang = FuzzySort.highlight(fs[0], '<b class="red-text">', "</b>")
                    obj.h_corp = FuzzySort.highlight(fs[1], '<b class="red-text">', "</b>")
                    this.matchingCorpora[fs.obj.corpname] = obj
                }, this)
            }

            var filteredCorpora = this.corpusList.filter(function(corpus){
                 return ((!this.data.lang || corpus.language_id == this.data.lang)
                        && (!this.data.lang2 || this.hasL2(corpus, this.data.lang2))
                        && (this.data.sketches != "1" || corpus.wsdef)
                        && (!isDef(this.data.query) || this.data.query === "" || this.matchingCorpora[corpus.corpname]))
            }.bind(this))

            // calculate corpus count in each category before filtering corpora to the selected category
            filteredCorpora.forEach(corpus => {
                for(let category in corpus.cats){
                    if(corpus.cats[category]){
                        if(corpus.new_version){
                            this.oldCatSizes[category] ++
                        } else{
                            this.catSizes[category] ++
                        }
                    }
                }
            })

            if(this.data.cat != "all"){
                filteredCorpora = filteredCorpora.filter(corpus => {
                    return corpus.cats[this.data.cat]
                })
            }

            this.visibleCorpora = []
            this.visibleCorporaOld = []
            filteredCorpora.forEach(corpus => {
                this.someHasSketches |= !!corpus.wsdef
                let updatedCorp = Object.assign({}, corpus, this.matchingCorpora[corpus.corpname] || {
                    h_lang: "",
                    h_corp: ""
                })
                if(lowestScore && !corpus.user_can_read){
                    updatedCorp.score += lowestScore
                }
                if(updatedCorp.new_version){
                    this.visibleCorporaOld.push(updatedCorp)
                } else{
                    this.visibleCorpora.push(updatedCorp)
                    this.presentLangs[corpus.language_id] = true
                }
            })

            if(this.data.query !== ""){
                this.visibleCorpora.sort((a, b) => {
                    return a.score == b.score ? this.compareCorporaFun(a, b) : Math.sign(b.score - a.score)
                })
            } else{
                this.sortCorpora()
            }

            Url.setQuery(this.data, true, true)
            this.update()
            this.highlightOccurrences(this)
        }

        initData() {
            this.corpMap = {}
            this.corpusList.forEach(corpus => {
                this.corpMap[corpus.corpname] = corpus
                corpus.cats = {}
                this.categories.forEach(category => {
                    corpus.cats[category] = category == "recent" ? false : this.checkCat(corpus, category)
                })
            })
            this.initHistoryList()
            this.initAlignedCorpora()
            this.filterCorpora()
        }

        initAlignedCorpora() {
            this.corpusList.forEach(function(corpus){
                corpus.alignedLanguages = []
                if (corpus.aligned.length) {
                    for (let j=0; j<corpus.aligned.length; j++) {
                        let cprefix = ""
                        if (corpus.corpname.startsWith('preloaded/')) {
                            cprefix = 'preloaded/'
                        }
                        if (corpus.corpname.startsWith('user/')) {
                            cprefix = corpus.corpname.split('/', 2).join('/') + '/'
                        }
                        let corp2 = this.corpMap[cprefix + corpus.aligned[j]]
                        // TODO: share aligned corpora of shared user corpora, put into ca/api/corpora
                        if (corp2) {
                            let l2 = this.corpMap[corp2.corpname].language_id
                            corpus.alignedLanguages.push(l2)
                        }
                    }
                }
            }.bind(this))
        }

        initHistoryList() {
            let h = UserDataStore.get('corpora')
            for (let i=0; i<h.length; i++) {
                let corpus = this.corpMap[h[i].corpname]
                if (corpus) {
                    if(corpus.new_version){
                        this.oldCatSizes.recent ++
                    } else{
                        this.catSizes.recent ++
                    }
                }
            }
        }

        initLanguages(data) {
            if(this.corpusListLoaded  && AppStore.get("languageListLoaded")){
                let languages = AppStore.get('languageList') || []
                let langCount = {}
                AppStore.get("corpusList").forEach(c => {
                    langCount[c.language_id] = langCount[c.language_id] + 1 || 1
                })
                this.langMap = {}
                this.langList = languages.filter(lang => {
                    return !!langCount[lang.id] // at least one?
                }).map((lang) => {
                    this.langMap[lang.id] = lang.name
                    return {
                        label: lang.name,
                        value: lang.id,
                        search: [lang.id, lang.autonym || ""],
                        generator: (item) => {
                            return `<span class="lAut">${lang.autonym ? lang.autonym + ' (' + lang.name + ')' : lang.name}<span class="lCnt background-color-blue-100">${langCount[lang.id]}</span></span>`
                                + (lang.id != lang.name ? `<span class="lId"> ${lang.id}</span>` : '')
                        }
                    }
                }, )
                this.langList.sort((a, b) => {
                    return a.label.toLowerCase().localeCompare(b.label.toLowerCase())
                })
                this.langList.unshift({
                    label: _("cp.allLanguages"),
                    value: ''
                })
                this.update()
            }
        }

        initCatDropdown(){
            let node = $('#catDropdown-button')
            node && node.dropdown({
                constrainWidth: true,
                coverTrigger: true,
                alignment: 'right'
            })
        }

        hasL2(corp, lang_id) {
            let alignedLanguages = this.corpMap[corp.corpname].alignedLanguages
            return alignedLanguages.includes(lang_id)
        }

        checkCat(corp, cat) {
            switch (cat) {
                case "all":
                    return true
                case "parallel":
                    return corp.aligned.length > 0
                case "my":
                    return corp.owner_id && corp.owner_id == this.userid
                case "gramdev":
                    return corp.is_sgdev
                case "shared":
                    return corp.user_can_read && corp.owner_id
                            && corp.owner_id != this.userid
                case "featured":
                    return corp.is_featured
                case "general":
                    return corp.tags.indexOf('general') >= 0
                case "specialized":
                    return corp.tags.indexOf('specialized') >= 0
                case "diachronic":
                    return corp.diachronic && corp.diachronic.length > 0
                case "web":
                    return corp.tags.indexOf('web') >= 0
                case "non-web":
                    return corp.tags.indexOf('web') == -1
                case "multimedia":
                    return corp.tags.indexOf('multimedia') >= 0
                case "spoken":
                    return corp.tags.indexOf('spoken') >= 0
                case "learner":
                    return corp.tags.indexOf('learner') >= 0
                case "error-annotated":
                    return corp.is_error_corpus
                default:
                    throw 'Unknown category: ' + cat
            }
        }

        highlightOccurrences(){
            if(this.isMounted && this.visibleCorpora){
                this.store.highlightOccurrences(this.visibleCorpora, this.refs, "a_")
                if(this.data.showOld){
                    this.store.highlightOccurrences(this.visibleCorpora, this.refs, "o_")
                }
            }
        }

        isNearEnd(){
            var rect = this.refs.last.getBoundingClientRect();
            return rect.bottom <= ((window.innerHeight || document.documentElement.clientHeight) + 1000) //near end
        }

        compareCorporaFun(a, b){
            if(a.sort_to_end && !b.sort_to_end) return 1
            if(!a.sort_to_end && b.sort_to_end) return -1
            if (a.id && !b.id) return -1 // corpus with ID is user corpus
            if (b.id && !a.id) return 1
            if (a.is_featured && !b.is_featured) return -1
            if (b.is_featured && !a.is_featured) return 1
            return a.name.localeCompare(b.name)
        }

        onScrollDebounced(){
            if(this.data.tab != "advanced") return
            clearTimeout(this.scrollTimer)
            this.scrollTimer = setTimeout(function(){
                if(this.isNearEnd()){
                    clearTimeout(this.scrollTimer)
                    this.showLimit += 100
                    this.update()
                    this.data.query !== "" && this.highlightOccurrences()
                }
            }.bind(this), 50);
        }

        onCorpusListChanged() {
            this.corpusList = copy(AppStore.get('corpusList')) || []
            this.corpusListLoaded = true
            this.initData()
            this.initLanguages()
        }

        if(AppStore.get("languageListLoaded")){
            this.initLanguages()
        } else{
            AppStore.on('languageListLoaded', this.initLanguages)
        }

        AppStore.get("corpusListLoaded") && this.onCorpusListChanged()

        this.on('updated', this.initCatDropdown)

        this.on('mount', () => {
            this.initCatDropdown()
            this.data.query !== "" && this.highlightOccurrences()
            $(window).on("scroll", this.onScrollDebounced)
            AppStore.on('corpusListChanged', this.onCorpusListChanged)
        })

        this.on('unmount', () => {
            $(window).off("scroll", this.onScrollDebounced)
            AppStore.off('corpusListChanged', this.onCorpusListChanged)
        })
    </script>
</corpus-tab-advanced>
