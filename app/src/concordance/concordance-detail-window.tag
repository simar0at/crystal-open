<concordance-detail-window class="concordance-detail-window {wide: showArgs && showArgs.cols.length > 1}">
    <div if={show} class="z-depth-5 {displayLoadStructBtn: displayLoadStructBtn}">
        <div class="close center-align" onclick={onCloseClick}>
            <i class="material-icons grey-text">keyboard_arrow_down</i>
        </div>
        <ui-checkbox if={showArgs.cols.length > 1}
                class="mb-2 ml-6"
                label={_("showAllLanguages")}
                checked={data.detailShowAll}
                on-change={onShowAllCorporaChange}></ui-checkbox>
        <div if={!isLoading} class="cd-content rtlNode">
            <div if={showPrevNext && (!maxcontext || leftCtx < maxcontext) && (showArgs.cols[0].toknum - leftCtx > 0)}
                    class="center-align">
                <a class="btn btn-floating btn-flat" onclick={loadPrev}>
                    <i class="material-icons grey-text">more_horiz</i>
                </a>
            </div>
            <div class="" style="display: flex;flex-wrap: wrap; column-gap: 20px;">
                <div each={col in showArgs.cols}
                        if={isCorpnameDisplayed(col.corpname)}
                        style="flex: 1">
                    <div if={showArgs.cols.length > 1}>
                        <b>{col.name}</b>
                    </div>
                    <virtual if={details[col.corpname]}>
                        <span each={item in details[col.corpname].content}
                                class="str {item.class} {coll: item.coll} _t"
                                style={item.color ? "color: " + item.color : ""}>
                            {item.str}
                        </span>
                    </virtual>
                </div>
            </div>
            <div if={showPrevNext && (!maxcontext || rightCtx < maxcontext)}
                    class="center-align">
                <a class="btn btn-floating btn-flat" onclick={loadNext}>
                    <i class="material-icons grey-text">more_horiz</i>
                </a>
            </div>
        </div>
        <div if={!isLoading && displayLoadStructBtn} class="loadSturctBtn">
            <a href="javascript:void(0);"
                    class="btn"
                    onclick={loadStructure}>
                {_("displayWholeDoc")}
            </a>
        </div>
        <div if={isLoading} class="center-align loading">
            <preloader-spinner></preloader-spinner>
        </div>
    </div>

    <script>
        require("./concordance-detail-window.scss")
        const {Connection} = require("core/Connection.js")
        const {AppStore} = require("core/AppStore.js")
        const {UserDataStore} = require("core/UserDataStore.js")

        this.mixin("feature-child")

        this.show = false
        this.isLoading = false
        this.maxcontext = 50
        this.details = {}

        onShow(showArgs, evt){
            evt.openConcordanceDetail = true
            this.displayLoadStructBtn = this.opts.structctx
            this.showPrevNext = true
            this.showArgs = showArgs
            showArgs.cols.forEach(col => {
                let corpus = AppStore.getCorpusByCorpname(col.corpname)
                col.name = corpus ? corpus.name : col.corpname
            })
            this.leftCtx = 50
            this.rightCtx = 50
            this.show = true
            this.isLoading = true
            this.details = {}
            this.loadData()
            this.update()
            this.root.classList.add("show")
            setTimeout(() => {
                // wait for opening animation
                document.addEventListener('click', this.handleDocumentClick)
            }, 200)
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            this.close()
        }

        onShowAllCorporaChange(checked){
            this.data.detailShowAll = checked
            if(checked){
                this.loadData()
            } else {
                this.update()
            }
            this.store.saveUserOptions(["detailShowAll"])
        }

        close(){
            if(this.show){
                document.removeEventListener('click', this.handleDocumentClick)
                this.show = false
                this.root.classList.remove("show")
                delay(this.update, 200)
                if(isFun(this.showArgs.onClose)){
                    this.showArgs.onClose()
                }
            }
        }

        onDataLoaded(corpname, payload){
            this.isLoading = false
            this.details[corpname] = payload
            this.maxcontext = Math.max(...Object.values(this.details).map(item => item.maxcontext))
            this.update()
        }

        loadData(){
            this.showArgs.cols.forEach(col => {
                Connection.get({
                    url: window.config.URL_BONITO + "widectx",
                    data: {
                        pos: col.toknum,
                        corpname: col.corpname || AppStore.getActualCorpname(),
                        hitlen: col.hitlen || 1,
                        structs: this.showArgs.structs || "g",
                        detail_left_ctx: this.leftCtx,
                        detail_right_ctx: this.rightCtx
                    },
                    done: this.onDataLoaded.bind(this, col.corpname),
                    fail: payload => {
                        SkE.showError("Could not load concordance data.", getPayloadError(payload))
                    }
                })
            })
        }

        loadStructure(evt){
            evt.stopPropagation()
            this.displayLoadStructBtn = false
            this.showPrevNext = false
            Connection.get({
                url: window.config.URL_BONITO + "structctx",
                data: {
                    pos: this.showArgs.cols[0].toknum,
                    corpname: this.showArgs.corpname || AppStore.getActualCorpname(),
                    struct: this.opts.structctx
                },
                done: this.onDataLoaded.bind(this, this.showArgs.corpname),
                fail: payload => {
                    SkE.showError("Could not load structure.", getPayloadError(payload))
                }
            })
        }

        loadPrev(evt){
            evt.stopPropagation()
            this.leftCtx += 100
            this.loadData()
        }

        loadNext(evt){
            evt.stopPropagation()
            this.rightCtx += 100
            this.loadData()
        }

        handleDocumentClick(evt){
            // if user clicks on another KWIC, do not close the window
            if(!evt.openConcordanceDetail && !this.root.contains(evt.target)){
                this.close()
            }
        }

        isCorpnameDisplayed(corpname){
            return this.data.detailShowAll || corpname == this.showArgs.corpname
        }

        this.on("mount", () => {
            Dispatcher.on("concordanceShowDetail", this.onShow)
            Dispatcher.on("ESCAPE_TAG", this.close)
        })
        this.on("unmount", () => {
            Dispatcher.off("concordanceShowDetail", this.onShow)
            Dispatcher.off("ESCAPE_TAG", this.close)
        })
    </script>
</concordance-detail-window>
