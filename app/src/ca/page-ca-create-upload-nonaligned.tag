<page-ca-create-upload-nonaligned class="page-ca-create-upload-nonaligned ca">
   <ca-breadcrumbs active="ca-create-upload-nonaligned" section="createMultiNonAligned"></ca-breadcrumbs>

   <div class="contentCard card-panel">
      <div class="row mb-4">
         <div class="col m6">
            <ui-filtering-list options={languageList}
                  name="language1"
                  floating-dropdown={true}
                  label-id="language1"
                  riot-value={language1}
                  value-in-search=1
                  open-on-focus=1
                  on-change={onLanguageChange.bind(this, 1)}></ui-filtering-list>
         </div>
         <div class="col m6">
            <ui-filtering-list options={languageList}
                  name="language2"
                  floating-dropdown={true}
                  label-id="language2"
                  riot-value={language2}
                  value-in-search=1
                  open-on-focus=1
                  on-change={onLanguageChange.bind(this, 2)}></ui-filtering-list>
         </div>
      </div>
      <div class="row">
         <div class="col m6">
            <ui-input name="corpname1"
                  label-id="corpusName1"
                  riot-value={corpname1}
                  on-input={onCorpnameInput}></ui-input>
         </div>
         <div class="col m6">
            <ui-input name="corpname2"
                  label-id="corpusName2"
                  riot-value={corpname2}
                  on-input={onCorpnameInput}></ui-input>
         </div>
      </div>

      <div class="row">
         <div class="col m12 center-align mt-10">
            <button id="btnConfirm"
                  class="btn btn-primary {disabled: isBussy || corpus1 || corpus2 || !language1 || !language2 || !corpname1 || !corpname2}"
                  onclick={onConfirmClick}>{_("confirm")}</button>
            <button id="btnReset"
                  class="btn {disabled: isBussy || (!corpus1 && !corpus2)}"
                  onclick={onResetClick}>{_("reset")}</button>
         </div>
      </div>

      <div if={(corpus1 && corpus2) || isBussy}
            class="corporaRow row mt-10">
         <preloader-spinner if={isBussy} center=1></preloader-spinner>
         <virtual if={!isBussy}>
            <div class="col m6">
               <ui-uploader id="upl1"
                     name="upload1"
                     accept=".doc,.docx,.htm,.html,.pdf,.txt"
                     note={_("nonAlignedUploaderFileTypes")}
                     on-add={onFileAdd.bind(this, 1)}></ui-uploader>

               <table if={uploadedFiles1.length}
                     class="uploadedFiles material-table highlight ml-2">
                  <thead>
                     <tr>
                        <th>{_("uploadedFiles")}</th>
                        <th></th>
                     </tr>
                  </thead>
                  <tr each={file in uploadedFiles1}>
                     <td>
                        {file.filename_display}
                     </td>
                     <td>
                        <div if={file.status != "ready"}
                              class="progress">
                        <div class="indeterminate"></div>
                        </div>
                        <i if={file.status == "ready"}
                              class="material-icons material-clickable"
                              onclick={onFileDelete.bind(this, 1 , file.id)}>delete</i>
                     </td>
                  </tr>
               </table>
            </div>


            <div class="col m6">
               <ui-uploader id="upl2"
                     name="upload2"
                     accept=".doc,.docx,.htm,.html,.pdf,.txt"
                     note={_("nonAlignedUploaderFileTypes")}
                     on-add={onFileAdd.bind(this, 2)}></ui-uploader>
               <table if={uploadedFiles2.length}
                     class="uploadedFiles material-table highlight ml-2">
                  <thead>
                     <tr>
                        <th>{_("uploadedFiles")}</th>
                        <th></th>
                     </tr>
                  </thead>
                  <tr each={file in uploadedFiles2}>
                     <td>
                        {file.filename_display}
                     </td>
                     <td>
                        <div if={file.status != "ready"}
                              class="progress">
                        <div class="indeterminate"></div>
                        </div>
                        <i if={file.status == "ready"}
                              class="material-icons material-clickable"
                              onclick={onFileDelete.bind(this, 2 , file.id)}>delete</i>
                     </td>
                  </tr>
               </table>
            </div>

         </virtual>
      </div>
   </div>

   <div if={uploadedFiles1.length && uploadedFiles2.length && (uploadedFiles1.length != uploadedFiles2.length)}
         class="red-text">
      {_("fileCountMustBeTheSame")}
   </div>

   <div class="buttons primaryButtons mt-10">
     <a href="#ca-create-alignment"
         id="btnBack"
         class="btn btn-flat color-blue-800">{_("back")}</a>
     <a href="javascript:void(0)"
         ref="btnNext"
         id="btnNext"
         class="btn btn-primary {disabled: isNextDisabled}"
         onclick={onNextClick}>{_("next")}</a>
   </div>


   <script>
      require("./page-ca-create-upload-nonaligned.scss")

      const {Connection} = require('core/Connection.js')
      const {AppStore} = require("core/AppStore.js")
      const {CAStore} = require("ca/castore.js")

      this.corpus1 = null
      this.corpus2 = null
      this.uploadedFiles1 = []
      this.uploadedFiles2 = []
      this.languageList = AppStore.get("availableLanguageList").map(l => {
          return {
              value: l.id,
              label: l.name
          }
      })

      this.on("mount", () => {
         Dispatcher.on("CORPUS_DELETED", this.update)
      })

      this.on("update", () => {
         this.isNextDisabled = this.isBussy
            || !this.uploadedFiles1.length
            || !this.uploadedFiles2.length
            || this.uploadedFiles1.length != this.uploadedFiles2.length
            || this.uploadedFiles1.some(f => f.status != "ready")
            || this.uploadedFiles2.some(f => f.status != "ready")
      })

      this.on("unmount", () => {
         Dispatcher.off("CORPUS_DELETED", this.update)
      })

      onLanguageChange(idx, language, name, label){
         let corpusname = CAStore.data.newCorpusName || "new corpus"
         let languageName = language == "select" ? "" : label
         this[`language${idx}`] = language
         this[`corpname${idx}`] = `${corpusname}, ${languageName}`
         this.update()
      }

      onCorpnameInput(value, name){
         this[name] = value
         this.update()
      }

      onConfirmClick(){
         this.isBussy = 2
         this.update()
         let onDone = (idx, response) => {
            this.isBussy--
            this[`corpus${idx}`] = response.data
            this[`uploadedFiles${idx}`] = []
            this.update()
         }
         CAStore.createCorpus(this.corpname1, this.language1)
               .always(onDone.bind(this, 1))
         CAStore.createCorpus(this.corpname2, this.language2)
               .always(onDone.bind(this, 2))
      }

      onResetClick(){
         let onDone = (idx, response) => {
            this.isBussy--
            this.update()
         }
         this.isBussy = (!!this.corpus1 * 1) + (!!this.corpus2 * 1)
         this.corpus1 && this.deleteCorpus(this.corpus1.id).always(onDone.bind(this))
         this.corpus2 && this.deleteCorpus(this.corpus2.id).always(onDone.bind(this))
         this.corpus1 = null
         this.corpus2 = null
         this.uploadedFiles1 = []
         this.uploadedFiles2 = []
         this.update()
      }

      onFileAdd(idx, files, onUploadComplete){
         this[`filesToUpload${idx}`] = files
         this[`filesUploadComplete${idx}`] = onUploadComplete
         this.uploadNextFile(idx)
      }

      onFileDelete(idx, fileId, evt){
         evt.target.classList.add("disabled")
         Connection.get({
            url: window.config.URL_CA + "corpora/" + this[`corpus${idx}`].id + "/documents/" + fileId,
            xhrParams:{method: "DELETE"},
            done: function(idx, fileId){
               this[`uploadedFiles${idx}`] = this[`uploadedFiles${idx}`].filter(f => f.id != fileId)
               this.update()
            }.bind(this, idx, fileId),
            fail: () => {
            }
        })
      }

      onNextClick(){
         AppStore.loadCorpusList()
         Dispatcher.trigger("ROUTER_GO_TO", "ca-create-compile-nonaligned", {
            corpora: JSON.stringify([this.corpus1.id, this.corpus2.id])
         })
      }

      uploadNextFile(idx){
         let files = this[`filesToUpload${idx}`]
         let corpus = this[`corpus${idx}`]
         if(files.length){
            let delayTime = files.length > 10 ? 1500 : 0
            delay(function(idx){
               let formData = new FormData()
               formData.append("file", this[`filesToUpload${idx}`].pop())
               Connection.get({
                    url: window.config.URL_CA + "corpora/" + corpus.id + "/documents?wait_with_tagging=1",
                    xhrParams: {
                        method: "POST",
                        processData: false,
                        contentType: false,
                        data: formData
                    },
                    done: payload => {
                        payload.data.status = "checking"
                        this[`uploadedFiles${idx}`].push(payload.data)
                        this.updateFileParameters(this[`corpus${idx}`].id, payload.data)
                        this.update()
                    },
                    always: payload => {
                        let error = payload.responseJSON && payload.responseJSON.error
                        if(!payload.data || error){
                            if(error == "QUOTA_EXCEEDED"){
                                Dispatcher.trigger("openDialog", {
                                    title: _("allSpaceUsed"),
                                    tag: "ca-space-dialog"
                                })
                            } else if(error == "DAILY_TAGGING_EXCEEDED"){
                                Dispatcher.trigger("openDialog", {
                                    tag: "external-text",
                                    opts: {text: "daily_tagging_exceeded.html"}
                                })
                            }
                            this[`filesToUpload${idx}`] = []
                            this.onFilesUploadFinished(idx)
                        } else{
                            this.uploadNextFile(idx)
                        }
                    },
               })
            }.bind(this, idx, delayTime))
         } else{
            this.onFilesUploadFinished(idx)
         }
      }

      onFilesUploadFinished(idx){
         this[`filesUploadComplete${idx}`]()
      }

      updateFileParameters(corpus_id, file) {
         file.parameters.auto_paragraphs = "p"
         Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file.id,
            xhrParams: {
               method: 'PUT',
               contentType: "application/json",
               data: JSON.stringify({
                  parameters: file.parameters
               })
            },
            done: function(corpus_id, file){
               CAStore.startFileChecking(corpus_id, file.id, function(payload){
                  file.status = "ready"
                  this.update()
               }.bind(this, corpus_id, file))
            }.bind(this, corpus_id, file)
        })
      }

      deleteCorpus(corpus_id){
         return Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id,
            xhrParams: {
                method: 'DELETE',
            }
        }).xhr
      }

      refreshLanguageList(){
         this.languageList = AppStore.data.languageList.map(l => {
             return {
                 value: l.id,
                 label: l.name
             }
         })
         this.languageList.unshift({
             value: "select",
             label: _("selectValue")
         })
      }
      this.refreshLanguageList()

      AppStore.on('languageListLoaded', () => {
         this.refreshLanguageList()
         this.update()
      })

   </script>
</page-ca-create-upload-nonaligned>
