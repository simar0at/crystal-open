<ui-select class="ui ui-select input-field {opts.classes}" style={style}>
    <select if={opts.options || opts.optgroups}
        name={opts.name || ""}
        ref="select"
        class="form-control"
        disabled={opts.disabled}
        multiple={opts.multiple}>
        <optgroup each={optgroup, ogIdx in opts.optgroups || []}
            no-reorder
            label={optgroup.label}>
            <option each={option, idx in optgroup.options || []}
                no-reorder
                value={option.value}
                ogi={ogIdx}
                i={idx}
                disabled={option.disabled}
                selected={parent.parent.opts.riotValue !== undefined && parent.parent.isOptionSelected(option)}>
                {parent.getLabel(option)}
            </option>
        </optgroup>
        <option if={!opts.optgroups}
            each={option, idx in opts.options || []}
            no-reorder
            value={option.value}
            i={idx}
            disabled={option.disabled}
            selected={parent.opts.riotValue !== undefined && parent.isOptionSelected(option)}>
            {getLabel(option)}
        </option>
    </select>
    <label if={opts.label || opts.labelId}
            class="{tooltipped: opts.tooltip}"
            data-tooltip={ui_getDataTooltip()}>
        {getLabel(opts)}
        <sup if={opts.tooltip}>?</sup>
        <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
    </label>

    <script>
        this.mixin('ui-mixin')
        this.value = this.opts.riotValue || null
        this.style = this.opts.size ? ("width:" + this.opts.size + "em") : ""

        getValue(){
            return this.value
        }

        onChange(evt){
            evt && evt.stopPropagation()
            this.value = this._getValueFromSelect()
            if(isFun(this.opts.onChange)){
                this.opts.onChange(this.value, this.opts.name, this.opts.multiple ? null : this.getLabelByValue(this.value), evt, this)
            }
        }

        isOptionSelected(option){
            var value = this.opts.riotValue
            if(this.opts.multiple){
                return value && value.length && value.indexOf(option.value) != -1;
            } else{
                return option.value == value
            }
        }

        _getOptionValue(el){
            let element = $(el)
            let idx = $(element).attr("i")
            let option = null
            if(this.opts.optgroups){
                let ogi = element.attr("ogi")
                option = this.opts.optgroups[ogi] ? this.opts.optgroups[ogi].options[idx] : null
            } else{
                option = this.opts.options[idx]
            }
            return option ? option.value : null
        }

        _getValueFromSelect(){
            let selected = $("option:selected", this.root)
            if(this.opts.multiple){
                if(!selected.length){
                    return []
                } else{
                    return selected.toArray().map(element => {
                        return this._getOptionValue(element)
                    }, this)
                }
            } else {
                if(!selected.length){
                    return null
                } else{
                    return this._getOptionValue(selected)
                }
            }
        }

        getLabelByValue(value){
            let option
            if(this.opts.optgroups){
                this.opts.optgroups.find(og => {
                    return og.options.find(o => {
                        return o.value == value
                    })
                })
            } else {
                this.opts.options.find(o => {
                    return o.value == value
                })
            }
            return option ? option.label : ""
        }

        _startupSelect(){
            if(this.refs.select && $.contains(document.documentElement, this.refs.select)){ // fix riot vs materialize bug
                $(this.refs.select).off("change")
                        .formSelect({
                            dropdownOptions: {
                                constrainWidth: false
                            }
                        })
                        .on("change", this.onChange)
                this.ui_refreshWidth()
            }
            if(this.opts.width){
                // materialize remove style when initializing select
                $(this.root).css({width: this.opts.width + "px"})
            }
        }

        this.on("mount", () => {
            $(document).ready(this._startupSelect.bind(this));
        })
        this.on("updated", () => {
            this._startupSelect()
        })
    </script>
</ui-select>
