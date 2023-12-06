<page-keywords class="page-keywords">
    <div class="form card" if={!store.data.showresults} id="keywordsform">
        <keywords-tabs></keywords-tabs>
    </div>
    <div class="content" if={store.data.showresults}>
        <subcorpus-chip></subcorpus-chip>
        <feature-toolbar store={store}
                options={optionsList}
                ref="ftoolbar"
                feature-page="keywords"
                formats={["csv", "xls", "xml"]}
                settings-tag="keywords-tabs"
                hide-on-load={false}>
        </feature-toolbar>
        <keywords-result></keywords-result>
    </div>

    <script>
        require("./keywords-tabs.tag")
        require("./keywords-tab-advanced.tag")
        require('./keywords-result-info.tag');
        require('./keywords-result-view.tag')
        require("./keywords-result.tag")
        require('./keywords.scss')

        const {KeywordsStore} = require("./keywordsstore.js")

        this.store = KeywordsStore
        this.data = KeywordsStore.data
        this.store.pageTag = this
        this.optionsList = [ {
            id: 'view',
            contentTag: 'keywords-result-view',
            iconClass: 'material-icons',
            icon: 'visibility',
            labelId: 'changeViewOpts'
        }, {
            id: 'info',
            contentTag: 'keywords-result-info',
            iconClass: 'material-icons',
            icon: 'info_outline',
            labelId: 'kw.labelInfo'
        }]

        this.on("mount", () => {
            if(!this.store.hasBeenLoaded && this.data.showresults){
                this.store.search()
            }
        })
    </script>
</page-keywords>
