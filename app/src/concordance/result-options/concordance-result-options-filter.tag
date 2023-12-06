<concordance-result-options-filter class="concordance-result-options-filter">
    <div if={data.total < data.fullsize}
            class="grey-text">
        {_(data.random ? "filterLimitationNoteRandom10M" : "filterLimitationNoteFirst10M", [Formatter.num(data.total)])}
    </div>
    <ui-tabs ref="tabs" tabs={tabs} active={data.filterTab} on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require('./concordance-result-options-filter-basic.tag')
        require('./concordance-result-options-filter-advanced.tag')

        this.mixin('feature-child')

        this.tabs = [{
                tabId: "basic",
                labelId: "basic",
                tag: "concordance-result-options-filter-basic"
            }, {
                tabId: "advanced",
                labelId: "advanced",
                tag: "concordance-result-options-filter-advanced"
            }
        ]

        focus() {
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        }

        onTabChange(tabId) {
            this.store.data.filterTab = tabId
            this.focus()
        }

        this.on("mount", this.focus)
    </script>
</concordance-result-options-filter>
