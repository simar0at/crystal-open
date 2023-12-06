<concordance-tab-about>
    <external-text text="conc_about" style="display:block; max-width: 800px;"></external-text>
</concordance-tab-about>


<concordance-tabs class="concordance-tabs">
    <ui-tabs ref="tabs" name="concordance-tabs" tabs={tabs} active={data.tab}
            on-tab-change={onTabChange}>
    </ui-tabs>

    <script>
        require("./concordance-tabs.scss")
        require("./concordance-tab-basic.tag")
        require("./concordance-tab-advanced.tag")
        require("./concordance-tab-error.tag")
        const {AppStore} = require('core/AppStore.js')
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        this.mixin("feature-child")

        this.tabs = [{
            tabId: "basic",
            labelId: "basic",
            tag: "concordance-tab-basic"
        }, {
            tabId: "advanced",
            labelId: "advanced",
            tag: "concordance-tab-advanced"
        }]
        if (AppStore.data.corpus.is_error_corpus) {
            this.tabs.push({
                tabId: "error",
                labelId: "errorAnalysis",
                tag: "concordance-tab-error"
            })
        }
        this.tabs.push({
            tabId: "about",
            label: "about",
            tag: "concordance-tab-about"
        })

        onTabChange(tabId){
            if(this.data.tab != tabId){
                TextTypesStore.reset()
                if(this.data.selection && this.data.selection.length){
                    TextTypesStore.setSelection(this.data.selection)
                }
                this.data.tab = tabId
                delay(() => {
                    $("input[name=\"keyword\"]:visible, textarea[name=\"cql\"]:visible", this.root).first().focus()
                }, 1)
                this.store.updateUrl()
                this.update()
            }
        }

        onSelectionChange(selection){
            this.data.selection = selection
        }

        this.on("mount", () => {
            TextTypesStore.on("selectionChange", this.onSelectionChange)
            $(document).ready(function(){
                $('.tooltipped', this.root).tooltip({
                    enterDelay: 50
                })
           })
        })

        this.on("unmount", () => {
            TextTypesStore.off("selectionChange", this.onSelectionChange)
        })

    </script>
</concordance-tabs>
