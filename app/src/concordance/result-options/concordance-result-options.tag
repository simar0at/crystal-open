<concordance-result-options class="concordance-result-options">
    <feature-toolbar store={store}
        feature-page="concordance"
        options={optionsList}
        active={data.act_opts}
        formats={["txt", "csv", "xlsx", "xml"]}
        download-limit={data.raw && data.raw.concordance_size_limit}
        download-disabled={isDownloadDisabled}
        show-limit=1
        limit-name={limitName}
        pulse-id={store.isConc && isEmpty && !wasOperation ? "settings" : ""}
        settings-tag="concordance-tabs"
        on-open={onOptionsOpen}
        on-close={onOptionsClose}></feature-toolbar>

    <script>
        this.mixin("tooltip-mixin")
        this.mixin("feature-child")
        const {AnnotationStore} = require("annotation/annotstore.js")

        require("./concordance-result-options.scss")
        require("./kwicsen.tag")
        require("./concordance-result-options-view.tag")
        require("./concordance-result-options-gdex.tag")
        require("./concordance-result-options-sample.tag")
        require("./concordance-result-options-shuffle.tag")
        require("./concordance-result-options-sort.tag")
        require("./concordance-result-options-filter.tag")
        require("annotation/result-options-annot.tag")
        require("./concordance-parconc-dialog.tag")
        require("concordance/collocations/collocations-tabs.tag")
        require("concordance/frequency/frequency-tabs.tag")
        require('concordance/concordance-distribution.tag')
        require("concordance/concordance-tabs.tag")
        require("concordance/concordance-subcorpus-dialog.tag")
        require("concordance/concordance-result-options-info.tag")


        const {Auth} = require("core/Auth.js")

        onViewChange(view){
            this.store.searchAndAddToHistory({
                "viewmode": view
            })
        }

        onOptionsOpen(optionsId){
            this.store.data.act_opts = optionsId
            if(optionsId == "distribution"){
                this.store.updateUrl()
            }
            if (optionsId == "annotate") {
                AnnotationStore.getAnnotLabels()
            }
        }

        onOptionsClose(){
            this.store.data.act_opts = ""
            this.store.updateUrl()
        }

        onParconcClick(){
            Dispatcher.trigger("openDialog", {
                small: true,
                title: _("translate"),
                tag: "concordance-parconc-dialog"
            })
        }

        updateAttributes(){
            this.wasOperation = this.data.operations.length > 1
            this.isEmpty = this.data.isEmpty
            this.isLoading = this.store.data.isCountLoading
            this.limitName = "pagesize"
            if(this.store.isFreq){
                this.limitName = "fmaxitems"
            } else if(this.store.isColl){
                this.limitName = "cmaxitems"
            }
            this.isDownloadDisabled = this.store.isConc && this.data.isEmpty
                    || this.store.isColl && this.data.c_isEmpty
                    || this.store.isFreq && this.data.f_isEmpty
            this.optionsList = []
            if(this.store.corpus.aligned.length){
                this.optionsList.push({
                    id: "translate",
                    labelId: "cc.tipTranslate",
                    onclick: this.onParconcClick,
                    iconClass: "ske-icons skeico_parallel_concordance"
                })
            }
            window.config.ENABLE_ANNOTATION && this.optionsList.push({
                id: "annotate",
                icon: "toc",
                labelId: "cc.tipAnnotate",
                contentTag: "result-options-annot",
                iconClass: "material-icons",
                btnClass: this.data.annotconc ? "annot" : "",
                contentOpts: {
                    source: "conc"
                }
            })
            this.optionsList = this.optionsList.concat([{
                    id: "view",
                    icon: "visibility",
                    iconClass: "material-icons",
                    labelId: "changeDisplayOptions",
                    contentTag: "concordance-result-options-view"
                }, {
                    id: "sample",
                    iconClass: "ske-icons skeico_random_i",
                    labelId: "cc.tipSample",
                    contentTag: "concordance-result-options-sample"
                }, {
                    id: "shuffle",
                    icon: "shuffle",
                    iconClass: "material-icons",
                    labelId: "cc.tipShuffle",
                    contentTag: "concordance-result-options-shuffle"
                }, {
                    id: "sort",
                    icon: "sort",
                    iconClass: "material-icons",
                    labelId: "sort",
                    contentTag: "concordance-result-options-sort"
                }, {
                    id: "filter",
                    icon: "filter_list",
                    iconClass: "material-icons",
                    labelId: "filter",
                    contentTag: "concordance-result-options-filter"
                }, {
                    id: "gdex",
                    iconClass: "ske-icons skeico_gdex_i",
                    labelId: "cc.tipGdex",
                    contentTag: "concordance-result-options-gdex"
                },{
                    id: "frequency",
                    icon: "insert_chart",
                    iconClass: "material-icons rotate90CW",
                    labelId: "frequency",
                    contentTag: "frequency-tabs"
                },{
                    id: "collocations",
                    icon: "linear_scale",
                    iconClass: "material-icons",
                    labelId: "collocations",
                    contentTag: "collocations-tabs"
                }, {
                    id: "distribution",
                    icon: "insert_chart",
                    iconClass: "material-icons",
                    labelId: "cc.freqDistrib",
                    contentTag: "concordance-distribution"
                }, {
                    id: "kwicSen",
                    itemTag: "kwicsen",
                    tagOpts: {
                        name: "viewmode",
                        disabled: this.isLoading || !this.store.isConc,
                        sel: this.data.viewmode,
                        onClick: this.onViewChange
                    }
                }
            ])
            if(this.corpus.deffilterlink){
                this.optionsList.splice(6, 0, {
                    id: "definitions",
                    icon: "wb_incandescent",
                    iconClass: "material-icons rotate180",
                    tooltip: "t_id:conc_r_definitions",
                    onclick: this.store.definitions.bind(this.store)
                })
            }
            if(Auth.isFullAccount()){
                this.optionsList.push({
                    id: "addsubc",
                    icon: "add",
                    disabled: !!this.store.data.usesubcorp,
                    tooltip: this.store.data.usesubcorp ? _("createSubcorpDisabled") : "",
                    iconClass: "material-icons",
                    labelId: "createSubcorpus",
                    contentTag: "concordance-subcorpus-dialog"
                })
            }
            this.optionsList.push({
                id: "info",
                contentTag: 'concordance-result-options-info',
                iconClass: "material-icons",
                icon: "info_outline",
                labelId: 'concordanceDescription'
            })
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

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.store.on("countChange", this.update)
        })

        this.on("unmount", () => {
            this.store.off("countChange", this.update)
        })
    </script>
</concordance-result-options>
