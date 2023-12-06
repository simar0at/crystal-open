<page-parconcordance class="page-parconcordance">
    <result-preloader-spinner store={store}></result-preloader-spinner>
    <div if={!store.hasBeenLoaded && store.isConc && !hideForm}
            class="card form narrowForm mt-0 mt-2">
        <parconcordance-tabs></parconcordance-tabs>
    </div>
    <div if={store.data.showresults} class="content card parconcordance-result {directionRTL: store.corpus.righttoleft}">
        <concordance-breadcrumbs if={!store.data.isError} show-jump-to={false}></concordance-breadcrumbs>
        <concordance-lemma-menu if={store.data.tab == "advanced" && (store.data.formValue.queryselector == "lemma" || store.data.formValue.queryselector == "lempos")} data={store.data.formValue}></concordance-lemma-menu>
        <parconcordance-translations></parconcordance-translations>
        <parconcordance-result-options if={store.hasBeenLoaded || !store.isConc}></parconcordance-result-options>
        <parconcordance-result if={store.isConc && !store.data.isError}></parconcordance-result>
        <h2 if={store.isConc && store.data.isEmpty && !store.data.isLoading} class="emptyResult">{_("nothingFound")}</h2>
        <parconcordance-frequency-result if={store.isFreq}></parconcordance-frequency-result>
        <parconcordance-collocations-result if={store.isColl}></parconcordance-collocations-result>
    </div>

    <script>
        require("./parconcordance-common.tag")
        require("./parconcordance-result.tag")
        require("./parconcordance-result-options.tag")
        require("./parconcordance-result-options-part.tag")
        require("./parconcordance-result-options-view.tag")
        require("./parconcordance-result-options-gdex.tag")
        require("./parconcordance-frequency-result.tag")
        require("./parconcordance-tabs.tag")
        require("./parconcordance.scss")
        require("./parconcordance-translations.tag")
        require("./parconcordance-kwicsen.tag")
        require("./parconcordance-result-options-distribution.tag")
        require("./parconcordance-collocations-result.tag")
        require("concordance/concordance-detail-window.tag")
        require("concordance/concordance-breadcrumbs.tag")
        require("concordance/concordance-lemma-menu.tag")

        const {ParconcordanceStore} = require("./parconcordancestore.js")

        this.store = ParconcordanceStore
        this.store.pageTag = this
        this.hideForm = this.store.data.showresults

        this.on("mount", () => {
            if(this.store.isConc && !this.store.hasBeenLoaded && this.store.data.showresults){
                this.store.search()
            }
            this.hideForm = false
        })
    </script>
</page-parconcordance>
