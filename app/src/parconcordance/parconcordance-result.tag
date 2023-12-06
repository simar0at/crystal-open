<parconcordance-result class={hasAttributes: hasAttributes,
            hasContextAttributes: hasContextAttributes,
            viewSen: data.viewmode == "sen",
            viewKwic: data.viewmode == "kwic"}>
    <div class="table material-table highlight result-table" if={items.length} onmouseover={onMouseOver}>
        <div class="thead">
            <div class="tr">
                <div if={data.linenumbers} class="th partmenu"></div>
                <div if={refsLeft} class="th partmenu"></div>
                <div class="th partmenu t_m-1">
                    <parconcordance-result-options-part
                            allowrm={false}>
                    </parconcordance-result-options-part>
                </div>
                <div if={data.gdex_enabled && data.show_gdex_scores} class="th gdexth">{_("cc.gdexScore")}</div>
                <div each={al, idx in items[0].Align} no-reorder class="th partmenu t_m-{idx + 2}">
                    <parconcordance-result-options-part
                            has_no_kwic={al.has_no_kwic}
                            allowrm={data.formparts.length > 1}
                            corpname={data.formparts[idx].corpname}>
                    </parconcordance-result-options-part>
                </div>
            </div>
        </div>
        <concordance-detail-window></concordance-detail-window>
        <div class="tbody">
            <virtual each={item, idx in items} no-reorder>
                <parconcordance-result-refs-row if={refsUp}
                        item={item}
                        num={(data.itemsPerPage * (data.page - 1)) + idx + 1}
                        onclick={onRefClick}>
                </parconcordance-result-refs-row>
                <div class="tr r-{idx + 1} tn-{item.toknum}">
                    <div if={lineNumbersLeft} class="td num color-blue-200">
                        {(data.itemsPerPage * (data.page-1)) + idx + 1}
                    </div>
                    <div if={lineNumbersUp} class="td"></div>
                    <div if={refsLeft} class="td ref {hasRef: item.ref !== ''}" onclick={onRefClick}>
                        <span><i class="material-icons material-clickable t_lineDetail"
                                    data-tooltip={_("lineDetailsTip")}>
                            info_outline</i>&nbsp;
                            <span if={data.refs !== ""}
                                    data-tooltip={(data.shorten_refs) ? item.ref : null}
                                    class="ref-label">
                                {(data.ref_size < item.ref.length) ?
                                  item.ref.substring(0,data.ref_size)+"..." : item.ref}
                            </span>
                        </span>
                    </div>
                    <virtual if={data.viewmode == "kwic"}>
                        <div class="td ctd l-1 _t {corpusDirClass}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <div class="subtdl right-align"
                                    style="{item.Left.length ? 'width: 50%' : ''}">
                                <parconcordance-result-items data={item.Left}
                                        class="t_leftContext"></parconcordance-result-items>
                            </div>
                            <div class="subtdc center-align"
                                    style="{item.Left.length+item.Right.length ? 'white-space: nowrap' : ''}">
                                <parconcordance-result-items data={item.Kwic}
                                        class="t_kwic kwicWrapper"
                                        onclick={onKwicClick.bind(this, item, idx, 0)}></parconcordance-result-items>
                            </div>
                            <div class="subtdr left-align"
                                    style="{item.Right.length ? 'width: 50%' : ''}">
                                <parconcordance-result-items data={item.Right}
                                        class="t_rightContext"></parconcordance-result-items>
                            </div>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align} no-reorder
                                class="td ctd l-{idx2 + 2} {alignedClasses[idx2]} {noKWIC: al.has_no_kwic}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <div class="subtdl right-align _t"
                                    style="{al.has_no_kwic ? '' : 'width: 50%'}">
                                <parconcordance-result-items if={al.Left}
                                        class="t_leftContext"
                                        data={al.Left} ></parconcordance-result-items>
                            </div>
                            <div class="subtdc center-align _t"
                                    style="{al.Left.length+al.Right.length ? 'white-space: nowrap' : ''}">
                                <parconcordance-result-items data={al.Kwic}
                                        class="t_kwic kwicWrapper"
                                        onclick={onKwicClick.bind(this, al, idx, idx2 + 1)}></parconcordance-result-items>
                            </div>
                            <div class="subtdr left-align _t"
                                    style="{al.has_no_kwic ? '' : 'width: 50%'}">
                                <parconcordance-result-items if={al.Right}
                                        class="t_rightContext"
                                        data={al.Right} ></parconcordance-result-items>
                            </div>
                        </div>
                    </virtual>
                    <virtual if={data.viewmode == "sen"}>
                        <div class="td ctd l-1 _t {corpusDirClass}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <parconcordance-result-items data={item.Left}
                                    class="t_leftContext"></parconcordance-result-items>
                            <parconcordance-result-items data={item.Kwic}
                                    class="t_kwic kwicWrapper"
                                    onclick={onKwicClick.bind(this, item, idx, 0)}></parconcordance-result-items>
                            <parconcordance-result-items data={item.Right}
                                     class="t_rightContext"></parconcordance-result-items>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align} no-reorder
                                class="td ctd l-{idx2 + 2} {alignedClasses[idx2]} {noKWIC: al.has_no_kwic}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <parconcordance-result-items data={al.Left}
                                     class="t_leftContext"></parconcordance-result-items>
                            <parconcordance-result-items data={al.Kwic}
                                    class="t_kwic kwicWrapper"
                                    onclick={onKwicClick.bind(this, al, idx, idx2 + 1)}></parconcordance-result-items>
                            <parconcordance-result-items data={al.Right}
                                     class="t_rightContext"></parconcordance-result-items>
                        </div>
                    </virtual>
                    <virtual if={data.viewmode == "align"}>
                        <div class="td ctd l-1 _t {corpusDirClass}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <parconcordance-result-items data={item.Left}
                                    class="t_leftContext"></parconcordance-result-items>
                            <parconcordance-result-items data={item.Kwic}
                                    class="t_kwic kwicWrapper"
                                    onclick={onKwicClick.bind(this, item, idx, 0)}></parconcordance-result-items>
                            <parconcordance-result-items data={item.Right}
                                     class="t_rightContext"></parconcordance-result-items>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align} no-reorder
                                class="td ctd l-{idx2 + 2} _t {alignedClasses[idx2]}"
                                style="width: {100 / (item.Align.length + 1)}%">
                            <parconcordance-result-items data={al.Left}
                                     class="t_leftContext"></parconcordance-result-items>
                            <parconcordance-result-items data={al.Kwic}
                                    class="t_kwic {kwicWrapper: !al.has_no_kwic} {latentkwic: al.has_no_kwic}"
                                    onclick={onKwicClick.bind(this, al, idx, idx2 + 1)}></parconcordance-result-items>
                            <parconcordance-result-items data={al.Right}
                                    class="t_rightContext"></parconcordance-result-items>
                        </div>
                    </virtual>
                </div>
            </virtual>
        </div>
    </div>
    <ui-pagination
        if={data.total > 10}
        count={data.total}
        items-per-page={data.itemsPerPage}
        actual={data.page}
        on-change={store.changePage.bind(store)}
        on-items-per-page-change={store.changeItemsPerPage.bind(store)}
        show-prev-next={true}>
    </ui-pagination>


    <script>
        const {AppStore} = require("core/AppStore.js")
        const {AppStyle} = require("core/AppStyle.js")
        require("../concordance/concordance-line-detail-dialog.tag")
        require("../concordance/concordance-result.tag")
        require("../concordance/concordance-result.scss")

        this.mixin("feature-child")


        getCorpusPrefix(corpname){
            return corpname.substr(0, corpname.lastIndexOf("/") + 1)
        }

        getContextReducedItems(items){
            // combine items into groups - [{str:"have"}, {str:"some"}, {str:"time"}, {strc:"<s>"}, {str:"How"}] ->[{str:"have some time"}, {strc:"<s>"}, {str:"How"}]
            return items.reduce((arr, token) => {
                if(!arr.length){
                    arr.push(token)
                } else{
                    let lastToken = arr[arr.length - 1]
                    if(!token.strc && !lastToken.strc && token.coll === lastToken.coll && token.hl === lastToken.hl && token.color === lastToken.color){
                        arr[arr.length-1].str += " " + token.str
                    } else {
                        arr.push(token)
                    }
                }
                return arr
            }, [])
        }

        updateAttributes(){
            this.refsLeft = !this.data.refs_up && this.data.refs !== ""
            this.refsUp = !this.refsLeft && this.data.refs !== ""
            this.lineNumbersLeft = this.data.linenumbers && !this.refsUp
            this.lineNumbersUp = this.data.linenumbers && this.refsUp
            this.corpusDirClass = this.corpus.righttoleft ? "rtl" : "ltr"
            this.alignedClasses = []
            this.hasAttributes = this.data.attrs.split(",").length > 1
            this.hasContextAttributes =  this.hasAttributes && this.data.attr_allpos == "all"
            if(this.hasContextAttributes){
                this.items = this.data.items
            } else{
                this.items = copy(this.data.items)
                this.items.forEach(item => {
                    item.Left = this.getContextReducedItems(item.Left)
                    item.Kwic = this.getContextReducedItems(item.Kwic)
                    item.Right = this.getContextReducedItems(item.Right)
                    item.Align.forEach(aligned => {
                        aligned.Left = this.getContextReducedItems(aligned.Left)
                        aligned.Kwic = this.getContextReducedItems(aligned.Kwic)
                        aligned.Right = this.getContextReducedItems(aligned.Right)
                    })
                }, this)
            }
            this.data.formparts.forEach((part, idx) => {
                let corpus = AppStore.getCorpusByCorpname(this.getCorpusPrefix(this.corpus.corpname) + part.corpname)
                let classes = [this.store.isAlignedRtl(idx) ? "rtl": "ltr"]
                if(corpus){
                    classes.push(AppStyle.getLangFontClass(corpus.language_id))
                    let script = AppStyle.getCorpusScript(corpus.corpname)
                    if(script != "Latn"){
                        script && classes.push("script-" + script.toLowerCase())
                    }
                }
                this.alignedClasses.push(classes.join(" "))
            }, this)
        }
        this.updateAttributes()

        onKwicClick(item, row_idx, lang_idx, evt) {
            let prefix = this.getCorpusPrefix(this.corpus.corpname)
            $(".tr.highlight", this.root).toggleClass("highlight", false)
            this.toggleRowHighlight(item.toknum, true)
            let cols = [{
                corpname: this.store.corpus.corpname,
                toknum: this.data.items[row_idx].toknum,
                hitlen: this.data.items[row_idx].hitlen
            }]
            this.data.items[row_idx].Align.forEach((row, i) => {
                cols.push({
                    corpname: prefix + this.data.formparts[i].corpname,
                    toknum: row.toknum,
                    hitlen: row.hitlen
                })
            })

            Dispatcher.trigger("concordanceShowDetail", {
                cols: cols,
                corpname: lang_idx == 0 ? this.store.corpus.corpname : (prefix + this.data.formparts[lang_idx - 1].corpname),
                structs: this.store.getStructs(),
                onClose: this.toggleRowHighlight.bind(this, item.toknum, false)
            }, evt)
        }

        onRefClick(evt) {
            evt.preventUpdate = true
            let toknum = evt.item.item.toknum
            // in case detail was opened and user click another row
            $(".tr.highlight", this.root).toggleClass("highlight", false)

            this.toggleRowHighlight(toknum, true)
            Dispatcher.trigger("openDialog", {
                tag: "concordance-line-detail-dialog",
                class: "modal-line-detail",
                opts: {
                    store: this.store,
                    toknum: toknum
                },
                buttons: [{
                    label: _("save"),
                    class: "btn-primary",
                    onClick: (dialog) => {
                        dialog.contentTag.save()
                    }
                }],
                fixedFooter: 1,
                big: 1,
                tall: 1,
                onClose: this.toggleRowHighlight.bind(this, toknum, false)
            })
        }

        getGDEXScore(item){
            let score = this.data.gdex_scores[item.toknum]
            return isDef(score) ? (score + "").substr(0, 5) : ""
        }

        toggleRowHighlight(toknum, highlight){
            $(".tn-" + toknum).toggleClass("highlight", highlight)
        }

        onMouseOver(evt){
            evt.preventUpdate = true
            let tooltip = jQuery(evt.target).data().tooltip
            tooltip && window.showTooltip(evt.target, tooltip, 600)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.store.on("translations_loaded", this.update)
            AppStore.on("corpusListChanged", this.update)
        })

        this.on("unmount", () => {
            this.store.off("translations_loaded", this.update)
            AppStore.off("corpusListChanged", this.update)
        })
    </script>
</parconcordance-result>
