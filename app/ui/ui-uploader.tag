<ui-uploader class="ui ui-uploader {opts.class}">
    <form class="box">
        <div class="input">
            <i class="material-icons icon">cloud_upload</i>
            <input type="file"
                    id="file"
                    name="files[]"
                    class="file"
                    data-multiple-caption="{count} files selected"
                    multiple
                    accept={opts.accept}/>
            <label for="file">
                <div class="text">
                    <span class="choosefile">{_("ui.chooseFile")}</span>
                    <span class="dragndrop">{_("ui.orDnD")}</span>.
                    <div if={opts.maxFiles} class="maxFiles">
                        {_("uploadFilesCountLimit", [opts.maxFiles])}
                    </div>
                    <div if={opts.maxFileSize} class="maxFiles">
                        {_("uploadFilesSizeLimit", [opts.maxFileSize])}
                    </div>
                </div>
            </label>
        </div>
        <div class="uploading">
            {_("ui.uploading")}
        </div>
        <div class="limitWarning">
            <h5>{_("ui.limitExceeded")}</h5>
            <div>
                <div if={opts.maxFiles}>
                    {_("ui.tooManyFilesDesc", [opts.maxFiles])}
                </div>
                <div if={opts.maxFileSize}>
                    {_("ui.tooLargeFileDesc", [opts.maxFileSize])}
                </div>
                <br>
                <a class="btn btn-flat" onclick={onCloseWarningClick}>
                    {_("close")}
                    <i class="material-icons right">close</i>
                </a>
            </div>
        </div>
    </form>

    <script>
        let self = this

        this.allowedFileTypes = []
        if(this.opts.accept){
            this.allowedFileTypes = this.opts.accept.split(",").map(t => {
                return t.trim().toLowerCase().replace(".", "")
            })
        }

        onComplete(){
            $('form', this.root).removeClass('is-uploading')
        }

        onCloseWarningClick(evt){
            evt.preventUpdate = true
            $(self.root).removeClass("showWarning")
        }

        this.on("mount", () => {
            let form = $('form', this.root)
            let input = form.find('input[type="file"]')
            let droppedFiles = false

            // automatically submit the form on file select
            input.on('change', function(e) {
                form.trigger('submit')
            })


            form.on('drag dragstart dragend dragover dragenter dragleave drop', function(e){
                    e.preventDefault()
                    e.stopPropagation()
                }).on('dragover dragenter', function() {
                    form.addClass('is-dragover')
                }).on('dragleave dragend drop', function(){
                    form.removeClass('is-dragover')
                }).on('drop', function(e){
                    droppedFiles = []
                    for(let i = 0; i < e.originalEvent.dataTransfer.files.length; i++){
                        let f = e.originalEvent.dataTransfer.files[i]
                        let fileType = f.name.split(".").pop().toLowerCase()
                        this.allowedFileTypes.includes(fileType) && droppedFiles.push(f)
                    }

                    if(droppedFiles.length){
                        form.trigger('submit') // automatically submit the form on file drop
                    } else{
                        SkE.showToast(_("uploaderWrongFileType", [this.opts.accept]))
                    }
                }.bind(this))

            form.on('submit', function(e){
                // preventing the duplicate submissions if the current one is in progress
                if(form.hasClass('is-uploading')) return false
                e.preventDefault()
                let formFiles = form.find("input[type=file]")[0].files
                if(self.opts.maxFiles && (parseInt(self.opts.maxFiles, 10) < formFiles.length)){
                    $(self.root).addClass("showWarning")
                    return
                }
                if(self.opts.maxFileSize){
                    for(let i = 0; i < formFiles.length; i++){
                        if(formFiles[i].size / 1024 / 1024 > self.opts.maxFileSize){
                            $(self.root).addClass("showWarning")
                            return
                        }
                    }
                }
                let files = []
                form.addClass('is-uploading')
                for(let i = 0; i < formFiles.length; i++){
                    files.push(formFiles.item(i))
                }
                if(droppedFiles){
                    files = files.concat(droppedFiles)
                }
                self.opts.onAdd(files, function() {
                    // on complete
                    form.removeClass('is-uploading')
                })

                // Firefox focus bug fix for file input
                input.on('focus', function(){ input.addClass('has-focus') })
                    .on('blur', function(){ input.removeClass('has-focus') })
            })
        })
    </script>
</ui-uploader>
