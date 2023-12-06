<ui-switch class="ui ui-switch switch {opts.class} {opts.disabled?'disabled':''}">
    <label>
        <span if={getLabel(opts)}
              data-tooltip={ui_getDataTooltip()}
              class="switch-label {tooltipped: opts.tooltip}">
            {getLabel(opts)}&nbsp;<sup if={opts.tooltip}>?</sup>
        </span>
        <input type="checkbox"
              ref="cb"
              name={opts.name}
              checked={opts.riotValue}
              disabled={opts.disabled}
              onchange={toggle}
              class="switch-input">
        <span class="lever"></span>
    </label>

    <script>
        this.mixin('ui-mixin')

        getValue(){
            return !!this.refs.cb.checked
        }

        toggle(evt){
            evt.preventUpdate = true
            isFun(this.opts.onChange) && this.opts.onChange(!!this.refs.cb.checked, this.opts.name, evt, this)
        }
    </script>
</ui-switch>
