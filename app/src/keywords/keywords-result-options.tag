<keywords-result-options>
    <subcorpus-chip></subcorpus-chip>
    <text-types-chip></text-types-chip>
    <feature-toolbar store={store}
            options={optionsList}
            ref="ftoolbar"
            feature-page="keywords"
            download-disabled={false}
            formats={["csv", "xlsx", "xml"]}
            settings-tag="keywords-tabs"
            hide-on-load={false}>
    </feature-toolbar>

    <script>

        this.mixin("feature-child")


        updateAttributes(){
            this.optionsList = [ {
                id: 'view',
                contentTag: 'keywords-result-view',
                iconClass: 'material-icons',
                icon: 'visibility',
                labelId: 'changeViewOpts'
            }, {
                id: "filter",
                contentTag: 'result-filter',
                disabled: !this.store.hasBeenLoaded
                    || ((this.data.k_isLoading || this.data.k_jobid)
                        && (this.data.t_isLoading || this.data.t_jobid)
                        && (this.data.n_isLoading || this.data.n_jobid)
                        && (this.data.w_isLoading || this.data.w_jobid)
                        ),
                iconClass: "material-icons",
                icon: "filter_list",
                labelId: 'filterResults'
            }, {
                id: 'info',
                contentTag: 'result-info',
                iconClass: 'material-icons',
                icon: 'info_outline',
                labelId: 'kw.labelInfo',
                contentOpts: {
                    options: [
                        ["alnum", _("kw.alnum")],
                        ["icase", _("icase")],
                        ["k_attr", _("k_attr")],
                        ["k_wlpat", _("k_wlpat")],
                        ["max_items", _("max_items")],
                        ["minfreq", _("minFreq")],
                        ["n_attr", _("n_attr")],
                        ["n_wlpat", _("n_wlpat")],
                        ["onealpha", _("kw.onealpha")],
                        ["ref_corpname", _("refCorpus")],
                        ["ref_usesubcorp", _("kw.refSubcorpus")],
                        ["simple_n", _("kw.simple_n")],
                        ["t_wlpat", _("t_wlpat")],
                        ["usesubcorp", _("subcorpus")]
                    ],
                    doNotRemove: ["ref_corpname"]
                }
            }]
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</keywords-result-options>
