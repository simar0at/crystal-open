<wordlist-result-options-info>
    <div class="ro-chips">
        <div style="line-height: 40px;">
            <div class="chip" each={option in userOptions} if={userOptions.length}>
                <i class="close material-icons" onclick={onUserValueClick}>close</i>
                {option.label}&nbsp;
                <span class="ro-value">{formatValue(option.value)}</span>
            </div>
        </div>

        <div if={defaultOptions.length}>
            <span class="ro-option" each={option in defaultOptions}>
                {option.label}&nbsp;
                <span class="ro-value">{formatValue(option.value)}</span>
            </span>
        </div>
    </div>

    <script>
        this.mixin("feature-child")

        formatValue(value){
            return value === "" ? _("none") : ('"' + truncate(value, 20) + '"')
        }

        addValueToList(isDefault, label, value, removeCallback){
            this[isDefault ? "defaultOptions" : "userOptions"].push({
                label: label,
                value: value,
                removeCallback: removeCallback
            })
        }

        onUserValueClick(e) {
            isFun(e.item.option.removeCallback)
                && e.item.option.removeCallback()
        }

        updateAttributes() {
            this.userOptions = []
            this.defaultOptions = []
            let value
            ;[
                ["usesubcorp", _("subcorpus")],
                ["wlminfreq", _("minFreq")],
                ["wlmaxfreq", _("maxFreq")],
                ["wlicase", _("ignoreCase")],
                ["include_nonwords", _("includeNonwords")]
            ].forEach((o) => {
                value = this.store.data[o[0]]
                this.addValueToList(this.store.isOptionDefault(o[0], value), o[1], value,
                        function(name){
                            this.store.searchAndAddToHistory({
                                [name]: this.store.defaults[name]
                            })
                        }.bind(this, o[0]))
            }, this)
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</wordlist-result-options-info>
