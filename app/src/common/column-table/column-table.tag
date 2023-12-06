<column-table class="column-table {opts.class}">
    <div if={items.length} ref="container" class="container-fluid">
        <div class="row">
            <div class="col-tab-col" each={x, colNumber in new Array(columnCount)}>
                <table class="table material-table {dense-table: denseTable}" style={style}>
                    <thead if={opts.theadMeta} class="theadMeta">
                        <tr>
                            <th each={th in opts.theadMeta} colspan={th.colspan} class={th.class}>
                                <raw-html if={th.content} content={th.content}></raw-html>
                            </th>
                        </tr>
                    </thead>
                    <thead>
                        <tr>
                            <th if={showLineNums()}></th>
                            <th each={cm in colMeta} class="{num: cm.num} {cm.class}">
                                <table-label
                                    align-right={cm.alignRight}
                                    label={getLabel(cm)}
                                    tooltip={cm.tooltip}
                                    desc-allowed={cm.sort ? cm.sort.descAllowed : null}
                                    asc-allowed={cm.sort ? cm.sort.ascAllowed : null}
                                    order-by={cm.sort ? cm.sort.orderBy : null}
                                    actual-sort={this.sort}
                                    actual-order-by={this.orderBy}
                                    on-sort={this.onSort}>
                                </table-label>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr each={item, i in getColData(colNumber)}
                                class="{last: item.lastinner, inner: item.inner} itm_{(itemsInColumn * colNumber) + i + 1 + startIndex}">
                            <td if={showLineNums()} class="col-tab-num">
                                {window.Formatter.num((itemsInColumn * colNumber) + i + 1 + startIndex)}
                            </td>
                            <td each={cm in colMeta} class="{num: cm.num, word: cm.word} {cm.class}">
                                <virtual if={!cm.tag && !isFun(cm.generator)}>{getCellValue(item, cm)}</virtual>
                                <raw-html if={isFun(cm.generator)}
                                    content={getRawHtml(item, cm)}
                                    onclick={onCellClick.bind(this, item, cm)}>
                                </raw-html>
                                <div if={cm.tag} data-is={cm.tag} opts={cm.opts} cm={cm} item={item}></div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="clearfix"></div>
        </div>
    </div>

    <script>
        require("./column-table.scss")
        let self = this
        this.items = []

        this.columnCount = 1 // calculated count of columns

        setOpts(){
            if(!this.opts.items || this.items.length != this.opts.items.length){
                this.columnCount = 1 // items changed - render one column and then calculate widths
            }
            this.items = this.opts.items
            this.startIndex = this.opts.startIndex || 0
            this.maxColumnCount = this.opts.maxColumnCount
            this.sort = this.opts.sort
            this.orderBy = this.opts.orderBy
            this.minItemsInColumn = opts.minItemsInColumn || 10 // minimal count of items in column
            this.denseTable = !JSON.parse(this.opts.standardWidth || false) // JSON parse to convert string to bool
            /*
            [{
                "id": string,
                "label": string,
                "generator": function, // returns html string of content
                "format": "num|...",  Formatter.js values,
                "onclick": function // event handler
                },..]
         */
            this.colMeta = opts.colMeta
        }
        this.setOpts()

        setItemsInColumn(){
            this.itemsInColumn = Math.ceil(this.items.length / this.columnCount)
            this.itemsInColumn = Math.max(this.itemsInColumn, this.minItemsInColumn)
        }
        this.setItemsInColumn()

        refresh(){
            if(!this.refs.container || this.opts.noResize){
                return
            }
            let containerWidth = $(this.refs.container).width()
            this.maxColWidth = 0
            $("table", this.root).removeAttr('style')
            $("thead", this.root).each(function(idx, elem){
                this.maxColWidth = Math.max(this.maxColWidth, $(elem).width())
            }.bind(this))
            this.maxColWidth += 14
            let newColumnCount = Math.floor(containerWidth / (this.maxColWidth + 0))

            if(this.maxColumnCount && this.maxColumnCount < newColumnCount) {
                newColumnCount = this.maxColumnCount
            }

            if(this.minItemsInColumn){
                if((this.items.length / this.minItemsInColumn) < newColumnCount){
                    newColumnCount =  Math.ceil(this.items.length / this.minItemsInColumn)
                }
            }
            newColumnCount = newColumnCount == 0 ? 1 : newColumnCount
            if(!this.fixingWidth && newColumnCount != this.columnCount){
                this.columnCount = newColumnCount
                this.fixingWidth = true //prevent update() loop
                this.update()
                return
            }
            this.fixingWidth = false
            this.setItemsInColumn()
        }

        resize(){
            if(this.isMounted){
                this.refresh()
            }
        }

        window.addEventListener('resize', () => {
            // use timer to prevent massive DOM manipulation during resizing browser window
            this.timer && clearInterval(this.timer)
            this.timer = setInterval(() => {
                clearInterval(this.timer)
                this.resize()
            }, 100)
        })

        onCellClick(item, colMeta, event){
            isFun(colMeta.onclick) && colMeta.onclick(item, colMeta, event)
        }

        onSort(sort){
            isFun(this.opts.onSort) && this.opts.onSort(sort)
        }

        getColData(colNumber){
            let data = []
            for(var i = colNumber * this.itemsInColumn; i < (colNumber + 1) * this.itemsInColumn; i++){
                if(this.items[i]){
                    data.push(Object.assign({}, this.items[i])) //copy of object so riot re-render properly
                }
            }
            return data
        }

        getCellValue(item, colMeta){
            let value = isFun(colMeta.selector) ? colMeta.selector(item, colMeta) : item[colMeta.id]
            if(value === ""){
                return ""
            } else {
                return colMeta.formatter ? colMeta.formatter(value) : value
            }
        }

        getRawHtml(item, colMeta){
            return colMeta.generator(item, colMeta)
        }

        showLineNums(){
            return !isDef(this.opts.showLineNums) || this.opts.showLineNums
        }

        this.on("updated", () => {
            this.refresh()
            let containerWidth = $(this.refs.container).width()
            let colWidth = this.maxColWidth - 14
            if(this.columnCount == 1){
                colWidth = Math.max(colWidth, containerWidth / 5) // at leas 20% of all space
            } else {
                // allow to strech columns up to 1.5x of original size
                if(this.maxColWidth * this.columnCount * 1.5 > containerWidth){
                    colWidth = Math.floor(containerWidth / this.columnCount) - 14
                }
            }

            $("table", this.root).css({"width": colWidth + "px", "max-width": colWidth + "px"})
        })

        this.on("mount", ()=>{
            let t = setTimeout(() => {
                // async, so DOM is created and ready for dimension calculations
                this.resize()
                clearTimeout(t)
            }, 0)
        })

        this.on("update", function(){
            this.setOpts()
            this.setItemsInColumn()
        }.bind(this))
    </script>
</column-table>
