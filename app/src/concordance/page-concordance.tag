<page-concordance class="page-concordance">
    <preloader-spinner if={store.data.isLoading} overlay=1 fixed=1 on-cancel={store.onLoadingCancel.bind(store)} browser-indicator=1></preloader-spinner>
    <div if={!store.hasBeenLoaded && store.isConc && !hideForm} class="card form mediumForm">
        <concordance-tabs></concordance-tabs>
    </div>
    <div if={store.data.showresults} class="content card result">
        <concordance-breadcrumbs if={!store.data.isError}></concordance-breadcrumbs>
        <concordance-lemma-menu
                if={(store.data.tab == "advanced" && (store.data.queryselector == "lemma" || store.data.queryselector == "lempos")) || store.data.annotconc}
                data={store.data}>
        </concordance-lemma-menu>
        <concordance-result-options if={store.hasBeenLoaded || !store.isConc}></concordance-result-options>
        <concordance-result if={store.isConc && !store.isError}></concordance-result>
        <h2 if={store.isConc && store.data.isEmpty && !store.data.isLoading} class="emptyResult">{_("nothingFound")}</h2>
        <frequency-result if={store.isFreq}></frequency-result>
        <collocations-result if={store.isColl}></collocations-result>
    </div>

    <script>
        require("./page-concordance.scss")
        require("./concordance-tabs.tag")
        require("./result-options/concordance-result-options.tag")
        require("./concordance-result.tag")
        require("./concordance-breadcrumbs.tag")
        require("./concordance-lemma-menu.tag")
        require("./collocations/collocations-result.tag")
        require("./frequency/frequency-result.tag")

        const {ConcordanceStore} = require("./ConcordanceStore.js")

        this.store = ConcordanceStore
        this.store.pageTag = this
        this.hideForm = this.store.data.showresults

        this.on("mount", () => {
            if(this.store.isConc && !this.store.hasBeenLoaded && this.store.data.showresults){
                this.store.search()
            }
            this.hideForm = false
        })
    </script>
</page-concordance>
