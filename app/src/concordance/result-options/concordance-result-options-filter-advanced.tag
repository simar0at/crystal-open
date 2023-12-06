<concordance-result-options-filter-advanced>
    <concordance-quick-filters></concordance-quick-filters>
    <div class="leftColumn">
        <div class="contextRow" class="dividerBottomDotted">
            <span class="tooltipped" data-tooltip="t_id:conc_r_filter_pnfilter">
                {_("cc.filterPN")}
                <sup>?</sup>
            </span>
            <ui-select
                inline=1
                name="pnfilter"
                value={pnfilter}
                options={pnOptionList}
                on-change={onOptionChange}></ui-select>
                <span>:</span>
            <br><br>

            <div class="queryWrapper">
                <query-types riot-value={formValue}
                    show-video={false}
                    on-change={onQueryTypesChange}
                    fixeddefattr={options.default_attr}
                    on-valid-change={onQueryTypesValidChange}
                    on-submit={onSubmit}
                    btn-label={_("search")}></query-types>
            </div>

            <div class="filterRange">
                <span class="inlineBlock">
                    <label class="tooltipped" data-tooltip="t_id:conc_r_filter_range">
                        {_("range")}
                        <sup>?</sup>
                    </label>
                    <ui-radio
                            name="filter_range"
                            options={filterRangeOptions}
                            riot-value={options.filter_range}
                            on-change={onFilterRangeChange}></ui-radio>
                </span>

                <span class="ranges inlineBlock {excludeKwic: !options.inclkwic}">
                    <div class="filterRangeToken">
                        <range-select if={options.filter_range == 0}
                                label=""
                                on-change={onTokenOrSentenceRangeChange}
                                kwic-active=1
                                name="filpos"
                                riot-value={{
                                    from: this.options.filfpos,
                                    to: this.options.filtpos
                                }}></range-select>
                    </div>
                    <div class="filterRangeSentence">
                        <ui-range if={options.filter_range == 1}
                                on-change={onTokenOrSentenceRangeChange}
                                range={sentenceOptionList}
                                name="filpos"
                                riot-value={{
                                    from: this.options.filfpos,
                                    to: this.options.filtpos
                                }}></ui-range>
                    </div>
                    <div if={options.filter_range == 2}>
                        <span style="margin-right: 30px;">
                            <label>{_("from")}</label>
                            <ui-input name="filfpos"
                                    ref="customFilfpos"
                                    type="number"
                                    label={_("position")}
                                    riot-value={options.filfpos}
                                    min=-100
                                    max=100
                                    validate=1
                                    size=4
                                    inline=1
                                    on-change={onRangePosChange}></ui-input>
                            <ui-select name="range_from_type"
                                    label={_("type")}
                                    size=7
                                    options={rangeTypeOptionList}
                                    on-change={onRangeTypeChange}
                                    inline=1></ui-select>
                        </span>
                        <span>
                            <label>{_("to")}</label>
                            <ui-input name="filtpos"
                                    ref="customFiltpos"
                                    type="number"
                                    label={_("position")}
                                    riot-value={options.filtpos}
                                    min=-100
                                    max=100
                                    validate=1
                                    size=4
                                    inline=1
                                    on-change={onRangePosChange}></ui-input>
                            <ui-select name="range_to_type"
                                    label={_("type")}
                                    size=7
                                    options={rangeTypeOptionList}
                                    on-change={onRangeTypeChange}
                                    inline=1></ui-select>
                        </span>
                    </div>
                </span>
            </div>
            <ui-checkbox
                name="inclkwic"
                label-id="cc.exclKwic"
                checked={!options.inclkwic}
                disabled={excludeKwicDisabled}
                on-change={onExclKwickChange}></ui-checkbox>
            <br><br>
        </div>
        <br>

        <text-types-collapsible></text-types-collapsible>


        <div class="center-align">
            <a id="btnGoAdvFilter" class="waves-effect waves-light btn contrast leftPad" disabled={isSearchDisabled} onclick={onSubmit}>{_("go")}</a>
        </div>

        <floating-button disabled={isSearchDisabled}
            name="btnGoFloat"
            onclick={onSubmit}
            refnodeid="btnGoAdvFilter"
            periodic="1"></floating-button>
    </div>
    <script>
        require("./concordance-result-options-filter.scss")
        require("concordance/query-types/query-types.tag")
        require("concordance/concordance-quick-filters.tag")
        require("concordance/range-select/range-select.tag")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.options = {
            pnfilter: "p",
            filter_range: 0,
            filfpos: -3,
            filtpos: 3,
            inclkwic: true,
            default_attr: 'word' // TODO: use DEFAULATTR
        }
        this.formValue = {
            queryselector: this.data.queryselector,
            qmcase: this.data.qmcase
        }
        this.pnOptionList = [{
            labelId: "containing",
            value: "p"
        }, {
            labelId: "notContaining",
            value: "n"
        }]
        this.rangeTypeOptionList = [{
            labelId: "token",
            value: "token"
        }, {
            labelId: "sentence",
            value: "sentence"
        }]

        this.filterRangeOptions = [
            {label: _("token"), value: 0},
            {label: _("sentence"), value: 1},
            {label: _("custom"), value: 2}
        ]

        this.sentenceOptionList = [
            {label: "-3", value: -3},
            {label: "-2", value: -2},
            {label: "-1", value: -1},
            {label: "KWIC", value: "kwic"},
            {label: "1", value: 1},
            {label: "2", value: 2},
            {label: "3", value: 3}
        ]
        this.isSearchDisabled = true
        this.isQueryFormValid = false
        this.isRangeValid = true
        this.excludeKwicDisabled = false

        onFilterRangeChange(filter_range){
            this.options.filter_range = filter_range
            if(filter_range == 0){
                this.options.filfpos = -3
                this.options.filtpos = 3
            } else if(filter_range == 1){
                this.options.filfpos = -1
                this.options.filtpos = 1
            } else if(filter_range == 2){
                this.options.filfpos = -10
                this.options.filtpos = 10
                this.options.range_from_type = "token"
                this.options.range_to_type = "token"
            }
            this.isRangeValid = true
            this.excludeKwicDisabled = false
            this.refreshDisabled()
            this.update()
        }

        onTokenOrSentenceRangeChange(value){
            this.options.filfpos = value.from
            this.options.filtpos = value.to
            this.refreshExcludeKwicDisabled()
            this.update()
        }

        onRangePosChange(value, name){
            this.options[name] = parseInt(value)
            this.onCustomRangeChange()
            this.update()
        }

        onRangeTypeChange(value, name){
            this.options[name] = value
            this.refreshExcludeKwicDisabled()
            this.update()
        }

        onCustomRangeChange(){
            let justKwic = this.options.filfpos == 0
                    && this.options.filtpos == 0
                    && this.options.range_from_type == "token"
                    && this.options.range_to_type == "token"
            let kwicInRange = (this.options.filfpos == 0 || this.options.filfpos <= 0)
                    && (this.options.filtpos == 0 || this.options.filtpos >= 0)
            if(justKwic){
                this.options.inclkwic = true
                this.excludeKwicDisabled = true
            } else {
                this.excludeKwicDisabled = !kwicInRange
            }
            this.isRangeValid = this.refs.customFilfpos.isValid
                    && this.refs.customFiltpos.isValid
                    && this.options.filfpos <= this.options.filtpos
            this.refreshDisabled()
        }

        onExclKwickChange(checked){
            this.options.inclkwic = !checked
            this.update()
        }

        onOptionChange(value, name){
            this.options[name] = value
        }

        onQueryTypesChange(value) {
            this.formValue = value
            this.formValue.default_attr = this.options.default_attr
        }

        onQueryTypesValidChange(isValid){
            if(this.isQueryFormValid != isValid){
                this.isQueryFormValid = isValid
                this.refreshDisabled()
            }
        }

        onSubmit(){
            let filfpos = this.options.filfpos
            let filtpos = this.options.filtpos
            if(filfpos != "kwic" && (this.options.filter_range == 1 || (this.options.filter_range == 2 && this.options.range_from_type == "sentence"))){
                filfpos += ":s"
            }
            if(filtpos != "kwic" && (this.options.filter_range == 1 || (this.options.filter_range == 2 && this.options.range_to_type == "sentence"))){
                filtpos += ":s"
            }
            let filter = {
                pnfilter: this.options.pnfilter,
                inclkwic: this.options.inclkwic,
                lpos: this.formValue.lpos,
                wpos: this.formValue.wpos,
                qmcase: this.formValue.qmcase,
                filfpos: this.corpus.righttoleft ? -filtpos : filfpos,
                filtpos: this.corpus.righttoleft ? -filfpos : filtpos
            }

            let selection = TextTypesStore.get("selection")
            for(let key in selection){
                filter["sca_" + key] = selection[key]
            }

            let queryselector = this.formValue.queryselector
            let valueField = queryselector == "cql" ? "cql" : "keyword"
            let value = this.formValue[valueField]
            if(!$.isEmptyObject(selection)){
                let textTyepsDesc = Object.values(selection).join(",")
                // only texttype is selected
                if(!value){
                    queryselector = "cql"
                    value = ""
                    filter.desc = textTyepsDesc
                } else {
                    filter.desc = value + "," + textTyepsDesc
                }
            }
            filter.queryselector = queryselector + "row"
            filter[queryselector] = value
            TextTypesStore.reset()
            this.store.filter(filter)
        }

        setDisabled(disabled){
            this.isSearchDisabled = disabled
            this.update()
        }

        refreshExcludeKwicDisabled(){
            let justKwic = this.options.filfpos == "kwic" && this.options.filtpos == "kwic"
            let kwicInRange = (this.options.filfpos == "kwic" || this.options.filfpos <= -1)
                    && (this.options.filtpos == "kwic" || this.options.filtpos >= 1)
            if(justKwic){
                this.options.inclkwic = true
                this.excludeKwicDisabled = true
            } else {
                if(!kwicInRange){
                    this.options.inclkwic = true
                }
                this.excludeKwicDisabled = !kwicInRange
            }
        }

        refreshDisabled(){
            let wasDisabled = this.isSearchDisabled
            let isTextTypeSelected = !$.isEmptyObject(TextTypesStore.get("selection"))
            if(isTextTypeSelected){
                this.isSearchDisabled = false
            } else {
                this.isSearchDisabled = !this.isQueryFormValid || !this.isRangeValid
            }
            if(wasDisabled != this.isSearchDisabled){
                this.update()
            }
        }

        this.on("mount", () => {
            TextTypesStore.reset()
            TextTypesStore.on("selectionChange", this.refreshDisabled)
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        })

        this.on("unmount", () => {
            TextTypesStore.off("selectionChange", this.refreshDisabled)
        })
    </script>
</concordance-result-options-filter-advanced>
