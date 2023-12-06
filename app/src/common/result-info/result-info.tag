<result-info class="result-info">
    <div class="ro-chips">
        <div>
            <div class="chip" each={option in userOptions} if={userOptions.length}>
                {getLabel(option)}&nbsp;
                <span class="ro-value">{option.value}</span>
                <i if={showCloseButton(option.name)} class="close material-icons" onclick={onUserValueClick}>close</i>
            </div>
        </div>
        <div if={defaultOptions.length}>
            <span class="ro-option" each={option in defaultOptions}>
                {getLabel(option)}&nbsp;
                <span class="ro-value">{option.value}</span>
            </span>
        </div>
        <div if={opts.customInfoTag} class="dividerTop" style="margin-top: 20px; padding-top: 20px;">
            <div data-is={opts.customInfoTag} opts={opts.customInfoOpts}></div>
        </div>
    </div>

    <script>
        this.store = getPageParent(this).store


        addValueToList(option, value) {
            let name = option[0]
            if(this.opts.skipOptions && this.opts.skipOptions.includes(name)){
                return
            }
            let item = {
                name: name,
                label: window.capitalize(_(option[1])),
                value: this.store.getValueLabel(value, name)
            }
            if(this.store.isOptionDefault(name, value)){
                this.defaultOptions.push(item)
            } else {
                this.userOptions.push(item)
            }
        }

        showCloseButton(name){
            return !this.opts.doNotRemove || !this.opts.doNotRemove.includes(name)
        }

        onUserValueClick(evt) {
            let name = evt.item.option.name
            this.store.searchAndAddToHistory({
                [name]: this.store.defaults[name]
            })
        }

        updateAttributes() {
            let options = this.opts && this.opts.options || this.store.searchOptions
            this.defaultOptions = []
            this.userOptions = []
            options.forEach(option => {
                let value = this.store.data[option[0]]
                this.addValueToList(option, value)
            })
        }
        this.updateAttributes()

        this.on('update', this.updateAttributes)
    </script>
</result-info>
