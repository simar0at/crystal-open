<concordance-tab-about>
    <external-text text="conc_about" style="display:block; max-width: 800px;"></external-text>
</concordance-tab-about>


<concordance-tabs class="concordance-tabs">
    <ui-tabs ref="tabs"
            class="searchTabs"
            name="concordance-tabs"
            tabs={tabs}
            active={data.tab}
            on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require("./concordance-tabs.scss")
        require("./concordance-tab-basic.tag")
        require("./concordance-tab-advanced.tag")
        require("./concordance-tab-error.tag")
        const {AppStore} = require('core/AppStore.js')

        this.mixin("feature-child")
        this.tabs = [{
                tabId: "basic",
                labelId: "basic",
                tag: "concordance-tab-basic"
            }, {
                tabId: "advanced",
                labelId: "advanced",
                tag: "concordance-tab-advanced"
            }, {
                tabId: "about",
                labelId: "about",
                tag: "concordance-tab-about"
            }]

        updateAttributes(){
            // Keep this.tabs object, just update it when needed.
            // Assigning array this.tabs=[...] creates new array object and even
            // if the content did not change, it makes riot update the component each time.
            if(this.tabs.length == 3 && this.store.corpus.is_error_corpus){
                this.tabs.splice(3, 0, {
                    tabId: "error",
                    labelId: "errorAnalysis",
                    tag: "concordance-tab-error"
                });
            } else if(this.tabs.length == 4 && !this.store.corpus.is_error_corpus){
                this.tabs.splice(3, 1)
            }
        }
        this.updateAttributes()

        onTabChange(tabId){
            if(this.data.tab != tabId){
                this.data.tab = tabId
                delay(() => {
                    $("input[name=\"keyword\"]:visible, textarea[name=\"cql\"]:visible", this.root).first().focus()
                }, 1)
                this.store.updateUrl()
                this.update()
            }
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            $(document).ready(function(){
                $('.tooltipped', this.root).tooltip({
                    enterDelay: 50
                })
           })
        })
    </script>
</concordance-tabs>
