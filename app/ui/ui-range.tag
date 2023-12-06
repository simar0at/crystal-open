<ui-range class="ui ui-range {opts.class}"
        onmouseover={onMouseOver}
        min={range[0].value}
        max={range[range.length - 1].value}
        onmouseleave={onMouseLeave}>
    <label class="label {tooltipped: opts.tooltip}"
            data-tooltip={ui_getDataTooltip()}>
        {getLabel(opts)}
        <sup if={opts.tooltip}>?</sup>
        <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
    </label>
    <div class="rangeWrapper" ref="rangeWrapper">
        <span each={item, idx in range}
                class="btn-selector btn-flat {item.class}"
                onclick={onItemClick}>
            <raw-html if={isFun(item.generator)} content={item.generator(item)}></raw-html>
            {isFun(item.generator) ? null : item.label}
        </span>
    </div>

    <script>
        this.mixin('ui-mixin')

        this.isSelecting = false

        onMouseOver(evt){
            evt.preventUpdate = true
            if(evt.target.classList.contains("btn-selector")){
                this.highlightTo(evt.target)
            } else {
                this.highlightTo(null)
            }
        }

        onMouseLeave(evt){
            this.highlightTo(null)
        }

        highlightTo(element){
            $(".highlighted", this.root).removeClass("highlighted")
            if(element){
                if(this.isSelecting){
                    let idx = this.nodes.indexOf(element)
                    let start = this.selection.from
                    let end = idx
                    if(start > end){
                        start = idx
                        end = this.selection.from
                    }
                    for(let i = start; i <= end; i++){
                        if($(this.nodes[i]).hasClass("btn-selector")){
                            $(this.nodes[i]).addClass("highlighted")
                        }
                    }
                }
            }
        }

        getValue(){
            return{
                from: this.getValueByIndex(this.selection.from),
                to: this.getValueByIndex(this.selection.to)
            }
        }

        getValueByIndex(idx){
            return isDef(idx) && this.range[idx].value ? this.range[idx].value : null
        }

        getIndexByValue(value){
            return this.range.findIndex(r => {
                return r.value === value
            })
        }

        /*
            opts:
            min: -3
            max: 5,
            riotValue   {from: 1, to: 3}
            range      [{label: "start" value: "s"}, {label:-5, value:-5}...]
         */
        if(this.opts.range){
            this.range = this.opts.range
        } else{
            this.range = Array.from(Array(this.opts.max - this.opts.min + 1).keys()).map(x => {
                return {
                    value: x + this.opts.min,
                    label: x + this.opts.min
                }
            })
        }
        this.size = this.range.length
        this.selection = {
            from: undefined,
            to: undefined
        }
        if(this.opts.riotValue){
            this.selection = {
                from: this.getIndexByValue(this.opts.riotValue.from),
                to: this.getIndexByValue(this.opts.riotValue.to)
            }
        }

        onItemClick(evt){
            evt.stopPropagation()
            let idx = evt.item.idx // clicked item index

            if(this.isSelecting){
                if(this.selection.from > idx){
                    this.selection.to = this.selection.from
                    this.selection.from = idx
                } else{
                    this.selection.to = idx
                }
            } else{
                this.selection.from = idx
                this.selection.to = idx
            }
            this.markSelection()

            this.isSelecting = !this.isSelecting

            isFun(this.opts.onChange) && this.opts.onChange(this.getValue(), this.opts.name, evt, this)
        }

        markSelection(){
            $(".rangeSelected", this.root).removeClass("rangeSelected")
            for(let i = this.selection.from; i <= this.selection.to; i++){
                if($(this.nodes[i]).hasClass("btn-selector")){
                    $(this.nodes[i]).addClass("rangeSelected")
                }
            }
        }

        this.on("mount", () => {
            this.nodes = $(".btn-selector", this.root).toArray()
            this.markSelection()
        })

        this.on("update", () => {
            this.nodes = $(".btn-selector", this.root).toArray()
            this.markSelection()
            if(this.opts.riotValue){
                this.selection = {
                    from: this.getIndexByValue(this.opts.riotValue.from),
                    to: this.getIndexByValue(this.opts.riotValue.to)
                }
            }
        })

        this.on("updated", this.markSelection)
    </script>
</ui-range>
