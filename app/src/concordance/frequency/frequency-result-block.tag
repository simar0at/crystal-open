<frequency-result-block class="frequency-result-block block_{opts.idx + 1}">
    <div class="totalItems color-blue-200">
        ({window.Formatter.num(block.total)} {_("wl.items")}, {window.Formatter.num(block.totalfrq)} {_("totalFrq")})
    </div>
    <column-table ref="table"
        items={blockItems}
        col-meta={colMeta}
        min-col-width={500}
        max-column-count={1}
        start-index={block.showResultsFrom}
        order-by={block.sort}
        sort="desc"
        on-sort={onSort}
        no-resize=1></column-table>
    <user-limit if={block.total > data.raw.wllimit}
            wllimit={data.raw.wllimit}
            total={block.total}
            screen-limit={data.f_fmaxitems}></user-limit>

    <ui-pagination
        if={block.Items.length > 10}
        count={block.Items.length}
        items-per-page={block.itemsPerPage}
        actual={block.page}
        on-change={onPageChange}
        on-items-per-page-change={onItemsPerPageChange}
        show-prev-next={true}></ui-pagination>

    <script>
        const {AppStore} = require("core/AppStore.js")
        require("./frequency-result-block.scss")

        this.mixin("feature-child")

        this.block = this.opts.block

        refreshColMeta(){
            this.colMeta = []
            this.showCheckboxes && this.colMeta.push({
                id: "chbox",
                "class": "chboxColumn",
                generator: (item, colMeta) => {
                    let checked = (this.block.selection.indexOf(item.id) != -1) ? 'checked=checked' : ''
                    return `<label>
                        <input type="checkbox" ${checked}/>
                        <span></span>
                    </label>`
                },
                onclick: function(item, colMeta, evt) {
                    evt.preventUpdate = true
                    evt.preventDefault() // without this event is fired twice
                    this.onItemSelectToggleClick(item, evt)
                }.bind(this)
            })
            this.block.Head.forEach((head, idx) => {
                if(head.s != "frq" && head.s != "rel"){
                    let col = {
                        id: "word",
                        "class": "word_" + (idx + 1),
                        label: head.n,
                        selector: (item, colMeta) => {
                            return item.Word[idx].n
                        },
                        sort: {
                            orderBy: head.s,
                            descAllowed: true,
                            ascAllowed: false
                        }
                    }
                    if(head.n == "pos"){
                        col.formatter = (value) => {
                            let lpos = AppStore.getLposByValue("-" + value)
                            if(lpos){
                                return lpos.label + " (" + value + ")"
                            } else if(value == "x"){
                                return _("other") + " (" + value + ")"
                            } else {
                                return value
                            }
                        }
                    }
                    this.colMeta.push(col)
                }
            })
            this.colMeta.push({
                id: "frq",
                "class": "freqColumn",
                labelId: "frequency",
                num: true,
                formatter: window.Formatter.num.bind(Formatter),
                sort: {
                    orderBy: "frq",
                    descAllowed: true,
                    ascAllowed: false
                }
            })

            if(!this.store.f_showRelTtAndRelDens()){
                if(this.data.f_showrelfrq && this.isConcordanceComplete){
                    this.colMeta.push({
                        id: "relfrq",
                        "class": "relColumn",
                        labelId: "relative",
                        tooltip: "t_id:relfreq",
                        num: true,
                        selector: this.getFromattedNumber.bind(this, "fpm", 2)
                    })
                }
                if(this.store.data.f_showperc){
                    this.colMeta.push({
                        id: "perc",
                        "class": "percColumn addPercSuffix",
                        labelId: "percOfConc",
                        tooltip: "t_id:conc_r_freq_perc",
                        num: true,
                        selector: this.getFromattedNumber.bind(this, "poc", 2)
                    })
                }
            }

            if(this.store.f_showRelTtAndRelDens() && this.isConcordanceComplete){
                if(this.data.f_showreltt){
                    this.colMeta.push({
                        id: "reltt",
                        "class": "relColumn",
                        labelId: "relativeInTT",
                        num: true,
                        selector: this.getFromattedNumber.bind(this, "reltt", 2),
                        tooltip: "t_id:conc_r_freq_rel",
                        sort: {
                            orderBy: "reltt",
                            descAllowed: true,
                            ascAllowed: false
                        }
                    })
                }
                if(this.store.data.f_showreldens){
                    this.colMeta.push({
                        id: "rel",
                        "class": "reldens addPercSuffix",
                        labelId: "reldens",
                        num: true,
                        selector: this.getFromattedNumber.bind(this, "rel", 2),
                        tooltip: "t_id:conc_r_freq_rel_dens",
                        sort: {
                            orderBy: "rel",
                            descAllowed: true,
                            ascAllowed: false
                        }
                    })
                }
            }

            this.isConcordanceComplete && this.colMeta.push({
                id: "bar",
                "class": "barColumn",
                label: "",
                "generator": function(item, colMeta) {
                    let height = item.frqbar ? (item.frqbar + 1) : 6
                    let width = isDef(item.relbar) ? (item.relbar / 3) : (item.fbar / 3)
                    return '<div class="progress" style="height:' + height +'px;"><div class="determinate" style="width: ' + width + '%;"></div></div>'
                }.bind(this)
            })
            this.colMeta.push({
                id: "menu",
                "class": "menuColumn",
                label: "",
                generator: () => {
                    return "<a class=\"iconButton btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt) {
                    item.block = this.block
                    this.parent.refs.interfeatureMenu.onOpenMenuButtonClick(evt, item)
                }.bind(this)
            })
        }

        getFromattedNumber(key, digits, item, colMeta){
            return window.valueFormatter(item[key], digits)
        }

        updateAttributes(){
            this.blockItems = this.block.Items.slice((this.block.page - 1) * this.block.itemsPerPage, this.block.page * this.block.itemsPerPage)
            this.showCheckboxes = this.opts.block.Head.filter(h => isDef(h.id)).length == 1
            this.isConcordanceComplete = this.data.total == this.data.fullsize
            this.refreshColMeta()
        }
        this.updateAttributes()

        onSort(sort){
            this.block.page = 1
            this.block.sort = sort.orderBy
            this.store.f_sortBlock(this.block)
            this.update()
        }

        onPageChange(page){
            let pageCount = Math.ceil(this.block.Items.length / this.block.itemsPerPage)
            if(page >= 1 && page <= pageCount){
                Object.assign(this.block, {
                    page: page,
                    showResultsFrom: (page - 1) * this.block.itemsPerPage
                })
            }
            this.update()
        }

        onItemsPerPageChange(itemsPerPage){
            let actualPosition = this.block.itemsPerPage * (this.block.page - 1) + 1// position of first visible item
            this.block.itemsPerPage = itemsPerPage
            this.block.page = Math.max(1, Math.floor(actualPosition / itemsPerPage) + 1)
            this.update()
        }

        onItemSelectToggleClick(item, evt){
            let input = $(evt.currentTarget).find("input")
            input.prop("checked", !input.prop("checked"))
            let idx = this.block.selection.indexOf(item.id)
            if(idx == -1){
                this.block.selection.push(item.id)
            } else {
                this.block.selection.splice(idx, 1)
            }
            this.parent.refs.selectedLinesBox.update()
            // it is allowed only to select lines from one block
            $(".frequency-result-block:not(.block_" + (this.opts.idx + 1) + ") .chboxColumn label")
                    .css("visibility", this.block.selection.length ? "hidden" : "")
        }

        prevPage(){
            this.data.f_items.length == 1 && this.onPageChange(this.block.page - 1)
        }

        nextPage(){
            this.data.f_items.length == 1 && this.onPageChange(this.block.page + 1)
        }

        this.on("update", this.updateAttributes)
        this.on("updated", this.parent.updateBlocksWidth.bind(this.parent))

         this.on("mount", () => {
            Dispatcher.on("RESULT_PREV_PAGE", this.prevPage)
            Dispatcher.on("RESULT_NEXT_PAGE", this.nextPage)
        })

        this.on("unmount", () => {
            Dispatcher.off("RESULT_PREV_PAGE", this.prevPage)
            Dispatcher.off("RESULT_NEXT_PAGE", this.nextPage)
        })
    </script>
</frequency-result-block>
