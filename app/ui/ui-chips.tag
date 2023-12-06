<ui-chips class="ui ui-chips {opts.class} {empty: !opts.data || !opts.data.length }">
    <div ref="chips" class="chips">
        <input ref="input" onkeydown={onChipKeyDown} oninput={onInput}>
    </div>

    <script>
        this.mixin("ui-mixin")

        getValue(){
            if(this.isMounted){
                return M.Chips.getInstance($(".chips", this.root)).chipsData.map(chip => {
                    return chip.tag
                })
            }
            return []
        }

        getInputValue(){
            return this.refs.input.value
        }

        onChipKeyDown(evt){
            if(evt.key == "," || evt.key == ";"){
                this._addChip()
                evt.preventDefault()
            }
            evt.preventUpdate = true
        }

        onInput(evt){
            evt.preventUpdate = true
            isDef(this.opts.onInput) && this.opts.onInput(this.refs.input.value)
        }

        _addChip(){
            this.instance.addChip({
                tag: this.instance.$input[0].value
            })
            this.instance.$input[0].value = ''
        }


        _initialize(){
            let data = (this.opts.riotValue || []).map(value => {
                return {
                    tag: value
                }
            })
            let chips = $(this.refs.chips)
            let params = {
                data: data,
                onChipAdd: this._onChipAdd,
                onChipDelete: this._onChipDelete,
                placeholder: this.opts.placeholder
            }

            if(this.opts.onSelect){
                params.onChipSelect = this.opts.onSelect
            }
            if(this.opts.secondaryPlaceholder){
                params.secondaryPlaceholder = this.opts.secondaryPlaceholder
            }
            chips.chips(params)
            this.instance = M.Chips.getInstance(this.refs.chips)
        }

        _onChipAdd(){
            this.opts.onAdd && delay(() => {
                // call asynchronously to let materialize code finish first
                this.opts.onAdd(this.refs.input.value)
            }, 0)
            this._onDataChanged()
        }

        _onChipDelete(){
            this.opts.onDelete && this.opts.onDelete()
            this._onDataChanged()
        }

        _onDataChanged(){
            $(this.root).toggleClass("empty", !this.instance.chipsData.length)
        }

        this.on("mount", this._initialize)
        this.on("updated", this._initialize)
    </script>
</ui-chips>
