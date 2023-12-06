<ui-chips class="ui ui-chips {opts.class} {empty: !opts.data || !opts.data.length }">
    <div ref="chips" class="chips">
        <input ref="input" onkeydown={onChipKeyDown}>
    </div>

    <script>
        this.mixin("ui-mixin")

        getValue(){
            if(this.isMounted){
                return $(".chips", this.root).data().chips.map(chip => {
                    return chip.tag
                })
            } else{
                return this.opts.riotValue
            }
        }

        onChipKeyDown(evt){
            if(evt.key == "," || evt.key == ";"){
                this._addChip()
                evt.preventDefault()
            }
            evt.preventUpdate = true
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
            this.opts.onAdd && this.opts.onAdd(this.refs.input.value)
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
