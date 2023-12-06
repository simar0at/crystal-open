<collocations-tab-about>
    <div class="card-content">
        <external-text text="conc_r_coll"></external-text>
    </div>
</collocations-tab-about>

<collocations-tabs class="collocations-tabs">
    <ui-tabs ref="tabs" name="collocations-tabs" tabs={tabs} active={store.data.c_tab} on-tab-change={onTabChange}></ui-tabs>

    <script>
        require("./collocations-tabs.scss")
        require("./collocations-tab-basic.tag")
        require("./collocations-tab-advanced.tag")
        require("./collocations-form.tag") // used in basic and advanced tab

        this.mixin("feature-child")

        this.tabs = [{
            tabId: "basic",
            labelId: "basic",
            tag: "collocations-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "collocations-tab-advanced"
        }, {
            tabId: "about",
            labelId: "about",
            tag: "collocations-tab-about"
        }]

        onTabChange(tab){
            this.store.data.c_tab = tab
        }
    </script>
</collocations-tabs>
