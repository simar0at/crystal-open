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
                        on-change={onSettingsChange}></ui-filtering-list>
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
                        on-change={onSettingsChange}></ui-filtering-list>
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
    <div class="filePreview {t_loaded: !!preview}">{preview ? preview : _("filePreviewEmpty")}</div>


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

        this.encodingList = [["ascii","ASCII (English)"],["big5","Big5 (Traditional Chinese)"],["big5hkscs","Big5-HKSCS (Traditional Chinese)"],["cp037","CP037 (English)"],["cp1006","CP1006 (Urdu)"],["cp1026","CP1026 (Turkish)"],["cp1140","CP1140 (Western Europe)"],["cp424","CP424  (Hebrew)"],["cp437","CP437 (English)"],["cp500","CP500 (Western Europe)"],["cp737","CP737 (Greek)"],["cp775","CP775 (Baltic languages)"],["cp850","CP850 (Western Europe)"],["cp852","CP852 (Central and Eastern Europe)"],["cp855","CP855 (Bulgarian, Byelorussian, Macedonian, Russian, Serbian)"],["cp856","CP856 (Hebrew)"],["cp857","CP857 (Turkish)"],["cp860","CP860 (Portuguese)"],["cp861","CP861 (Icelandic)"],["cp862","CP862 (Hebrew)"],["cp863","CP863 (Canadian)"],["cp864","CP864 (Arabic)"],["cp865","CP865 (Danish, Norwegian)"],["cp866","CP866 (Russian)"],["cp869","CP869 (Greek)"],["cp874","CP874 (Thai)"],["cp875","CP875 (Greek)"],["cp932","CP932 (Japanese)"],["cp949","CP949 (Korean)"],["cp950","CP950 (Traditional Chinese)"],["euc_jis_2004","EUC-JIS-2004 (Japanese)"],["euc_jp","EUC-JP (Japanese)"],["euc_kr","EUC-KR  (Korean)"],["gb18030","GB 10830 (Unified Chinese)"],["gb2312","GB 2312 (Simplified Chinese)"],["gbk","GBK (Unified Chinese)"],["hz","HZ (Simplified Chinese)"],["iso2022_jp","ISO-2022-JP (Japanese)"],["iso2022_jp_1","ISO-2022-JP-1 (Japanese)"],["iso2022_jp_2","ISO-2022-JP-2 (Japanese, Korean, Simplified Chinese, Western Europe, Greek)"],["iso2022_jp_2004","ISO-2022-JP-2004 (Japanese)"],["iso2022_jp_3","ISO-2022-JP-3 (Japanese)"],["iso2022_jp_ext","ISO-2022-JP-EXT (Japanese)"],["iso2022_kr","ISO-2022-KR (Korean)"],["latin_1","ISO-8859-1 (West Europe)"],["iso8859_10","ISO-8859-10 (Nordic languages)"],["iso8859_11","ISO-8859-11 (Thai)"],["iso8859_13","ISO-8859-13 (Baltic languages)"],["iso8859_14","ISO-8859-14 (Celtic languages)"],["iso8859_15","ISO-8859-15 (Western Europe)"],["iso8859_2","ISO-8859-2 (Central and Eastern Europe)"],["iso8859_3","ISO-8859-3 (Esperanto, Maltese)"],["iso8859_4","ISO-8859-4 (Baltic languagues)"],["iso8859_5","ISO-8859-5 (Bulgarian, Byelorussian, Macedonian, Russian, Serbian)"],["iso8859_6","ISO-8859-6 (Arabic)"],["iso8859_7","ISO-8859-7 (Greek)"],["iso8859_8","ISO-8859-8 (Hebrew)"],["iso8859_9","ISO-8859-9 (Turkish)"],["euc_jisx0213","JIS X 0213 (Japanese)"],["johab","JOHAB (CP1361) (Korean)"],["koi8_r","KOI8-R (Russian)"],["koi8_u","KOI8-U (Ukrainian)"],["mac_latin2","Mac Central European (Central and Eastern Europe)"],["mac_cyrillic","Mac Cyrillic (Bulgarian, Byelorussian, Macedonian, Russian, Serbian)"],["mac_greek","Mac Greek (Greek)"],["mac_iceland","Mac Icelandic (Icelandic)"],["mac_roman","Mac Roman (Western Europe)"],["mac_turkish","Mac Turkish (Turkish)"],["ptcp154","PTCP154 (Kazakh)"],["shift_jis","Shift JIS (Japanese)"],["shift_jis_2004","Shift JIS-2004 (Japanese)"],["shift_jisx0213","Shift JISX0213 (Japanese)"],["utf_16","UTF-16 (all languages)"],["utf_16_be","UTF-16BE (all languages (BMP only))"],["utf_16_le","UTF-16LE (all languages (BMP only))"],["utf_7","UTF-7 (all languages)"],["utf_8","UTF-8 (all languages)"],["utf_8_sig","UTF-8 with BOM (all languages)"],["cp1250","Windows-1250 (Central and Eastern Europe)"],["cp1251","Windows-1251 (Bulgarian, Byelorussian, Macedonian, Russian, Serbian)"],["cp1252","Windows-1252 (Western Europe)"],["cp1253","Windows-1253 (Greek)"],["cp1254","Windows-1254 (Turkish)"],["cp1255","Windows-1255 (Hebrew)"],["cp1256","Windows-1256 (Arabic)"],["cp1257","Windows-1257 (Baltic languages)"],["cp1258","Windows-1258 (Vietnamese)"]]
                .map(e => {
                        return {
                            value: e[0],
                            label: e[1]
                        }
                    })
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

        this.on("mount", () => {
            CAStore.on("filePreviewLoaded", this.onFilePreviewLoaded)
            CAStore.on("filePreviewLoadFail", this.filePreviewLoadFailed)
        })

        this.on("unmount", () => {
            CAStore.off("filePreviewLoaded", this.onFilePreviewLoaded)
            CAStore.off("filePreviewLoadFail", this.filePreviewLoadFailed)
        })
    </script>
</ca-file-preview-dialog>
