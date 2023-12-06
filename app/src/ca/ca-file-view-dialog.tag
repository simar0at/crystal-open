<ca-file-view-dialog>
    <span class="right">
        <ui-select
            name="type"
            label={_("show")}
            inline=1
            options={options}
            riot-value={type}
            on-change={onTypeChange}></ui-select>
    </span>
    <h4>
        {_("viewingFile", [opts.fileName])}
    </h4>
    <div class="clearfix"></div>
    <br>

    <div if={type=="plaintext"} class="t_content {t_loaded: loadedBytes}">
        {content}
    </div>
    <div if={type=="vertical"}>
        <pre class="t_content {t_loaded: loadedBytes}">
            {content}
        </pre>
    </div>
    <div class="grey-text center-align">{getSizeStr(loadedBytes)} / {getSizeStr(totalBytes)}</div>
    <br>

    <div class="center-align" if={start + 1024 < totalBytes}>
        <a href="javascript:void(0);" class="btn" onclick={onLoadMoreClick}>Load more</a>
    </div>


    <script>
        const {CAStore} = require("./castore.js")

        this.type = "plaintext"
        this.content = ""
        this.start = 0
        this.loadedBytes = 0
        this.totalBytes = 0

        this.options = [{
            label: _("plainText"),
            value: "plaintext"
        },{
            label: "Vertical",
            value: "vertical"
        } ]

        load(){
            CAStore.loadFileContent(this.opts.corpus_id, this.opts.file_id, this.type, this.start)
        }
        this.load()

        onLoadMoreClick(){
            this.start += 1024
            this.load()
        }

        onTypeChange(type){
            this.loadedBytes = 0
            this.content = ""
            this.type = type
            this.start = 0
            this.load()
            this.update()
        }

        onFileContentLoaded(content, loadedBytes, totalBytes){
            this.content += content
            this.loadedBytes = loadedBytes
            this.totalBytes = totalBytes
            this.update()
        }

        getSizeStr(size){
            if(size < 1048576){
                return Math.round(size * 10 / 1024) / 10 + "KB"
            }
            return Math.round(size * 10 / 1024 / 1024) / 10 + "MB"
        }

        this.on("mount", () => {
            CAStore.on("fileContentLoaded", this.onFileContentLoaded)
        })

        this.on("unmount", () => {
            CAStore.off("fileContentLoaded", this.onFileContentLoaded)
        })
    </script>
</ca-file-view-dialog>
