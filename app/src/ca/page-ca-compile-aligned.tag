<page-ca-compile-aligned class="page-ca-compile-aligned ca">
    <ca-breadcrumbs active="ca-compile-aligned" section="createMultiAligned"></ca-breadcrumbs>
    <div if={isLoading} class="centerSpinner">
        <preloader-spinner></preloader-spinner>
    </div>
    <div if={!isLoading && !corpora.length}>
        <div class="primaryButtons">
            {_("somethingWentWrong")}
            <a href="#dashboard" class="btn btn-primary">{_("goToDashboard")}</a>
        </div>
    </div>
    <div class="columnWrapper" if={corpora.length}>
        <div class="card-panel">
            <div each={corpus in corpora} class="row t_{corpus.language_id}">
                <span class="col m7 s12">
                    <b>{corpus.name}</b> ({corpus.language_name})
                    <i class="material-icons link grey-text"
                        if={corpus.status == "COMPILED"}
                        data-tooltip={_("showCorpusDetails")}
                        style="vertical-align: text-bottom;"
                        onclick={onInfoClick}>info_outline</i>
                </span>
                <span  class="col m5 s12 statusColumn">
                    <div class="status">
                        {corpus.status == "CHECKING" ? _("checking") : ""}
                        {corpus.status == "COMPILING" ? _("compiling") : ""}
                        {corpus.status == "COMPILATION_FAILED" ? _("compilation_failed") : ""}
                    </div>
                    <span if={corpus.status == "CHECKING" || corpus.status == "COMPILING"}
                            class="progress">
                        <span class="indeterminate"></span>
                    </span>
                    <span if={corpus.status == "COMPILED"}
                            class="compiledBtns">
                        <a href="#dashboard?corpname={corpus.corpname}"
                                class="btn btn-floating tooltipped t_dashboard"
                                data-tooltip={_("goToCorpusDashboard")}>
                            <i class="material-icons">dashboard</i>
                        </a>
                        &nbsp;
                        <a href="#parconcordance?corpname={corpus.corpname}"
                                class="btn btn-floating tooltipped t_parconcordance"
                                data-tooltip={_("openParconcordance")}>
                            <i class="small ske-icons skeico_parallel_concordance"></i>
                        </a>
                    </span>
                </span>
            </div>
            <div class="row">
                <div class="col hint">
                    <div if={isCompiling}>
                        {_("estimatedTime")}: {_("ca.compilingTime1")}, {_("ca.compilingTime2")}
                    </div>
                </div>
            </div>
            <div class="center-align">
                <a href="#dashboard" id="btnLeave" class="btn">{_("leave")}</a>
                <div class="leaveNote" if={isCompiling}>
                    {_("ca.compileLeaveNote")}
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./page-ca-compile-aligned.scss")
        const {AppStore} = require("core/AppStore.js")
        const {CAStore} = require("./castore.js")
        const {Url} = require("core/url.js")

        this.mixin("tooltip-mixin")

        this.query = Url.getQuery()
        this.isLoading = true
        this.corpora = []
        this.isCompiling = false

        initCorpora(){
            this.corpora = JSON.parse(this.query.corpora).map(corpus_id => {
                let corpus = AppStore.getCorpusById(corpus_id)
                if(corpus){
                    return {
                        id: corpus_id,
                        status: "CHECKING",
                        name: corpus.name,
                        corpname: corpus.corpname,
                        language_id: corpus.language_id,
                        language_name: corpus.language_name
                    }
                }
            })
            this.isLoading = false
            this.update()
            this.startChecking()
        }

        onInfoClick(evt){
            SkE.showCorpusInfo(AppStore.getCorpusById(evt.item.corpus.id).corpname)
        }

        updateCorpusProgress(corpus_id, progress, payload){
            let corpus = this.corpora.find(c => {
                return c.id == corpus_id
            })
            if(this.isMounted){
                this.isCompiling = progress < 100 && progress >= 1
                let status = "COMPILING"
                if(progress == 100){
                    status = "COMPILED"
                } else if (progress == -1){
                    status = "COMPILATION_FAILED"
                    SkE.showError(_("compilation_failed", [corpus.name, payload.result.error]))
                }
                corpus.status = status
                this.update()
            } else{
                // user navigated out of the page -> show toast
                SkE.showToast(_("ca.corpusIsRedy", [corpus.name]))
            }
        }

        startChecking(){
            Dispatcher.on("CA_CORPUS_PROGRESS", this.updateCorpusProgress)
            this.corpora.forEach(corpus => {
                CAStore.checkCorpusStatus(corpus.id)
            })
        }

        if(this.query.corpora){
            if(AppStore.data.corpusListLoaded){
                this.initCorpora()
            } else{
                AppStore.one("corpusListChanged", this.initCorpora)
            }
        }

        this.on("unmount", () => {
            Dispatcher.off("CA_CORPUS_PROGRESS", this.updateCorpusProgress)
        })

        CAStore.updateUrl()
    </script>
</page-ca-compile-aligned>
