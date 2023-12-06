<page-corpus class="page-corpus">
    <introduction if={!skipWizard && isFullAccount && !noSkeNoCa}></introduction>
    <div class="form card">
        <ui-tabs if={!noSkeNoCa}
                name="corpus-tabs"
                tabs={tabs}
                active={tab}
                on-tab-change={onTabChange}>
        </ui-tabs>
        <corpus-tab-advanced if={noSkeNoCa}></corpus-tab-advanced>
    </div>

    <script>
        require("./page-corpus.scss")
        require("./corpus-tab-basic.tag")
        require("./corpus-tab-advanced.tag")
        require("./corpus-tab-my.tag")
        require("./corpus-tab-shared.tag")
        require("./introduction.tag")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {CorpusStore} = require("corpus/CorpusStore.js")
        const {AppStore} = require("core/AppStore.js")
        const {Auth} = require("core/Auth.js")

        this.noSkeNoCa = window.config.NO_SKE || window.config.NO_CA
        this.skipWizard = true
        this.isFullAccount = Auth.isFullAccount()
        this.languageCount = AppStore.get("languageList").length
        this.tab = CorpusStore.get("tab")
        this.tabs = [{
            tabId: "basic",
            labelId: "basic",
            tag: "corpus-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "corpus-tab-advanced"
        }, {
            tabId: "shared",
            labelId: "cp.shared",
            tag: "corpus-tab-shared"
        }]
        if(!Auth.isSiteLicenceMember()){
            this.tabs.splice(2, 0, {
                tabId: "my",
                labelId: "cp.my",
                tag: "corpus-tab-my"
            })
        } else {
            if(this.tab == "my"){
                this.tab = "basic"
            }
        }


        onTabChange(tabId){
            CorpusStore.changeTab(tabId)
        }

        updateIntro() {
            this.skipWizard = UserDataStore.data.globalDataLoaded
                    ? UserDataStore.data.global.skipWizard
                    : true
            this.update()
        }

        this.on("mount", () => {
            UserDataStore.on("globalUserDataChange", this.updateIntro)
        })

        this.on("unmount", () => {
            UserDataStore.off("globalUserDataChange", this.updateIntro)
        })
    </script>
</page-corpus>
