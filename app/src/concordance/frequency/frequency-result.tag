<frequency-result class="frequency-result">
    <preloader-spinner if={data.isLoading} overlay=1 fixed=1 on-cancel={store.onLoadingCancel.bind(store)} browser-indicator=1></preloader-spinner>
    <h4 class="header">{_("frequency")}</h4>
    <span class="headerButtons">
        <a id="btnNewSearch" class="btn contrast" onclick={onToggleShowFormClick}>
            {_("newSearch")}
        </a>
        <a id="btnBackToConcordance" class="btn contrast" onclick={store.goBackToTheConcordance.bind(store)}>
            {_("backToConcordance")}
        </a>
    </span>
    <div if={!data.f_isEmpty && !data.isLoading} class="dividerTop center-align">
        <div if={showRelFreq} class="z-depth-1 card-content frequencyOptions">
            <ui-checkbox id="showrelfrq"
                name="showrelfrq"
                checked={data.f_showrelfrq}
                label-id="relFreq"
                on-change={onShowrelfrqChange}></ui-checkbox>
        </div>
        <br>
        <frequency-result-block each={block, idx in data.f_items} class="block_{idx + 1}" block="{block}" show-rel-freq={showRelFreq}>
        </frequency-result-block>
    </div>

    <div if={data.f_error} class="card-panel white">
        <h4 style="margin-top: 0;">
            <i class="material-icons">error</i>
            {_("somethingWentWrong")}
        </h4>
        <div class="red-text">
            {data.f_error}
        </div>
    </div>

    <interfeature-menu ref="interfeatureMenu"
                links={interFeatureMenuLinks}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>

    <script>
        require("./frequency-result-block.tag")
        require("./frequency-result.scss")

        this.mixin("feature-child")

        updateAttributes(){
            this.showRelFreq = false
            if(this.store.data.f_mode != "texttypes"){
                let refListFlat = this.store.refList.map(ref => {return ref.value})
                this.showRelFreq = !this.store.data.f_freqml.some(freq => {
                    return refListFlat.includes(freq.attr)
                })
            }
            this.interFeatureMenuLinks = [{
                name: "concordance",
                feature: "concordance",
                labelId: "positiveFilter",
                pn: "p"
            }]
            if(this.data.f_freqml.length <= 1){
                // cannot combine negative filter with multi-column frequency
                this.interFeatureMenuLinks.push({
                    name: "concordanceNeg",
                    feature: "concordance",
                    labelId: "negativeFilter",
                    pn: "n"
                })
            }
        }
        this.updateAttributes()

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let value = rowData.Word[0].n
            let block = rowData.block
            let operations = JSON.parse(JSON.stringify(this.data.operations))

            const addFilter = (filter, desc) => {
                operations.push({
                    id: Math.floor((Math.random() * 10000)),
                    name: "filter",
                    arg: desc,
                    query: filter,
                    active: true
                })
            }

            if(this.data.f_mode == "texttypes"){
                addFilter({
                    ["sca_" + block.Head[0].id]: value,
                    pnfilter: featureParams.pn,
                    queryselector: "cqlrow",
                    filfpos: 0,
                    filtpos: 0,
                    inclkwic: true,
                    cql: "[]"
                }, `sca_${block.Head[0].id}${(featureParams.pn == "p" ? " is " : " is not ")}'${value}'`)
            } else if(this.data.f_mode == "multilevel"){
                this.data.f_freqml.forEach((freq, idx) => {
                    let attr = block.Head[idx].id.split("/")[0]
                    let cql = ""
                    let isTextType = this.store.refList.findIndex(r => {return r.value == attr}) != -1
                    if(isTextType){
                        cql += `[] within<${attr.replace(".", " ")}=="${rowData.Word[idx].n}"/>`
                    } else{
                        rowData.Word[idx].n.split(" ").forEach(part => {
                            let clearPart = part.trim()
                            if(clearPart){
                                clearPart = clearPart.replace(/[\"\\]/g, "\\$&") //escape " and \
                                cql += `[${attr}=="${clearPart}"]`
                            }
                        }, this)
                    }
                    let filfpos
                    let filtpos

                    if(freq.ctx == 0 && freq.base == "kwic"){
                        filfpos = filtpos = "0"
                    } else if (!isNaN(freq.base)){
                        // filter on collocates
                        filfpos = freq.ctx + "<" + freq.base
                        filtpos = freq.ctx + ">" + freq.base
                    } else {
                        filfpos = filtpos = this.store.getFilterContextStr(freq.ctx, freq.base)
                    }
                    addFilter({
                        pnfilter: featureParams.pn,
                        queryselector: "cqlrow",
                        inclkwic: true,
                        filfpos: filfpos,
                        filtpos: filtpos,
                        cql: cql
                    }, (featureParams.pn == "n" ? "not " : "") + cql)
                }, this)
            }
            let params = {}
            this.store.urlOptions.forEach(option => {
                params[option] = this.data[option]
            })
            Object.assign(params, {
                tab: "advanced",
                page: 1,
                results_screen: "concordance",
                corpname: this.data.corpname,
                operations: operations
            })

            return params
        }

        onShowrelfrqChange(showrelfrq){
            this.data.f_showrelfrq = showrelfrq ? 1 : 0
            this.update()
        }

        onToggleShowFormClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", this.data.act_opts == "frequency" ? null : "frequency")
        }

        this.on("update", () => {
            this.updateAttributes()
        })

        this.on("updated", () => {
            let maxWidth = 0
            let containerWidth = $(this.root).width()
            $("frequency-result-block .col-tab-col>table", this.root).each((idx, elem) => {
                maxWidth = Math.max(maxWidth, $(elem).width())
            })
            maxWidth = Math.min(maxWidth, containerWidth)

            $("frequency-result-block .col-tab-col>table", this.root).each((idx, elem) => {
                $(elem).css("min-width", Math.max($(elem).width(), maxWidth) + "px")
            })
        })

        this.on("mount", () => {
            if(!this.data.f_hasBeenLoaded){
                this.store.f_search()
            }
        })
    </script>
</frequency-result>
