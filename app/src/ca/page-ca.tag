<page-ca class="page-ca ca">
    <div class="ca-title dividerBottom">
        <span class="name">{_("corpus")}:</span>
        <span class="corpname">{corpus.name}</span>
        <span class="language">({corpus.language_name})</span>
        <span if={corpus.isEmpty} class="badge red lighten-2 white-text t_empty" style="float: none">
            {_("db.emptyTitle")}
        </span>
        <span if={corpus.hasDocuments && corpus.needs_recompiling} class="badge red lighten-2 white-text t_should_compile" style="float: none">
            {_("ca.shouldCompile")}
        </span>
        <span if={corpus.hasDocuments && corpus.can_be_upgraded && !data.upgradeTagsetInProgress && corpus.user_can_manage} class="badge red lighten-2 white-text t_should_upgrade" style="float: none">
            {_("ca.shouldUpgrade")}
        </span>
        <span if={corpus.hasDocuments && corpus.isCompilationFailed} class="badge red lighten-2 white-text t_compilation_failed" style="float: none">
            {_("ca.compilation_failedDesc")}
        </span>
        <i if={corpus.user_can_manage}
                class="material-icons material-clickable ml-3"
                onclick={onCorpusEditClick}>edit</i>
    </div>

    <div class="corpusInfo">{corpus.info}</div>

    <div if={isBusy} class="busy center-align">
        <span class="statusText">
            <h5 class="inline-block" ref="compilationText">
                {corpus.isCompiling ? _("compiling") : _("ca.upgrading")}
            </h5>
            <a id="btnCancelCompilation"
                    if={corpus.isCompiling}
                    class="btn btn-floating btn-flat"
                    onclick={onCancelCompilation}>
                <i class="material-icons grey-text">close</i>
            </a>
        </span>
        <div class="progress">
            <div class="indeterminate"></div>
            <br>
        </div>
        <div class="busyDesc grey-text">{_("ca.corpusBusyDesc")}</div>
    </div>

    <div class="options">
        <span each={option in options} class="inline-block {ca-tooltip: option.disabled}" data-tooltip={_("notAllowed")}>
            <a href={option.href} onclick={option.onclick} id="btnCa{option.id}" class="cardBtn card-panel {disabled: option.disabled} {option.class} {ca-tooltip: option.disabled} {pulse: option.highlight && !option.disabled}">
                <i class="material-icons {orange-text: option.highlight && !option.disabled}">{option.icon}</i>
                <div class="title">{_(option.title)}</div>
                <div class="desc">{_(option.desc)}</div>
            </a>
        </span>
    </div>
    <div class="clearfix"></div>

    <div class="center-align">
        <a href="#dashboard" class="btn btn-flat">{_("backToDashboard")}</a>
    </div>

    <script>
        require("./page-ca.scss")
        require("./ca-corpus-download-dialog.tag")
        const {AppStore} = require("core/AppStore.js")
        const {CAStore} = require("ca/castore.js")
        const Dialogs = require("dialogs/dialogs.js")

        this.tooltipClass = ".ca-tooltip"
        this.tooltipMargin = -105
        this.mixin("tooltip-mixin")

        onDownloadClick(){
            Dispatcher.trigger("openDialog", {
                id: "downloadCorpus",
                tag: "ca-corpus-download-dialog",
                title: _("downloadCorpus")
            })
        }

        onDeleteClick(){
            AppStore.deleteCorpus(this.corpus.id)
        }

        onConfigClick(){
            Dialogs.showCorpusConfigDialog(this.corpus.id)
        }

        onUpgradeClick(){
            let content = _("ca.upgradeCorpusDialog1")
            if(this.corpus.tagsetdoc){
                content += "<br><br><b>"
                        + _("ca.upgradeCorpusDialog2")
                        + '</b>'
            }
            content += "<br><br>"
                    + _("ca.upgradeCorpusDialog2Desc", ['<a href="mailto:' + externalLink("supportMail") + '">' + externalLink("supportMail") + '</a>'])

            Dispatcher.trigger("openDialog", {
                id: "upgradeTagset",
                content: content,
                title: _("ca.upgradeCorpus"),
                type: "warning",
                small: true,
                buttons: [{
                    label: _("upgrade"),
                    onClick: () => {
                        CAStore.upgradeTagset()
                        Dispatcher.trigger("closeDialog", "upgradeTagset")
                        this.update()
                    }
                }]
            })
        }

        onCorpusEditClick(){
            Dialogs.showCorpusConfigDialog(this.corpus.id)
        }

        updateOptions(){
            this.options = [{
                id: "browse",
                href: "#ca-browse",
                icon: "folder",
                title: "browse",
                desc: "ca.browseDesc",
                disabled: this.corpus.isEmpty && !this.corpus.hasDocuments
            }, {
                id: "addContent",
                href: "#ca-add-content",
                icon: "add_circle",
                title: "enlargeCorpus",
                desc: "ca.makeBiggerDesc",
                highlight: !this.corpus.hasDocuments
            }, {
                id: "share",
                href: "#ca-share",
                icon: "share",
                title: "share",
                desc: "ca.shareDesc",
                disabled: this.corpus.isEmpty
            }, {
                id: "download",
                onclick: this.onDownloadClick,
                icon: "cloud_download",
                title: "download",
                desc: "ca.downloadDesc",
                disabled: window.config.NO_CA || (this.corpus.id && !this.corpus.user_can_manage)
            }, {
                id: "compile",
                href: "#ca-compile",
                icon: "build",
                title: "ca.compile",
                desc: "ca.compileDesc",
                disabled: this.corpus.isEmpty,
                highlight: this.corpus.hasDocuments && (this.corpus.isCompilationFailed || this.corpus.needs_recompiling)
            }, {
                id: "delete",
                onclick: this.onDeleteClick,
                icon: "delete_forever",
                title: "delete",
                desc: "ca.deleteDesc",
                disabled: window.config.NO_CA || !this.corpus.user_can_manage
            }, {
                id: "subcorpora",
                href: "#ca-subcorpora",
                icon: "dns",
                title: "subcorpora",
                desc: "ca.subcorporaDesc"
            }, {
                id: "configure",
                onclick: this.onConfigClick,
                icon: "settings",
                title: "configure",
                desc: "ca.configureDesc",
                disabled: window.config.NO_CA || !this.corpus.user_can_manage
            }, {
                id: "logs",
                href: "#ca-logs",
                icon: "description",
                title: "logs",
                desc: "ca.logsDesc"
            }]

            if(!window.config.NO_CA){
                if(this.corpus.can_be_upgraded && !this.data.upgradeTagsetInProgress &&this.corpus.user_can_manage){
                    this.options.push({
                        id: "upgradeTagset",
                        onclick: this.onUpgradeClick,
                        icon: "update",
                        title: "upgrade",
                        desc: "ca.upgradeCorpusDesc",
                        highlight: this.corpus.isCompilationFailed
                    })
                }

                this.options.push({
                    id: "new",
                    href: "#ca-create",
                    icon: "add",
                    title: "newCorpus",
                    desc: "ca.newCorpusDesc",
                    class: "newCorpus"
                })
            }

            this.options.forEach(option => {
                if(option.href && !window.permissions[option.href.substring(1)] || this.isBusy){
                    option.disabled = true
                }
            })
        }

        onCancelCompilation(evt){
            this.refs.compilationText.innerHTML = _("cancelling")
            $(evt.currentTarget).addClass("disabled")
            CAStore.cancelCompilation(this.corpus.id)
            this.update()
        }

        updateAttributes(){
            this.corpus = CAStore.corpus || {}
            this.data = CAStore.data
            this.corpus.id && CAStore.loadActualTagSet()
            this.isBusy = this.corpus.isCompiling || this.data.upgradeTagsetInProgress
            this.corpus.isCompiling && CAStore.checkCorpusStatus(this.corpus.id)
            this.updateOptions()
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)

        this.on("before-mount", () => {
            AppStore.loadCorpus(this.corpus.corpname)
        })
        this.on("mount", () => {
            AppStore.on("corpusChanged", this.update)
        })

        this.on("unmount", () => {
            AppStore.off("corpusChanged", this.update)
        })

        CAStore.updateUrl()
    </script>
</page-ca>
