<ca-add-content class="ca-add-content">
    <screen-overlay event-name="BOOTCAT_STARTING"></screen-overlay>
    <div if={!section} class="dataSource">
        <a id="btnWeb"
                class="cardBtn card-panel {disabled: isDisabled || !data.tagset || !data.tagset.has_pipeline}"
                onclick={showSection.bind(this, "webbootcat")}>
            <i class="material-icons">language</i>
            <div class="title">{_("ca.dataFromWeb")}</div>
            <div class="desc">{_("ca.dataFromWebDesc")}</div>
        </a>
         <a id="btnFiles"
                class="cardBtn card-panel {disabled: isDisabled}"
                onclick={showSection.bind(this, "ownTexts")}>
            <i class="material-icons">cloud_upload</i>
            <div class="title">{_("ca.ownData")}</div>
            <div class="desc">{_("ca.ownDataDesc")}</div>
        </a>
    </div>

    <div style="max-width: 800px; margin: auto;">
        <div if={section == "webbootcat" || section == "ownTexts"}>

            <a if={section == "ownTexts"} class="plainTextToggle link right" onclick={onPlainTextToggleClick}>
                {_(showPlainText ? "ca.orUploadFiles" : "ca.orPasteText")}
            </a>
            <h5 class="backTitle">
                <a onclick={showSection.bind(this, null)}>
                    <span class="btn btn-floating btn-flat">
                        <i class="material-icons grey-text">arrow_back</i>
                    </span>
                    <span class="title">
                        {_(section == "webbootcat" ? "ca.fromWeb" : (showPlainText ? "ca.pasteText" : "ca.fromFiles"))}
                    </span>
                </a>
            </h5>
            <ca-web-bootcat if={section == "webbootcat"}
                    corpus={corpus}
                    on-cancel={showSection.bind(this, null)}></ca-web-bootcat>
            <virtual if={section == "ownTexts"} >
                <virtual if={!showPlainText}>
                    <ui-uploader class="card-panel"
                            ref="uploader"
                            on-add={onFilesAdd}
                            max-files=100
                            max-file-size=500
                            accept=".csv, .doc, .docx, .htm, .html, .ods, .pdf, .tar.bz2, .tar.gz, .tei, .tgz, .tmx, .txt, .vert, .xlf, .xliff, {corpus.aligned.length ? ".xls," : ""} .xml, .zip" style="display: block;"></ui-uploader>
                    <div class="caSupportedFormats">
                        {_("ca.supportedFormats")}
                        .csv, .doc, .docx, .htm, .html, .ods, .pdf, .tar.bz2, .tar.gz, .tei, .tgz, .tmx, .txt, .vert, .xlf, .xliff, {corpus.aligned.length ? ".xls," : ""} .xml, .zip
                    </div>
                    <div class="left">
                        <a onclick={showLegalDialog} class="link">
                            <i class="material-icons" style="position: relative; top: 5px;">help</i>
                            {_("ca.dataPrivacy")}
                        </a>
                    </div>
                </virtual>
                <div if={showPlainText} class="plainText card-panel">
                    <ui-textarea
                        ref="plainText"
                        name="plaintext"
                        placeholder={_("ca.pasteTextHere")}></ui-textarea>
                    <div class="center-align">
                        <a id="btnUpload" class="btn" onclick={onPlainTextUploadClick}>{_("upload")}</a>
                    </div>
                </div>
                <div class="clearfix"></div>
                <div class="center-align">
                    <br>
                    <a id="btnWebBootCaTCancel" class="btn btn-flat" onclick={showSection.bind(this, null)}>
                        {_("cancel")}
                    </a>
                </div>
            <virtual>
        </div>
    </div>

    <ca-browser corpus={corpus} empty-desc={_("ca.addCorpusContent")}></ca-browser>

    <script>
        require("./ca-add-content.scss")
        require("./ca-web-bootcat.tag")
        require("./ca-browser.tag")
        const {CAStore} = require("./castore.js")

        this.section = null
        this.corpus = CAStore.corpus || {}
        this.data = CAStore.data
        this.showPlainText = false


        onFilesAdd(files){
            if(files.length >= 30){
                Dispatcher.trigger("openDialog", {
                    title: _("tooMuchFiles"),
                    small: true,
                    showCloseButton: false,
                    content: _("tooMuchFilesDialog", ["<br><br>"]),
                    buttons: [{
                        label: _("uploadAnyway"),
                        onClick: function(dialog, modal) {
                            CAStore.uploadFiles(this.corpus.id, files)
                            this.showSection(null)
                            modal.close()
                        }.bind(this)
                    }, {
                        label: _("willCreateZip"),
                        class: "btn-primary",
                        onClick: function(dialog, modal){
                            this.refs.uploader.onComplete()
                            modal.close()
                        }.bind(this)
                    }]
                })
            } else {
                CAStore.uploadFiles(this.corpus.id, files)
                this.showSection(null)
            }
        }

        updateAttributes(){
            this.hasFilesets = !!this.data.filesets.length
            this.allFilesetsReady = CAStore.allFilesetsReady()
            this.isDisabled = !this.allFilesetsReady && this.data.compileWhenFinished
        }
        this.updateAttributes()

        showSection(section){
            this.section = section
            this.update()
            this.callOnValidChange()
        }

        showLegalDialog(){
            let dialogText = "<p><b>" + _("ca.dataPrivacyLegal1") + "</b><br />"
                + _("ca.dataPrivacyLegal2") + "<br /><br /><b>"
                + _("ca.dataPrivacyCopy1") + "</b><br />"
                + _("ca.dataPrivacyCopy2") + "</p>"
            Dispatcher.trigger("openDialog", {
                content: dialogText,
                title: _("ca.dataPrivacy"),
                type: "info",
                small: true
            })
        }

        onFilesetsChanged(){
            if(this.hasFilesets != !!this.data.filesets.length || this.allFilesetsReady != CAStore.allFilesetsReady()){
                this.update()
                this.callOnValidChange()
            }
        }

        onPlainTextUploadClick(){
            CAStore.uploadPlainText(this.corpus.id, this.refs.plainText.getValue())
            this.showSection(null)
        }

        onPlainTextToggleClick(){
            this.showPlainText = !this.showPlainText
        }

        callOnValidChange(){
            let isValid = this.section === null && this.hasFilesets && this.allFilesetsReady && CAStore.getTotalWordCount()
            if(this.isValid != isValid){
                this.isValid = isValid
                this.opts.onValidChange(isValid)
            }
        }

        this.on("update", this.updateAttributes)

        onWBCStarted(){
            this.showSection(null)
        }

        this.on("mount", () => {
            CAStore.on("webBotCaTStarted", this.onWBCStarted)
            CAStore.on("filesetsChanged", this.onFilesetsChanged)
            CAStore.on("actualTagsetLoaded", this.update)
        })

        this.on("unmount", () => {
            CAStore.off("webBotCaTStarted", this.onWBCStarted)
            CAStore.off("filesetsChanged", this.onFilesetsChanged)
            CAStore.off("actualTagsetLoaded", this.update)

        })
    </script>
</ca-add-content>
