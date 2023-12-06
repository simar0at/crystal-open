<page-wordlist class="page-wordlist tab-{store.data.tab}">
    <preloader-spinner if={store.data.isLoading && !store.data.jobid} on-cancel={store.onLoadingCancel.bind(store)} overlay=1 fixed=1 browser-indicator=1></preloader-spinner>
    <div if={!store.hasBeenLoaded && !hideForm} class="form card " id="wordlistform">
        <wordlist-tabs></wordlist-tabs>
    </div>
    <bgjob-card if={store.data.jobid} data={store.data}></bgjob-card>
    <div if={store.hasBeenLoaded} class="content result">
        <wordlist-result-options></wordlist-result-options>
        <wordlist-result-table></wordlist-result-table>
    </div>

    <script>
        require("./page-wordlist.scss")
        require("./wordlist-tabs.tag")
        require("./wordlist-result-table.tag")
        require("./wordlist-result-options.tag")

        const {WordlistStore} = require("./WordlistStore.js")

        this.store = WordlistStore
        this.store.pageTag = this
        this.hideForm = this.store.data.showresults

        this.on("mount", () => {
            if(!this.store.hasBeenLoaded && this.store.data.showresults){
                this.store.search()
            }
            this.hideForm = false
        })
    </script>
</page-wordlist>
