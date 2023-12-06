<download class="download-tag">
    <div class="row">
        <div if={opts.opts.limit}>
            <raw-html content={_("downloadLimit", [opts.opts.limit, '<a href="' + window.config.accountLimitations + '" target="_blank">' + _('accountLimitations') + '</a>'])}>
            </raw-html>
            <br>
        </div>
        <div class="col {ptag.store.request.length == 2 ? 's6 center' : 's12'}">
            <span if={opts.opts.showLimit}>
            {_("downloadFirst")}
                <ui-input ref="limit"
                        riot-value={opts.opts.limit == 0 ? "" : opts.opts.limit}
                        validate=1
                        size=6
                        max={opts.opts.limit ? opts.opts.limit : null}
                        min=0
                        type="number"
                        inline=1></ui-input>
                {_("rows")}
                &nbsp;&nbsp;
            </span>
            <h6 if={ptag.store.request.length == 2}
                    style="font-size: large; margin: 0 0 .5em 0;">{_("keywords")}</h6>
            <a class="btn waves-effect btn-crystal tooltipped"
                    onclick={download}
                    data-tooltip={_(format + "Warning")}
                    each={format in opts.opts.formats}>
                <i class="ske-icons skeico_{format}"></i>
                {format.toUpperCase()}
            </a>
            <a class="btn waves-effect btn-crystal tooltipped"
                    if={showSVG} download="ske-viz.svg"
                    href={exportSVG()}
                    target="_blank"
                    data-tooltip="svgWarning">
                <i class="ske-icons skeico_xml"></i> SVG
            </a>
        </div>
        <div class="col s6 center" if={ptag.store.request.length == 2}>
            <h6 style="font-size: large; margin: 0 0 .5em 0;">{_("terms")}</h6>
            <a class="btn waves-effect btn-crystal tooltipped"
                    onclick={download.bind(this, 1)}
                    data-tooltip={_(format + "Warning")}
                    each={format in opts.opts.formats}>
                <i class="ske-icons skeico_{format}"></i>
                {format.toUpperCase()}
            </a>
        </div>
    </div>
    <div class="row" style="border: solid 1px black; border-width: 1px 0 0 0; margin-top: 1em;">
        <div class="col s12">
            <p>{_("pdfLabel")}
                <a class="btn waves-effect btn-crystal tooltipped" onclick={pdf_print}
                        data-tooltip={_("pdfWarning")}>
                    <i class="ske-icons skeico_pdf"></i> PDF
                </a>
            </p>
        </div>
    </div>
    <div class="row">
        <div class="col s12 center">{_("wOpenWarning")}</div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        this.tooltipPosition = "top"
        this.mixin("tooltip-mixin")
        this.ptag = getPageParent(this)
        this.showSVG = !!jQuery('svg[id^=ske-viz]:visible').length

        // https://stackoverflow.com/questions/38477972/javascript-save-svg-element-to-file-on-disk?rq=1
	exportSVG() {
            let svg = jQuery('svg[id^=ske-viz]:visible')[0]
            var svgDocType = document.implementation.createDocumentType('svg', "-//W3C//DTD SVG 1.1//EN", "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
            var svgDoc = document.implementation.createDocument('http://www.w3.org/2000/svg', 'svg', svgDocType)
            svgDoc.replaceChild(svg.cloneNode(true), svgDoc.documentElement)
            var svgData = (new XMLSerializer()).serializeToString(svgDoc)
            return 'data:image/svg+xml; charset=utf8, ' + encodeURIComponent(svgData.replace(/></g, '>\n\r<'))
        }

        pdf_print() {
            window.print()
        }

        download(e, f) {
            let i = f ? e : 0
            let ev = f ? f : e
            let p = this.ptag.store.data.page
            let request = this.ptag.store.request[i]
            if(this.opts.opts.showLimit){
                let limit = this.refs.limit.getValue() || 0
                this.parent.store.updateRequestData(request, {[opts.opts.limitName]: limit})
            }
            if ((this.ptag.store.feature == "concordance"
                    || this.ptag.store.feature == "parconcordance")
                    && (p && p > 1)) {
                Dispatcher.trigger("openDialog", {
                    id: "downloadConc",
                    type: "warning",
                    content: _("downloadConcWarning"),
                    title: _("downloadConcTitle"),
                    buttons: [{
                        label: _("download"),
                        showCloseButton: false,
                        onClick: function () {
                            Connection.download(request, ev.item.format)
                            Dispatcher.trigger("closeDialog")
                        }.bind(this)
                    }]
                })
            }
            else {
                Connection.download(request, ev.item.format)
            }
            return false
        }
    </script>
</download>

<feature-toolbar class="feature-toolbar">
    <div class="bar {opts.empty ? "left" : "right"}">
        <ul>
            <li each={option in menuItems}
                    class="ft-tooltip"
                    data-tooltip={option.tooltip || capitalize(getLabel(option))}>
                <raw-html if={typeof option.generator == "function"}
                        content={option.generator(option)}
                        onclick={option.onclick}></raw-html>
                <a if={!option.generator && !option.itemTag}
                    id="btn{option.id}"
                    class="waves-effect waves-light btn btn-floating  {active: (activeOptions && activeOptions.id == option.id)} {option.id == parent.opts.pulseId ? 'pulse' : 'btn-flat'} {option.btnClass}"
                    disabled={isDef(option.disabled) ? option.disabled : parent.opts.disabled}
                    onclick={isFun(option.onclick) ? option.onclick : onOptionClick.bind(this, option.id)}>
                    <i class="{option.iconClass}">{option.icon}</i>
                </a>
                <div if={option.itemTag}
                        style={"padding-top: 4px": option.isButton}
                        class={"waves-effect waves-light btn btn-floating btn-flat": option.isButton}>
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
        <div class="activeOptions z-depth-3 card-content">
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

    <script>
        require("./feature-toolbar.scss")

        const {Auth} = require("core/Auth.js")

        this.tooltipClass = ".ft-tooltip"
        this.mixin("tooltip-mixin")

        this.activeOptions = null
        this.store = opts.store
        this.isFullAccount = Auth.isFullAccount()

        setActiveOptions(optionsId){
            if(!optionsId){
                this.closeOptions()
            } else if(!this.activeOptions || this.activeOptions.id != optionsId){
                let wasOpen = !!this.activeOptions
                this.activeOptions = this.getOptions(optionsId)
                if(optionsId == "settings"){
                    this.store.saveState()
                }
                this.update()

                !wasOpen && $("#activeOptionsWrapper", this.root).css({display: "none"})
                isFun(this.opts.onOpen) && this.opts.onOpen(this.activeOptions.id)
                this.refs.active && delay(() => {$("#activeOptionsWrapper", this.root).slideDown()}, 10)
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

        this.on("update", this.updateAttributes)

        this.on("updated", this.mountItems)

        this.on("mount", () => {
            this.mountItems()
            Dispatcher.on("FEATURE_TOOLBAR_SHOW_OPTIONS", this.setActiveOptions)
            Dispatcher.on("CHANGE_CRITERIA", this.showSettings)
        })

        this.on("unmount", () => {
            Dispatcher.off("FEATURE_TOOLBAR_SHOW_OPTIONS", this.setActiveOptions)
            Dispatcher.off("CHANGE_CRITERIA", this.showSettings)
        })

    </script>
</feature-toolbar>
