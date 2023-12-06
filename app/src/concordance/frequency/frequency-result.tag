<frequency-result class="frequency-result">
    <result-preloader-spinner store={store}></result-preloader-spinner>
    <collfreq-selected-lines-box ref="selectedLinesBox"
            get-data-length={getSelectedLinesBoxDataLength}
            on-close-click={onSelectedLinesBoxClose}
            get-url-to-result-page={getSelectedLinesBoxUrl}></collfreq-selected-lines-box>
    <virtual if={data.f_hasBeenLoaded || !data.isLoading}>
        <a href="javascript:void(0);"
                if={data.total < data.fullsize}
                id="frequencyWarning"
                class="tooltipped warningBtn btn btn-floating {red: !data.random} mr-2"
                data-tooltip={_(data.random ? "freqRandom10M" : "freqFirst10M")}
                onclick={onRandomClick}>
            <i class="material-icons white-text">
                priority_high
            </i>
        </a>
        <h4 class="header">{_("frequency")}</h4>
        <span class="headerButtons">
            <a id="btnNewSearch" class="btn btn-primary" onclick={onToggleShowFormClick}>
                {_("newSearch")}
            </a>
            <a id="btnBackToConcordance" class="btn btn-primary" onclick={store.goBackToTheConcordance.bind(store)}>
                {_("backToConcordance")}
            </a>
        </span>
    </virtual>
    <bgjob-card if={data.jobid}
            is-loading={data.isBgJobLoading}
            desc={data.raw.desc}
            progress={data.raw.processing}></bgjob-card>
    <div if={!data.f_isEmpty && !data.isLoading && !data.jobid} class="dividerTop center-align">
        <div class="z-depth-1 card-content frequencyOptions">
            <ui-checkbox if={!showRelTtAndRelDens}
                    id="showrelfrq"
                    name="f_showrelfrq"
                    checked={isConcordanceComplete && data.f_showrelfrq}
                    disabled={!isConcordanceComplete}
                    inline=1
                    label-id="showRelFrq"
                    on-change={setCheckboxValue.bind(this, "f_showrelfrq")}></ui-checkbox>
            <ui-checkbox if={!showRelTtAndRelDens}
                    id="showperc"
                    name="f_showperc"
                    checked={data.f_showperc}
                    inline=1
                    label-id="showPercOfConc"
                    on-change={setCheckboxValue.bind(this, "f_showperc")}></ui-checkbox>
            <ui-checkbox if={showRelTtAndRelDens}
                    id="showreltt"
                    name="f_showreltt"
                    checked={isConcordanceComplete && data.f_showreltt}
                    disabled={!isConcordanceComplete}
                    inline=1
                    label-id="showRelTT"
                    on-change={setCheckboxValue.bind(this, "f_showreltt")}></ui-checkbox>
            <ui-checkbox if={showRelTtAndRelDens}
                    id="showreldens"
                    name="f_showreldens"
                    checked={isConcordanceComplete && data.f_showreldens}
                    disabled={!isConcordanceComplete}
                    inline=1
                    label-id="showReldens"
                    on-change={setCheckboxValue.bind(this, "f_showreldens")}></ui-checkbox>
        </div>
        <br>
        <frequency-result-block each={block, idx in data.f_items}
                idx={idx}
                block="{block}">
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
                is-feature-link-active={isFeatureLinkActive}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>

    <script>
        require("./frequency-result-block.tag")
        require("./frequency-result.scss")
        require("concordance/collfreq-selected-lines-box.tag")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        getSelectedLinesBoxUrl(pn){
            let cqls = []
            this.data.f_items.forEach(block => {
                block.selection.forEach(idx => {
                    let cql = block.Items[idx].pfilter_list[0]
                    cqls.push(cql.substr(cql.indexOf("[") - 1))
                })
            })
            let tmp = this.data.f_items[0].Items[0].pfilter_list[0].split(" ")
            return this.store.getUrlToResultPage(this._getFilterLinkParams([{
                pn: pn,
                filfpos: tmp[0].substr(1),
                filtpos: tmp[1],
                cql: cqls.length > 1 ? `(${cqls.join(")|(")})` : cqls[0]
            }]))
        }

        onSelectedLinesBoxClose(){
            this.data.f_items.forEach(block => {block.selection.splice(0, block.selection.length)})
            this.store.updatePageTag()
        }

        onRandomClick(){
            this.store.toggleRandom()
        }

        getSelectedLinesBoxDataLength(){
            return this.data.f_items.reduce((total, block) => {return total + block.selection.length}, 0)
        }

        updateAttributes(){
            this.isConcordanceComplete = this.data.total == this.data.fullsize
            this.showRelTtAndRelDens = this.store.f_showRelTtAndRelDens()
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

        isFeatureLinkActive(feature, rowData, evt, linkObj){
            if(!this.data.f_freqml.length){
                return true
            }
            // if frequency is computed on structre and row value is "", do not allow filters
            return this.data.f_freqml.some((freq, idx) => {
                let attr = rowData.block.Head[idx].id.split("/")[0]
                return rowData.Word[idx].n !== "" || (this.store.structList.findIndex(r => {
                    return r.value == attr
                }) == -1)
            }, this)
        }

        getFeatureLinkParams(feature, rowData, event, featureParams){
            let filterArr = rowData.pfilter_list.map(f => {
                let tmp = f.split(" ")
                return {
                    pn: featureParams.pn,
                    filfpos: tmp[0].substr(1),
                    filtpos: tmp[1],
                    cql: f.substr(f.indexOf("[") - 1)
                }
            })
            return this._getFilterLinkParams(filterArr)
        }

        onToggleShowFormClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", this.data.act_opts == "frequency" ? null : "frequency")
        }

        setCheckboxValue(name, value){
            this.data[name] = value
            this.store.saveUserOptions([name])
            this.store.updateUrl()
            this.update()
        }

        updateBlocksWidth(){
            let maxWidth = 0
            let containerWidth = $(this.root).width()
            $("frequency-result-block .table", this.root).each((idx, elem) => {
                maxWidth = Math.max(maxWidth, $(elem).width())
            })
            maxWidth = Math.min(maxWidth, containerWidth)

            $("frequency-result-block .table", this.root).each((idx, elem) => {
                $(elem).css("min-width", maxWidth + "px")
            })
        }

        _getFilterLinkParams(filterArr){
            let operations = JSON.parse(JSON.stringify(this.data.operations))

            filterArr.forEach(f => {
                operations.push({
                    name: "filter",
                    arg: (f.pn == "n" ? "not " : "") + f.cql,
                    query: {
                        pnfilter: f.pn,
                        queryselector: "cqlrow",
                        inclkwic: true,
                        filfpos: f.filfpos,
                        filtpos: f.filtpos,
                        partial_match: 0,
                        cql: f.cql
                    }
                })
            })

            let params = {}
            this.store.urlOptions.forEach(option => {
                params[option] = this.data[option]
            })
            Object.assign(params, {
                tab: this.store.data.tab == "error" ? "error" : "advanced",
                page: 1,
                results_screen: "concordance",
                corpname: this.data.corpname,
                operations: operations
            })

            return params
        }

        this.on("update", () => {
            this.updateAttributes()
        })

        this.on("updated", this.updateBlocksWidth.bind(this))

        this.on("mount", () => {
            if(!this.data.f_hasBeenLoaded && !this.data.isLoading){
                this.store.f_search()
            }
        })
    </script>
</frequency-result>
