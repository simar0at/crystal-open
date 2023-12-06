<parconcordance-result-options-part class="parconcordance-result-options-part">
    <feature-toolbar store={store}
            ref="ftoolbarp"
            feature-page="parconcordance"
            options={optionsList}
            settings-tag="parconcordance-tabs"
            empty={true}>
    </feature-toolbar>
    <div class="alcorpname">{alname}</div>

    <script>
        require("./parconcordance-result-options-sort.tag")
        require("./parconcordance-result-options-filter.tag")
        require("./parconcordance-result-options-freq.tag")
        require("concordance/collocations/collocations-tabs.tag")
        require("concordance/concordance-subcorpus-dialog.tag")

        const {Auth} = require("core/Auth.js")

        this.mixin('feature-child')

        removeLang() {
            if(this.opts.corpname){
                let idx = -1
                for (let i=0; i<this.data.formparts.length; i++) {
                    if (this.data.formparts[i].corpname == this.opts.corpname) {
                        idx = i
                        break
                    }
                }
                if (idx >= 0) {
                    this.data.formparts.splice(idx, 1)
                    this.store.operationsInit()
                    this.store.searchAndAddToHistory()
                }
            }
        }

        updateAttributes() {
            this.alname = ""
            if (this.data.aligned_corpora && this.opts.corpname) {
                this.alname = this.data.aligned_corpora.find((x) => {
                    return x.n == this.opts.corpname
                }).label
            }
            this.optionsList = [{
                id: "sort",
                icon: "sort",
                iconClass: "material-icons",
                labelId: "sort",
                contentTag: "parconcordance-result-options-sort",
                contentOpts: {
                    corpname: this.opts.corpname,
                    has_no_kwic: opts.has_no_kwic
                },
                disabled: opts.has_no_kwic
            }, {
                id: "filter",
                icon: "filter_list",
                iconClass: "material-icons",
                labelId: "filter",
                contentTag: "parconcordance-result-options-filter",
                contentOpts: {
                    corpname: this.opts.corpname,
                    showQuickFilter: false,
                    has_no_kwic: opts.has_no_kwic
                }
            }]
            if(!this.opts.corpname){
                this.optionsList.push({
                    id: "gdex",
                    iconClass: "ske-icons skeico_gdex_i",
                    labelId: "cc.tipGdex",
                    contentTag: "parconcordance-result-options-gdex"
                })
            }
            this.optionsList = this.optionsList.concat([{
                id: "frequency",
                icon: "insert_chart",
                iconClass: "material-icons rotate90CW",
                labelId: "frequency",
                contentTag: "parconcordance-result-options-freq",
                contentOpts: {
                    corpname: this.opts.corpname
                },
                disabled: opts.has_no_kwic
            }, {
                id: "collocations",
                iconClass: "material-icons",
                icon: "linear_scale",
                labelId: "collocations",
                contentTag: "collocations-tabs",
                contentOpts: {
                    corpname: this.opts.corpname,
                    has_no_kwic: opts.has_no_kwic
                },
                disabled: opts.has_no_kwic
            }])
            if (!this.opts.corpname || !this.opts.has_no_kwic) {
                this.optionsList.push({
                    id: "distribution",
                    icon: "insert_chart",
                    iconClass: "material-icons",
                    labelId: "cc.freqDistrib",
                    contentTag: "parconcordance-result-options-distribution",
                    contentOpts: {
                        corpname: this.opts.corpname ? this.store.addPrefixToCorpname(this.opts.corpname) : ""
                    }
                })
            }
            if(Auth.isFullAccount()){
                this.optionsList.push({
                    id: "addsubc",
                    icon: "add",
                    iconClass: "material-icons",
                    labelId: "createSubcorpus",
                    contentTag: "concordance-subcorpus-dialog",
                    contentOpts: {
                        corpname: this.opts.corpname ? this.store.addPrefixToCorpname(this.opts.corpname) : ""
                    }
                })
            }
            if (opts.allowrm) {
                this.optionsList.push({
                    id: "close",
                    icon: "close",
                    iconClass: "material-icons",
                    labelId: "pc.rmLang",
                    onclick: this.removeLang
                })
            }
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.store.on("change", this.update)
        })

        this.on("unmount", () => {
            this.store.off("change", this.update)
        })
    </script>
</parconcordance-result-options-part>
