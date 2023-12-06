<parconcordance-result-options>
    <feature-toolbar store={store}
        feature-page="parconcordance"
        options={optionsList}
        active={data.act_opts}
        formats={["csv", "xlsx", "xml", "txt", "tmx"]}
        download-limit={data.raw && data.raw.concordance_size_limit}
        show-limit=1
        limit-name={limitName}
        pulse-id={store.isConc && isEmpty && !wasOperation ? "settings" : ""}
        settings-tag="parconcordance-tabs"
        on-open={onOptionsOpen}
        on-close={onOptionsClose}>
    </feature-toolbar>

    <script>
        require("concordance/concordance-result-options-info.tag")

        this.mixin("feature-child")

        onViewChange(view){
            this.store.searchAndAddToHistory({
                "viewmode": view
            })
        }

        updateAttributes(){
            this.wasOperation = this.data.operations.length > 1
            this.isEmpty = this.data.isEmpty
            this.limitName = "pagesize"
            if(this.store.isFreq){
                this.limitName = "fmaxitems"
            } else if(this.store.isColl){
                this.limitName = "cmaxitems"
            }
            this.optionsList = [{
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
                    id: "kwicSen",
                    itemTag: "kwicsen",
                    tagOpts: {
                        name: "viewmode",
                        disabled: this.isLoading || this.results_screen != "parconcordance",
                        sel: this.data.viewmode,
                        onClick: this.onViewChange
                    }
                }, {
                    id: "info",
                    contentTag: 'concordance-result-options-info',
                    iconClass: "material-icons",
                    icon: "info_outline",
                    labelId: 'concordanceDescription'
                }
            ]
             this.optionsList.forEach(option => {
                if(this.isEmpty){
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
