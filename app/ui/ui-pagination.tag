<ui-pagination class="ui ui-pagination text-secondary {opts.narrow ? 'narrow' : ''}">
    <span class="pagination-per-page">
        {_("ui.rowsPerPage")}
    </span>

    <ui-select options={perPageOptions}
        inline=1
        size=4
        value={itemsPerPage}
        on-change={onItemsPerPageChange}
        style="width: 60px; display: inline-block;"></ui-select>

    <span class="pagination-range {opts.narrow ? 'narrow' : ''}" if={itemsCount}>{getRange()}
        <span class="of">&nbsp;{_("of")}&nbsp;</span>
        <span>{window.Formatter.num(itemsCount) || ""}</span>
    </span>

    <ul class="pagination {opts.narrow ? 'narrow' : ''}">
        <li class={disabled: actual == 1}>
            <a href="" onclick={onPageClick.bind(this, 1)}>
                <i class="material-icons">first_page</i>
            </a>
        </li>

        <li if={showPrevNext} class={disabled: actual == 1}>
            <a href="" onclick={onPageClick.bind(this, actual - 1)}>
                <i class="material-icons">chevron_left</i>
            </a>
        </li>

        <li class="hide-on-small-only">
            <ui-input ref="input"
                placeholder="page"
                on-submit={onPageInputChange}
                riot-value={actual}
                class="center-align"
                style="width: 45px;"></ui-input>
        </li>

        <li if={showPrevNext} class={disabled: actual == pageCount || opts.lastpage}>
            <a href="" onclick={onPageClick.bind(this, actual + 1)}>
                <i class="material-icons">chevron_right</i>
            </a>
        </li>
        <li if={pageCount > 1} class={disabled: actual == pageCount || opts.lastpage}>
            <a href="" onclick={onPageClick.bind(this, pageCount)}>
                <i class="material-icons">last_page</i>
            </a>
        </li>
    </ul>

    <script>
        this.showPrevNext = this.opts.showPrevNext
        this.perPageOptions = [10, 20, 50, 100, 200, 300, 400, 500].map((item) => {
            return {
                value: item,
                label: item + ""
            }
        })

        getRange(){
            return window.Formatter.num(((this.actual - 1) * this.itemsPerPage) + 1) + "–" + window.Formatter.num(Math.min(this.actual * this.itemsPerPage, this.itemsCount)) // on last page
        }

        refreshAttributes(){
            this.actual = this.opts.actual || 1
            this.itemsPerPage = this.opts.itemsPerPage
            this.itemsCount = this.opts.count || 0
            this.pageCount = Math.ceil(this.itemsCount / this.itemsPerPage)
            this.range = this.getRange()
        }
        this.refreshAttributes()

        onPageInputChange(value){
            if(!isNaN(value) && value > 0){
                this.setPage(value * 1)
            }
        }

        onPageClick(page, evt){
            evt.preventDefault()
            this.setPage(page)
        }

        onItemsPerPageChange(value){
            isFun(this.opts.onItemsPerPageChange) && this.opts.onItemsPerPageChange(value)
        }

        setPage(page){
            if(page > 0 && page != this.actual && (!this.pageCount || page <= this.pageCount)){
                this.actual = page
                if(typeof this.opts.onChange == "function"){
                    this.opts.onChange(this.actual)
                }
                this.refs.input && this.refs.input.update({
                    value: this.actual
                })
            }
        }

        this.on("mount", () => {
            this.refs.input && this.refs.input.on("blur", () => {
                this.onPageInputChange()
            })
        })

        this.on("update", this.refreshAttributes)
    </script>
</ui-pagination>
