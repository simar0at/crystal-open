<ca-browser class="ca-browser">
    <h5>{_("ca.corpusContent")}</h5>
    <div class="card-panel">
        <preloader-spinner if={!filesetsLoaded} overlay=1></preloader-spinner>

        <div if={filesetsLoaded && hasFilesets} class="row">
            <div class="col l5 m12">
                <div class="filesetsNote">
                    <div if={data.uploadInProgress}>
                        {_("fileUploadInProgress")}
                    </div>
                    <div if={!data.uploadInProgress && !allFilesetsReady}>
                        {_("fileProcessInProgress")}
                    </div>
                </div>
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
                                id="t_{window.idEscape(fileset.name)}"
                                class="link {deleteInProgress: fileset.deleteInProgress, active: fileset.id === data.activeFilesetId}"
                                onclick={onFilesetClick}>
                            <td class="filesetCell">
                                <span>
                                    <i class="folder material-icons {fileset.id === data.activeFilesetId ? 'blue-text' : 'grey-text'}">folder</i>
                                    <span class="filesetName inline-block truncate">
                                        {fileset.name}
                                    </span>
                                </span>
                            </td>
                            <td class="progressCell" class="right-align">
                                <virtual if={fileset.progress < 100 && fileset.progress != -1}>
                                    <span class="t_progress" style="text-align: center;">
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
                                <span if={(fileset.progress == -1 || fileset.progress == 100) && fileset.verticalInProgress} class="grey-text t_processing">
                                    {_("processing")}
                                </span>
                                <span if={fileset.progress == -1 && fileset.cancelling} class="grey-text">
                                    {_("cancelling")}
                                </span>
                            </td>
                            <td class="num" style="white-space: nowrap;">
                                <span if={fileset.error} class="left">
                                    <i class="orange-text material-icons tooltipped"
                                            data-tooltip={(fileset.web_crawl ? _("ca.webCrawlError") : '') + fileset.error}>warning</i>
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
                    <virtual if={allFiles}>
                        <span if={data.filesLoaded}
                                class="blue-text link fileFilterToggle"
                                onclick={onFileFilterToggleClick}>
                            <span>
                                {_("filesFilter")}
                            </span>
                            <i ref="fileFilterArrow"
                                    class="material-icons">arrow_drop_down</i>
                        </span>
                        <div  if={data.filesLoaded}
                                ref="fileFilter"
                                class="fileFilter"
                                style="display: none;">
                            <ui-select options={filesFilterPnOptions}
                                    riot-value={filesFilterPn}
                                    inline=1
                                    size=8
                                    on-change={onFilesFilterPnChange}></ui-select>
                            <ui-select options={filesFilterConditionOptions}
                                    riot-value={filesFilterCondition}
                                    inline=1
                                    size=10
                                    on-change={onFilesFilterConditionChange}></ui-select>
                            <ui-select if={filesFilterCondition == "havingAttribute" || filesFilterCondition == "attributeValue"}
                                    options={filesFilterAttributeOptions}
                                    inline=1
                                    size=9
                                    riot-value={filesFilterAttribute}
                                    on-change={filesFilterAttributeChange}></ui-select>
                            <span if={filesFilterCondition == "attributeValue"}> = </span>
                            <ui-input
                                    if={filesFilterCondition != "havingAttribute" }
                                    inline=1
                                    size=8
                                    riot-value={filesFilterQuery}
                                    on-input={onFilesFilterQueryChange}
                                    on-submit={filterFiles}></ui-input>
                            <button class="btn btn-flat" onclick={filterFiles}>
                                {_("filter")}
                            </button>
                            <button class="btn btn-flat" onclick={clearFilter}>
                                {_("cancelFilter")}
                            </button>
                        </div>
                        <table if={files.length} class="table filesTable highlight">
                            <thead>
                                <tr>
                                    <th class="selectColumn">
                                        <button id="selectionBtn"
                                                class="dropdown-trigger btn btn-flat"
                                                data-target="selectionMenu">
                                            <span class="ui ui-checkbox">
                                                <label>
                                                    <input type="checkbox"/>
                                                    <span></span>
                                                </label>
                                            </span>
                                            <i class="material-icons right" style="margin: 0">arrow_drop_down</i>
                                        </button>
                                        <ul id="selectionMenu" class="dropdown-content">
                                            <li each={option in selectionOptions}>
                                                <a href="javascript:void(0);" onclick={onSelectionMenuItemClick.bind(option)}>
                                                    {_(option.labelId)}
                                                </a>
                                            </li>
                                        </ul>
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
                            <tbody each={file, idx in files} key={file.id} id="t_{window.idEscape(file.filename_display)}">
                                <tr class="{deleteInProgress: file.deleteInProgress} {selectedRow: file.showDetails}">
                                    <td class="chbCell">
                                        <label if={!file.inProgress}>
                                            <input type="checkbox"
                                                    id="chb_{idx}"
                                                    checked={file.selected}
                                                    onclick={onFileSelectChange} />
                                            <span></span>
                                        </label>
                                    </td>
                                    <td class="link" onclick={onFileClick}>
                                        {file.filename_display}
                                        <virtual if={file.inProgress}>
                                            <span class="fileProgress inline-block center-align">
                                                <virtual if={!file.cancelling}>
                                                    <span class="progressTop inline-block">
                                                        {file.vertical_progress}% &nbsp;
                                                    </span>
                                                    <span class="progress inline-block">
                                                        <div class="indeterminate"></div>
                                                    </span>
                                                    <a class="btnIco inline-block tooltipped"
                                                            onclick={onCancelFileJobClick}
                                                            data-tooltip={_("cancelFileProcessing")}>
                                                        <i class="material-icons grey-text">close</i>
                                                    </a>
                                                </virtual>
                                                <span if={file.cancelling} class="grey-text">
                                                    {_("cancelling")}
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
                                                class="btn btn-floating left t_expandArchive"
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
                        <div if={files.length} class="inline-block left bulkBtns">
                            <button id="bulkActionBtn"
                                    class="dropdown-trigger btn {disabled: !selectedCountAll}"
                                    data-target="bulkMenu">
                                {_("bulkActions", [selectedCountAll ? (' (' + selectedCountAll + ')') : ''])}
                                <i class="material-icons right">arrow_drop_down</i>
                            </button>
                        </div>
                        <div class="inline-block right">
                            <ui-pagination
                                if={filteredFiles.length > 10}
                                count={filteredFiles.length}
                                items-per-page={itemsPerPage}
                                actual={page}
                                on-change={onPageChange}
                                on-items-per-page-change={onItemsPerPageChange}
                                show-prev-next={true}></ui-pagination>
                        </div>
                        <div class="clearfix"></div>
                    </virtual>
                    <div if={!allFiles && data.filesLoaded && !activeFilesetIsInProgress} class="emptyFolder">
                        <h4>{_("ca.folderIsEmpty")}</h4>
                    </div>
                    <div if={allFiles.length && !files.length && !activeFilesetIsInProgress} class="emptyFolder">
                        <h4>{_("nothingFound")}</h4>
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
            <div if={!opts.emptyDesc} class="primaryButtons">
                <a href="#ca-add-content" class="btn btn-primary">{_("addTexts")}</a>
            </div>
        </div>
    </div>
    <div id="bulkMenuContainer"></div>
    <ul id="bulkMenu" class="dropdown-content">
        <li class="t_bulk_metadata">
            <a href="javascript:void(0);" onclick={onBulkEditMetadataClick}>
                <i class="material-icons">edit</i>
                {_("editMetadata")}
            </a>
        </li>
        <li class="t_bulk_delete">
            <a href="javascript:void(0);" onclick={onBulkDeleteClick}>
                <i class="material-icons">delete</i>
                {_("delete")}
            </a>
        </li>
        <li class="divider" tabindex="-1"></li>
        <li class="docCountItem">{_("selectedDocuments", [selectedCountAll])}</span></li>
    </ul>


    <ul id="caBrowserMenuDropdownList" class="dropdown-content">
        <li if={isViewFileEnabled} class="t_menu_item_view">
            <a data-callback="onFileViewClick">
                <i class="material-icons">search</i>
                {_("viewFile")}
            </a>
        </li>
        <li class="t_menu_item_settings">
            <a data-callback="onMenuFileSettingsClick">
                <i class="material-icons">settings</i>
                {_("documentSettings")}
            </a>
        </li>
        <li class="t_menu_item_metadata">
            <a data-callback="onFileEditMetadata">
                <i class="material-icons">edit</i>
                {_("editMetadata")}
            </a>
        </li>
        <li class="t_menu_item_download">
            <a data-callback="onFileDownloadClick">
                <i class="material-icons">cloud_download</i>
                {_("downloadFile")}
            </a>
        </li>
        <li class="t_menu_item_delete">
            <a data-callback="onFileDeleteClick">
                <i class="material-icons">delete</i>
                {_("delete")}
            </a>
        </li>
    </ul>

    <virtual if={space.total}>
        <i if={!space.has_space}
                class="orange-text material-icons"
                style="vertical-align:top; margin-right: 10px;">warning</i>
        <span class="inline-block grey-text">
            {_("ca.spaceUsage")}
            {space.used_str}
            {_("of")}
            {space.total_str}
            {_("wordP")}
            (<span class={red-text: !space.has_space}>{space.percent}%</span>)

            <br>
            <span if={!space.has_space}>
                {_("ca.buyMoreSpace")}
                <a href={window.config.URL_RASPI + "#account/overview"} target="_blank">{_("ca.subscriptionOverview")}</a>.
            </span>
        </span>
    </virtual>

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
        this.allFiles = []
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
        this.lastSelectedLineIdx = null
        this.filesFilterCondition = "containing"
        this.filesFilterConditionOptions = ["startingWith", "endingWith", "containing", "matchingRegex", "havingAttribute", "attributeValue"].map(key => ({
            label: _(key),
            value: key
        }))
        this.filesFilterPnOptions = [{
            label: _("showFiles"),
            value: "p"
        }, {
            label: _("hideFiles"),
            value: "n"
        }]
        this.filesFilterPn = "p"
        this.filesFilterQuery = ""
        this.selectionOptions = [{
            labelId:"selectAll",
            scope: "all",
            select: true
        }, {
            labelId:"deselectAll",
            scope: "all",
            select: false
        }, {
            labelId:"selectPage",
            scope: "page",
            select: true
        }, {
            labelId:"deselectPage",
            scope: "page",
            select: false
        }, {
            labelId:"invertAll",
            scope: "all",
            select: "invert"
        }, {
            labelId:"invertPage",
            scope: "page",
            select: "invert"
        }]
        this.filesFilterAttribute = "==select=="
        this.fileFilterExpanded = false


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
        }

        _filterItems(){
            if(this.filesFilterCondition == "havingAttribute"){
                if(this.filesFilterAttribute != "==select=="){
                    return this.data.files.filter(file => {
                        return (this.filesFilterPn == "p") == this.filesFilterAttribute in file.metadata
                    }, this)
                }
            } else if(this.filesFilterCondition == "attributeValue"){
                if(this.filesFilterAttribute != "==select==" && this.filesFilterQuery != ""){
                    return this.data.files.filter(file => {
                        return (this.filesFilterPn == "p") == (file.metadata[this.filesFilterAttribute] == this.filesFilterQuery)
                    }, this)
                }
            } else if(this.filesFilterQuery !== ""){
                let re = window.getFilterRegEx(this.filesFilterQuery, this.filesFilterCondition)
                return this.data.files.filter(file => {
                    return (this.filesFilterPn == "p") == (file.filename_display.match(re) != null)
                }, this)
            }
            return this.data.files
        }

        updateAttributes(){
            this.allFiles = this.data.files
            this.filesets = this.data.filesets
            this.hasFilesets = !!this.filesets.length
            this.filesetsLoaded = this.data.filesetsLoaded && this.data.filesWithoutfFolderLoaded
            this.showResultsFrom = (this.page - 1) * this.itemsPerPage
            this.filteredFiles = this._filterItems()
            this._sort("filesets", this.filesets)
            this._sort("files", this.filteredFiles)
            this.files = this.filteredFiles.slice((this.page - 1) * this.itemsPerPage, this.page * this.itemsPerPage)
            this.allFilesetsReady = CAStore.allFilesetsReady()
            this.activeFileset = this.filesets[this.data.activeFilesetId]
            this.activeFilesetIsInProgress = this.activeFileset ? (this.activeFileset.progress > 0 && this.activeFileset.progress < 100) : false
            this.total = CAStore.getTotalWordCount()
            this.selectedCountAll = this.getSelectedFiles(true).length
            this.selectedCount = this.getSelectedFiles().length
            this.filesFilterAttributeOptions = CAStore.getAttributeList()
            this.filesFilterAttributeOptions.unshift({
                label: _("selectValue"),
                value: "==select=="
            })
            this.updateSpace()
        }
        this.updateAttributes()

        onFilesetClick(evt){
            this.files = []
            CAStore.setActiveFilesetId(this.opts.corpus.id, evt.item.fileset.id)
        }

        onFileSelectChange(evt){
            evt.stopPropagation()
            let idx = evt.item.idx
            let selected = !evt.item.file.selected
            let fromIdx = evt.shiftKey ? Math.min(idx, this.lastSelectedLineIdx) : idx
            let toIdx = evt.shiftKey ? Math.max(idx, this.lastSelectedLineIdx) : idx
            for(let i = fromIdx; i <= toIdx; i++){
                $("#chb_" + i).prop("checked", selected)
                this.data.files[(this.page - 1) * this.itemsPerPage + i].selected = selected
            }
            this.lastSelectedLineIdx = idx
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
                    class: "btn-primary",
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
            let url = window.config.URL_CA + "corpora/" + this.opts.corpus.id + "/documents/" + this.dropdownMenuFile.id + "/original"
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
                    class: "btn-primary",
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
            CAStore.cancelFilesetProcess(this.opts.corpus.id, evt.item.fileset.id)
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
                    class: "btn-primary",
                    onClick: function(dialog, modal){
                        dialog.contentTag.save()
                        this.update()
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
                large: true,
                opts: {
                    corpus_id: this.opts.corpus.id,
                    file_ids: file_ids
                },
                buttons: [{
                    label: _("save"),
                    id: "bulkSaveBtn",
                    class: "btn-primary disabled",
                    onClick: function(dialog, modal){
                        dialog.contentTag.save()
                        this.update()
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
                    class: "btn-primary",
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

        onSelectionMenuItemClick(evt){
            let items = evt.item.option.scope == "all" ? this.filteredFiles : this.files
            items.forEach(item => {
                if(evt.item.option.select == "invert"){
                    item.selected = !item.selected
                } else {
                    item.selected = evt.item.option.select
                }
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

        onFileFilterToggleClick(evt){
            evt.preventUpdate = true
            this.fileFilterExpanded = !this.fileFilterExpanded
            $(this.refs.fileFilter).slideToggle()
            $(this.refs.fileFilterArrow).html(this.fileFilterExpanded ? "arrow_drop_up" : "arrow_drop_down")
        }

        onFilesFilterPnChange(value){
            this.filesFilterPn = value
            this.update()
        }

        onFilesFilterConditionChange(value){
            if(value == "havingAttribute" || value == "attributeValue"){
                this.filesFilterQuery = ""
            } else {
                if(this.filesFilterCondition != "havingAttribute" && this.filesFilterCondition != "attributeValue"){
                    this.filesFilterAttribute = "==select=="
                }
            }
            this.filesFilterCondition = value
            this.update()
        }

        onFilesFilterQueryChange(value){
            this.filesFilterQuery = value
        }

        filesFilterAttributeChange(value){
            this.filesFilterAttribute = value
            this.update()
        }

        filterFiles(){
            this.page = 1
            this.update()
        }

        clearFilter(){
            this.filesFilterQuery = ""
            this.filesFilterAttribute = "==select=="
        }

        getFile(file_id){
            return this.files.find(f => {
                return f.id == file_id
            })
        }

        initDropdown(){
            if($("#bulkActionBtn").length && !M.Dropdown.getInstance($("#bulkActionBtn"))){
                $("#bulkActionBtn").dropdown({
                    constrainWidth: false,
                    container: document.getElementById("bulkMenuContainer")
                })
            }
            if($("#selectionBtn").length && !M.Dropdown.getInstance($("#selectionBtn"))){
                $("#selectionBtn").dropdown({
                    constrainWidth: false,
                    coverTrigger: false
                })
            }
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
