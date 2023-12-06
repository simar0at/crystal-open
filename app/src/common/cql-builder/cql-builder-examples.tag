<cql-builder-examples class="cql-builder-examples">
    <div if={builder.tokens.length}>
        <span class="cb-examples-title tooltipped"
                data-tooltip={_("resultExampleTip")}
                onclick={onToggleDisplayClick}>
            {_("resultExample")}
            <i class="material-icons" ref="toggleIcon">
                {showExamples ? "keyboard_arrow_down" : "keyboard_arrow_up"}
            </i>
        </span>
        <br>
    </div>
    <div if={builder.tokens.length}
            ref="content"
            class="card-panel cb-examples-content relative">
        <div class="concordance-result">
            <preloader-spinner if={activeRequest}
                    center=1
                    overlay=1
                    message={_("examplesLoading")}></preloader-spinner>
            <div if={!loaded} class="emptyContent">
                <div class="title">
                    {_("nothingHere")}
                </div>
                <div>
                    {_("createCQLFirst")}
                </div>
            </div>
            <div if={loaded && !items.length && !error} class="emptyContent">
                <virtual if={!activeRequest}>
                    <i class="material-icons">space_bar</i>
                    <div class="title">{_("emptyConcordance")}</div>
                    <div>{_("emptyConcordanceDesc")}</div>
                </virtual>
            </div>
            <div if={loaded && error} class="emptyContent">
                <i class="material-icons">warning</i>
                <div class="title">
                    error
                </div>
                {error}
            </div>
            <div class="table result-table displayKwic" if={items.length}>
                <div class="tr tr-{idx + 1}" each={item, idx in items}>
                    <div class="td leftCol _t right-align">
                        <concordance-result-items data={isRTL ? item.Right : item.Left} class="leftCtx"></concordance-result-items>
                    </div>

                    <div class="td center-align middle _t rtlNode">
                        <concordance-result-items data={item.Kwic} class="kwicWrapper"></concordance-result-items>
                    </div>
                    <div class="td rightCol _t left-align">
                        <concordance-result-items data={isRTL ? item.Left : item.Right} class="rightCtx"></concordance-result-items>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const {Connection} = require("core/Connection.js")
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")
        require("concordance/concordance-result.tag")
        require("concordance/concordance-result.scss")

        this.builder = this.opts.builder
        this.store = ConcordanceStore
        this.activeRequest = null
        this.loaded = false
        this.items = []
        this.showExamples = true

        onToggleDisplayClick(evt){
            evt.preventUpdate = true
            this.toggleExamples()
        }

        toggleExamples(){
            this.showExamples = !this.showExamples
            this.refs.toggleIcon.innerHTML = this.showExamples ? "keyboard_arrow_down" : "keyboard_arrow_up"
            $(this.refs.content).slideToggle()
            this.showExamples && this.reload()
        }

        cancelPreviousRequest(){
            this.activeRequest && Connection.abortRequest(this.activeRequest)
        }

        reload(){
            if(!this.showExamples || !this.builder.isCQLValid){
                return
            }
            this.debounceHandle && clearTimeout(this.debounceHandle)
            let cql = this.builder.getCQLString()
            if(cql && this.lastCQL != cql){
                this.lastCQL = cql
                this.cancelPreviousRequest()
                this.activeRequest = Connection.get({
                    url: this.store.getRequestUrl(),
                    data: this.store.getRequestData({
                        fromp: 1,
                        pagesize: 10,
                        structs: "",
                        concordance_query: [{
                            queryselector: "cqlrow",
                            cql: cql
                        }]
                    }),
                    done: (payload) => {
                        if(payload.error){
                            this.items = []
                            this.error = payload.error
                        } else{
                            this.error = ""
                            this.items = payload.Lines
                        }
                    },
                    fail: (payload) => {
                        this.error = payload.error
                    },
                    always: () =>{
                        this.loaded = true
                        this.activeRequest = null
                        this.update()
                    }
                })
                this.update()
            }
        }

        tokenChanged(){
            this.update()
            this.debounceHandle && clearTimeout(this.debounceHandle)
            this.debounceHandle = setTimeout(this.reloadDebounced.bind(this), 2000)
        }

        reloadDebounced(){
            this.reload()
            this.debounceHandle = null
        }

        updateAttributes(){
            this.isBtnDisabled = !this.builder.isCQLValid
            if(!this.builder.tokens.length || !this.builder.isCQLValid){
                this.items = []
            }
        }
        this.updateAttributes()

        this.on("update", this.updateAttributes)
    </script>
</cql-builder-examples>
