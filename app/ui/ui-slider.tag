<ui-slider class="ui ui-slider {opts.class} {reversed: opts.reversed}">
    <p class="range-field" style={style}>
        <label class={tooltipped: opts.tooltip}
                    data-tooltip={ui_getDataTooltip()}>
                {getLabel(opts)}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
        </label>
        <input
                disabled={opts.disabled}
                ref="slider"
                id={this.id}
                type="range"
                name={opts.name || ""}
                min={isDef(opts.sliderMin) ? opts.sliderMin : opts.min}
                max={isDef(opts.sliderMax) ? opts.sliderMax : opts.max}
                step={opts.step}
                value={sliderValue}
                oninput={onSliderInput}
                onchange={callOnChange}>
        <label for={this.id} class="llabel">
                {opts.leftLabel}
        </label>
        <input if={!opts.disableinput}
                ref="input"
                disabled={opts.disabled}
                type="number"
                min={isDef(opts.inputMin) ? opts.inputMin : opts.min}
                max={isDef(opts.inputMax) ? opts.inputMax : opts.max}
                step={opts.step}
                value={inputValue}
                oninput={onInputInput}
                onchange={callOnChange}>

        <label for={this.id} class="rlabel">{opts.rightLabel}</label>
    </p>
    <br />

    <script>
        this.mixin('ui-mixin')
        if (this.opts.hfill) {
            this.style = "width: auto;"
        }
        else if (this.opts.size) {
            this.style = "width:" + this.opts.size + "em"
        }

        updateAttributes(){
            this.sliderValue = isFun(this.opts.inputToSlider) ? this.opts.inputToSlider(this.opts.riotValue) : this.opts.riotValue
            this.inputValue = this.opts.riotValue
        }
        this.updateAttributes()

        onSliderInput(evt){
            evt.stopPropagation()
            evt.preventUpdate = true
            if(this.refs.input){
                if(isFun(this.opts.sliderToInput)){
                    this.refs.input.value = this.opts.sliderToInput(evt.target.value)
                } else {
                    this.refs.input.value = evt.target.value
                }
            }
        }

        onInputInput(evt){
            evt.stopPropagation()
            evt.preventUpdate = true
            if(isFun(this.opts.inputToSlider)){
                this.refs.slider.value = this.opts.inputToSlider(evt.target.value)
            } else{
                this.refs.slider.value = evt.target.value
            }
        }

        callOnChange() {
            let value = this.refs.input ? this.refs.input.value : this.refs.slider.value
            isFun(this.opts.onChange) && this.opts.onChange(value, this.opts.name)
        }

        this.on('mount', this._refreshValue)
        this.on('update', this.updateAttributese)
    </script>
</ui-slider>
