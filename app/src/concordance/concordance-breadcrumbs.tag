<breadcrumb-info class="breadcrumb-info">
    <h5>{_("resultDetails")}</h5>
    <b>

    <span each={operation, opIdx in data.operations}
            if={opIdx <= idx}
            class="operation inline-block">
        <i if={opIdx != 0} class="material-icons delimiter">chevron_right</i>
        {_(operation.name, {_: operation.name})}
        <span class="params" if={operation.arg}>{operation.arg}</span>
        <span if={operation.contextStr}>
            |
            <!--span>{_(parent.data.showcontext == "pos" ? "posContext" : "lemmaContext")}</span>
            <span class="params">
                {parent.opts.contextStr}
            </span-->
        </span>
    </span>
    </b>
    <div class="flex flexWrapper">
        <table class="material-table mt-4 mb-4">
            <tr>
                <td>{_("numOfHits")}</td>
                <td>{window.Formatter.num(desc.size)}</td>
            </tr>
            <tr>
                <td>{_("relNumOfHits")}</td>
                <td>{window.Formatter.num(desc.rel)}</td>
            </tr>
            <tr>
                <td>{_("percentOfCorpus")}</td>
                <td>{percentOfCorpus.toPrecision(4)}%</td>
            </tr>
            <tr if={idx != 0}>
                <td>{_("percentOfFirst")}</td>
                <td>{Number(percentOfFirst).toPrecision(4)}%</td>
            </tr>
            <tr if={idx >= 2}>
                <td>{_("percentOfPrevious")}</td>
                <td>{Number(percentOfPrevious).toPrecision(4)}%</td>
            </tr>
            <tr if={data.raw.star}>
                <td>{_("averageRating")}</td>
                <td>
                    {Math.round(data.raw.star * 10) / 10}
                    <i class="breadcrumbIcon material-icons amber-text">star</i>
                </td>
            </tr>
            <tr if={data.raw.docf}>
                <td>{_(parent.corpus.hasStarAttr ? "mr" : "wl.docf")}</td>
                <td>
                    {window.Formatter.num(data.raw.docf)}
                    <i class="breadcrumbIcon material-icons grey-text">description</i>
                </td>
            </tr>
            <tr if={data.raw.reldocf}>
                <td>{_(parent.corpus.hasStarAttr ? "relmr" : "reldocf")}</td>
                <td>
                    {window.Formatter.num(data.raw.reldocf)}%
                    <i class="breadcrumbIcon material-icons grey-text">description</i>
                </td>
            </tr>
            <tr>
                <td>{_("corpusSize")} ({_("tokens").toLowerCase()})</td>
                <td>{window.Formatter.num(parent.corpus.sizes.tokencount)}</td>
            </tr>
        </table>
        <div ref="chartContainer"
                class="concDist">
            <div class="mt-2 pl-8 concDistHeader">{_("cc.freqDistrib")}</div>
            <concordance-distribution if={showChart}
                    just-chart=1
                    concordance-query={query}
                    page-tag={opts.pageTag}
                    granularity={chartGranularity}
                    height={chartHeight}
                    width={chartWidth}
                    on-click={Dispatcher.trigger.bind(null, "closeDialog")}></concordance-distribution>
        </div>
    </div>

    <script>
        require("concordance/concordance-distribution.tag")
        this.store = this.opts.pageTag.store
        this.idx = this.parent.opts.idx * 1
        this.query = this.store.getConcordanceQuery().splice(0, this.idx + 1)
        this.parent = this.opts.parent
        this.data = this.parent.data
        this.desc = this.parent.desc
        this.percentOfCorpus = this.desc.size / (this.parent.corpus.sizes.tokencount / 100)
        if(this.idx != 0){
            this.percentOfFirst = this.desc.size / (this.parent.parent.desc[0].size / 100)
        }
        if(this.idx >= 2){
            this.percentOfPrevious = this.desc.size / (this.parent.parent.desc[this.idx - 1].size / 100)
        }
        this.on("mount", ()=>{
            // wait for dialog to open
            setTimeout(() => {
                this.chartWidth = Math.round(this.refs.chartContainer.offsetWidth) - 12 //scrollbar
                this.chartHeight = Math.min(this.chartWidth / 2.5, 300)
                this.chartGranularity = Math.round((this.chartWidth - 90) / 5)
                this.showChart = true
                this.update()
            }, 400)
        })
    </script>
