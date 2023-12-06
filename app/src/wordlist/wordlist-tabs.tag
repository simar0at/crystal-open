<wordlist-tab-about>
    <external-text text="wl_about"></external-text>
</wordlist-tab-about>

<wordlist-tabs class="wordlist-tabs">
    <ui-tabs ref="tabs"
            class="searchTabs"
            name="wordlist-tabs"
            tabs={tabs}
            active={store.data.tab}
            on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require("./wordlist-tab-basic.tag")
        require("./wordlist-tab-advanced.tag")

        this.mixin("feature-child")

        this.tabs = [{
            tabId: "basic",
            labelId: "basic",
            tag: "wordlist-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "wordlist-tab-advanced"
        }, {
            tabId: "about",
            labelId: "about",
            tag: "wordlist-tab-about"
        }]

        onTabChange(tabId){
            if(isFun(this.opts.onTabChange)){
                this.opts.onTabChange(tabId)
            } else{
                this.store.data.tab = tabId
                this.store.updateUrl()
            }
        }
    </script>
</wordlist-tabs>
