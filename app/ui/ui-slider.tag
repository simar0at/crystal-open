<ui-slider class="ui ui-slider {opts.class} {reversed: opts.reversed}">
    <p class="range-field" style={style}>
        <label class="{tooltipped: opts.tooltip}  {opts.labelClass}"
                    data-tooltip={ui_getDataTooltip()}>
                {getLabel(opts)}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
        </label>
        <input disabled={opts.disabled}
                ref="slider"
                id={id}
                type="range"
                name={opts.name || ""}
                min={sliderMin}
                max={sliderMax}
                step={opts.step}
                value={sliderValue}
                oninput={onSliderInput}
                onchange={callOnChange}>
        <label for={id}
                class="llabel valLabel"
                onclick={onLabelClick.bind(this, 0)}>
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
        <label class="rlabel valLabel"
                onclick={onLabelClick.bind(this, 100)}>
            {opts.rightLabel}
        </label>
        <span class="block labelContainer">
            <span class="block">
                <label each={label in opts.labels}
                        class="customLabel valLabel"
                        onclick={onLabelClick.bind(this, label.value)}
                        style="left: calc({getLabelPosition(label.value)}%);">
                    {label.text}
                </label>
            </span>
        </span>
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
            this.sliderMin = isDef(this.opts.sliderMin) ? this.opts.sliderMin : this.opts.min
            this.sliderMax = isDef(this.opts.sliderMax) ? this.opts.sliderMax : this.opts.max
        }
        this.updateAttributes()

        onSliderInput(evt){
            evt.stopPropagation()
            evt.preventUpdate = true
            this.sliderValueToInput(evt.target.value)
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

        onLabelClick(value, evt){
            if(this.opts.disabled){
                return
            }
            this.refs.slider.value = value
            this.sliderValueToInput(value)
            this.callOnChange(evt)
        }

        callOnChange(evt) {
            let value = this.refs.input ? this.refs.input.value : this.refs.slider.value
            isFun(this.opts.onChange) && this.opts.onChange(value, this.opts.name, evt, this)
        }

        sliderValueToInput(value){
            if(this.refs.input){
                if(isFun(this.opts.sliderToInput)){
                    this.refs.input.value = this.opts.sliderToInput(value)
                } else {
                    this.refs.input.value = value
                }
            }
        }

        getLabelPosition(value){
            return ((value - this.opts.min) * 100) / (this.opts.max - this.opts.min)
        }

        this.on('mount', this._refreshValue)
        this.on('update', this.updateAttributes)
    </script>
</ui-slider>
