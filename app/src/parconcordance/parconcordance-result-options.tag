<parconcordance-result-options>
    <feature-toolbar store={store}
        feature-page="parconcordance"
        options={optionsList}
        active={data.act_opts}
        formats={["csv", "xls", "xml", "txt"]}
        pulse-id={store.isConc && isEmpty ? (wasOperation ? "undo": "settings") : ""}
        settings-tag="parconcordance-tabs"
        on-open={onOptionsOpen}
        on-close={onOptionsClose}>
    </feature-toolbar>

    <script>
        this.mixin("feature-child")

        onViewChange(view){
            this.store.searchAndAddToHistory({
                "viewmode": view
            })
        }

        onUndoClick(){
            this.store.removeOperation(this.data.operations[this.data.operations.length - 1])
        }

        updateAttributes(){
            this.wasOperation = this.data.operations.length > 1
            this.isEmpty = this.data.isEmpty
            this.optionsList = [{
                    id: "undo",
                    labelId: "undo",
                    icon: "undo",
                    iconClass: "material-icons",
                    onclick: this.onUndoClick,
                    disabled: this.isLoading || !this.wasOperation
                }, {
                    id: "view",
                    icon: "visibility",
                    iconClass: "material-icons",
                    labelId: "changeDisplayOptions",
                    contentTag: "parconcordance-result-options-view"
                }, {
                    id: "sample",
                    iconClass: "ske-icons skeico_random_i",
                    labelId: "cc.tipSample",
                    contentTag: "parconcordance-result-options-sample"
                }, {
                    id: "shuffle",
                    icon: "shuffle",
                    iconClass: "material-icons",
                    labelId: "cc.tipShuffle",
                    contentTag: "parconcordance-result-options-shuffle"
                }, {
                    id: "gdex",
                    iconClass: "ske-icons skeico_gdex_i",
                    labelId: "cc.tipGdex",
                    contentTag: "parconcordance-result-options-gdex"
                }, {
                    id: "kwicSen",
                    itemTag: "kwicsen",
                    tagOpts: {
                        name: "viewmode",
                        disabled: this.isLoading || this.results_screen != "parconcordance",
                        sel: this.data.viewmode,
                        onClick: this.onViewChange
                    }
                }
            ]
             this.optionsList.forEach(option => {
                if(option.id != "undo" && this.isEmpty){
                    option.disabled = true
                }
                if(!this.store.isConc){
                    option.disabled = this.data.results_screen != option.id
                }
            })
        }
        this.updateAttributes()

        onOptionsOpen(optionsId){
            this.store.data.act_opts = optionsId
        }

        onOptionsClose(){
            this.store.data.act_opts = ""
            this.store.updateUrl()
        }

        this.on("update", this.updateAttributes)
    </script>
</parconcordance-result-options>
