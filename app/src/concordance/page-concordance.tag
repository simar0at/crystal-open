<page-concordance class="page-concordance {concordance: store.isConc} {frequency: store.isFreq} {collocations: store.isColl}">
    <result-preloader-spinner store={store}></result-preloader-spinner>
    <div if={!store.hasBeenLoaded && store.isConc && !hideForm}
            class="card form mediumForm mt-0 mt-2">
        <concordance-tabs></concordance-tabs>
    </div>
    <div if={store.data.showresults} class="content card result">
        <concordance-breadcrumbs if={!store.data.isError}></concordance-breadcrumbs>
        <manage-macros-icon if={isFullAccount && (store.hasBeenLoaded || store.c_hasBeenLoaded || store.f_hasBeenLoaded)}></manage-macros-icon>
        <concordance-lemma-menu
                if={(store.data.tab == "advanced" && (store.data.queryselector == "lemma" || store.data.queryselector == "lempos")) || store.data.annotconc}
                data={store.data}>
        </concordance-lemma-menu>
        <concordance-result-options if={store.hasBeenLoaded || !store.isConc}></concordance-result-options>
        <concordance-result if={store.isConc && !store.data.isError}></concordance-result>
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

        const {Auth} = require("core/Auth.js")
        const {ConcordanceStore} = require("./ConcordanceStore.js")

        this.store = ConcordanceStore
        this.store.pageTag = this
        this.hideForm = this.store.data.showresults
        this.isFullAccount = Auth.isFullAccount()

        startPulseTimer(){
            let bcWarning = $("#breadcrumbsWarning")
            let frqWarning = $("#frequencyWarning")
            let node = null
            if(frqWarning.length){
                node = frqWarning
            } else if(bcWarning.length){
                node = bcWarning
            }
            if(node && node.hasClass("red")){
                node.addClass("pulse")
                this.pulseTimerHandle = setTimeout(this.removePulseClass, 6000)
            }
        }

        stopPulseTimer(){
            this.pulseTimerHandle && clearTimeout(this.pulseTimerHandle)
            this.removePulseClass()
        }

        removePulseClass(){
            $("#breadcrumbsWarning, #frequencyWarning").removeClass("pulse")
        }

        this.on("mount", () => {
            if(this.store.isConc && !this.store.hasBeenLoaded && this.store.data.showresults){
                this.store.search()
            }
            this.hideForm = false
            this.store.on("onDataLoadAlways", this.startPulseTimer)
            this.store.on("search", this.stopPulseTimer)
        })

        this.on("unmount", () => {
            this.store.off("onDataLoadAlways", this.startPulseTimer)
            this.store.off("search", this.stopPulseTimer)
        })
    </script>
</page-concordance>
