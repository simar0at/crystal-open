<ui-checkbox class="ui ui-checkbox {opts.class}">
    <label for="{id}_i">
         <input type="checkbox"
            id="{id}_i"
            name={opts.name}
            ref="checkbox"
            checked={opts.checked}
            disabled={opts.disabled}
            onchange={onChange} />
            <span data-tooltip={ui_getDataTooltip()}
                    class={tooltipped: opts.tooltip}>
                {getLabel(opts)}
                <sup if={opts.tooltip}>?</sup>
                <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
            </span>
    </label>

    <script>
        this.mixin('ui-mixin')

        onChange(evt){
            if(!this.refs.checkbox.disabled){
                if(typeof this.opts.onChange == "function"){
                    this.opts.onChange(!!this.refs.checkbox.checked, this.opts.name, evt, this)
                }
            }
            evt.stopPropagation()
        }

        _setIndeterminate(){
            if(this.refs && this.refs.checkbox){
                this.refs.checkbox.indeterminate = this.opts.indeterminate
            }
        }

        this.on("mount", this._setIndeterminate)
        this.on("updated", this._setIndeterminate)
    </script>
</ui-checkbox>
