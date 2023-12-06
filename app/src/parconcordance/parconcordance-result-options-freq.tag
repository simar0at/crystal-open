<parconcordance-result-options-freq>
    <ui-tabs ref="tabs" tabs={tabs} active={tab} on-tab-change={this.onTabChange}>
    </ui-tabs>

    <script>
        require('./parconcordance-result-options-freq-basic.tag')
        require('./parconcordance-result-options-freq-advanced.tag')

        this.mixin("feature-child")

        this.tabs = [{
                tabId: "basic",
                labelId: "basic",
                tag: "parconcordance-result-options-freq-basic"
            }, {
                tabId: "advanced",
                labelId: "advanced",
                tag: "parconcordance-result-options-freq-advanced"
            }
        ]
        this.tab = this.store.data.f_tab

        onTabChange(tabId) {
            this.store.data.f_tab = tabId
            this.store.updateUrl()
        }
    </script>
</parconcordance-result-options-freq>
