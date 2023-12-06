<breadcrumb-chip class="bc-{(opts.idx * 1) + 1} {bcLast: isLast} chip z-depth-1 {active: opts.active} {disabled: disabled}"
        onclick={!disabled ? onOperationClick : null}>
    <span>{_(opts.name, {_ : opts.name})}</span>
    <span class="params truncate" if={opts.arg} onmouseover={showTooltip}>{opts.arg}</span>
    <span if={opts.contextStr}>
        |
        <span>{_(data.showcontext == "pos" ? "posContext" : "lemmaContext")}</span>
        <span class="params truncate" onmouseover={showTooltip}>
            {opts.contextStr}
        </span>
    </span>

    <span if={desc && (!data.isLoading || isLast || isLastActive)} class="size">
        {isNaN(size) || size == -1 ? "" : window.Formatter.num(size)}
        <span if={data.isCountLoading} class="dotsAnimation">
            <span>...</span>
        </span>
    </span>
    <span if={!data.isLoading && (isLast || isLastActive)} class="relsize">
        {getRelSize()}
    </span>
    <i if={!disabled && (opts.idx != 0 || opts.contextStr)}
            class="close material-icons"
            onclick={onCloseClick}>close</i>

    <script>
        this.mixin("feature-child")


        updateAttributes(){
            this.disabled = !this.store.isConc
            this.desc = this.parent.desc ? this.parent.desc[this.opts.idx] : null
            this.size = this.desc ? this.desc.size : ""
            this.operations = this.parent.operations
            this.isLastActive = this.parent.desc ? this.parent.desc.length == this.opts.idx + 1 : false
            this.isLast = this.operations.length ==  this.opts.idx + 1
        }
        this.updateAttributes()

        shouldUpdate(data, nextOpts){
            // do not redraw inactive chips (raw.Desc is not available for inactive)
            return this.opts.active || nextOpts.active
        }

        getRelSize(){
            if(!this.desc || isNaN(this.desc.rel)){
                return ""
            }
            if(this.desc.rel){
                return "(" + window.Formatter.num(this.desc.rel) + " " + _("perMillion") + ")"
            } else if(this.desc.size){
                return  _("cc.lessThan001")
            }
        }

        onOperationClick(idx){
            if(this.operations.length == 0){
                return // there is only initial operation -> no reason to allow click on it
            }
            this.store.goToOperation(this.operations[opts.idx])
        }

        onCloseClick(evt){
            evt.stopPropagation()
            evt.preventDefault()
            evt.preventUpdate = true
            evt.item.operation.name == "context" && this.store.resetContext()
            this.store.removeOperation(this.operations[evt.item.idx])
        }

        showTooltip(evt){
            evt.preventUpdate = true
            let node = evt.currentTarget
            if(node.clientWidth < node.scrollWidth){
                window.showTooltip(node, node.innerHTML, 600)
                evt.stopPropagation()
            }
        }

        this.on("update", this.updateAttributes)
    </script>
</breadcrumb-chip>


<concordance-breadcrumbs class="concordance-breadcrumbs">
    <a href="javascript:void(0);"
            if={showShuffle}
            class="cbttp"
            data-tooltip={_(data.random ? "cc.usingRandomTip" : "cc.usingFirst10MTip")}
            onclick={onRandomClick}
            style="margin-right: 5px;">
        <i class="material-icons {red-text: !data.random}" style="font-size: 35px;">
            error
        </i>
    </a>

     <virtual if={desc}>
        <subcorpus-chip on-change={onSubcorpusChange}></subcorpus-chip>
        <breadcrumb-chip idx=0
                active={!isDisabled}
                name={_(firstOp.name)}
                arg={firstOp.arg + tts}
                context-str={contextStr}></breadcrumb-chip>

        <virtual each={operation, idx in operations}>
            <i if={idx !=0} class="material-icons delimiter">chevron_right</i>
            <breadcrumb-chip if={idx !=0}
                    idx={idx}
                    active={operation.active && !isDisabled}
                    name={operation.name}
                    arg={operation.arg}></breadcrumb-chip>
        </virtual>

        <virtual if={sort || data.gdex_enabled}>
            <span class="pipe">|</span>
            <virtual if={data.gdex_enabled}>
                <span class="chip z-depth-1 sort" onclick={onGdexClick}>
                    <span>{_("sort")}</span>
                    <span class="params">GDEX</span>
                    <span class="params"
                            if={data.gdexconf}>({data.gdexconf == "__default__" ? _("cc.gdexDefault") : data.gdexconf})</span>
                    <i class="close material-icons" onclick={onGdexRemoveClick}>close</i>
                </span>
            </virtual>
            <virtual if={sort}>
                <span class="chip z-depth-1 sort" onclick={onSortClick}>
                    <span>{_("sort")}</span>
                    <span class="params">{sort}</span>
                    <i class="close material-icons" onclick={onSortRemoveClick}>close</i>
                </span>
                <a if={!isDef(opts.showJumpTo) || opts.showJumpTo} id="btnJumpTo" class="btn btn-floating btn-small orange lighten-2" onclick={onJumpToClick}>
                    <i class="material-icons white-text text-darken-1">redo</i>
                </a>
            </virtual>
        </virtual>
    </virtual>

    <script>
        require("./concordance-breadcrumbs.scss")
        require("./concordance-10m-dialog.tag")

        this.tooltipClass = ".cbttp"
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.operations = Object.assign(this.data.annotconc ? (this.data.operations_annotconc || []) : this.data.operations)
            this.firstOp = this.operations[0]
            this.lastOp = this.operations[this.operations.length - 1]
            this.sort = this.data.sort.reduce((str, sort) => {
                return str + (str ? ", " : "") + sort.attr
            }, "")
            this.tts = ""
            for(let textTypeName in this.store.data.selection){
                this.tts += this.tts ? ";" : ""
                this.tts += textTypeName + ":" + this.store.data.selection[textTypeName].join(",")
            }
            if(this.tts){
                this.tts = ", " + this.tts
            }

            //this.contextStr = this.store.getContextStr()
            this.desc = this.data.raw ? this.data.raw.Desc : null
            this.showShuffle = this.data.total < this.data.fullsize
            this.isDisabled = !this.store.isConc
        }
        this.updateAttributes()

        onRandomClick(){
            Dispatcher.trigger("openDialog", {
                id: "concordance10M",
                tag: "concordance-10m-dialog",
                small: true,
                opts:{
                    parent: this,
                    random: this.data.random
                }
            })
        }

        onSortClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "sort")
        }

        onSortRemoveClick(evt){
            evt.stopPropagation()
            this.store.searchAndAddToHistory({
                sort: []
            })
        }

        onGdexClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "gdex")
        }

        onGdexRemoveClick(evt){
            evt.stopPropagation()
            this.store.searchAndAddToHistory({
                gdexconf: "",
                gdex_enabled: 0
            })
        }

        onJumpToClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("concordanceOpenJumpTo")
        }

        onSubcorpusChange(subcorpus){
            this.store.onSubcorpusChange && this.store.onSubcorpusChange(subcorpus)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.store.on("countChange", this.update)
        })

        this.on("unmount", () => {
            this.store.off("countChange", this.update)
        })
    </script>
</concordance-breadcrumbs>
