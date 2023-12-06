<result-info class="result-info">
    <div class="ro-chips">
        <div style="line-height: 40px;">
            <div class="chip" each={option in userOptions} if={userOptions.length}>
                {getLabel(option)}&nbsp;
                <span class="ro-value">{formatValue(option.value)}</span>
                <i class="close material-icons" onclick={onUserValueClick}>close</i>
            </div>
        </div>
        <div if={defaultOptions.length} style="line-height: 40px;">
            <span class="ro-option" each={option in defaultOptions}>
                {getLabel(option)}&nbsp;
                <span class="ro-value">{formatValue(option.value)}</span>
            </span>
        </div>
    </div>

    <script>
        this.store = getPageParent(this).store

        formatValue(value) {
            return value === "" ? _("none") : ('"' + truncate(value, 20) + '"')
        }

        addValueToList(isDefault, labelId, value, callback) {
            this[isDefault ? "defaultOptions" : "userOptions"].push({
                label: _(labelId),
                removeCallback: callback,
                value: value
            })
        }

        onUserValueClick(event) {
            event.item.option.removeCallback()
        }

        updateAttributes() {
            let options = this.opts.opts && this.opts.opts.options || this.store.searchOptions
            this.defaultOptions = []
            this.userOptions = []
            options.forEach((o) => {
                let value = this.store.data[o[0]]
                this.addValueToList(this.store.isOptionDefault(o[0], value), o[1], value,
                        function(name){
                            this.store.searchAndAddToHistory({
                                [name]: this.store.defaults[name]
                            })
                        }.bind (this, [o[0]]))
            })
        }
        this.updateAttributes()

        this.on('update', this.updateAttributes)
    </script>
</result-info>
