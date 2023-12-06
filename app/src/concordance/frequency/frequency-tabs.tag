<frequency-tab-about>
    <div class="card-content">
        <external-text text="conc_r_freq"></external-text>
    </div>
</frequency-tab-about>

<frequency-tabs class="frequency-tabs">
    <ui-tabs ref="tabs" name="frequency-tabs" tabs={tabs} active={data.f_tab} on-tab-change={onTabChange}></ui-tabs>

    <script>
        require("./frequency-tabs.scss")
        require("./frequency-tab-basic.tag")
        require("./frequency-tab-advanced.tag")

        this.mixin("feature-child")

        this.tabs = [{
            tabId: "basic",
            labelId: "basic",
            tag: "concordance-frequency-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "concordance-frequency-tab-advanced"
        }, {
            tabId: "about",
            labelId: "about",
            tag: "frequency-tab-about"
        }]


        onTabChange(tab){
            this.store.data.f_tab = tab
        }
    </script>
</frequency-tabs>
