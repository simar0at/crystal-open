<download class="download-tag">
    <div if={opts.limit || opts.formats || opts.showLimit || showSVG}
            class="row dividerBottom pb-8" >
        <div if={opts.limit}>
            <raw-html content={_("downloadLimit", [opts.limit, '<a href="' + window.config.accountLimitations + '" target="_blank">' + _('accountLimitations') + '</a>'])}>
            </raw-html>
            <br>
        </div>
        <span if={store.feature != "keywords" || kwWithKeywords}
                class="col inline-block mr-10">
            <span if={opts.showLimit}>
            {_("downloadFirst")}
                <ui-input ref="limit"
                        riot-value={opts.limit == 0 ? "" : opts.limit}
                        validate=1
                        size=6
                        max={opts.limit ? opts.limit : null}
                        min=0
                        type="number"
                        inline=1></ui-input>
                {_("rows")}<virtual if={isConcordance && store.isConc && data.viewmode == 'kwic'}><span>
                        ,&nbsp;
                            {_("context-size")}
                            <sup class="tooltipped" data-tooltip="t_id:conc_r_download_ctx">
                                ?
                            </sup>
                        </span>
                        <ui-input ref="context"
                                size=4
                                inline=1
                                type="number"
                                riot-value={data.downloadcontext === "" ? ctxMax : data.downloadcontext}
                                min=0
                                max={ctxMax}
                                validate=1></ui-input>
                    </virtual>
                &nbsp;
                &nbsp;
            </span>
            <h6 if={kwWithKeywords}
                    style="font-size: large; margin: 0 0 .5em 0;">{_("keywords")}</h6>
            <a class="btn tooltipped mr-4"
                    onclick={download.bind(this, 0, format)}
                    data-tooltip={_(format + "Warning")}
                    each={format in opts.formats}>
                <i class="ske-icons skeico_{format}"></i>
                {format.toUpperCase()}
            </a>
            <a class="btn tooltipped mr-4"
                    if={showSVG}
                    onclick={exportSVG}
                    data-tooltip={_("svgWarning")}>
                <vis-icon class="download"></vis-icon> SVG
            </a>
            <a class="btn tooltipped mr-4"
                    if={showSVG}
                    onclick={exportPNG}
                    data-tooltip={_("downloadVizDesc")}>
                <vis-icon class="download"></vis-icon> PNG
            </a>
        </span>
        <span if={kwWithTerms} class="col inline-block mr-10">
            <h6 style="font-size: large; margin: 0 0 .5em 0;">{_("terms")}</h6>
            <a class="btn tooltipped mr-4"
                    onclick={download.bind(this, kwWithKeywords ? 1 : 0, format)}
                    data-tooltip={_(format + "Warning")}
                    each={format in opts.formats}>
                <i class="ske-icons skeico_{format}"></i>
                {format.toUpperCase()}
            </a>
        </span>
        <span if={kwWithNgrams} class="col inline-block mr-10">
            <h6 style="font-size: large; margin: 0 0 .5em 0;">{_("ngrams")}</h6>
            <a class="btn tooltipped mr-4"
                    onclick={download.bind(this, (kwWithKeywords * 1) + (kwWithTerms * 1), format)}
                    data-tooltip={_(format + "Warning")}
                    each={format in opts.formats}>
                <i class="ske-icons skeico_{format}"></i>
                {format.toUpperCase()}
            </a>
        </span>

        <span if={kwWithWipo} class="col inline-block mr-10">
            <h6 style="font-size: large; margin: 0 0 .5em 0;">WIPO</h6>
            <a class="btn tooltipped mr-4"
                    onclick={download.bind(this, (kwWithKeywords * 1) + (kwWithTerms * 1) + (kwWithNgrams * 1), "csv")}
                    data-tooltip={_("csvWarning")}>
                <i class="ske-icons skeico_csv"></i>
                {format.toUpperCase()}
            </a>
        </span>
    </div>
    <div class="row">
        <div class="col s12 mt-4">
            <p>{_("pdfLabel")}
                &nbsp;
                <a class="btn tooltipped mr-4" onclick={pdf_print}
                        data-tooltip={_("pdfWarning")}>
                    <i class="ske-icons skeico_pdf"></i> PDF
                </a>
            </p>
            <br>
            <raw-html content={_("seeDownloadLimits", ['<a target="_blank" href="' + externalLink("accountLimitations") + '">' + _("downloadLimits") + '</a>'])}></raw-html>
        </div>
    </div>
    <div class="row">
        <div class="col s12 center">{_("wOpenWarning")}</div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require('core/Auth.js')
        this.tooltipPosition = "top"
        this.mixin("tooltip-mixin")
        this.ptag = getPageParent(this)
        this.store = this.ptag.store
        this.data = this.store.data
        this.showSVG = !!jQuery('svg[id^=ske-viz]:visible').length
        this.isConcordance = this.store.feature == "concordance" || this.store.feature == "parconcordance"
        this.ctxMax = this.store.corpus.id ? 500 : 100
        this.kwWithKeywords = this.store.feature == "keywords" && this.store.data.usekeywords
        this.kwWithTerms = this.store.feature == "keywords" && this.store.data.useterms
        this.kwWithNgrams = this.store.feature == "keywords" && this.store.data.usengrams
        this.kwWithWipo = this.store.feature == "keywords" && this.store.data.do_wipo && !this.store.data.t_notAvailable


        pdf_print() {
            window.print()
        }

        download(requestIdx, format) {
            let p = this.data.page
            let request = this.store.getDownloadRequest(requestIdx)
            if(Auth.isAcademic()){
                request.data.export_note = _("academicUseOnly")
            }
            if(this.opts.showLimit){
                let limit = this.refs.limit.getValue() || 0
                Object.assign(request.data, {[this.opts.limitName]: limit})
            }
            if(this.isConcordance && this.refs.context){
                let ctx = this.refs.context.getValue()
                if(ctx === ""){
                    ctx = this.ctxMax
                } else {
                    ctx = Math.min(this.ctxMax, Math.max(0, ctx))
                }
                this.store.data.downloadcontext = ctx
                ctx += "#"
                Object.assign(request.data, {
                    kwicleftctx: ctx,
                    kwicrightctx: ctx
                })
                this.store.saveUserOptions(["downloadcontext"])
            }
            if (this.isConcordance && this.store.isConc && (p && p > 1)) {
                Dispatcher.trigger("openDialog", {
                    id: "downloadConc",
                    type: "warning",
                    content: _("downloadConcWarning"),
                    title: _("downloadConcTitle"),
                    buttons: [{
                        label: _("download"),
                        showCloseButton: false,
                        onClick: function () {
                            Connection.download(request, format)
                            Dispatcher.trigger("closeDialog")
                        }.bind(this)
                    }]
                })
            }
            else {
                Connection.download(request, format)
            }
            return false
        }

        exportPNG(e) {
            import ('libs/ske-viz/src/index.js').then(skeViz => {
                skeViz.exportPNG()
            })
        }

        exportSVG(e) {
            import ('libs/ske-viz/src/index.js').then(skeViz => {
                skeViz.exportSVG()
            })
        }
    </script>
