<ui-input-file class="ui ui-input-file">
    <div class="file-field input-field">
        <div class="btn {opts.btnClass} {disabled: this.opts.disabled}" disabled={this.opts.disabled}>
            <span>
                {_(opts.labelId || "file")}
                <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
            </span>
            <input type="file"
                    ref="input"
                    name={opts.name}
                    accept={opts.accept}
                    multiple={opts.multiple}
                    onchange={onChange}>
        </div>
        <div class="file-path-wrapper {hidden: opts.hideList}">
            <div ref="fileList"></div>
        </div>
    </div>

   <script>
    this.mixin('ui-mixin')

    getValue(){
        return this.refs.input.value
    }

    onChange(evt){
        this.updateFileList()
        if(typeof this.opts.onChange == "function"){
            this.opts.onChange(this.refs.input.files, this.opts.name, evt, this)
        }
        evt.stopPropagation()
    }

    reset(){
        this.refs.input.value = ""
        this.updateFileList()
    }

    updateFileList(){
        let val = ""
        let files = this.refs.input.files
        for(let i = 0; i < files.length; i++){
            val += (val == "" ? "" : ", ") + files[i].name
        }
        this.refs.fileList.innerHTML = val
    }
   </script>
</ui-input-file>
