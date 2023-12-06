<corpus-tab-basic>
    <div class="corpus-tab-basic card-content">
        <div class="tab-content card-content" style="display: flex; flex-wrap: wrap">
            <div class="corpusLeftCol" id="intro_lang_overview">
                <h5 class="cardtitle">{_("cp.languages")}</h5>
                {_("cp.languagesDesc")}
                <br><br>
                <div if={loading} class="center-align">
                    <br>
                    <preloader-spinner loading={loading}></preloader-spinner>
                </div>
                <div if={!loading}>
                    <a href="javascript:void(0);"
                            class="btn white-text langBtn waves-effect waves-light"
                            each={corpus in quickCorpList}
                            onclick={onLangClick}>{corpus.language_name.split(" ")[0]}</a>
                    <br><br>
                    {_("moreLanguages")}
                    <br>
                    <lang-corp-list
                        name="langCorp"
                        loading={loading}></lang-corp-list>
                </div>
            </div>
            <div class="corpusRightCol" id="intro_tutorial">
                <h5 class="cardtitle">{_("cp.quickStartTutorial")}</h5>
                <div class="youtubeVideoContainer">
                    <iframe width="560"
                            height="315"
                            src={externalLink("sketchEngineIntro")}
                            frameborder="0"
                            allow="autoplay; encrypted-media"
                            allowfullscreen></iframe>
                </div>
            </div>
        </div>
    </div>

    <script>
        const {AppStore} = require('core/AppStore.js')

        this.mixin("tooltip-mixin")
        this.tab = "basic"
        this.corpusList = AppStore.get("corpusList")

        // TODO: when history is empty, show featured, otherwise show latest
        this.quickStartCorporaIdList = [{
            corpname: "preloaded/bnc2_tt2",
            name: "British national corpus"
        }, {
            corpname: "preloaded/ententen15_tt21",
            name: "English Web"
        }, {
            corpname: "preloaded/frtenten12_1",
            name: "French web"
        }, {
            corpname: "preloaded/estenten11_freeling_v4_virt",
            name: "Spanish web"
        }, {
            corpname: "preloaded/artenten12_stanford",
            name: "Arabic web"
        }, {
            corpname: "preloaded/zhtenten",
            name: "Chinese web"
        }]
        this.quickStartCorporaList = []
        this.loading = !AppStore.get("corpusListLoaded")



        onLangClick(evt){
            let corpus = evt.item.corpus
            AppStore.changeCorpus(AppStore.getLatestCorpusVersion(corpus).corpname)
            AppStore.one("corpusChanged", () => {
                Dispatcher.trigger("ROUTER_GO_TO", "dashboard", {corpname: corpus.corpname})
            })
        }

        onCorpusListLoad(corpusList){
            this.loading = false
            this.corpusList = corpusList
            this.refreshQuickCorpList()
            this.update()
        }

        refreshQuickCorpList() {
            if(this.corpusList){
                this.quickCorpList = [];
                ["preloaded/ententen15_tt21",
                    "preloaded/frtenten12_1",
                    "preloaded/estenten11_freeling_v4_virt",
                    "preloaded/ittenten16_2",
                    "preloaded/artenten12_stanford",
                    "preloaded/rutenten11_8",
                    "preloaded/detenten13_rft3",
                    "preloaded/pttenten11_fl4",
                    "preloaded/pltenten12_rft",
                    "preloaded/jptenten11_2",
                    "preloaded/zhtenten"].forEach(corpname => {
                        let corpus = AppStore.getCorpusByCorpname(corpname)
                        if(corpus){
                            this.quickCorpList.push(AppStore.getLatestCorpusVersion(corpus))
                        }
                    })
            }
        }
        this.refreshQuickCorpList()


        this.on("mount", () => {
            AppStore.on("corpusListChanged", this.onCorpusListLoad)
        })

        this.on("unmount", () => {
            AppStore.off("corpusListChanged", this.onCorpusListLoad)
        })
    </script>
</corpus-tab-basic>
