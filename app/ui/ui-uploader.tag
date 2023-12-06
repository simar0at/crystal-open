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
        this.allowedFileTypes = []
        this.droppedFiles = []
        this.isUploading = false
        if(this.opts.accept){
            this.allowedFileTypes = this.opts.accept.split(",").map(t => {
                return t.trim().toLowerCase().replace(".", "")
            })
        }

        onComplete(){
            this.setUploading(false)
        }

        onCloseWarningClick(evt){
            evt.preventUpdate = true
            this.toggleWarning(false)
        }

        setUploading(isUploading){
            this.isUploading = isUploading
            $('form', this.root).toggleClass('is-uploading', this.isUploading)
        }

        toggleWarning(showWarning){
            $(this.root).toggleClass("showWarning", showWarning)
        }

        resetForm(){
            this.droppedFiles = []
            $('form input[type="file"]', this.root)[0].value = ""
        }

        this.on("mount", () => {
            let form = $('form', this.root)
            let input = form.find('input[type="file"]')
            this.droppedFiles = []

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
                    this.droppedFiles = []
                    for(let i = 0; i < e.originalEvent.dataTransfer.files.length; i++){
                        let f = e.originalEvent.dataTransfer.files[i]
                        let fileType = f.name.split(".").pop().toLowerCase()
                        this.allowedFileTypes.includes(fileType) && this.droppedFiles.push(f)
                    }

                    if(this.droppedFiles.length){
                        form.trigger('submit') // automatically submit the form on file drop
                    } else{
                        SkE.showToast(_("uploaderWrongFileType", [this.opts.accept]))
                    }
                }.bind(this))

            form.on('submit', function(e){
                // preventing the duplicate submissions if the current one is in progress
                if(this.isUploading){
                    return false
                }
                e.preventDefault()
                let files = [...form.find("input[type=file]")[0].files].concat(this.droppedFiles)
                let filesValid = true
                if((this.opts.maxFiles && (parseInt(this.opts.maxFiles, 10) < files.length))
                    || (this.opts.maxFileSize && files.some(file => file.size / 1024 /1024 > this.opts.maxFileSize))){
                    this.toggleWarning(true)
                    this.setUploading(false)
                    this.resetForm()
                    return
                }
                this.setUploading(true)

                this.opts.onAdd(files, this.setUploading.bind(this, false))

                // Firefox focus bug fix for file input
                input.on('focus', function(){ input.addClass('has-focus') })
                    .on('blur', function(){ input.removeClass('has-focus') })
            }.bind(this))
        })
    </script>
</ui-uploader>
