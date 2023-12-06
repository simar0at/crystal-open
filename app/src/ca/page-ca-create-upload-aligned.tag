<page-ca-create-upload-aligned class="page-ca-create-upload-aligned ca">
   <ca-breadcrumbs active="ca-create-upload-aligned" section="createMultiAligned"></ca-breadcrumbs>

   <div class="uploaderCard card-panel">
      <ui-uploader accept=".tmx,.xliff,.xlf,.xls,.xlsx,.zip"
            max-files=1
            class="mb-0"
            on-add={onAdd}
            note={_("alignedUploaderFileTypes")}></ui-uploader>
   </div>
   <br>
   <div class="buttons primaryButtons">
      <a href="#ca-create-alignment"
            id="btnBack"
            class="btn btn-flat color-blue-800">{_("back")}</a>
   </div>

   <script>
      require("./page-ca-create-upload-aligned.scss")
      const {CAStore} = require("./castore.js")

      this.on("mount", () => {
         if(!CAStore.data.newCorpusName){
            SkE.showToast(_("selectCorpusFirst"))
            Dispatcher.trigger("ROUTER_GO_TO", "ca-create")
         }
      })

      onAdd(files){
         CAStore.uploadAlignedDataFile(files[0]).xhr
               .done(function(payload){
                  if(payload.data.id){
                        Dispatcher.trigger("ROUTER_GO_TO",
                           "ca-settings-aligned",  {
                           somefile_id: payload.data.id,
                           corpusname: CAStore.data.newCorpusName
                        })
                  }
                }.bind(this))
               .fail(xhr => {
                   SkE.showError(_("err.uploadAlignedDataFailed") + xhr.responseJSON.error)
               })
           $(".btnNext", this.root).addClass("disabled")
      }
   </script>
</page-ca-create-upload-aligned>
