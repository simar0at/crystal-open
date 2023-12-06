<ca-bulk-metadata-dialog class="ca-bulk-metadata-dialog">
    <preloader-spinner if={isSaving} center=1 overlay=1></preloader-spinner>
    <div class="hint">
        {_("bulkMetadataNote")}
    </div>
    <br>
    <div class="topBar">
        <ui-filtering-list ref="attribute"
                name="attribute"
                options={attributeList}
                inline=1
                floating-dropdown=1
                label-id="attribute"
                clear-on-focus={false}
                pattern="[a-zA-Z0-9_]+"
                pattern-mismatch-message={_("alphanumAndUnderscoreAllowed")}
                validate=1
                add-not-found=1
                not-found-label={_("attribute")}
                on-input={onAttributeInput}
                on-change={onAttributeChange}></ui-filtering-list>

        <span class="right" if={attribute}>
            <ui-checkbox on-change={onSetToAllChange}
                    name="setToAll"
                    checked={setToAll}
                    inline=1
                    label-id="setToAll"></ui-checkbox>
            <ui-input inline=1
                    name="setToAllValue"
                    disabled={!setToAll}
                    on-input={onValueInput}></ui-input>
        </span>
    </div>


    <table class="table material-table">
        <thead if={files.length}>
            <tr>
                <th>{_("document")}</th>
                <th>
                    {attribute}
                    <div class="subLabel">
                        {attribute ? _("originalValue") : "&nbsp;"}
                    </div>
                </th>
                <th>
                    {attribute}
                    <div class="subLabel">
                        {attribute ? _("newValue") : "&nbsp;"}
                    </div>
                </th>
            </tr>
        </thead>
        <tbody if={files.length}>
            <tr each={file in files}
                    id="t_{window.idEscape(file.name)}">
                <td>{file.name}</td>
                <td>
                    {file.metadata[parent.attribute] ? file.metadata[parent.attribute].oldValue: ""}
                </td>
                <td>
                    <ui-input riot-value={file.metadata[parent.attribute] ? file.metadata[parent.attribute].newValue: ""}
                            name="value"
                            if={attribute}
                            inline=1
                            on-input={onFileValueInput.bind(this, file)}
                            placeholder={_("empty")}></ui-input>
                </td>
            </tr>
        </tbody>
    </table>

    <script>
        require("./ca-bulk-metadata-dialog.scss")
        const {CAStore} = require("./castore.js")

        this.isSaving = false

        updateAttributes(){
            this.files = []
            CAStore.get("files").forEach(file => {
                if(file.selected){
                    let metadata = {}
                    for(let key in file.metadata){
                        metadata[key] = {
                            oldValue: file.metadata[key],
                            newValue: file.metadata[key]
                        }
                    }
                    this.files.push({
                        id: file.id,
                        name: file.filename_display,
                        metadata: metadata
                    })
                }
            }, this)
            this.attributeList = CAStore.getAttributeList()
        }
        this.updateAttributes()

        save(){
            let toSave = this._getDataToSave()
            if(toSave.length){
                CAStore.saveFilesMetadata(this.opts.corpus_id, toSave).xhr
                    .done((payload) => {
                        this.files.forEach(file => {
                            for(let key in file.metadata){
                                file.metadata[key].oldValue = file.metadata[key].newValue
                            }
                        })
                        $("#bulkSaveBtn").addClass("disabled")
                    })
                    .always(() => {
                        this.isSaving = false
                        this.updateAttributes()
                        this.update()
                    })
                this.isSaving = true
                this.update()
            } else{
                $("#bulkSaveBtn").addClass("disabled")
            }
        }

        onAttributeInput(value){
            this.attribute = this.refs.attribute.isValid ? value : ""
            this.update()
        }

        onAttributeChange(value){
            this.onAttributeInput(value)
            $("input", this.refs.attribute.root)[0].value = value
        }

        onValueInput(value){
            this.files.forEach(file => {
                this._setFileValue(file, value)
            }, this)
            this.update()
            $("#bulkSaveBtn").removeClass("disabled")
        }

        onSetToAllChange(checked){
            this.setToAll = checked
            this.update()
        }

        onFileValueInput(file, value){
            this._setFileValue(file, value)
            $("#bulkSaveBtn").removeClass("disabled")
        }

        _getDataToSave(){
            let toSave = []
            this.files.forEach(file => {
                let fileData = {
                    id: file.id,
                    metadata: {}
                }
                for(let key in file.metadata){
                    if(file.metadata[key].newValue !== ""){
                        fileData.metadata[key] = file.metadata[key].newValue
                    }
                    file.metadata[key].oldValue = file.metadata[key].newValue
                }
                toSave.push(fileData)
            })
            return toSave
        }

        _setFileValue(file, value){
            if(!file.metadata[this.attribute]){
                file.metadata[this.attribute] = {
                    oldValue: ""
                }
            }
            file.metadata[this.attribute].newValue = value
        }

        this.on("mount", () => {
            delay(function(){$(".topBar input", this.root).focus()}.bind(this), 0)
        })
    </script>
</ca-bulk-metadata-dialog>
