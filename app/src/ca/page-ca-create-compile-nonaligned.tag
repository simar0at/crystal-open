<page-ca-create-compile-nonaligned class="ca-create-compile-nonaligned ca">
   <ca-breadcrumbs active="ca-compile-aligned" section="createMultiNonAligned"></ca-breadcrumbs>
   <div if={isLoading}
         class="centerSpinner">
      <preloader-spinner></preloader-spinner>
   </div>
   <div if={!isLoading && !corpora.length}>
      <div class="primaryButtons">
         {_("somethingWentWrong")}
         <a href="#dashboard"
               class="btn btn-primary">{_("goToDashboard")}</a>
      </div>
   </div>

   <div if={corpora.length}
         class="columnWrapper">
      <div class="card-panel">
         <div if={status != "done"}>
            <div class="status center-align">
               <h4>{_(status)}</h4>
               <div if={error}>{error}</div>
            </div>
            <span class="progress">
               <span class="indeterminate"></span>
            </span>
         </div>
         <div if={status == "done"}>
            <div class="center-align mb-12">
               <h4>{_("corporaReady")}</h4>
            </div>
            <div each={corpus in corpora}
                  class="row corpusRow t_{corpus.language_id}">
               <span class="col m7 s12">
                  <b>{corpus.name}</b>
                  <span class="grey-text">({corpus.language_name})</span>
                  <i class="material-icons link grey-text infoIcon"
                        data-tooltip={_("showCorpusDetails")}
                        onclick={onInfoClick}>info_outline</i>
               </span>
               <span  class="col m5 s12 statusColumn right-align">
                  <span class="compiledBtns">
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
         </div>
         <div if={status != "done"}
               class="hint center-align">
            {_("estimatedTime")}: {_("ca.compilingTime1")}, {_("ca.compilingTime2")}
         </div>
         <div if={finalCompilation}
               class="center-align">
            <a href="#dashboard"
                  id="btnLeave"
                  class="btn mt-10">{_("leave")}</a>
            <div if={status != "done"}
                  class="leaveNote">
               {_("ca.compileLeaveNote")}
            </div>
         </div>
      </div>
   </div>

   <script>
      require("./page-ca-compile-nonaligned.scss")
      const {Connection} = require('core/Connection.js')
      const {AppStore} = require("core/AppStore.js")
      const {CAStore} = require("./castore.js")
      const {Url} = require("core/url.js")

      this.mixin("tooltip-mixin")

      this.query = Url.getQuery()
      this.isLoading = true
      this.corpora = []
      this.checking = true
      this.status = "checking"

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
         SkE.showCorpusInfo(evt.item.corpus.corpname)
      }

      alignCorpora() {
         Connection.get({
            url: window.config.URL_CA + "corpora/align",
            xhrParams: {
               method: 'POST',
               data: JSON.stringify({
                 corpus_ids: [this.corpora[0].id, this.corpora[1].id],
                 auto: true,
                 alignstruct: "s"
               }),
               contentType: "application/json"
            },
            done: payload => {
               this.compileAligned()
            }
         }).xhr
         this.status = "aligning"
     }

     compileAligned() {
         Connection.get({
            url: window.config.URL_CA + "corpora/compile_aligned",
            xhrParams: {
               method: 'POST',
               data: JSON.stringify({
                 corpus_ids: [this.corpora[0].id, this.corpora[1].id]
               }),
               contentType: "application/json"
            },
            always: payload => {
               this.finalCompilation = true
               this.update()
               this.startChecking()
            }
         }).xhr
         this.status = "compiling"
      }

      updateCorpusProgress(corpus_id, progress, payload){
         let corpus = this.corpora.find(c => {
            return c.id == corpus_id
         })
         if(this.checking) {
            if(progress == 0 || progress == 100){
               corpus.status = "READY"
            } else if(progress == -1){
               this.status = "COMPILATION_FAILED"
               this.error = _("compilation_failed", [corpus.name, payload.result.error])
            }

            if(this.corpora[0].status == "ERROR" && this.corpora[1].status == "ERROR"){
               this.status = "error"
               this.checking = false
            } else if(this.corpora[0].status == "READY" && this.corpora[1].status == "READY"){
               this.checking = false
               this.alignOnceReady = true
               this.status = "compiling"
               CAStore.compileCorpus(this.corpora[0].id, {structures: "all"})
               CAStore.compileCorpus(this.corpora[1].id, {structures: "all"})
               this.corpora[0].status = "COMPILING"
               this.corpora[1].status = "COMPILING"
               this.update()
            }
         } else {
            let status = "COMPILING"
            if(progress == 100){
               status = "COMPILED"
               if(!this.isMounted && this.finalCompilation){
                  // user navigated out of the page -> show toast
                  SkE.showToast(_("ca.corpusIsRedy", [corpus.name]))
               }
            } else if (progress == -1){
               status = "COMPILATION_FAILED"
               SkE.showError(_("compilation_failed", [corpus.name, payload.result.error]))
            }
            corpus.status = status
            if(this.corpora[0].status == "COMPILED" && this.corpora[1].status == "COMPILED"){
               if(this.alignOnceReady){
                  this.alignOnceReady = false
                  this.alignCorpora()
               } else if(this.finalCompilation){
                  this.status = "done"
               }
            }
            this.update()
         }
      }

      startChecking(){
         CAStore.checkCorpusStatus(this.corpora[0].id)
         CAStore.checkCorpusStatus(this.corpora[1].id)
      }

      if(this.query.corpora){
         if(AppStore.data.corpusListLoaded){
            this.initCorpora()
         } else{
            AppStore.one("corpusListChanged", this.initCorpora)
         }
      }

      this.on("mount", () => {
         Dispatcher.on("CA_CORPUS_PROGRESS", this.updateCorpusProgress)
      })

      this.on("unmount", () => {
         Dispatcher.off("CA_CORPUS_PROGRESS", this.updateCorpusProgress)
      })

      CAStore.updateUrl()
   </script>
</page-ca-create-compile-nonaligned>
