<ca-file-preview-dialog class="ca-file-preview-dialog">
    <preloader-spinner if={isLoading} overlay=1></preloader-spinner>
    <div if={encodingList.length}>
        <div class="columnForm">
            <div class="row">
                <label class="col s12 m3">
                    {_("fileType")}
                </label>
                <span class="col s12 m8">
                    <ui-filtering-list
                        options={fileTypeList}
                        name="type"
                        constrainWidth={false}
                        riot-value={parameters.type}
                        style="max-width: 500px;"
                        floating-dropdown=1
                        value-in-search=1
                        open-on-focus=1
                        on-change={onSettingsChange}
                        deselect-on-click={false}></ui-filtering-list>
                </span>
            </div>
            <div class="row" if={!file.isArchive}>
                <label class="col s12 m3">
                    {_("encodings")}
                </label>
                <span class="col s12 m8">
                    <ui-filtering-list
                        options={encodingList}
                        name="encoding"
                        constrainWidth={false}
                        riot-value={parameters.encoding}
                        style="max-width: 500px;"
                        floating-dropdown=1
                        value-in-search=1
                        open-on-focus=1
                        on-change={onSettingsChange}
                        deselect-on-click={false}></ui-filtering-list>
                        <div class="fieldHelp">
                            {_("encodingsHelp")}
                        </div>
                </span>
            </div>
            <div class="row" if={parameters.type == "vert"} each={attr, idx in static_attributes}>
                <label class="col s12 m3">
                    {attr} {_("attributeColumn")}
                </label>
                <span class="col s12 m8">
                    <ui-input inline=1
                            type="number"
                            min=1
                            riot-value={parameters.permutation[idx] + 1}
                            on-change={onPermutationChange.bind(this, idx)}></ui-select>
                </span>
            </div>
            <div class="row" if={parameters.type == "tmx" || parameters.type == "xlf" || parameters.type == "xls"}>
                <label class="col s12 m3">
                    {_("tmxXliff")}
                </label>
                <span class="col s12 m8">
                    <ui-input
                        name="tmx_lang"
                        style="max-width: 100px;"
                        riot-value={parameters.tmx_lang}
                        on-change={onSettingsChange}></ui-input>
                        <div class="fieldHelp">
                            {_("tmxXliffHelp")}
                        </div>
                </span>
            </div>
            <div class="row" if={parameters.type == "tmx" || parameters.type == "xlf" || parameters.type == "xls"}>
                <label class="col s12 m3">
                    {_("segmentStructure")}
                </label>
                <span class="col s12 m8">
                    <ui-input
                        name="tmx_struct"
                        riot-value={parameters.tmx_struct}
                        style="max-width: 200px;"
                        on-change={onSettingsChange}></ui-input>
                        <div class="fieldHelp">
                            {_("segmentStructureHelp")}
                        </div>
                </span>
            </div>
            <div class="row" if={parameters.type == "tmx" || parameters.type == "xlf" || parameters.type == "xls"}>
                <label class="col s12 m3">
                    {_("untranslatedToken")}
                </label>
                <span class="col s12 m8">
                    <ui-input
                        name="tmx_untranslated"
                        riot-value={parameters.tmx_untranslated}
                        style="max-width: 200px;"
                        on-change={onSettingsChange}></ui-input>
                        <div class="fieldHelp">
                            {_("untranslatedTokenHelp")}
                        </div>
                </span>
            </div>
        </div>
    </div>
    <div class="filePreview">{preview ? preview : _("filePreviewEmpty")}</div>


    <script>
        require("./ca-file-preview-dialog.scss")
        const {CAStore} = require("./castore.js")

        this.files = this.opts.files
        this.fileIndex = this.opts.files.findIndex(f => {
            return f.id == this.opts.file_id
        })
        this.file = this.files[this.fileIndex]
        this.parameters = this.file.parameters
        this.preview = ""
        this.isLoading = true
        this.static_attributes = CAStore.data.tagset.static_attributes

        this.encodingList = []
        this.fileTypeList = [
            ['vert', 'Vertical file'],
            ['txt',  'Plain text'],
            ['html', 'HTML'],
            ['doc',  'Microsoft Word (.doc)'],
            ['docx', 'Microsoft Word XML (.docx)'],
            ['pdf',  'PDF'],
            ['xml',  'XML file'],
            ['tei',  'TEI XML file'],
            ['tmx',  'Translation Memory eXchange'],
            ['xlf',  'Localization file exchange format'],
            ['xls',  'Spreadsheet'],
            ['zip',  'Zip Archive'],
            ['tar',  'Tar Archive']
        ].map(item => {
            return {
                value: item[0],
                label: item[1]
            }
        })
        this.columnList = []
        for(let i = 0; i <= 11; i++){
            this.columnList.push({
                value: i,
                label: _("column") + " " + i
            })
        }

        CAStore.loadFileEncodings()

        load(){
            CAStore.loadFilePreview(this.opts.corpus_id, this.file.id, this.parameters)
        }
        this.load()

        reload(){
            this.isLoading =  true
            this.update()
            this.load()
        }

        onSettingsChange(value, name){
            this.parameters[name] = value
            this.reload()
        }

        onPermutationChange(idx, value){
            this.parameters.permutation[idx] = value - 1
            this.reload()
        }

        onFilePreviewLoaded(file_id, preview){
            this.preview = preview
            this.isLoading = false
            this.update()
        }

        filePreviewLoadFailed(){
            this.isLoading = false
            this.update()
        }

        onFileEncodingsLoaded(encodings){
            this.encodingList = encodings.sort((a, b) => {
                return a.name.localeCompare(b.name)
            }).map(e => {
                return {
                    value: e.id,
                    label: e.name
                }
            })
            this.update()
        }

        this.on("mount", () => {
            CAStore.on("filePreviewLoaded", this.onFilePreviewLoaded)
            CAStore.on("fileEncodingsLoaded", this.onFileEncodingsLoaded)
            CAStore.on("filePreviewLoadFail", this.filePreviewLoadFailed)
        })

        this.on("unmount", () => {
            CAStore.off("filePreviewLoaded", this.onFilePreviewLoaded)
            CAStore.off("fileEncodingsLoaded", this.onFileEncodingsLoaded)
            CAStore.off("filePreviewLoadFail", this.filePreviewLoadFailed)
        })
    </script>
</ca-file-preview-dialog>
