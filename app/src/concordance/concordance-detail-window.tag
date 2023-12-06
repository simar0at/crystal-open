<concordance-detail-window class="concordance-detail-window">
    <div if={show} class="z-depth-5 {displayLoadStructBtn: displayLoadStructBtn}">
        <div class="close center-align" onclick={onCloseClick}>
            <i class="material-icons grey-text">keyboard_arrow_down</i>
        </div>
        <div if={!isLoading} class="cd-content rtlNode">
            <div if={showPrevNext && (!limit || leftCtx < limit)}
                    class="center-align">
                <a class="btn btn-floating btn-flat" onclick={loadPrev}>
                    <i class="material-icons grey-text">more_horiz</i>
                </a>
            </div>
            <span each={item in data.content}
                    class="str {item.class} {coll: item.coll}"
                    style={item.color ? "color: " + item.color : ""}>
                {item.str}
            </span>
            <div if={showPrevNext && (!limit || rightCtx < limit)}
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

        this.show = false
        this.isLoading = false
        this.limit = 50

        onShow(showArgs){
            this.displayLoadStructBtn = this.opts.structctx
            this.showPrevNext = true
            this.showArgs = showArgs
            if(showArgs.kwic){
                this.leftCtx = 50
                this.rightCtx = 50
            }
            this.show = true
            this.isLoading = true
            this.loadData()
            this.update()
            this.root.classList.add("show")
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            this.close()
        }

        close(){
            if(this.show){
                this.show = false
                this.root.classList.remove("show")
                delay(this.update, 200)
                if(isFun(this.showArgs.onClose)){
                    this.showArgs.onClose()
                }
            }
        }

        onDataLoaded(payload){
            this.isLoading = false
            this.data = payload
            this.limit = payload.maxcontext
            this.update()
        }

        loadData(){
            Connection.get({
                url: window.config.URL_BONITO + "widectx",
                query: {
                    pos: this.showArgs.toknum,
                    corpname: this.showArgs.corpname || AppStore.getActualCorpname(),
                    hitlen: this.showArgs.hitlen || 1,
                    structs: this.showArgs.structs || "g",
                    detail_left_ctx: this.leftCtx,
                    detail_right_ctx: this.rightCtx
                },
                done: this.onDataLoaded.bind(this)
            })
        }

        loadStructure(){
            this.displayLoadStructBtn = false
            this.showPrevNext = false
            Connection.get({
                url: window.config.URL_BONITO + "structctx",
                query: {
                    pos: this.showArgs.toknum,
                    corpname: this.showArgs.corpname || AppStore.getActualCorpname(),
                    struct: this.opts.structctx
                },
                done: this.onDataLoaded.bind(this)
            })
        }

        loadPrev(){
            this.leftCtx += 100
            this.loadData()
        }

        loadNext(){
            this.rightCtx += 100
            this.loadData()
        }

        this.on("mount", () => {
            Dispatcher.on("concordanceShowDetail", this.onShow)
        })
        this.on("unmount", () => {
            Dispatcher.off("concordanceShowDetail", this.onShow)
        })
    </script>
</concordance-detail-window>
