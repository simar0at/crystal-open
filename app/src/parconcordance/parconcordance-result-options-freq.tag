<parconcordance-result-options-freq class="frequency-tabs">
    <ui-tabs ref="tabs" tabs={tabs} active={data.f_tab} on-tab-change={onTabChange}>
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

        onTabChange(tabId) {
            this.store.data.f_tab = tabId
            this.store.updateUrl()
        }
    </script>
</parconcordance-result-options-freq>
