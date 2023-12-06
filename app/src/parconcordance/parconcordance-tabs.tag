<parconcordance-tab-about>
    <external-text text="parc_about" style="display:block; max-width: 800px;"></external-text>
</parconcordance-tab-about>

<parconcordance-tabs>
    <ui-tabs ref="tabs"
            class="searchTabs"
            tabs={tabs}
            active={data.tab}
            on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require('./parconcordance-tab-basic.tag')
        require('./parconcordance-tab-advanced.tag')

        this.mixin('feature-child')

        this.tabs = [{
                tabId: "basic",
                labelId: "basic",
                tag: "parconcordance-tab-basic"
            }, {
                tabId: "advanced",
                labelId: "advanced",
                tag: "parconcordance-tab-advanced"
            }, {
                tabId: "about",
                labelId: "about",
                tag: "parconcordance-tab-about"
            }
        ]

        onTabChange(tabId) {
            this.data.tab = tabId
            if (tabId == "basic") {
                for (let i=0; i<this.data.formparts.length; i++) {
                    this.data.formparts[i].formValue.queryselector = "iquery"
                }
                this.data.formValue.queryselector = "iquery"
            }
            this.store.updateUrl()
            $('input[name="lemma"]:visible').focus()
        }
    </script>
</parconcordance-tabs>
