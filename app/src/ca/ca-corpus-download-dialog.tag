<ca-corpus-download-dialog class="ca-corpus-download-dialog">
    <virtual if={corpus.id === null}>
        <raw-html content={_("ca.downloadDialogText", ['<a href="mailto:inquiries@sketchengine.eu" target="_blank">inquiries@sketchengine.eu</a>',
                '<a href="' + externalLink('serviceRequest') + '" target="_blank">' + _("ca.downloadDialogLink1") + '</a>'])}></raw-html>
        <br><br>
        <small class="grey-text">
            {_("ca.downloadDialogNote")}
        </small>
    </virtual>

    <virtual if={corpus.id !== null}>
        <div class="downloadBtns center-align">
            <a href={linkPrefix + "?format=txt" + fileStructure}
                    class="cardBtn card-panel"
                    onclick={onLinkClick}>
                <span class="iconContainer">
                    <i class="material-icons">insert_drive_file</i>
                    <span>txt</span>
                </span>
                <div class="title">{_("plainText")}</div>
                <div class="desc">{_("ca.downloadTxtDesc")}</div>
            </a>
            <a href={linkPrefix + "?format=vert" + fileStructure}
                    class="cardBtn card-panel"
                    onclick={onLinkClick}>
                <span class="iconContainer">
                    <i class="material-icons">insert_drive_file</i>
                    <span>vert</span>
                </span>
                <div class="title">{_("ca.downloadVertTitle")}</div>
                <div class="desc">{_("ca.downloadVertDesc")}</div>
            </a>
            <a href={linkPrefix + "?format=tmx&aligned=" + corpus.aligned[0]}
                    class="cardBtn card-panel {disabled: !corpus.aligned.length}">
                <span class="iconContainer">
                    <i class="material-icons">insert_drive_file</i>
                    <span>tmx</span>
                </span>
                <div class="title">TMX</div>
                <div class="desc">{_("ca.downloadTmxDesc")}</div>
            </a>
        </div>
        <div>
            <div if={!showSettings} class="center-align">
                <a class="btn btn-flat btn-waves" onclick={onShowSettings} style="text-transform: none;">
                    {_("moreSettings")}
                    <i class="material-icons right">arrow_drop_down</i>
                </a>
            </div>

            <div if={showSettings} class="center-align" style="width: 500px; margin: auto;">
                <label>{_("structNameForFiles")}</label>
                <ui-input inline=1
                        on-change={onFileStructureChange}></ui-input>
                &nbsp;
                <i class="material-icons help tooltipped"
                        data-tooltip={_("structNameForFilesTip")}
                        style="vertical-align: middle;">help</i>
            </div>
        </div>
    </virtual>


    <script>
        require("./ca-corpus-download-dialog.scss")
        const {AppStore} = require("core/AppStore.js")

        this.corpus = this.opts.corpus || AppStore.getActualCorpus()
        this.linkPrefix = window.config.URL_CA + "/corpora/" + this.corpus.id + "/download"
        this.showSettings = false
        this.fileStructure = ""

        this.mixin("tooltip-mixin")

        onLinkClick(){
            Dispatcher.trigger("closeDialog", "downloadCorpus")
        }

        onShowSettings(){
            this.showSettings = !this.showSettings
        }

        onFileStructureChange(value){
            this.fileStructure = ""
            if(value){
                this.fileStructure = "&file_structure=" + value
            }
            this.update()
        }
    </script>
</ca-corpus-download-dialog>
