<page-text-type-analysis class="page-text-type-analysis">
    <result-preloader-spinner store={store}></result-preloader-spinner>
    <bgjob-card if={store.data.jobid}
            is-loading={data.isBgJobLoading}
            desc={data.raw.desc}
            progress={data.raw.processing}></bgjob-card>
    <div class="content result">
        <text-type-analysis-result-table></text-type-analysis-result-table>
    </div>

    <script>
        require("./text-type-analysis-result-table.tag")

        const {WordlistStore} = require("./WordlistStore.js")

        this.store = WordlistStore
        this.store.pageTag = this
        this.data = this.store.data

        this.on("mount", () => {
            this.store.search()
        })
    </script>
</page-text-type-analysis>