</breadcrumb-info>


<breadcrumb-chip class="bc-{idx + 1} {bcLast: isLast} z-depth-1 {active: opts.active} {cursor-pointer: operations.length > 1}"
        onclick={onOperationClick}>
    <div class="firstRow">
        <span>{_(opts.operation.name, {_ : opts.operation.name})}</span>
        <span if={showOf10M()}
            class="grey-text tooltipped"
            data-tooltip="{_(data.random ? 'breadcrumbsFilterRandom10MTip' : 'breadcrumbsFilterFirst10MTip')}">
            ({_(data.random ? "breadcrumbsFilterRandom10M" : "breadcrumbsFilterFirst10M")})
        </span>
        <span class="params truncate" if={opts.arg} onmouseover={showTooltip}>{opts.arg}</span>
        <!--span if={opts.contextStr}>
            |
            <span>{_(data.showcontext == "pos" ? "posContext" : "lemmaContext")}</span>
            <span class="params truncate" onmouseover={showTooltip}>
                {opts.contextStr}
            </span>
        </span-->
        ●
        <span if={desc && (!data.isLoading || isLast || isLastActive)}
                class="size tooltipped"
                data-tooltip={_("numOfHits")}>
            {isNaN(size) || size == -1 ? "" : window.Formatter.num(size)}
            <span if={data.isCountLoading}
                    class="dotsAnimation">
                <span>...</span>
            </span>
        </span>
        <span if={!data.isLoading && (isLast || isLastActive) && data.raw.star}
                class="tooltipped"
                data-tooltip={_("averageRating")}>
            ●
            <i class="breadcrumbIcon material-icons amber-text">star</i>
            {Math.round(data.raw.star * 10) / 10}
        </span>
    </span>
    <span if={idx != 0 || opts.contextStr}
            class="closeBtn btn btn-floating grey lighten-4">
        <i class="close material-icons"
                onclick={onCloseClick}>close</i>
    </span>
    </div>
    <div class="secondRow">
        <span if={!data.isLoading} class="relsize">
            {getRelSize()}
            ●
            <span class="tooltipped" data-tooltip={_("percentOfCorpus")}>
                {Number((this.size / this.store.corpus.sizes.tokencount * 100).toPrecision(2))}%
            </span>
            <span if={data.raw.reldocf} class="tooltipped" data-tooltip={parent.corpus.hasStarAttr ? "t_id:relmr" : _("reldocf")}>
                ●
                <i class="breadcrumbIcon material-icons grey-text">description</i>
                {window.Formatter.num(data.raw.reldocf)}%
            </span>
        </span>

        <i class="infoBtn material-icons material-clickable" onclick={showInfo}>info</i>
    </div>

    <script>
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")


        updateAttributes(){
            this.idx = this.opts.idx * 1
            this.desc = this.parent.desc ? this.parent.desc[this.idx] : null
            this.size = this.desc ? this.desc.size : ""
            this.operations = this.parent.operations
            this.isLast = this.operations.length ==  this.idx + 1
            this.isLastActive = this.isLast && this.opts.active//this.parent.desc ? this.parent.desc.length == this.opts.idx + 1 : false
        }
        this.updateAttributes()

        shouldUpdate(data, nextOpts){
            // do not redraw inactive chips (raw.Desc is not available for inactive)
            return this.opts.active || nextOpts.active
        }

        showOf10M(evt){
            // breadcrumb is the first filter operation and previous operation has more than 10M results
            return this.data.total < this.data.fullsize
                    && this.opts.operation.name == "filter"
                    && this.parent.operations.findIndex(o => o.name == "filter") == this.idx // is the first filter
                    && this.parent.desc[this.idx - 1]
                            && this.parent.desc[this.idx - 1].size
                            && this.parent.desc[this.idx - 1].size >= 10000000
        }

        getRelSize(){
            if(!this.desc || isNaN(this.desc.rel)){
                return ""
            }
            if(this.desc.rel){
                return window.Formatter.num(this.desc.rel) + " " + _("freqPerMillion").toLowerCase()
            } else if(this.desc.size){
                return  _("cc.lessThan001")
            }
        }

        onOperationClick(evt){
            if(evt.target.nodeName != "I"){
                if(this.operations.length == 0){
                    return // there is only initial operation -> no reason to allow click on it
                }
                if(this.isLastActive){
                    return
                }
                this.store.goToOperation(this.operations[this.idx])
            }
        }

        onCloseClick(evt){
            evt.stopPropagation()
            evt.preventDefault()
            evt.preventUpdate = true
            evt.item.operation.name == "context" && this.store.resetContext()
            this.store.removeOperation(evt.item.operation)
        }

        showInfo(evt){
            Dispatcher.trigger("openDialog", {
                tag: "breadcrumb-info",
                opts: {
                    pageTag: this.pageTag,
                    parent: this
                }
            })
        }

        showTooltip(evt){
            evt.preventUpdate = true
            let node = evt.currentTarget
            if(node.clientWidth < node.scrollWidth){
                window.showTooltip(node, node.innerHTML)
                evt.stopPropagation()
            }
        }

        this.on("update", this.updateAttributes)
    </script>
