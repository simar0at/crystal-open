<frequency-result-block class="frequency-result-block">
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

    <ui-pagination
        if={block.total > 10}
        count={block.total}
        items-per-page={block.itemsPerPage}
        actual={block.page}
        on-change={onPageChange}
        on-items-per-page-change={onItemsPerPageChange}
        show-prev-next={true}></ui-pagination>

    <script>
        require("./frequency-result-block.scss")

        this.mixin("feature-child")

        this.block = this.opts.block

        refreshColMeta(){
            this.colMeta = []
            this.block.Head.forEach((head, idx) => {
                if(head.s != "freq" && head.s != "rel"){
                    this.colMeta.push({
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
                    })
                }
            })
            this.colMeta.push({
                id: "freq",
                "class": "freqColumn",
                labelId: "frequency",
                num: true,
                formatter: window.Formatter.num.bind(Formatter),
                sort: {
                    orderBy: "freq",
                    descAllowed: true,
                    ascAllowed: false
                }
            })

            if(this.opts.showRelFreq && this.store.data.f_showrelfrq){
                this.colMeta.push({
                    id: "relfrq",
                    "class": "relColumn",
                    labelId: "freqPerMillion",
                    num: true,
                    selector: (item, colMeta) => {
                        let freq = item.freq / this.corpus.sizes.tokencount * 1000000
                        let freqStr = window.Formatter.num(freq, {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2
                        })
                        if(freq <= 0.01){
                            freqStr = "< 0.01"
                        }
                        return freqStr
                    }
                })
            }

            if(this.block.Head[2] && this.block.Head[2].s == "rel"){
                this.colMeta.push({
                    id: "rel",
                    "class": "relColumn",
                    labelId: "frq.rel",
                    num: true,
                    formatter: window.Formatter.num.bind(Formatter),
                    sort: {
                        orderBy: "rel",
                        descAllowed: true,
                        ascAllowed: false
                    }
                })
            }

            this.colMeta.push({
                id: "bar",
                "class": "barColumn",
                label: "",
                "generator": function(item, colMeta) {
                    return '<div class="progress" style="height:' + (item.freqbar ? (item.freqbar + 1) : 6)  +'px;"><div class="determinate" style="width: ' + (item.fbar / 3) + '%;"></div></div>'
                }.bind(this)
            })
            this.colMeta.push({
                id: "menu",
                "class": "menuColumn",
                label: "",
                generator: () => {
                    return "<a class=\"iconButton waves-effect waves-light btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt) {
                    item.block = this.block
                    this.parent.refs.interfeatureMenu.onOpenMenuButtonClick(evt, item)
                }.bind(this)
            })
        }

        updateAttributes(){
            this.blockItems = this.block.Items.slice((this.block.page - 1) * this.block.itemsPerPage, this.block.page * this.block.itemsPerPage)
            this.refreshColMeta()
        }
        this.updateAttributes()

        onSort(sort){
            this.block.page = 1
            this.block.sort = sort.orderBy
            this.store.f_search(this.block)
        }

        onPageChange(page){
            let pageCount = Math.ceil(this.block.total / this.block.itemsPerPage)
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

        this.on("update", this.updateAttributes)
    </script>
</frequency-result-block>
