<ca-file-metadata-dialog class="ca-file-metadata-dialog">
    <preloader-spinner if={isSaving} center=1 overlay=1></preloader-spinner>
    <div class="hint" if={opts.fileName}>
        {opts.fileName}
    </div>

    <br>
    <table class="table material-table highlight">
        <thead>
            <tr>
                <th>{_("attribute")}</th>
                <th>{_("value")}</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <tr each={item, idx in metadata} class="t_{item.name}">
                <td>
                    <ui-filtering-list ref="name_{idx}"
                            name="name"
                            options={attributeList}
                            inline=1
                            riot-value={item.name}
                            floating-dropdown=1
                            clear-on-focus={false}
                            open-on-focus=1
                            add-not-found=1
                            not-found-label={_("attribute")}
                            validate=1
                            pattern="[a-zA-Z0-9_]+"
                            pattern-mismatch-message={_("alphanumAndUnderscoreAllowed")}
                            list-size=3
                            on-input={onNameInput.bind(this, idx)}
                            on-change={onNameChanged.bind(this, idx)}
                            style="margin-right: 20px;"></ui-filtering-input>
                </td>
                <td>
                    <ui-input name="value"
                            inline=1
                            on-input={onValueChanged}
                            value={item.value}></ui-input>
                </td>
                <td>
                    <i class="material-icons material-clickable t_removeAttribute" onclick={onRemoveRowClick}>delete_forever</i>
                </td>
            </tr>
        </tbody>
    </table>
    <br>
    <div class="center">
        <a href="javascript:void(0);"
                id="btnAddAttribute"
                class="btn btn-floating"
                onclick={onAddRow}>
            <i class="material-icons">add</i>
        </a>
    </div>

    <script>
        require("./ca-file-metadata-dialog.scss")
        const {CAStore} = require("./castore.js")

        this.isSaving = false
        this.attributeList = CAStore.getAttributeList()

        save(){
            CAStore.saveFilesMetadata(this.opts.corpus_id, this._getDataToSave()).xhr
                    .done(payload => {
                        Dispatcher.trigger("closeDialog", "editMetadata")
                    })
                    .fail(payload => {
                        SkE.showError(_("couldNotUpdateFile", [payload.error || JSON.parse(payload.responseText).error]))
                    })
        }

        onRemoveRowClick(evt){
            this.metadata.splice(evt.item.idx, 1)
        }

        onAddRow(evt){
            this.metadata.push({
                name: "",
                value: ""
            })
        }

        onNameInput(idx, value){
            this.metadata[idx].name = value
            this._refreshBtnDisabled()
        }

        onNameChanged(idx, value, name, label, option, evt){
            this.metadata[idx].name = value
            this._refreshBtnDisabled()
            $(evt.target).closest(".ui-filtering-list").find("input").val(value)
        }

        onValueChanged(value, name, evt){
            this.metadata[evt.item.idx].value = value
            this._refreshBtnDisabled()
        }

        _refreshBtnDisabled(){
            let disabled = this.metadata.some((m, idx) => {
                let input = this.refs["name_" + idx].refs.input
                input.validate()
                return m.name === "" || m.value === "" || !input.isValid
            }, this)
            $("#fileSaveBtn").toggleClass("disabled", disabled)
        }

        _getDataToSave(){
            return this.opts.file_ids.map(file_id => {
                let metadata = {}
                this.metadata.forEach(m => {
                    metadata[m.name] = m.value
                })
                return {
                    id: file_id,
                    metadata: metadata
                }
            }, this)
        }

        this.metadata = []
        for(let key in this.opts.metadata){
            this.metadata.push({
                name: key,
                value: this.opts.metadata[key]
            })
        }

        !this.metadata.length && this.onAddRow()

        this.on("updated", this._refreshBtnDisabled)
        this.on("mount", this._refreshBtnDisabled)
    </script>

</ca-file-metadata-dialog>
