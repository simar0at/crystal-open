<keywords-result-info class="keywords-result-info">
    <div class="ro-chips">
        <div style="line-height: 40px;">
            <div class="chip" each={option in userOptions}
                    if={userOptions.length}>
                <i class="close material-icons"
                        if={option.name != 'k_ref_corpname' && option.name != 't_ref_corpname'}
                        onclick={onUserValueClick}>close</i>
                {option.label}&nbsp;
                <span class="ro-value">{this.formatValue(option.value)}</span>
            </div>
        </div>
        <div if={defaultOptions.length}>
            <span class="ro-option" each={option in defaultOptions}>
                {option.label}&nbsp;
                <span class="ro-value">{this.formatValue(option.value)}</span>
            </span>
        </div>
    </div>

    <script>
        this.mixin("feature-child")
        const {AppStore} = require("core/AppStore.js")

        resetOption(k) {
            if (k == 'k_ref_corpname') {
                this.store.data[k] = AppStore.data.corpus.refKeywordsCorpname
            }
            else if (k == 't_ref_corpname') {
                this.store.data[k] = AppStore.data.corpus.refTermsCorpname
            }
            else {
                this.store.data[k] = this.store.defaults[k]
            }
            this.store.searchAndAddToHistory()
        }

        addValueToList(isDefault, label, value, removeCallback) {
            this[isDefault ? "defaultOptions" : "userOptions"].push({
                label: label,
                removeCallback: removeCallback,
                value: value
            })
        }

        onUserValueClick(event) {
            isFun(event.item.option.removeCallback)
                    && event.item.option.removeCallback()
        }

        formatValue(value){
            return value === "" ? _("none") : ('"' + truncate(value, 20) + '"')
        }

        refreshAttributes() {
            let defs = this.store.defaults
            this.defaultOptions = []
            this.userOptions = []
            let self = this
            ;[
                ["k_ref_corpname", _("kw.keywordsRefCorpname")],
                ["t_ref_corpname", _("kw.termsRefCorpname")],
                ["simple_n", _("kw.simple_n")],
                ["max_terms", _("kw.max_terms")],
                ["max_keywords", _("kw.max_keywords")],
                ["attr", _("kw.attr")],
                ["alnum", _("kw.alnum")],
                ["onealpha", _("kw.onealpha")]
            ].forEach((o) => {
                let value = this.store.data[o[0]]
                this.addValueToList(this.store.isOptionDefault(o[0], value), o[1],
                        value, self.resetOption.bind(this, [o[0]]))
            })
        }
        this.refreshAttributes()
    </script>
</keywords-result-info>
