<page-keywords class="page-keywords">
    <div if={store.showRecompileWarning}
            class="termdefWarning card-panel">
        <i class="material-icons right material-clickable"
                onclick={closeRecompileWarning}>close</i>
        <b>{_("recompileCorpus")}</b><br>
        <span class="mr-4">
            {_("outdatedTermdef")}
        </span>
        <button class="btn btn-primary"
                onclick={onRecompileClick}>{_("recompile")}</a>
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

        onRecompileClick(){
            CAStore.upgradeTermDef().xhr.always(() =>{
                Dispatcher.trigger("ROUTER_GO_TO", "ca-compile")
            })
        }

        closeRecompileWarning(){
            this.store.showRecompileWarning = false
        }

        this.on("mount", () => {
            if(!this.store.hasBeenLoaded && this.data.showresults){
                this.store.search()
            }
        })
    </script>
</page-keywords>
