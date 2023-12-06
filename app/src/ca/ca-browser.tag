<ca-browser class="ca-browser">
    <h5>{_("ca.corpusContent")}</h5>
    <div class="card-panel">
        <preloader-spinner if={!filesetsLoaded} overlay=1></preloader-spinner>

        <div if={filesetsLoaded && hasFilesets} class="row">
            <div class="col l5 m12">
                <table class="table filesetsTable highlight">
                    <thead>
                        <th style="width:90%;">
                            <table-label
                                label={_("folder")}
                                desc-allowed=1
                                asc-allowed=1
                                order-by="name"
                                actual-sort={sorts.filesets.sort}
                                actual-order-by={sorts.filesets.orderBy}
                                on-sort={onFilesetsSort}>
                            </table-label>
                        </th>
                        <th></th>
                        <th>
                            <table-label
                                align-right=1
                                label={_("wordP")}
                                desc-allowed=1
                                asc-allowed=1
                                order-by="word_count"
                                actual-sort={sorts.filesets.sort}
                                actual-order-by={sorts.filesets.orderBy}
                                on-sort={onFilesetsSort}>
                            </table-label>
                        </th>
                        <th style="width:1%; min-width: 63px;"></th>
                    </thead>
                    <tbody>
                        <tr each={fileset in filesets}
                                key={fileset.id}
                                class="link {deleteInProgress: fileset.deleteInProgress, active: fileset.id === data.activeFilesetId}"
                                onclick={onFilesetClick}>
                            <td class="filesetCell">
                                <span>
                                    <i class="folder material-icons text-lighten-1 {fileset.id === data.activeFilesetId ? 'blue-text' : 'grey-text'}">folder</i>
                                    <span class="filesetName inlineBlock">
                                        {fileset.name}
                                    </span>
                                </span>
                            </td>
                            <td class="progressCell" class="right-align">
                                <virtual if={fileset.progress < 100 && fileset.progress != -1}>
                                    <span style="text-align: center;">
                                        <div class="progressTop">
                                            {fileset.progress}% &nbsp;
                                            <span class="hint" if={fileset.time_est && fileset.web_crawl}>(est. {fileset.time_est_str})</span>
                                        </div>
                                        <div class="progress">
                                            <div class="indeterminate"></div>
                                        </div>
                                    </span>
                                    <a if={!fileset.cancelling}
                                            class="btnIco"
                                            onclick={onStopWebSearchClick} >
                                        <i class="material-icons grey-text">close</i>
                                    </a>
                                </virtual>
                                <span if={(fileset.progress == -1 || fileset.progress == 100) && fileset.verticalInProgress} class="grey-text">
                                    {_("processing")}
                                </span>
                                <span if={fileset.progress == -1 && fileset.cancelling} class="grey-text">
                                    {_("ca.canceling")}
                                </span>
                            </td>
                            <td class="num" style="white-space: nowrap;">
                                <span if={fileset.error} class="left">
                                    <i class="orange-text material-icons tooltipped"
                                            data-tooltip={_("ca.webCrawlError") + fileset.error}>warning</i>
                                </span>
                                <div style="margin-left: 40px;">
                                    ~{window.Formatter.num(fileset.word_count)}
                                </div>
                            </td>
                            <td>
                                <a if={(fileset.progress == -1 || fileset.progress == 100) && !fileset.deleteInProgress} class="btnIco" onclick={onFilesetDeleteClick}>
                                    <i class="material-icons grey-text">delete</i>
                                </a>
                                <span if={fileset.deleteInProgress} class="dotsAnimation">
                                    <span>...</span>
                                </span>
                                <a if={fileset.web_crawl}
                                        class="btnIco"
                                        onclick={onWebcrawlInfoClick}>
                                    <i class="webcrawlInfo material-icons grey-text">info</i>
                                </a>
                            </td>
                        </tr>
                        <tr if={filesets.length > 1}>
                            <td colspan="3" class="num dividerTop"><b>~{window.Formatter.num(total)}</b></td>
                            <td class="dividerTop"></td>
                        </tr>
                    </tbody>
                </table>
                <br><br>
            </div>

            <div class="columnFiles col l7 m12">
                <preloader-spinner if={data.filesLoading && !data.filesLoaded} overlay=1></preloader-spinner>
                <div if={data.activeFilesetId !== null}>
                    <virtual if={files.length}>
                        <table class="table filesTable highlight">
                            <thead>
                                <tr>
                                    <th class="selectColumn">
                                        <ui-checkbox
                                            checked={selectedCount == files.length}
                                            on-change={onToggleAllSelect}></ui-checkbox>
                                    </th>
                                    <th>
                                        <table-label
                                            label={_("document")}
                                            desc-allowed=1
                                            asc-allowed=1
                                            order-by="filename_display"
                                            actual-sort={sorts.files.sort}
                                            actual-order-by={sorts.files.orderBy}
                                            on-sort={onFilesSort}>
                                        </table-label>
                                    </th>
                                    <th style="width:1%;">
                                        <table-label
                                            label={_("ca.fileType")}
                                            desc-allowed=1
                                            asc-allowed=1
                                            order-by="type"
                                            actual-sort={sorts.files.sort}
                                            actual-order-by={sorts.files.orderBy}
                                            on-sort={onFilesSort}>
                                        </table-label>
                                    </th>
                                    <th style="width: 1%;">
                                        <table-label
                                            align-right=1
                                            label={_("wordP")}
                                            desc-allowed=1
                                            asc-allowed=1
                                            order-by="word_count"
                                            actual-sort={sorts.files.sort}
                                            actual-order-by={sorts.files.orderBy}
                                            on-sort={onFilesSort}>
                                        </table-label>
                                    </th>
                                    <th style="width: 1%;"></th>
                                </tr>
                            </thead>
                            <tbody each={file in files} key={file.id}>
                                <tr class="{deleteInProgress: file.deleteInProgress} {selectedRow: file.showDetails}">
                                    <td class="chbCell">
                                        <label if={!file.inProgress}>
                                            <input type="checkbox"
                                                checked={file.selected}
                                                onchange={onFileSelectChange} />
                                            <span></span>
                                        </label>
                                    </td>
                                    <td class="link" onclick={onFileClick}>
                                        {file.filename_display}
                                        <virtual if={file.inProgress}>
                                            <span class="fileProgress inlineBlock center-align">
                                                <virtual if={!file.cancelling}>
                                                    <span class="progressTop inlineBlock">
                                                        {file.vertical_progress}% &nbsp;
                                                    </span>
                                                    <span class="progress inlineBlock">
                                                        <div class="indeterminate"></div>
                                                    </span>
                                                    <a class="btnIco inlineBlock tooltipped"
                                                            onclick={onCancelFileJobClick}
                                                            data-tooltip={_("cancelFileProcessing")}>
                                                        <i class="material-icons grey-text">close</i>
                                                    </a>
                                                </virtual>
                                                <span if={file.cancelling} class="grey-text">
                                                    {_("ca.canceling")}
                                                </span>
                                            </span>
                                        </virtual>
                                    </td>
                                    <td>{file.parameters.type}</td>
                                    <td class="num">
                                        <span if={file.vertical_progress == -1} class="left">
                                            <i class="orange-text material-icons tooltipped"
                                                    data-tooltip={file.vertical_error || _("somethingWentWrong")}>warning</i>
                                        </span>
                                        ~{window.Formatter.num(file.word_count)}
                                    </td>
                                    <td class="btnCell">
                                        <a if={!file.deleteInProgress && !file.inProgress}
                                                class="caBrowserDropdownButton iconButton btn btn-flat btn-floating"
                                                onclick={onOpenFileMenuClick}>
                                            <i class="material-icons grey-text">more_horiz</i>
                                        </a>
                                        <span if={file.deleteInProgress} class="dotsAnimation">
                                            <span>...</span>
                                        </span>
                                    </td>
                                </tr>
                                <tr if={file.showDetails} class="fileDetails">
                                    <td colspan="4">
                                        <div if={file.isPreviewLoading} class="centerSpinner">
                                            <preloader-spinner></preloader-spinner>
                                        </div>
                                        <div if={!file.isArchive && !file.isPreviewLoading}>
                                            <a href="javascript:void(0)"
                                                    class="btn btn-floating left"
                                                    onclick={onFileSettingsClick.bind(this, file)}>
                                                <i class="material-icons">settings</i>
                                            </a>
                                            <div class="filePreview" style="max-height: 100px;">
                                                <b>{_("filePreview")}:</b>
                                                <div>{file.preview ? file.preview.trim() : _("filePreviewEmpty")}</div>
                                            </div>
                                            <div class="center-align expandArrow" if={file.preview}>
                                                <a href="javascript:void(0);" onclick={onPreviewExpandToggle}>
                                                    <i class="material-icons">{previewExpanded ? "keyboard_arrow_up" : "keyboard_arrow_down"}</i>
                                                </a>
                                            </div>
                                        </div>
                                        <div if={file.isArchive}>
                                            <a href="javascript:void(0)"
                                                class="btn btn-floating left"
                                                onclick={onExpandArchiveClick}>
                                                <i class="material-icons">zoom_out_map</i>
                                            </a>
                                            <div class="lineDetailText">
                                                {_("expandArchive")}
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <div class="inlineBlock left">
                            <a id="bulkActionBtn" class="dropdown-trigger btn {disabled: !selectedCountAll}" href="javascript:void(0);" data-target="bulkMenu">
                                {_("bulkActions")}
                                <i class="material-icons right">arrow_drop_down</i>
                            </a>
                            <ul id="bulkMenu" class="dropdown-content">
                                <li>
                                    <a href="javascript:void(0);" onclick={onBulkEditMetadataClick}>
                                        <i class="material-icons">edit</i>
                                        {_("editMetadata")}
                                    </a>
                                </li>
                                <li>
                                    <a href="javascript:void(0);" onclick={onBulkDeleteClick}>
                                        <i class="material-icons">delete</i>
                                        {_("delete")}
                                    </a>
                                </li>
                                <li class="divider" tabindex="-1"></li>
                                <li class="docCountItem">{_("selectedDocuments", [selectedCountAll])}</span></li>
                            </ul>
                        </div>
                        <div class="inlineBlock right">
                            <br>
                            <ui-pagination
                                if={items.length > 10}
                                count={items.length}
                                items-per-page={itemsPerPage}
                                actual={page}
                                on-change={onPageChange}
                                on-items-per-page-change={onItemsPerPageChange}
                                show-prev-next={true}></ui-pagination>
                        </div>
                        <div class="clearfix"></div>
                    </virtual>
                    <div if={!files.length && data.filesLoaded && !activeFilesetIsInProgress} class="emptyFolder">
                        <h4>{_("ca.folderIsEmpty")}</h4>
                    </div>

                    <div if={!data.filesLoaded && this.activeFilesetIsInProgress} class="loadingFolder">
                        <h4>{_("ca.stillWorking")}</h4>
                    </div>
                </div>
            </div>
        </div>

        <div if={filesetsLoaded && !hasFilesets} class="emptyCorpus">
            <i class="material-icons">input</i>
            <h4>{_("nothingHere")}</h4>
            <div if={opts.emptyDesc}>{opts.emptyDesc}</div>
            <div if={!opts.emptyDesc}>
                <a href="#ca-add-content" class="btn contrast">{_("addTexts")}</a>
            </div>
        </div>
    </div>


    <ul id="caBrowserMenuDropdownList" class="dropdown-content">
        <li if={isViewFileEnabled}>
            <a data-callback="onFileViewClick">
                <i class="material-icons">search</i>
                {_("viewFile")}
            </a>
        </li>
        <li>
            <a data-callback="onMenuFileSettingsClick">
                <i class="material-icons">settings</i>
                {_("documentSettings")}
            </a>
        </li>
        <li>
            <a data-callback="onFileEditMetadata">
                <i class="material-icons">edit</i>
                {_("editMetadata")}
            </a>
        </li>
        <li>
            <a data-callback="onFileDownloadClick">
                <i class="material-icons">cloud_download</i>
                {_("downloadFile")}
            </a>
        </li>
        <li >
            <a data-callback="onFileDeleteClick">
                <i class="material-icons">delete</i>
                {_("delete")}
            </a>
        </li>
    </ul>


    <i if={usageWarning}
            class="orange-text material-icons"
            style="vertical-align:top; margin-right: 10px;">warning</i>
    <span class="inlineBlock grey-text">
        {_("ca.spaceUsage")}
        {space.used_str}
        {_("of")}
        {space.total_str}
        {_("wordP")}
        (<span class={red-text: usageWarning}>{space.percent}%</span>)

        <br>
        <span if={usageWarning}>
            {_("ca.buyMoreSpace")}
            <a href={window.config.URL_RASPI + "#account/overview"} target="_blank">{_("ca.subscriptionOverview")}</a>.
        </span>
    </span>

    <script>
        require("./ca-browser.scss")
        require("./ca-webcrawl-dialog.tag")
        require("./ca-file-preview-dialog.tag")
        require("./ca-file-view-dialog.tag")
        require("./ca-bulk-metadata-dialog.tag")
        require("./ca-file-metadata-dialog.tag")
        const {Auth} = require("core/Auth.js")
        const {CAStore} = require("./castore.js")

        this.mixin("tooltip-mixin")

        this.data = CAStore.data
        this.user = Auth.getSession().user
        this.itemsPerPage = 20
        this.page = 1
        this.showResultsFrom = 1
        this.filesetsLoaded = false
        this.files = []
        this.sorts = {
            "filesets":{
                orderBy :null,
                sort: "asc"
            },
            "files": {
                orderBy :null,
                sort: "asc"
            }
        }
        this.isViewFileEnabled = this.opts.corpus.progress != 0


        _sort(what, data){
            let sort = this.sorts[what]
            let orderBy = this.sorts[what].orderBy
            if(orderBy){
                data.sort( function(objA, objB){
                    let a = objA[orderBy]
                    let b = objB[orderBy]
                    if(orderBy == "type"){
                        a = objA.parameters.type
                        b = objB.parameters.type
                    }
                    if(typeof a == "string"){
                        return sort.sort == "asc" ? a.localeCompare(b) : b.localeCompare(a)
                    } else if(typeof a == "number"){
                        return sort.sort == "asc" ? a - b : b - a
                    }
                }.bind(this))
            }
        }

        getSelectedFiles(all){
            return (all ? CAStore.data.files : this.files).filter(f => {
                return f.selected
            })
        }

        updateSpace(){
            this.space = Auth.getSpace()
            this.usageWarning = this.space.total < this.space.used
        }

        updateAttributes(){
            this.items = this.data.files
            this.filesets = this.data.filesets
            this.hasFilesets = !!this.filesets.length
            this.filesetsLoaded = this.data.filesetsLoaded && this.data.filesWithoutfFolderLoaded
            this.showResultsFrom = (this.page - 1) * this.itemsPerPage
            this._sort("filesets", this.filesets)
            this._sort("files", this.items)
            this.files = this.items.slice((this.page - 1) * this.itemsPerPage, this.page * this.itemsPerPage)
            this.activeFileset = this.filesets[this.data.activeFilesetId]
            this.activeFilesetIsInProgress = this.activeFileset ? (this.activeFileset.progress > 0 && this.activeFileset.progress < 100) : false
            this.total = CAStore.getTotalWordCount()
            this.selectedCountAll = this.getSelectedFiles(true).length
            this.selectedCount = this.getSelectedFiles().length
            this.updateSpace()
        }
        this.updateAttributes()

        onFilesetClick(evt){
            this.files = []
            CAStore.setActiveFilesetId(this.opts.corpus.id, evt.item.fileset.id)
        }

        onFileSelectChange(evt){
            evt.stopPropagation()
            evt.item.file.selected = evt.target.checked
            this.update()
        }

        onCancelFileJobClick(evt){
            evt.stopPropagation()
            CAStore.cancelFileJob(this.opts.corpus.id, evt.item.file.id)
        }

        onOpenFileMenuClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()

            this.dropdownMenuFile = evt.item.file
            let id = "l_" + Date.now()
            $("#caBrowserMenuDropdownList").clone()
                    .attr({id: id})
                    .appendTo($("body"))
                    .find("a").each(function(idx, e){
                        let element = $(e)
                        let callback = this[element.data("callback")]
                        element.click(callback)
                    }.bind(this))

            let menuNode = $(evt.currentTarget)
            menuNode.attr("data-target", id)
                .dropdown({constrainWidth: false})
                .dropdown('open')

        }

        onFilesetDeleteClick(evt){
            Dispatcher.trigger("openDialog", {
                title: _("ca.deleteFolder"),
                content: _("ca.reallyDeleteFolder", [evt.item.fileset.name]),
                small: 1,
                buttons: [{
                    label: _("delete"),
                    class: "contrast",
                    onClick: () => {
                        evt.item.fileset.deleteInProgress = true
                        this.update()
                        CAStore.deleteFileset(this.opts.corpus.id, evt.item.fileset.id)
                        Dispatcher.trigger("closeDialog")
                    }
                }]
            })
            evt.stopPropagation()
            evt.preventUpdate = true
        }

        onFileViewClick(evt){
            evt.stopPropagation(evt)
            Dispatcher.trigger("openDialog", {
                tag: "ca-file-view-dialog",
                fixedFooter: true,
                opts: {
                    fileName: this.dropdownMenuFile.filename_display,
                    corpus_id: this.opts.corpus.id,
                    file_id: this.dropdownMenuFile.id
                }
            })
        }

        onFileDownloadClick(evt){
            evt.stopPropagation()
            let url = window.config.URL_CA + "/corpora/" + this.opts.corpus.id + "/documents/" + this.dropdownMenuFile.id + "/original"
            window.open(url, "_blank")
        }

        onFileDeleteClick(evt){
            evt.stopPropagation()
            let file = this.dropdownMenuFile
            Dispatcher.trigger("openDialog", {
                title: _("deleteFile"),
                content: _("reallyDeleteFile", [file.filename_display]),
                small: 1,
                buttons: [{
                    label: _("delete"),
                    class: "contrast",
                    onClick: () => {
                        file.deleteInProgress = true
                        this.update()
                        CAStore.deleteFiles(this.opts.corpus.id, file.id, this.data.activeFilesetId)
                        Dispatcher.trigger("closeDialog")
                    }
                }]
            })
        }

        onStopWebSearchClick(evt){
            evt.stopPropagation()
            CAStore.cancelWebBootCaT(this.opts.corpus.id, evt.item.fileset.id)
            this.update()
        }

        onPageChange(page){
            this.page = page
            this.update()
        }

        onItemsPerPageChange(itemsPerPage){
            this.itemsPerPage = itemsPerPage
            this.update()
        }

        onFilesetsSort(sort){
            this.sorts.filesets = sort
            this.update()
        }

        onFilesSort(sort){
            this.sorts.files = sort
            this.showResultsFrom = 1
            this.page = 1
            this.update()
        }

        onFileClick(evt){
            let file = evt.item.file
            if(file.inProgress){
                return
            }
            file.showDetails = !file.showDetails
            if(!file.isPreviewLoading && !file.isArchive){
                if(!file.preview){
                    file.isPreviewLoading = true
                    CAStore.one("filePlaintextPreviewLoadFinished", this.onFilePreviewLoadFinished)
                    CAStore.loadFilePlaintextPreview(this.opts.corpus.id, file.id, file.parameters)
                } else{
                    file.preview = null
                }
            }
        }

        onExpandArchiveClick(evt){
            CAStore.expandArchive(this.opts.corpus.id, evt.item.file.id)
        }

        onWebcrawlInfoClick(evt){
            evt.stopPropagation()
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                title: _("ca.searchDetails"),
                tag: "ca-webcrawl-dialog",
                opts: {
                    corpus_id: this.opts.corpus.id,
                    fileset_id: evt.item.fileset.id
                }
            })
        }

        onMenuFileSettingsClick(evt){
            evt.stopPropagation()
            this.onFileSettingsClick(this.dropdownMenuFile)
        }

        onFileSettingsClick(file){
            let oldParameters = Object.assign({}, file.parameters)
            Dispatcher.trigger("openDialog", {
                id: "filePreview",
                title: file.filename_display,
                tag: "ca-file-preview-dialog",
                fixedFooter: 1,
                opts: {
                    files: this.files,
                    corpus_id: this.opts.corpus.id,
                    file_id: file.id
                },
                buttons: [{
                    label: _("save"),
                    onClick: function(file){
                        CAStore.updateFile(this.opts.corpus.id, file)
                        Dispatcher.trigger("closeDialog", "filePreview")
                    }.bind(this, file)
                }],
                onClose: function(file){
                    file.parameters = oldParameters
                    this.update()
                }.bind(this, file)
            })
        }

        onFileEditMetadata(evt){
            evt.stopPropagation()
            Dispatcher.trigger("openDialog", {
                id: "editMetadata",
                title: _("editMetadata"),
                small: true,
                tag: "ca-file-metadata-dialog",
                opts: {
                    corpus_id: this.opts.corpus.id,
                    file_ids: [this.dropdownMenuFile.id],
                    metadata: copy(this.dropdownMenuFile.metadata),
                    fileName: this.dropdownMenuFile.filename_display
                },
                buttons: [{
                    id: "fileSaveBtn",
                    label: _("save"),
                    class: "contrast",
                    onClick: function(dialog, modal){
                        dialog.contentTag.save()
                    }.bind(this)
                }]
            })
        }

        onBulkEditMetadataClick(evt){
            evt.preventUpdate = true
            let file_ids = this.getSelectedFiles().map(f => {
                return f.id
            })
            Dispatcher.trigger("openDialog", {
                title: _("editMetadata"),
                tag: "ca-bulk-metadata-dialog",
                fixedFooter: true,
                dismissible: false,
                opts: {
                    corpus_id: this.opts.corpus.id,
                    file_ids: file_ids
                },
                buttons: [{
                    label: _("save"),
                    id: "bulkSaveBtn",
                    class: "contrast disabled",
                    onClick: function(dialog, modal){
                        dialog.contentTag.save()
                    }.bind(this)
                }]
            })
        }

        onBulkDeleteClick(){
            Dispatcher.trigger("openDialog", {
                title: _("deleteFiles"),
                small: true,
                content: _("confirmFilesDelete", [this.selectedCountAll]),
                buttons: [{
                    label: _("delete"),
                    class: "contrast",
                    onClick: function(dialog, modal){
                        let file_ids = [];
                        this.getSelectedFiles().forEach(file => {
                            file.deleteInProgress = true
                            file_ids.push(file.id)
                        })
                        CAStore.deleteFiles(this.opts.corpus.id, file_ids, this.data.activeFilesetId)
                        modal.close()
                        this.update()
                    }.bind(this)
                }]
            })
        }

        onPreviewExpandToggle(evt){
            this.previewExpanded = !this.previewExpanded
            let td = $(evt.target).closest("td")
            td.find("div").css("max-height", this.previewExpanded ? "1500px" : "100px")
        }

        onToggleAllSelect(selected){
            this.files.forEach(file => {
                file.selected = selected
            })
            this.update()
        }

        onFileExpanded(filesetId){
            if(this.files.length == 0){ // in fileset Upload was only one archive - now is Upload gone
                CAStore.setActiveFilesetId(this.opts.corpus.id, filesetId)
            }
        }

        onFilePreviewLoadFinished(file_id, payload){
            let file = this.getFile(file_id)
            file.preview = payload
            file.isPreviewLoading = false
            this.update()
        }

        onUserSpaceReloaded(space){
            if(this.space.used != space.used){
                this.updateSpace()
                this.update()
            }
        }

        getFile(file_id){
            return this.files.find(f => {
                return f.id == file_id
            })
        }

        initDropdown(){
            $("#bulkActionBtn").dropdown({
                constrainWidth: false
            })
        }

        this.on("update", this.updateAttributes)

        this.on("updated", this.initDropdown)

        this.on("mount", () => {
            this.initDropdown()
            CAStore.on("filesChanged", this.update)
            CAStore.on("activeFilesetChanged", this.update)
            CAStore.on("filesetsChanged", this.update)
            CAStore.on("fileExpanded", this.onFileExpanded)
            Dispatcher.on("USER_SPACE_RELOADED", this.onUserSpaceReloaded)
        })

        this.on("unmount", () => {
            CAStore.off("filesChanged", this.update)
            CAStore.off("activeFilesetChanged", this.update)
            CAStore.off("filesetsChanged", this.update)
            CAStore.off("fileExpanded", this.onFileExpanded)
            Dispatcher.off("USER_SPACE_RELOADED", this.onUserSpaceReloaded)
        })
    </script>
</ca-browser>
