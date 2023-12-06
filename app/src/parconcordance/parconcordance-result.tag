<parconcordance-result>
    <div class="table material-table highlight result-table
                display{data.viewmode == 'kwic' ? 'Kwic' : 'Sen'}" if={data.items.length}>
        <div class="thead">
            <div class="tr">
                <div if={data.linenumbers} class="th partmenu"></div>
                <div if={refsLeft} class="th partmenu"></div>
                <div class="th partmenu">
                    <parconcordance-result-options-part
                            allowrm={false}>
                    </parconcordance-result-options-part>
                </div>
                <div if={data.gdex_enabled && data.show_gdex_scores} class="th gdexth">{_("cc.gdexScore")}</div>
                <div each={al, idx in data.items[0].Align} class="th partmenu">
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
            <virtual each={item, idx in data.items}>
                <parconcordance-result-refs-row if={data.refs_up}
                        item={item}
                        num={(data.itemsPerPage * (data.page - 1)) + idx + 1}
                        onclick={onRefClick}>
                </parconcordance-result-refs-row>
                <div class="tr tn-{item.toknum}">
                    <div if={lineNumbersLeft} class="td num medium">
                        {(data.itemsPerPage * (data.page-1)) + idx + 1}
                    </div>
                    <div if={lineNumbersUp} class="td"></div>
                    <div class="td ref" if={refsLeft}
                            onclick={onRefClick}
                            style={"max-width: " + (data.shorten_refs ? (data.ref_size + "em;") : "auto")}>
                        <span>
                            <a class="btn btn-flat btn-floating lineDetail tooltipped"
                                    data-tooltip={_("lineDetailsTip")}>
                                <i class="material-icons medium">info_outline</i>
                            </a>{item.ref}</span>
                    </div>
                    <virtual if={data.viewmode == "kwic"}>
                        <div class="td ctd _t {corpusDirClass}"
                                style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <div class="subtdl right-align"
                                    style={item.Left.length ? "width: 50%" : ""}>
                                <parconcordance-result-context data={item.Left}></parconcordance-result-context>
                            </div>
                            <div class="subtdc center-align"
                                    style={item.Left.length+item.Right.length ? "white-space: nowrap" : ""}>
                                <span each={kwic in item.Kwic}
                                        class="kwicWrapper"
                                        onclick={onKwicClick.bind(this, item)}>
                                    <span if={kwic.str} class="kwic">{kwic.str}</span>
                                    <span if={kwic.strc} class="strc">{kwic.strc}</span>
                                    <span if={kwic.attr} class="attr">
                                        {kwic.attr.substr(1)}
                                    </span>
                                </span>
                            </div>
                            <div class="subtdr left-align"
                                    style={item.Right.length ? "width: 50%" : ""}>
                                <parconcordance-result-context data={item.Right}></parconcordance-result-context>
                            </div>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align}
                                class="td ctd {alignedClasses[idx2]} {noKWIC: al.hasKwic}"
                                style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <div class="subtdl right-align _t"
                                    style={al.hasKwic ? "width: 50%" : ""}>
                                <parconcordance-result-context data={al.Left} if={al.Left}></parconcordance-result-context>
                            </div>
                            <div class="subtdc center-align _t"
                                    style={al.Left.length+al.Right.length ? "white-space: nowrap" : ""}>
                                <span each={kwic in al.Kwic}
                                        class="kwicWrapper"
                                        onclick={onKwicClick.bind(this, al, idx2)}>
                                    <span class="kwic">{kwic.str}</span>
                                    <span if={kwic.attr} class="attr">
                                        {kwic.attr.substr(1)}
                                    </span>
                                </span>
                            </div>
                            <div class="subtdr left-align _t"
                                    style={al.hasKwic ? "width: 50%" : ""}>
                                <parconcordance-result-context data={al.Right} if={al.Right}></parconcordance-result-context>
                            </div>
                        </div>
                    </virtual>
                    <virtual if={data.viewmode == "sen"}>
                        <div class="td ctd _t {corpusDirClass}"
                                style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <parconcordance-result-context data={item.Left}></parconcordance-result-context>
                            <span each={kwic in item.Kwic}
                                    class="kwicWrapper"
                                    onclick={onKwicClick.bind(this, item)}>
                                <span if={kwic.str} class="kwic">{kwic.str}</span>
                                <span if={kwic.strc} class="strc">{kwic.strc}</span>
                                <span if={kwic.attr} class="attr">
                                    {kwic.attr.substr(1)}
                                </span>
                            </span>
                            <parconcordance-result-context data={item.Right}></parconcordance-result-context>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align}
                                class="td ctd {alignedClasses[idx2]} {noKWIC: al.hasKwic}"
                                style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <parconcordance-result-context data={al.Left}></parconcordance-result-context>
                            <span each={kwic in al.Kwic} class="kwicWrapper"
                                    onclick={onKwicClick.bind(this, al, idx2)}>
                                <span class="kwic">{kwic.str}</span>
                                <span if={kwic.strc} class="strc">{kwic.strc}</span>
                                <span if={kwic.attr} class="attr">{kwic.attr.substr(1)}</span>
                            </span>
                            <parconcordance-result-context data={al.Right}></parconcordance-result-context>
                        </div>
                    </virtual>
                    <virtual if={data.viewmode == "align"}>
                        <div class="td ctd_t {corpusDirClass}"
                                style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <parconcordance-result-context data={item.Left}></parconcordance-result-context>
                            <span each={kwic in item.Kwic}
                                    class="kwicWrapper"
                                    onclick={onKwicClick.bind(this, item)}>
                                <span if={kwic.str} class="kwic">{kwic.str}</span>
                                <span if={kwic.strc} class="strc">{kwic.strc}</span>
                                <span if={kwic.attr}
                                        class="attr">{kwic.attr.substr(1)}
                                </span>
                            </span>
                            <parconcordance-result-context data={item.Right}></parconcordance-result-context>
                        </div>
                        <div if={data.gdex_enabled && data.show_gdex_scores} class="td gdex">
                            <span class="badge small">{getGDEXScore(item)}</span>
                        </div>
                        <div each={al, idx2 in item.Align}
                                class="td ctd {alignedClasses[idx2]}" style={"width:" + 100/(item.Align.length+1) + "%"}>
                            <parconcordance-result-context data={al.Left}></parconcordance-result-context>
                            <span each={kwic in al.Kwic} class="kwicWrapper"
                                    onclick={al.has_no_kwic ? undefined : onKwicClick.bind(this, al, idx2)}>
                                <span class={latentkwic: al.has_no_kwic, kwic: !al.has_no_kwic, hl: kwic.hl}>{kwic.str}</span>
                                <span if={kwic.strc} class="strc">{kwic.strc}</span>
                                <span if={kwic.attr} class="attr">{kwic.attr.substr(1)}</span>
                            </span>
                            <parconcordance-result-context data={al.Right}></parconcordance-result-context>
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
        require("../concordance/concordance-line-detail-dialog.tag")

        this.mixin("feature-child")


        getCorpusPrefix(corpname){
            return corpname.substr(0, corpname.lastIndexOf("/") + 1)
        }

        updateAttributes(){
            this.refsLeft = !this.data.refs_up
            this.lineNumbersLeft = this.data.linenumbers && !this.data.refs_up
            this.lineNumbersUp = this.data.linenumbers && this.data.refs_up
            this.corpusDirClass = this.corpus.righttoleft ? "rtl" : "ltr"
            this.alignedClasses = []
            this.data.formparts.forEach((part, idx) => {
                let corpus = AppStore.getCorpusByCorpname(this.getCorpusPrefix(this.corpus.corpname) + part.corpname)
                let classes = corpus ? window.getLangFontClass(corpus.language_id) : ""
                classes += this.store.isAlignedRtl(idx) ? " rtl": " ltr"
                this.alignedClasses.push(classes)
            }, this)
        }
        this.updateAttributes()

        onKwicClick(item, idx) {
            let toknum = item.toknum
            $(".tr.highlight", this.root).toggleClass("highlight", false)
            this.toggleRowHighlight(toknum, true)
            let corpname = null
            if(Number.isInteger(idx)){
                corpname = this.getCorpusPrefix(this.corpus.corpname) + this.data.formparts[idx].corpname
            }
            Dispatcher.trigger("concordanceShowDetail", {
                kwic: true,
                corpname: corpname,
                hitlen: item.hitlen,
                structs: this.store.getStructs(),
                toknum: toknum,
                onClose: this.toggleRowHighlight.bind(this, toknum, false)
            })
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

        this.on("update", this.updateAttributes)
    </script>
</parconcordance-result>
