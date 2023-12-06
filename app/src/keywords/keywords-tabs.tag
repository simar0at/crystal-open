<keywords-tab-wipo class="keywords-tab-wipo">
    <div class="card-content" style="padding-top: 1em;">
        <div class="row">
            <div class="col s12 center-align">
                <button class="btn btn-primary contrast"
                        onclick={onWipoSearch}>{_("kw.wipoExtraction")}</button>
            </div>
        </div>
    </div>

    <script>
        this.mixin("feature-child")

        onWipoSearch() {
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
            this.store.data.do_wipo = 1
            this.store.data.ktab = "wipo"
            this.store.resetSearchAndAddToHistory({w_page: 1})
        }
    </script>
</keywords-tab-wipo>

<keywords-tab-about>
    <external-text text="kw_about"></external-text>
</keywords-tab-about>

<keywords-tabs>
    <ui-tabs ref="tabs" tabs={tabs} active={store.data.tab} on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require('./keywords-tab-basic.tag')
        require('./keywords-tab-advanced.tag')
        const {Auth} = require('core/Auth.js')
        const {AppStore} = require('core/AppStore.js')

        this.mixin("feature-child")

        this.tabs = [ {
            tabId: "basic",
            labelId: "basic",
            tag: "keywords-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "keywords-tab-advanced"
        }, {
            tabId: "about",
            labelId: "about",
            tag: "keywords-tab-about"
        }]
        if (Auth.isWIPO()) {
            this.tabs.splice(2, 0, {
                tabId: "wipo",
                labelId: "kw.wipo",
                tag: "keywords-tab-wipo"
            })
        }
        let corpus = AppStore.getActualCorpus()
        if (window.config.NO_CA || AppStore.data.compTermsCorpList.length == 1 || AppStore.data.compKeywordsCorpList.length == 1) {
            this.tabs.splice(0, 1)
            this.store.data.tab = "advanced"
        }

        onTabChange(tabId) {
            if(isFun(this.opts.onTabChange)){
                this.opts.onTabChange(tabId)
            } else{
                this.store.data.tab = tabId
                this.store.updateUrl()
            }
        }
    </script>
</keywords-tabs>
