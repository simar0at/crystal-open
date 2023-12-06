<text-type class="text-type" data-testing-name={textTypeName}>
    <div class="card {expanded:expanded, collapsed: !expanded, hasSelection: selection.length && !isRE}" onclick={onCardClick}>
        <div class="{overlay: disabled}"></div>
        <div class="card-content">
            <div class="buttons right">
                <a id="btnShowDetail" onclick={onShowDetailView} class="iconButton btn btn-floating btn-flat">
                    <i class="material-icons grey-text text-darken-1">zoom_out_map</i>
                </a>
                <a if={opts.textType.attr_doc && expanded} href={opts.textType.attr_doc} target="_blank" class="iconButton btn btn-floating btn-flat">
                    <i class="material-icons grey-text text-darken-1">info_outline</i>
                </a>
            </div>
            <span if={!expanded && selection.length} class="chip left btn-chip white-text" onclick={toggleExpand}>
                {selection.length}
            </span>
            <span class="card-title" onclick={onTitleClick}>
                <span class="inline {truncate: !expanded}">
                    {opts.textType.label}
                </span>
                <i class="material-icons inline-block vertical-top">{expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"}</i>
            </span>
            <text-type-selection if={expanded} text-type={opts.textType}></text-type-selection>
            <text-type-list if={expanded && !isRE} ref="list" text-type={opts.textType}></text-type-list>
            <div if={expanded && isRE} class="warningRE">{_("cannotCombineRE")}</div>
        </div>
    </div>
    <script>
        require("./text-type.scss")
        this.textTypeName = this.opts.textType.name
        this.textTypesTag = this.parent

        updateAttributes(){
            this.selection = this.textTypesTag.getSelection(this.textTypeName)
            this.isRE = this.selection[0] && this.selection[0].startsWith("%RE%")
            this.expanded = opts.textType.expanded
            this.disabled = opts.textType.disabled || this.textTypesTag.disabled
        }
        this.updateAttributes()

        onShowDetailView(textType){
            this.textTypesTag.toggleDetail(this.opts.textType)
        }

        onCloseDetail(){
            this.textTypesTag.toggleDetail(null)
        }

        onCardClick(evt){
            evt.preventUpdate = true
            !this.expanded && !this.disabled && this.toggleExpand()
        }

        onTitleClick(evt){
            this.toggleExpand()
            evt.stopPropagation()
        }

        toggleExpand(){
            this.textTypesTag.toggleExpand(this.textTypeName)
            !this.opts.textType.disabled && $("input:visible", this.root).focus()
        }

        onTextTypeChange(textType){
            (textType.name == this.textTypeName) && this.update()
        }

        refreshListheight(){
            // update list height to use maximum of available space
            if(this.isMounted){
                let list = $(".ui-list-list", this.root)
                let ttList = $("text-type-list", this.root)[0]
                if(list[0] && ttList){
                    let rest = 355 - list[0].offsetTop - ttList.offsetTop
                    list.css("max-height", rest)
                }
            }
        }

        this.on("updated", this.refreshListheight)

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            delay(this.refreshListheight, 1) // wait so rest of page is generated
            this.textTypesTag.on("textTypeChange", this.onTextTypeChange)
        })

        this.on("unmount", () => {
            this.textTypesTag.off("textTypeChange", this.onTextTypeChange)
        })
    </script>
</text-type>
