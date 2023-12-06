<ui-radio class="ui ui-radio {radio-inline: opts.inline}">
   <div each={option, idx in opts.options}>
        <label for={parent.opts.name + "-" + idx}
            data-tooltip={option.tooltip || parent.opts.tooltip}
            class="rb_{(option.value + "").replace(/\W/g,'_')} {tooltipped: option.tooltip || parent.opts.tooltip}">
            <input type="radio"
                id={parent.opts.name + "-" + idx}
                name={option.name || parent.opts.name}
                disabled={parent.opts.disabled || option.disabled}
                value={option.value}
                checked={option.value == parent.opts.riotValue}
                onchange={parent.onChange}>
            <span>
                <virtual if={!isFun(parent.opts.generator)}>
                    {getLabel(option)}
                </virtual>
                <raw-html if={isFun(parent.opts.generator)} content={parent.opts.generator(option)}></raw-html>
            </span>
            <sup if={option.tooltip}>?</sup>
        </label>
        <div class="info" if={option.value == parent.value}>{option.info || ""}</div>
   </div>

   <script>
    this.mixin('ui-mixin')
    this.value = opts.riotValue


    onChange(evt){
        if(typeof this.opts.onChange == "function"){
            this.opts.onChange(evt.item.option.value, this.opts.name)
        }
        evt.stopPropagation()
    }

   </script>
</ui-radio>
