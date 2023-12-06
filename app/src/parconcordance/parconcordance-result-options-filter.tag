<parconcordance-result-options-filter>
    <ui-tabs ref="tabs" tabs={tabs} active={data.filterTab} on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require('./parconcordance-result-options-filter-basic.tag')
        require('./parconcordance-result-options-filter-advanced.tag')

        this.mixin('feature-child')

        this.tabs = [{
                tabId: "basic",
                labelId: "basic",
                tag: "parconcordance-result-options-filter-basic"
            }, {
                tabId: "advanced",
                labelId: "advanced",
                tag: "parconcordance-result-options-filter-advanced"
            }
        ]

        focus() {
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        }

        onTabChange(tabId) {
            this.store.data.filterTab = tabId
            this.store.updateUrl()
            this.focus()
        }

        this.on("mount", this.focus)
    </script>
</parconcordance-result-options-filter>
