<page-annotation class="page-annotation g{annotation_group} pt-2">
    <div class="helper-box z-depth-5" if={model.ontology || model.browse_labels || model.browse_values || opened_label >= 0 || opened_query >= 0}>
        <div>
            <button class="btn btn-flat" if={model.ontology}
                    onclick={toggle_ontology}>
                {show_ontology ? _("hide") : _("show")} {ontology_label}
            </button>
            <button class="btn btn-flat" if={model.browse_labels}
                    onclick={toggle_search}>
                {_("an.browseLabels")}
            </button>
            <button class="btn btn-flat" if={model.browse_values}
                    onclick={toggle_listing}>
                {_("an.browseValues")}
            </button>
            <a class="tooltipped btn btn-flat" href={query_annot_url()}
                    data-position="top"
                    data-tooltip={_("an.goToConcordance")}
                    if={opened_query >= 0}>
                {_("annotate")}&nbsp;<q>{truncateWithEllipses(query.conc, 10)}</q>
            </a>
            <a class="tooltipped btn btn-flat" href={query && label_annot_url()}
                    data-position="top"
                    data-tooltip={_("an.annotateLabel")}
                    if={opened_label >= 0}>
                <i class="ske-icons skeico_concordance"></i>
            </a>
            <a class="tooltipped btn btn-flat" href={query2wsurl(query)}
                    data-tooltip={_("an.goToWordSketch")}
                    data-position="top"
                    if={opened_query >= 0 && query2wsurl(query)}>
                <i class="ske-icons skeico_word_sketch"></i>
            </a>
        </div>
    </div>
    <div class="row" if={loadingQueries}>
        <div class="col s12">
            <preloader-spinner center={1}></preloader-spinner>
        </div>
    </div>
    <div class="queries card mt-0">
        <div class="card-title">
            <ui-input placeholder={_("an.filterQueries")}
                    class="inline"
                    suffix-icon="search"
                    on-input={filterQueries}>
            </ui-input>
            <a class="btn btn-flat right {disabled: !queries.length}"
                    href={download_url}
                    target="_blank">{_("an.download")}
            </a>
            <a class="btn btn-flat right"
                    href={concordanceFormUrl}>{_("concordanceSearch")}
            </a>
        </div>
        <div class="row" if={!show_queries.length} style="margin-bottom: 1em;">
            <div class="col s12">{_("an.noQueries")}</div>
        </div>
        <table class="table material-table striped highlight queriesTable" id="rtable"
                if={show_queries.length}>
            <thead>
                <tr>
                    <th each={c in schema}>
                        <table-label on-sort={onSort}
                                label={_("an." + (c.label || c.id))}
                                desc-allowed="true"
                                asc-allowed="true"
                                order-by={c.id}
                                actual-sort={sortQVal.sort}
                                actual-order-by={sortQVal.orderBy}>
                      </table-label>
                    </th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr each={q, i in show_queries}
                    class={pointer: 1, opened: opened_query == q.id}
                    onclick={open_query}>
                    <td  each={c in schema}>{this.parentNode}{q[c.id]}</td>
                    <td class="actions">
                        <a class="tooltipped btn-floating btn-flat"
                                  href={query_annot_url(q.conc)}
                                  onclick={stopClick}
                                  data-tooltip={_("an.goToConcordance")}>
                              <i class="ske-icons skeico_concordance"></i>
                        </a>
                        <button class="btn-flat btn-floating" onclick={remove_query}>
                              <i class="material-icons">delete</i>
                        </button>
                    </td>
                </tr>
            </tbody>
        </table>
        <ui-pagination if={matched_queries.length > 10}
                count={matched_queries.length}
                items-per-page={itemsPerPage}
                actual={page}
                on-change={changePage}
                on-items-per-page-change={changeItemsPerPage}
                show-prev-next={true}>
        </ui-pagination>
    </div>
    <div class="labels card" if={query && query.id>=0} id="labels">
        <div class="row">
            <div class="col {model.status_codes ? 's3 m2' : 's6 m4'}">
                <span class="card-title">{query.query}</span>
            </div>
            <div class="col s3 m2 text-right tooltipped"
                    data-tooltip={_("an.status")}
                    if={model.status_codes && !model.status_codes_select}>
                <input name="status" ref="status" id="status"
                        class="tooltipped"
                        data-tooltip={_("an.status")}
                        onchange={onStatusChange}
                        value={query.status} list="statuses" />
            </div>
            <div if={model.status_codes && model.status_codes_select}
                    data-tooltip={_("an.status")}
                    class="col s3 m2 text-right tooltipped">
                <select name="status" ref="status" id="status"
                        oninput={onStatusChange}
                        class="browser-default tiny">
                    <option value="">{_("an.status")}</option>
                    <option selected={sc == query.status} value={sc}
                            each={sc in model.status_codes}>{sc}</option>
                </select>
            </div>
            <div class="col s6 m8 text-right">
                <button class="btn mt-1"
                        onclick={renLabels}
                        hide={renaming}>
                    {_("an.renameLabels")}
                </button>
                <button class="btn btn-floating pulse tooltipped"
                        onclick={renLabels}
                        show={renaming}
                        data-tooltip={_("an.saveRenaming")}>
                    <i class="material-icons">save</i>
                </button>
                <button class="btn btn-flat btn-floating tooltipped"
                        onclick={cancel_rename}
                        show={renaming}
                        data-tooltip={_("an.cancelRename")}>
                    <i class="material-icons">close</i>
                </button>
                <button class="btn btn-flat" onclick={toggle_all_labels}
                        if={annotation_group != "pdev" && num_of_sublabels > 0}>
                    {show_all_labels ? _("an.hideSublabels") : _("an.showSublabels")}
                </button>
            </div>
        </div>

        <div class="row">
            <div class="col s12" if={loadingLabels}>
                <preloader-spinner center={1}></preloader-spinner>
            </div>
            <table class="table material-table striped highlight"
                    if={!loadingLabels}>
                <tbody>
                    <tr each={l, i in labels}
                            class="{opened: opened_label == i, sub: l.label.indexOf('.') > 0}"
                            if={(renaming || show_all_labels || l.label.indexOf('.') < 0) && l.id != 0}>
                        <td class={label_head: model.detail_under_label}
                                    onclick={open_label}>
                            <span class="label" hide={editLabel[l.id]}>{l.label}</span>
                            <i class="material-icons tiny color-blue-800 editIcon"
                                    onclick={showInput}
                                    hide={editLabel[l.id]}>edit
                            </i>
                            <ui-input name={l.id}
                                    show={editLabel[l.id]}
                                    riot-value={l.label}
                                    on-blur={updateLabelName}
                                    on-submit={updateLabelName}
                                    class="newLabelInput">
                            </ui-input>
                            <span if={l.data.type && annotation_group == "ivdnt" && l.data.type.indexOf("norm") < 0}
                                    class="lbtyp">{l.data.type}</span>
                        </td>
                        <td if={renaming}>
                            <input type="text"
                                    value={l.label}
                                    data-lid={l.id}
                                    size="5"
                                    onkeypress={checkSymbols}
                                    class="browser-default" />
                            <div class="red-text" style="font-size: 70%;"
                                    if={showWarning == i}>{_("an.labelNameSymbols")}
                            </div>
                        </td>
                        <td onclick={open_label}>
                            <pattern-string content={l.pattern_string}
                                    if={l.label.indexOf('.') == -1 || l.label.indexOf('.m')}
                                    class="pattern-string {anclass}">
                            </pattern-string>
                            <div class="below" if={model.detail_below}>
                                {l.data[model.detail_below]}
                            </div>
                            <div class="meaning" if={model.detail_under_label}>
                                {l.data[model.detail_under_label]}
                            </div>
                            <div class="below" if={annotation_group == "ivdnt"}>
                                {(l.data && l.data.examples && l.data.examples.length) ? l.data.examples[0].text : ""}
                            </div>
                        </td>
                        <td onclick={open_label} if={model.show_percents} class="perc">
                            {Math.round(l.ratio * 100) / 100}%
                        </td>
                        <td onclick={open_label} if={model.show_raw} class="perc">
                            {l.freq}&times;
                        </td>
                        <td class="actions">
                            <button class="btn-flat btn-floating" onclick={confirm_del_label}>
                                <i class="material-icons">delete</i>
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div class="center-align mt-2">
                <button onclick={onshow_new_label_form}
                        class="btn btn-floating tooltipped"
                        data-tooltip={_("an.addLabel")}>
                    <i class="material-icons">add</i>
                </a>
            </div>
        </div>
        <div if={labels.length < 1 && !loadingLabels} class="row">
            <div class="col s12">
                <em>{_("an.noLabels")}</em>
            </div>
        </div>
    </div> <!-- end of labels -->
    <div id="skematag"></div>
    <div class="browse-labels card fullscreen" if={show_search}>
        <button class="btn btn-flat right"
              onclick={toggle_search}>
              <i class="material-icons">close</i>
        </button>
        <div class="card-content">
            <div class="card-title">{_("an.searchLabels")}</div>
            <div class="row" each={idx in search_rows}>
                <div class="col s1">
                    <button class="btn btn-flat" onclick={idx>0 ? del_row : add_row}>
                        <i class="material-icons">{idx>0 ? "remove" : "add"}</i>
                    </button>
                </div>
                <div class="col s4 m3 l2 input-field">
                    <input id="semtype_{idx}" placeholder={_("an.semtype")}
                            list="semtypes" />
                </div>
                <div class="col s4 m3 l2 input-field">
                    <input placeholder={_("an.position")} id="position_{idx}"
                            list="positions" />
                </div>
                <div class="col s3 input-field" if={idx == 0}>
                    <button class="btn btn-flat" onclick={browse_labels}>
                        <i class="material-icons">search</i>
                    </button>
                </div>
            </div>
            <div class="row">
                <div class="col s12" style="padding-top: 1em;">
                    <preloader-spinner center={1} if={loadingBrowseLabels}>
                    </preloader-spinner>
                    <column-table
                            items={onto_search_result}
                            show-line-nums={true}
                            max-column-count={0}
                            col-meta={[{id: "query"}, {id: "label"}]}>
                    </column-table>
                    <p if={onto_search_empty}>{_("an.ontoSearchEmpty")}</p>
                </div>
            </div>
        </div>
    </div>
    <div class="ontology card fullscreen {hidden: !show_ontology}">
        <button class="btn btn-flat right"
            onclick={hide_ontology}>
            <i class="material-icons">close</i>
        </button>
        <div class="card-content">
            <div if={!loadingOntology && model.ontology && !noonto}>
                <div class="card-title">{ontology_label}</div>
                <ui-input class="mt-4" label-id="filter" inline=1 on-input={onFilter} style="max-width: 150px;"/>
                <node data={nodes}></node>
            </div>
            <div if={loadingOntology}>{_("loading")}</div>
            <div if={noonto}>
                <span>{_("an.noOnto")}</span>
            </div>
        </div>
    </div>
    <div class="listing card fullscreen" if={show_listing}>
        <div class="card-content">
            <div class="card-title">{_("an.browseValues")}</div>
            <preloader-spinner center={1} if={loadingListing}></preloader-spinner>
            <div class="row" if={!loadingListing}>
                <div class="col s4">
                    <label for="search-st" class="active">{_("an.semtype")}</label>
                    <input onkeyup={listing_search.bind(this, "semtype")}
                            id="search-st" placeholder={_("an.searchST")} />
                    <table class="listing_result">
                        <tbody>
                            <tr each={st in listing_result["semtype"]}>
                                <td>{st[0]}</td>
                                <td>
                                    <span each={s in st[1]}>
                                        <button onclick={open_query}>{s[0]}</button>:{s[1]}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col s4">
                    <label for="search-ls" class="active">{_("an.lexitem")}</label>
                    <input onkeyup={listing_search.bind(this, "lexset")} type="text"
                            id="search-ls" />
                    <table class="listing_result">
                        <tbody>
                            <tr each={ls in listing_result["lexset"]}>
                                <td>{ls[0]}</td>
                                <td>
                                    <span each={li in ls[1]}>
                                        <button onclick={open_query}>{li[0]}</button>:{li[1]}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col s4">
                    <label for="search-r" class="active">{_("an.role")}</label>
                    <input onkeyup={listing_search.bind(this, "role")} type="text"
                            id="search-r" />
                    <table class="listing_result">
                        <tbody>
                            <tr each={r in listing_result["role"]}>
                                <td>{r[0]}</td>
                                <td>
                                    <span each={ri in r[1]}>
                                        <button onclick={open_query}>{ri[0]}</button>:{ri[1]}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div> <!-- end of listing -->
    <datalist id="semtypes">
        <option each={st in semtypes} value={st} />
    </datalist>
    <datalist id="positions">
        <option each={p in positions} data-value={p[0]}>{p[1]}</option>
    </datalist>
    <datalist id="statuses" if={model.status_codes}>
        <option each={st in model.status_codes} value={st} />
    </datalist>

    <script>
        this.mixin("tooltip-mixin")
        const {AnnotationStore} = require("annotation/annotstore.js")
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")
        const {Url} = require("core/url.js")

        require('annotation/annotation.scss')
        require('annotation/pattern-string.tag')
        require('annotation/node.tag')

        // project specific components
        require('annotation/generic.tag')
        require('annotation/tpas.tag')
        require('annotation/ivdnt.tag')
        require('annotation/pdev.tag')
        require('annotation/croatpas.tag')

        this.store = AnnotationStore
        this.store.pageTag = this
        this.query = null
        this.label = null
        this.show_ontology = false
        this.show_listing = false
        this.sortQVal = {
            sort: 'desc',
            orderBy: 'edited'
        }

        // from queries
        this.queries = AnnotationStore.queries || []
        this.matched_queries = []
        this.search_query = ""
        this.page = 1
        this.last_page = -1
        this.opened_query = -1

        // labels
        this.labels = AnnotationStore.labels || []
        this.query_edited = false
        this.opened_label = AnnotationStore.labelidx || -1
        this.show_all_labels = false
        this.renaming = false
        this.showWarning = -1
        this.loadingLabels = false
        this.loadingQueries = AnnotationStore.loading_queries
        this.itemsPerPage = 10
        this.editLabel = []

        // ontology
        this.onto_search_result = []
        this.onto_search_empty = false
        this.search_rows = [0]
        this.loadingOntology = false
        this.noonto = false

        truncateWithEllipses(text, max) {
            return text.length>max ? text.substr(0,max-1) + '...' : text
        }

        onSort(sortQVal) {
            this.sortQVal = sortQVal
            this.sortQuery()
            this.update()
        }

        sortQuery(){
            let sortColumn = this.sortQVal.orderBy
            let type = this.schema.find(sch => sch.id == sortColumn).type

            if (type=="string"){
                this.queries.sort(function(a, b) {
                    return a[sortColumn].localeCompare(b[sortColumn])
                })
            } else if (type=="datetime") {
                this.queries.sort(function(a, b) {
                    return new Date(a[sortColumn]) - new Date(b[sortColumn])
                })
            } else {
                this.queries.sort(function(a, b) {
                    return a[sortColumn] - b[sortColumn]
                })
            }

            (this.sortQVal.sort == "desc") && this.queries.reverse()

            this.page = 1
            this.search_query && this.filterQueries()
            this.paginate()
        }

        changeItemsPerPage(v) {
            this.page = 1
            this.itemsPerPage = v
            this.paginate()
        }

        toggle_all_labels() {
            this.show_all_labels = !this.show_all_labels
        }

        showInput(e){
            e.preventDefault()
            e.stopPropagation()
            this.editLabel[e.item.l.id] = true
            this.update()
            e.target.parentNode.querySelector('input').focus()
        }

        updateLabelName(value, name, e){
            this.editLabel[name] = false
            let newVal = value.trim()
            let lbl = e.item.l

            if (newVal && newVal !== lbl.label && !this.labels.some(l => l.label === newVal)) {
                $.ajax({
                    url: window.config.URL_BONITO + 'renlngroup',
                    data: {
                        corpname: this.corpname,
                        qid: lbl.qid,
                        lid: lbl.id,
                        label: newVal
                    },
                    xhrFields: {
                        withCredentials: true
                    },
                    success: function (d) {
                        lbl.label = newVal
                        SkE.showToast(_("labelSaved", [newVal]), {duration: 5000})
                        AnnotationStore.updateQueryRow(d)
                        this.update()
                    }.bind(this),
                    error: function (d) {
                        console.log(d)
                    }
                })
            }
        }

        checkSymbols(ev) {
            if (ev.keyCode == 124 || ev.keyCode == 58) {
                this.showWarning = ev.item.i
                setTimeout(function () {
                    this.showWarning = -1
                    this.update()
                }.bind(this), 2000)
                ev.preventDefault()
                ev.stopPropagation()
            }
        }

        cancel_rename() {
            this.renaming = false
        }

        updateLabCnt(qid, how) {
            how = how || 1
            for (let i=0; i<this.queries.length; i++) {
                if (this.queries[i].id == qid) {
                    this.queries[i].label_count += how
                }
            }
        }

        updatePatStr(labeldata) {
            for (let i=0; i<this.labels.length; i++) {
                if (this.labels[i].id == labeldata.id) {
                    this.labels[i].data = labeldata.data
                    let rl = AnnotationStore.render(this.labels[i].data)
                    this.labels[i].pattern_string = rl[0]
                    this.labels[i].pattern_string_flat = rl[1]
                }
            }
            this.update()
        }

        renLabels() {
            if (this.renaming) {
                let qid = this.labels[0].qid
                let data = []
                $('.labels table tr').each(function (el) {
                    let l1 = $(this).find('td:nth-child(1)').text()
                    let l2 = $(this).find('td:nth-child(2) input').val()
                    let lid = $(this).find('td:nth-child(2) input').data('lid')
                    if (l1 != l2) {
                        data.push(lid + "::" + l2)
                    }
                })
                if (data.length) {
                    $.ajax({
                        url: window.config.URL_BONITO + 'annot_rename_labels',
                        data: {
                            corpname: this.corpname,
                            qid: qid,
                            data: data.join('||')
                        },
                        xhrFields: {
                            withCredentials: true
                        },
                        success: function (d) {
                            this.renaming = false
                            this.loadingLabels = true
                            AnnotationStore.getAnnotLabels()
                            AnnotationStore.updateQueryRow(d)
                            this.update()
                        }.bind(this),
                        error: function (d) {
                            console.log(d)
                        }
                    })
                }
                else {
                    this.renaming = false
                    this.update()
                }
            }
            else {
                this.close_label()
                this.renaming = true
            }
        }


        onshow_new_label_form() {
            AnnotationStore.addLabelModal()
        }

        oninput(e) {
            let i = e.item ? e.item.i : null
            let name = e.target.name
            this.query_edited = true
            this.update()
            return true
        }

        onStatusChange(e) {
            let st = this.refs.status.value
            $.ajax({
                url: window.config.URL_BONITO + 'annot_save_query',
                data: {
                    id: this.query.id,
                    status: st,
                    corpname: this.corpname
                },
                xhrFields: {
                    withCredentials: true
                },
                success: function (d) {
                    for (let i=0; i<this.queries.length; i++) {
                        if (this.queries[i].id == this.query.id) {
                            this.queries[i].status = st
                        }
                    }
                    AnnotationStore.updateQueryRow(d)
                    this.update()
                }.bind(this),
                error: function (d) {
                    console.log(d)
                },
                complete: function (d) {
                    this.query_edited = false
                    this.update()
                }.bind(this)
            })
        }

        close_query() {
            // TODO: check if label or query was changed before closing!
            this.opened_query = -1
            this.query = null
            this.close_label()
        }

        confirm_del_label(e) {
            Dispatcher.trigger("openDialog", {
                title: _("an.confirmDelete"),
                content: _("an.permDelLabel"),
                small: 1,
                buttons: [
                    {
                        label: _("delete"),
                        class: "btn-primary",
                        onClick: function () {
                            $.ajax({
                                url: window.config.URL_BONITO + 'dellngroup',
                                data: {
                                    qid: e.item.l.qid,
                                    lid: e.item.l.id,
                                    corpname: this.corpname
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                success: function (d) {
                                    this.labels.splice(e.item.i, 1)
                                    this.opened_label = -1
                                    AnnotationStore.labelidx = -1
                                    this.label = {}
                                    this.updateLabCnt(this.query.id, -1)
                                    AnnotationStore.updateQueryRow(d)
                                    this.update()
                                }.bind(this),
                                error: function () {
                                    console.log('Labels could not be deleted.')
                                },
                                complete: function (d) {
                                    Dispatcher.trigger("closeDialog")
                                    this.update()
                                }.bind(this)
                            })
                        }.bind(this)
                    }
                ]
            })
        }

        // listing
        this.listing = {}
        this.listing_result = {"semtype": [], "lexset": [], "role": []}
        this.loadingListing = false

        listing_search(type, ev) {
            let q = ev.target.value.toLowerCase()
            this.result[type] = []
            for (let i=0; i<this.listing[type].length; i++) {
                let k = this.listing[type][i][0]
                if (k.toLowerCase().indexOf(q) >= 0) {
                    this.result[type].push(this.listing[type][i])
                }
            }
        }

        stopClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
        }

        external_open_query(q) {
            let query = {}
            for (let i=0; i<this.queries.length; i++) {
                if (this.queries[i]["query"] == q) {
                    this.page = Math.floor(i / this.itemsPerPage) + 1
                    this.paginate()
                    query = this.queries[i]
                    break
                }
            }
            if (!query.conc) return
            this.opened_query = query.id
            this.labels = AnnotationStore.labels
            if (AnnotationStore.labelidx >= 0) {
                this.label = this.labels[AnnotationStore.labelidx]
                this.opened_label = AnnotationStore.labelidx
            }
            else {
                this.label = null
                this.opened_label = -1
            }
            this.query = query
            this.update()
        }

        open_annotconc(ac) {
            for (let i=0; i<this.queries.length; i++) {
                if (this.queries[i].query == ac) {
                    this.opened_query = this.queries[i].id
                    this.label = null
                    this.opened_label = -1
                    this.query = this.queries[i]
                    break
                }
            }
            this.update()
        }

        get_listing() {
            this.loadingListing = true
            $.ajax({
                xhrFields: {
                    withCredentials: true
                },
                url: window.config.URL_BONITO + `annot_listing?corpname=${this.corpname}`,
                success: function (payload) {
                    this.listing = payload
                }.bind(this),
                error: function (payload) {
                    console.log('ERROR', payload.error)
                }.bind(this),
                complete: function () {
                    this.loadingListing = false
                    this.update()
                }.bind(this)
            })
        }
        // this.get_listing()

        toggle_search() {
            this.show_search = !this.show_search
        }

        toggle_listing() {
            this.show_listing = !this.show_listing
        }

        hide_ontology() {
            this.show_ontology = false
        }

        toggle_ontology() {
            this.show_ontology = !this.show_ontology
            if (this.show_ontology && $.isEmptyObject(AnnotationStore.nodes)) {
                this.get_onto()
            }
        }

        close_label() {
            this.label = null
            this.opened_label = -1
            AnnotationStore.labelidx = -1
            this.skematag.innerHTML = ""
            this.skematag.className = ""
            this.update()
        }

        open_label(row) {
            this.opened_label = row.item.i
            AnnotationStore.labelidx = row.item.i
            this.label = row.item.l
            riot.mount(this.skematag,
                    this.annotation_group.indexOf("user_") == 0 ? "generic" : this.annotation_group,
                    {
                        query: this.query,
                        data: this.label,
                        settings: this.settings
                    })
            AnnotationStore.labelidx > -1 && this.skematag.scrollIntoView(true)
        }

        initialize() {
            this.page = 1
            this.matched_queries = this.queries
            this.paginate()
            AnnotationStore.annotconc && this.external_open_query(AnnotationStore.annotconc)
        }

        remove_query(e) {
            Dispatcher.trigger("openDialog", {
                title: _("an.confirmRemQuery"),
                content: _("an.reallyRemoveQuery"),
                small: 1,
                buttons: [
                    {
                        label: _("an.remove"),
                        class: "btn-primary",
                        onClick: function () {
                            $.ajax({
                                url: window.config.URL_BONITO + 'delstored',
                                xhrFields: {
                                    withCredentials: true
                                },
                                data: {
                                    corpname: this.corpname,
                                    annotconc: e.item.q.conc
                                },
                                success: function (payload) {
                                    AnnotationStore.removeQueryFromQueries(payload.removed)
                                    this.page = 1
                                    this.search_query && this.filterQueries()
                                    this.opened_query = -1
                                    this.label = null
                                    this.query = null
                                    this.update()
                                }.bind(this),
                                error: function (payload) {
                                    console.log(payload)
                                },
                                complete: function () {
                                    Dispatcher.trigger("closeDialog")
                                }
                            })
                        }.bind(this)
                    }
                ]
            })
            e.stopPropagation()
            e.preventUpdate = true
        }

        paginate() {
            let from = (this.page-1) * this.itemsPerPage
            this.show_queries = this.matched_queries.slice(from,
                    this.page*this.itemsPerPage)
            this.last_page = Math.floor(this.matched_queries.length /
                    this.itemsPerPage) + 1
            this.update()
        }
        this.paginate()

        filterQueries(value, name, e) {
            if (e && e.currentTarget) {
                this.search_query = e.currentTarget.value.toLowerCase().trim()
            }
            if (this.search_query == '') {
                this.matched_queries = this.queries
                this.paginate()
                return
            }
            this.matched_queries = []
            for (let i=0; i<this.queries.length; i++) {
                var re = new RegExp(this.search_query, 'g')
                if (this.queries[i]['query'].toLowerCase().search(re) >= 0) {
                    this.matched_queries.push(this.queries[i])
                }
            }
            this.page = 1
            this.paginate()
        }

        changePage(page) {
            this.page = page
            this.paginate()
        }

        label_annot_url() {
            return location.origin + "#concordance?"
                + `corpname=${this.corpname}&`
                + `showresults=1&annotconc=${this.query.conc}`
                + "&gdex_enabled=" + ConcordanceStore.data.gdex_enabled
                + "&gdexconf=" + ConcordanceStore.data.gdexconf
                + "&operations_annotconc=" + JSON.stringify([
                    {
                        name: "",
                        arg: this.query.conc,
                        active: true,
                        query: {q: 's' + this.query.conc}
                    },
                    {
                        name: _("an.posFilter"),
                        arg: encodeURIComponent(this.label.label),
                        active: true,
                        query: {q: 'L' + this.query.conc + ' -' + this.label.id}
                    }
                ])
        }

        query_annot_url(conc) {
            return location.origin + "#concordance?corpname="
                    + this.corpname + "&annotconc=" + (conc ? encodeURI(conc) : this.query.conc)
                    + "&showresults=1"
                    + "&gdex_enabled=" + ConcordanceStore.data.gdex_enabled
                    + "&gdexconf=" + ConcordanceStore.data.gdexconf
        }

        open_query(row) {
            this.opened_query = row.item.q.id
            this.label = null
            this.opened_label = -1
            AnnotationStore.labelidx = -1
            this.query = row.item.q
            this.labels = []
            if (this.skematag) {
                this.skematag.innerHTML = ""
                this.skematag.className = ""
            }
            this.loadingLabels = true
            AnnotationStore.annotconcToUrl(this.query.conc)
            AnnotationStore.getAnnotLabels()
            this.update()
        }


        updateQueries() {
            this.loadingQueries = false
            this.queries = AnnotationStore.queries
            this.initialize()
            this.search_query && this.filterQueries()
            this.update()
        }

        updateLabels() {
            this.updateQueries()
            this.loadingLabels = AnnotationStore.annotLabelsLoading
            this.labels = AnnotationStore.labels
            this.num_of_sublabels = AnnotationStore.nsublabels
            if (AnnotationStore.labelidx >= 0) {
                this.opened_label = AnnotationStore.labelidx
                this.open_label({
                    item: {
                        i: AnnotationStore.labelidx,
                        l: this.labels[AnnotationStore.labelidx]
                    }
                })
            }
            this.update()
        }

        updateAttributes() {
            this.model = AnnotationStore.model
            this.schema = AnnotationStore.schema
            this.corpname = AnnotationStore.corpus.corpname
            this.annotation_group = AnnotationStore.annotation_group
            this.anclass = this.annotation_group.indexOf('user_') == 0 ? "generic" : this.annotation_group
            this.download_url = window.config.URL_BONITO + "annot_download?corpname=" + this.corpname
            this.ontology_label = this.model.ontology_label || _("an.ontology")
            this.nodes = AnnotationStore.nodes
            this.settings = {
                corpname: this.corpname,
                schema: this.schema,
                model: this.model,
                annotation_group: this.annotation_group
            }
            this.semtypes = this.model.semtypes
            this.positions = this.model.positions
            this.concordanceFormUrl = Url.create("concordance", {corpname: this.corpname})
        }
        this.updateAttributes()


        filteNode(node){
            if(node._sub){
                node._sub.forEach(sub => {
                    this.filteNode(sub)
                })
            }
            node._match = node._st.toLowerCase().indexOf(this.searchQuery) != -1
            node._opened = this.searchQuery &&
                (node._match || (node._sub && node._sub.some(sub => sub._opened)))
        }

        onFilter(value){
            this.searchQuery = value.toLowerCase()
            this.filteNode(this.nodes)
            this.update()
        }

        get_onto() {
            this.loadingOntology = true
            $.ajax({
                xhrFields: {
                    withCredentials: true
                },
                url: window.config.URL_BONITO + 'annot_onto?corpname=' + this.corpname,
                success: function (payload) {
                    if (payload.error) {
                        AnnotationStore.nodes = null
                        this.noonto = true
                    }
                    else {
                        AnnotationStore.nodes = payload.ontology
                        AnnotationStore.nodes["_opened"] = true
                        this.nodes = payload.ontology
                        this.nodes["_opened"] = true
                        this.noonto = false
                    }
                }.bind(this),
                error: function (payload) {
                    console.log(payload)
                }.bind(this),
                complete: function () {
                    this.loadingOntology = false
                    this.update()
                }.bind(this)
            })
        }

        add_row() {
            let lastid = this.search_rows[this.search_rows.length-1]
            this.search_rows.push(lastid+1)
            this.update()
        }

        del_row(ev) {
            this.search_rows.pop(this.search_rows.indexOf(ev.item.idx))
            this.update()
        }

        browse_labels() {
            let semtype_values = []
            let position_values = []
            $('[id^="semtype_"]').each(function (i, el) {
                semtype_values.push($(el).val())
            })
            $('[id^="position_"]').each(function (i, el) {
                position_values.push($(el).val())
            })
            this.loadingBrowseLabels = true
            this.onto_search_result = []
            $.ajax({
                xhrFields: {
                    withCredentials: true
                },
                url: window.config.URL_BONITO + "annot_query_labels?"
                        + "&position=" + position_values.join('&position=')
                        + '&semtype=' + semtype_values.join("&semtype=")
                        + '&corpname=' + this.corpname,
                success: function (payload) {
                    this.onto_search_result = payload.data
                    this.onto_search_empty = !payload.data.length
                    this.loadingBrowseLabels = false
                    this.update()
                }.bind(this),
                error: function (payload) {
                    this.loadingBrowseLabels = false
                    this.update()
                    console.log(payload)
                }.bind(this)
            })
        }

        this.on("update", this.updateAttributes)

        this.on("mount", function () {
            AnnotationStore.on("ANNOTATIONS_UPDATED", this.updateQueries)
            AnnotationStore.on("ANNOTATION_LABELS_UPDATED", this.updateLabels)
            AnnotationStore.on("ANNOTATION_LABEL_SAVED", this.updatePatStr)
            this.initialize()
            this.skematag = document.getElementById("skematag")
        })

        this.on("unmount", function () {
            AnnotationStore.off("ANNOTATIONS_UPDATED", this.updateQueries)
            AnnotationStore.off("ANNOTATION_LABELS_UPDATED", this.updateLabels)
            AnnotationStore.off("ANNOTATION_LABEL_SAVED", this.updatePatStr)
        })
    </script>
</page-annotation>
