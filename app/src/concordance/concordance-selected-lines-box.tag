<concordance-selected-lines-box  class="concordance-selected-lines-box">
    <div class="z-depth-3">
        <span class="closeBtnWrapper">
            <i class="material-icons material-clickable" onclick={onDeselectAllClick}>close</i>
        </span>
        <div class="columnsWrapper flex">
            <div>
                <label>{_("selectOnPage")}:</label>
                <div>
                    <button class="btn" onclick={onSelectPageClick}>{_("all")}</button>
                    <button class="btn" onclick={onDeselectPageClick}>{_("none")}</button>
                </div>
            </div>
            <div if={data.checkboxes}>
                <label>
                    {_("showOnly")}
                </label>
                <div>
                    <a class="btn" href={urlSelectedLines}>
                        {_("selected")} ({store.selectedLines.length})
                    </a>
                    <a class="btn" href={urlNotSelectedLines}>
                        {_("notSelected")}
                    </a>
                </div>
            </div>
            <div>
                <label>
                </label>
                <div>
                    <button class="btn" onclick={onCopyClick}>
                        {_("copy")} ({store.selectedLines.length})
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./concordance-selected-lines-box.scss")

        this.mixin("feature-child")

        onCopyClick(){
            let text = this.store.selectedLines.reduce((str, line) => {
                str += (str ? "\n" : "") + line.text
                return str
            }, "")
            window.copyToClipboard(text, SkE.showToast.bind(null, _("copied")))
        }

        onSelectPageClick(){
            this.store.selectedLinesSelectPage()
            this.toggleLinesSelection(true)
        }

        onDeselectPageClick(){
            this.store.selectedLinesDeselectPage()
            this.toggleLinesSelection(false)
        }

        onDeselectAllClick(){
            this.store.selectedLinesDeselectAll()
            this.toggleLinesSelection(false)
        }

        toggleLinesSelection(selected){
            $(".tr .td_chb input[type='checkbox']").prop("checked", selected)
            $(".result-table .tbody > .tr").toggleClass("selected", selected)
        }

        getUrl(pn){
            let cql = "[" + this.store.selectedLines.map(line => { return "#" + line.toknum}).join("|") + "]"
            let filterOperation = this.store._createOperationsFromFilters([{
                pnfilter: pn,
                queryselector: "cqlrow",
                desc: cql,
                cql: cql,
                filfpos: 0,
                filtpos: 0,
                inclkwic:true
            }])
            let operations = [].concat(this.store.data.operations, filterOperation)
            let data = Object.assign({}, this.data, {
                page: 1,
                operations: operations
            })
            return this.store.getUrlToResultPage(data)
        }

        this.on("update", () => {
            this.urlSelectedLines = this.getUrl("p")
            this.urlNotSelectedLines = this.getUrl("n")
        })

        this.on("updated", () => {
            if(this.store.selectedLines.length){
                $(this.root).slideDown(200)
            } else{
                $(this.root).slideUp(200)
            }
        })

        this.on("mount", () => {
            this.store.on("selectedLinesChanged", this.update)
        })

        this.on("unmount", () => {
            this.store.off("selectedLinesChanged", this.update)
        })
    </script>
</concordance-selected-lines-box>
