<ui-input class="ui ui-input {opts.class} {whiteField: opts.white}">
    <div class="input-field {hasSuffixIcon: opts.suffixIcon} {hasPrefixIcon: opts.prefixIcon}" style={style}>
        <i if={opts.prefixIcon} class="material-icons prefix-icon">{opts.prefixIcon}</i>
        <input ref="input" class="truncate {invalid: opts.error} {monospace: opts.monospace}"
            disabled={opts.disabled}
            id={id}
            type={opts.type || "text"}
            name={name}
            placeholder={opts.placeholder || ""}
            value={typeof opts.riotValue == "undefined" ? "" : opts.riotValue}
            readonly={opts.readonly}
            required={opts.required}
            autocapitalize="off"
            autocorrect="off"
            autocomplete={isDef(opts.autocomplete) && !opts.autocomplete ? "off" : null}
            min={opts.min}
            max={opts.max}
            maxlength={opts.maxlength}
            pattern={opts.pattern}
            step={opts.step}
            onclick={onClick}
            onkeypress={opts.onKeyPress}
            onkeydown={opts.onKeyDown}
            onkeyup={onKeyUp}
            oninput={onInput}
            onfocus={onFocus}
            onblur={onBlur}
            onchange={onChange}>
        <span ref="errorLabel" data-error="{opts.error}" class="errorLabel"></span>
        <label for={id}
            class="{tooltipped: opts.tooltip}"
            data-tooltip={ui_getDataTooltip()}
            ref="label">
            {getLabel(opts) || "&nbsp;"}{opts.required && opts.label ? " *" : ""}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
        </label>
        <i if={opts.suffixIcon} onclick={onSuffixIconClick}
                class="material-icons suffix">{opts.suffixIcon}</i>
    </div>
    <span class="helper-text">{opts.helpertext}</span>

    <script>
        this.mixin('ui-mixin')
        this.style = this.opts.size ? ("width:" + this.opts.size + "em") : ""

        this.name = this.opts.name || ""
        if(isDef(this.opts.autocomplete) && !this.opts.autocomplete){
            this.name += Math.round(Math.random() * 1000000)
        }

        getValue(){
            return this.refs.input ? this.refs.input.value : opts.riotValue
        }

        onKeyUp(evt){
            evt.preventUpdate = true
            if(evt.which == "27" && !this.opts.noBlurOnEsc){
                $(this.refs.input).blur()
            } else if(evt.which == 13){
                isFun(this.opts.onSubmit) && this.opts.onSubmit(evt.target.value, this.opts.name, evt, this)
            }
            isFun(this.opts.onKeyUp) && this.opts.onKeyUp(evt, this)
        }

        onChange(evt){
            evt.preventUpdate = true
            evt && evt.stopPropagation()
            isFun(this.opts.onChange) && this.opts.onChange(this.refs.input.value, this.opts.name, evt, this)
        }

        onInput(evt){
            evt.preventUpdate = true
            evt && evt.stopPropagation()
            this.opts.validate && this.validate()
            let value = this.refs.input.value
            if(this.opts.type && this.opts.type.toLowerCase() == "number"){
                value = value * 1
                if(isDef(this.opts.min) && this.opts.min * 1 > value){
                    this.refs.input.value = this.opts.min
                }
                if(isDef(this.opts.max) && this.opts.max * 1 < value){
                    this.refs.input.value = this.opts.max
                }
                this._refreshValue()
            }
            isFun(this.opts.onInput) && this.opts.onInput(this.refs.input.value, this.opts.name, evt, this)
            this.ui_refreshWidth()
        }

        onBlur(evt){
            evt.preventUpdate = true
            isFun(this.opts.onBlur) && this.opts.onBlur(this.refs.input.value, this.opts.name, evt, this)
        }

        onFocus(evt){
            evt.preventUpdate = true
            isFun(this.opts.onFocus) && this.opts.onFocus(evt, this)
        }

        validate(){
            this.ui_validate()
        }

        onSuffixIconClick(evt) {
            evt.preventUpdate = true
            if(isFun(this.opts.onSuffixIconClick)){
                this.opts.onSuffixIconClick(evt, this)
            } else {
                $(this.refs.input).focus()
            }
        }

        onPrefixIconClick(evt) {
            evt.preventUpdate = true
            $(this.refs.input).focus()
            isFun(this.opts.onPrefixIconClick) && this.opts.onPrefixIconClick(evt, this)
        }

        _refreshValue(){
            // so refs.some_ui_input.value is available
            if(this.refs.input){
                this.value = this.refs.input.value
            }
        }

        this.on("mount", this._refreshValue)
        this.on("updated", this._refreshValue)

    </script>
</ui-input>
