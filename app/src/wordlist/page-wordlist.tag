<page-wordlist class="page-wordlist tab-{store.data.tab}">
    <result-preloader-spinner store={store}></result-preloader-spinner>
    <div if={!store.hasBeenLoaded && !hideForm}
            id="wordlistform"
            class="form card mt-0 mt-2">
        <wordlist-tabs></wordlist-tabs>
    </div>
    <div if={store.hasBeenLoaded}>
        <wordlist-result-options></wordlist-result-options>
        <wordlist-result-table if={!data.jobid && !data.isEmpty && !data.isEmptySearch}></wordlist-result-table>
        <h2 if={!data.isLoading && !data.jobid && (data.isEmptySearch || data.isEmpty)} class="emptyResult">{_("nothingFound")}</h2>
    </div>
    <bgjob-card if={data.jobid}
            is-loading={data.isBgJobLoading}
            desc={data.raw.desc}
            progress={data.raw.processing}></bgjob-card>

    <script>
        require("./page-wordlist.scss")
        require("./wordlist-tabs.tag")
        require("./wordlist-result-table.tag")
        require("./wordlist-result-options.tag")

        const {WordlistStore} = require("./WordlistStore.js")

        this.store = WordlistStore
        this.store.pageTag = this
        this.data = this.store.data
        this.hideForm = this.store.data.showresults

        this.on("mount", () => {
            if(!this.store.hasBeenLoaded && this.store.data.showresults){
                this.store.search()
            }
            this.hideForm = false
        })
    </script>
</page-wordlist>
