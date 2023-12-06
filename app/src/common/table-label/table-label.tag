<table-label class="table-label {right: opts.alignRight, active: active} {opts.class}">
    <span class="{selected: selected, tl_tooltipped: !!opts.tooltip}"
            onclick={onSortClick}
            data-tooltip={window.getTooltip(opts.tooltip)}
            style="display:flex; {opts.alignRight ? 'flex-direction:row-reverse;' : ''}">
        <span>
            {opts.label}
            <sup if={opts.tooltip}>?</sup>
        </span>
        <i if={arrow} class="sort-arrow material-icons">
            {arrow}
        </i>
    </span>

    <script>
        require("./table-label.scss")
        this.tooltipClass = ".tl_tooltipped"
        this.mixin("tooltip-mixin")

        /*
            opts:
                label: string
                actualSort String asc|desc
                actualOrderBy: string
                onSort: function
                descAllowed: Bool
                ascAllowed: Bool
                orderBy: string //key to order by
        */
        this.descAllowed = false
        this.ascAllowed = false
        this.selected = false
        this.active = false
        this.arrow = null

        updateAttributes() {
            if(this.opts.descAllowed || this.opts.ascAllowed){
                this.descAllowed = this.opts.descAllowed
                this.ascAllowed = this.opts.ascAllowed
                this.orderBy = this.opts.orderBy
                //data are sort by this column
                this.selected = this.orderBy == this.opts.actualOrderBy
                //is label clickable
                this.active = (this.descAllowed && this.ascAllowed) // can switch between asc and desc
                    || (!this.selected && (this.descAllowed || this.ascAllowed)) // one sort is allowed and its not selected
                if(this.descAllowed || this.ascAllowed){ // arrow should be displayed
                    this.arrow = this.opts.actualSort == "asc" ? "arrow_upward" : "arrow_downward"
                }
            }
        }
        this.updateAttributes()

        onSortClick(){
            if(this.descAllowed || this.ascAllowed){
                if (this.selected) {
                    if(this.descAllowed && this.ascAllowed){
                        // if table is already sorted by this column and it is
                        // allowed to sort desc and asc -> aftere click change
                        // order
                         this.opts.actualSort = this.opts.actualSort == 'desc' ? "asc" : "desc"
                     } else{
                        // is already sorted by this column and other sort is
                        // not allowed -> end
                        return
                     }
                }
                else {
                    if (this.descAllowed && !this.ascAllowed) this.opts.actualSort = "desc"
                    if (this.ascAllowed && !this.descAllowed) this.opts.actualSort = "asc"
                }
                this.arrow = this.opts.actualSort == "asc" ? "arrow_upward" : "arrow_downward"
                this.opts.onSort({
                    orderBy: this.orderBy,
                    sort: this.opts.actualSort
                })
            }
        }

        this.on('update', this.updateAttributes)
    </script>
</table-label>
