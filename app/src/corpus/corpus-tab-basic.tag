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
                            class="btn white-text langBtn"
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
                    <a if={window.config.DISABLE_EMBEDDED_YOUTUBE}
                            href={externalLink("sketchEngineIntro")}
                            target="_blank"
                            class="youtubePlaceholder"
                            style="width:560px;height:315px;">
                        <img src="images/youtube-placeholder.jpg"
                                loading="lazy"
                                alt="Sketch Engine Intro">
                    </a>
                    <iframe if={!window.config.DISABLE_EMBEDDED_YOUTUBE}
                            width="560"
                            height="315"
                            src={externalLink("sketchEngineIntro")}
                            frameborder="0"
                            allow="autoplay; encrypted-media"
                            allowfullscreen
                            loading="lazy"></iframe>
                </div>
            </div>
        </div>
    </div>

    <script>
        const {AppStore} = require('core/AppStore.js')

        this.mixin("tooltip-mixin")
        this.tab = "basic"
        this.loading = !AppStore.get("corpusListLoaded")

        onLangClick(evt){
            let corpus = evt.item.corpus
            AppStore.changeCorpus(AppStore.getLatestCorpusVersion(corpus).corpname)
            AppStore.one("corpusChanged", () => {
                Dispatcher.trigger("ROUTER_GO_TO", "dashboard", {corpname: corpus.corpname})
            })
        }

        onCorpusListLoad(){
            this.loading = false
            this.refreshQuickCorpList()
            this.update()
        }

        refreshQuickCorpList() {
            if(AppStore.data.corpusList.length){
                this.quickCorpList = AppStore.data.corpusList.filter(c => {
                    return c.is_featured
                })
                let userLang = (navigator.language || navigator.userLanguage).split("-")[0]
                if(!this.quickCorpList.find(c => c.language_id == userLang)){ // language is not in featured
                    let userLangCorpora = AppStore.data.corpusList.filter(c => c.language_id == userLang && c.user_can_read && !c.id)
                    this.quickCorpList = this.quickCorpList.concat(userLangCorpora)
                }
                this.quickCorpList.sort((a, b) => {
                    return a.language_name.localeCompare(b.language_name)
                })
                // use only the biggest corpus for each language
                this.quickCorpList = this.quickCorpList.filter(c => {
                    return !this.quickCorpList.find(c2 => { //no bigger corpus of same language found -> keep it
                        return c2.language_id == c.language_id && c.corpname != c2.corpname && c.sizes.wordcount < c2.sizes.wordcount
                    }, this)
                }, this)
                this.quickCorpList = this.quickCorpList.map(c => {
                    return AppStore.getLatestCorpusVersion(c)
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
