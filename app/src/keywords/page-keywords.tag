<page-keywords class="page-keywords">
    <div if={outdatedTerms}
            class="card-panel background-color-blue-100 center-align outdatedTermsWarning">
        <h4>{_("db.toCompileTitle")}</h4>
        <div class="mb-4">{_("outdatedTerms")}</div>
        <a href="#ca-compile?run=1"
                class="btn btn-primary">{_("ca.recompile")}</a>
    </div>


    <virtual if={!outdatedTerms}>
        <div if={store.showUpgradeTagsetWarning}
                class="card-panel background-color-blue-100">
            <i class="material-icons right material-clickable"
                    onclick={closeUpgradeTagsetWarning}>close</i>
            <b>{_("ca.shouldUpgrade")}</b><br>
            <span class="mr-4">
                {_("outdatedTagset")}
            </span>
            <button class="btn btn-primary"
                    onclick={onUpgradeClick}>{_("upgrade")}</button>
        </div>
        <div if={store.showRecompileWarning}
                class="card-panel background-color-blue-100">
            <i class="material-icons right material-clickable"
                    onclick={closeRecompileWarning}>close</i>
            <b>{_("recompileCorpus")}</b><br>
            <span class="mr-4">
                {_("outdatedTermdef")}
            </span>
            <button class="btn btn-primary"
                    onclick={onUpgradeTermdefClick}>{_("ca.recompile")}</button>
        </div>
        <div if={!store.data.showresults}
                id="keywordsform"
                class="form card mt-0 mt-2">
            <keywords-tabs></keywords-tabs>
        </div>
        <div class="content" if={store.data.showresults}>
            <keywords-result-options ref="options"></keywords-result-options>
            <keywords-result ref="results"></keywords-result>
        </div>
    </virtual>

    <script>
        require("./keywords-tabs.tag")
        require("./keywords-tab-advanced.tag")
        require('./keywords-result-view.tag')
        require("./keywords-result-options.tag")
        require("./keywords-result.tag")
        require('common/result-info/result-info.tag')
        require('./keywords.scss')

        const {KeywordsStore} = require("./keywordsstore.js")
        const {CAStore} = require("ca/castore.js")

        this.store = KeywordsStore
        this.data = KeywordsStore.data
        this.store.pageTag = this

        updateAttributes(){
            this.outdatedTerms = this.store.corpus.user_can_manage
                    && !!this.store.corpus.termdef
                    && isDef(this.store.corpus.terms_compiled)
                    && !this.store.corpus.terms_compiled
        }
        this.updateAttributes()

        onUpgradeTermdefClick(){
            CAStore.upgradeTermDef().xhr.always(() => {
                Dispatcher.trigger("ROUTER_GO_TO", "ca-compile")
            })
        }

        onUpgradeClick(){
            CAStore.upgradeTagset().xhr.always(() => {
                Dispatcher.trigger("ROUTER_GO_TO", "ca-compile")
            })
        }

        closeRecompileWarning(){
            this.store.showRecompileWarning = false
        }

        closeUpgradeTagsetWarning(){
            this.store.showUpgradeTagsetWarning = false
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            if(!this.store.hasBeenLoaded && this.data.showresults){
                this.store.search()
            }
        })
    </script>
</page-keywords>