</download>

<feature-toolbar class="feature-toolbar">
    <div class="bar {opts.empty ? "left" : "right"}">
        <ul>
            <li each={option in menuItems}
                    class="{ft-tooltip: option.tooltip}"
                    data-tooltip={option.tooltip}>
                <raw-html if={typeof option.generator == "function"}
                        content={option.generator(option)}
                        onclick={option.onclick}></raw-html>
                <a if={!option.generator && !option.itemTag}
                    id="btn{option.id}"
                    class="btn btn-floating  {active: (activeOptions && activeOptions.id == option.id)} {option.id == parent.opts.pulseId ? 'pulse' : 'btn-flat'} {option.btnClass}"
                    disabled={isDef(option.disabled) ? option.disabled : parent.opts.disabled}
                    onclick={isFun(option.onclick) ? option.onclick : onOptionClick.bind(this, option.id)}>
                    <i class="{option.iconClass}">{option.icon}</i>
                </a>
                <div if={option.itemTag}
                        style={"padding-top: 4px": option.isButton}
                        class="{'btn btn-floating btn-flat': option.isButton} {disabled:option.disabled}">
                    <div ref="node-{option.id}"></div>
                </div>
            </li>
            <li if={isFullAccount && !opts.empty}>
                <favourite-toggle disabled={isEmpty || opts.disabled} store={opts.store}></favourite-toggle>
            </li>
        </ul>
    </div>
    <div class="clearfix"></div>

    <div if={activeOptions && activeOptions.contentTag} ref="active" id="activeOptionsWrapper" style={activeOptions ? "" : "display:none;"}>
        <div class="activeOptions z-depth-3 card-content card">
            <div class="optsHeader">
                <i class={activeOptions.iconClass}>{activeOptions.icon}</i>
                {getLabel(activeOptions)}
                <a class="btn btn-floating btn-flat close" onclick={onCloseClick}>
                    <i class="material-icons">close</i>
                </a>
            </div>
            <div class="optsContent">
                <div data-is={activeOptions ? activeOptions.contentTag : ""} opts={activeOptions ? activeOptions.contentOpts : ""}></div>
            </div>
        </div>
    </div>
    <annotation-box
            if={window.config.ENABLE_ANNOTATION && parent.data.annotconc}
            active={activeOptions && activeOptions.id == "annotate"}>
    </annotation-box>

    <script>
        require("./feature-toolbar.scss")
        require("./annotation-box.tag")

        const {Auth} = require("core/Auth.js")
        const {TextTypesStore} = require('../text-types/TextTypesStore.js')

        this.tooltipClass = ".ft-tooltip"
        this.mixin("tooltip-mixin")

        this.activeOptions = null
        this.store = opts.store
        this.isFullAccount = Auth.isFullAccount()

        setActiveOptions(optionsId, disableFocus){
            if(!optionsId){
                this.closeOptions()
            } else if(!this.activeOptions || this.activeOptions.id != optionsId){
                let activeOptions = this.getOptions(optionsId)
                if(!activeOptions){
                    return // ignore unknown options
                }
                let wasOpen = !!this.activeOptions
                this.activeOptions = activeOptions
                if(optionsId == "settings"){
                    this.store.saveState()
                }
                this.update()

                !wasOpen && $("#activeOptionsWrapper", this.root).css({display: "none"})
                isFun(this.opts.onOpen) && this.opts.onOpen(this.activeOptions.id)
                if(this.refs.active){
                    delay(() => {$("#activeOptionsWrapper", this.root).slideDown(400, () => {
                        !disableFocus && $(".mainFormField:visible", this.root)
                                .find("input[type=text], input[type=file], textarea, select, .ui-list-list")
                                .first()
                                .focus()
                    })}, 10)
                }
            }
        }

        getOptions(id){
            return this.menuItems.find(o => {
                return o.id == id
            })
        }

        updateAttributes(){
            if(this.opts.empty) {
                this.menuItems = this.opts.options
            } else {
                this.menuItems = [].concat(this.opts.settingsTag ? [{
                    id: "settings",
                    icon: "youtube_searched_for",
                    iconClass: "material-icons",
                    labelId: opts.newSearchLabel || "newSearch",
                    contentTag: opts.settingsTag
                }] : [],
                [{
                    id: "download",
                    icon: "file_download",
                    iconClass: "material-icons",
                    labelId: "download",
                    disabled: isDef(this.opts.downloadDisabled) ? this.opts.downloadDisabled : this.opts.store.data.isEmpty,
                    contentTag: "download",
                    contentOpts: {
                        store: this.opts.store,
                        formats: this.opts.formats,
                        limit: this.opts.downloadLimit,
                        showLimit: this.opts.showLimit,
                        limitName: this.opts.limitName
                    }
                }],
                this.opts.options)
            }
            this.menuItems.forEach(i => {
                if(!i.tooltip && (i.labelId || i.label)){
                     i.tooltip = capitalize(getLabel(i))
                }
            })
        }
        this.updateAttributes()
        this.activeOptions = this.getOptions(this.opts.active)

        onOptionClick(optionsId, evt){
            evt.preventUpdate = true
            if(this.activeOptions && optionsId == this.activeOptions.id){
                // clicked on open item -> close it
                this.restoreStoreAndClose()
            } else {
                this.setActiveOptions(optionsId)
            }
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            this.restoreStoreAndClose()
        }

        restoreStoreAndClose(){
            if(this.activeOptions && this.activeOptions.id == "settings"){
                this.store.restoreState()
            }
            this.closeOptions()
        }

        closeOptions(){
            if(this.activeOptions){
                isFun(this.opts.onClose) && this.opts.onClose(this.activeOptions)
                this.activeOptions = null
                if(this.refs.active){
                    $("#activeOptionsWrapper", this.root).slideUp()
                    delay(this.update.bind(this), 400) // remove from DOM after slide is finished
                } else{
                    this.update()
                }
            }
        }

        mountItems(){
            this.menuItems.forEach(option => {
                if(option.itemTag){
                    riot.mount(this.refs["node-" + option.id], option.itemTag, option.tagOpts || {})
                }
            })
        }

        showSettings(){
            this.setActiveOptions("settings")
        }

        showTT(){
            this.store.data.tab = "advanced"
            TextTypesStore.data.openToolbar = true
            this.setActiveOptions("settings", true)
        }

        this.on("update", this.updateAttributes)

        this.on("updated", this.mountItems)

        this.on("mount", () => {
            this.mountItems()
            Dispatcher.on("FEATURE_TOOLBAR_SHOW_OPTIONS", this.setActiveOptions)
            Dispatcher.on("CHANGE_CRITERIA", this.showSettings)
            Dispatcher.on("SHOW_TT", this.showTT)
            Dispatcher.on("FEATURE_TOOLBAR_HIDE_OPTIONS", this.restoreStoreAndClose)
        })

        this.on("unmount", () => {
            Dispatcher.off("FEATURE_TOOLBAR_SHOW_OPTIONS", this.setActiveOptions)
            Dispatcher.off("CHANGE_CRITERIA", this.showSettings)
            Dispatcher.off("SHOW_TT", this.showTT)
            Dispatcher.off("FEATURE_TOOLBAR_HIDE_OPTIONS", this.restoreStoreAndClose)
        })

    </script>
</feature-toolbar>