</breadcrumb-chip>


<concordance-breadcrumbs class="concordance-breadcrumbs">
    <a href="javascript:void(0);"
            if={showShuffle}
            id="breadcrumbsWarning"
            class="cbttp warningBtn btn btn-floating {red: !data.random}"
            data-tooltip={_(data.random ? "concRandom10M" : "concFirst10M", [Formatter.num(data.total)])}
            onclick={onRandomClick}>
        <i class="material-icons">
            priority_high
        </i>
    </a>

    <i if={showSlowWarning}
        class="slowWarning cbttp material-icons red-text flipHorizontal"
        data-tooltip={_("slowConcordanceWarning")}>
        speed
    </i>

    <virtual if={desc}>
        <subcorpus-chip on-change={onSubcorpusChange}></subcorpus-chip>
        <text-types-chip on-change={onTextTypesChange}
                disable-structure-mixing={false}></text-types-chip>
        <breadcrumb-chip idx=0
                active={true}
                arg={firstOp.arg}
                operation={firstOp}
                context-str={contextStr}></breadcrumb-chip>

        <virtual each={operation, idx in operations}>
            <i if={idx !=0} class="material-icons delimiter">chevron_right</i>
            <breadcrumb-chip if={idx !=0}
                    idx={idx}
                    active={!operation.inactive}
                    operation={operation}
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

        this.tooltipClass = ".cbttp"
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.operations = Object.assign(this.data.annotconc ? (this.data.operations_annotconc || []) : this.data.operations)
            this.firstOp = this.operations[0]
            this.lastOp = this.operations[this.operations.length - 1]
            this.sort = this.data.sort.reduce((str, sort) => {
                return str + (str ? ", " : "") + (sort.label || sort.attr)
            }, "")
            if(this.data.sort[0] && this.data.sort[0].corpname){
                this.sort = "(" + this.store.getAlignedLangName(this.data.sort[0].corpname) + ") "  + this.sort
            }

            this.desc = this.data.breadcrumbsDesc || (this.data.raw ? this.data.raw.Desc : null)
            this.showShuffle = this.data.total < this.data.fullsize
            this.showSlowWarning = this.data.itemsPerPage > 200 || (this.data.itemsPerPage > 50 && this.data.attrs.split(",").length > 1 && this.data.attr_allpos == "all")
        }
        this.updateAttributes()

        onRandomClick(){
            this.store.toggleRandom()
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
                gdex_enabled: false
            })
        }

        onJumpToClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("concordanceOpenJumpTo")
        }

        onSubcorpusChange(usesubcorp){
            this.store.reloadActualResults && this.store.reloadActualResults({usesubcorp: usesubcorp})
        }

        onTextTypesChange(tts){
            this.store.reloadActualResults && this.store.reloadActualResults({tts: tts})
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
