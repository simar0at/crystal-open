<parconcordance-result-options-sort class="parconcordance-result-options-sort">
    <external-text text="conc_r_sort"></external-text>
    <br>
    <div class="sortContainer">
        <div class="sortForm">
            <context-selector range=3
                    riot-value={ctx}
                    name="ctx"
                    tooltip="t_id:conc_r_sort_context"
                    on-change={onOptionChange}>
            </context-selector>
            <br/>
            <div class="sortOptions">
                <ui-filtering-list name="attr"
                        label={_("sortAttribute")}
                        inline=1
                        value={attr}
                        options={attrList}
                        on-change={onOptionChange}
                        open-on-focus={true}
                        value-in-search={true}
                        tooltip="t_id:conc_r_sort_attribute"
                        floating-dropdown=1>
                </ui-filtering-list>
                <br/><br/>
                <ui-checkbox name="icase"
                        label-id="ignoreCase"
                        checked={icase}
                        tooltip="t_id:conc_r_sort_icase"
                        on-change={onOptionChange}>
                </ui-checkbox>
                <ui-checkbox name="bward"
                        label-id="retrograde"
                        tooltip="t_id:conc_r_sort_retrograde"
                        on-change={onOptionChange}>
                </ui-checkbox>
            </div>
        </div>
    </div>
    <div class="buttonGo primaryButtons">
        <a id="btnGoSort" class="btn" disabled={isLoading}
                onclick={onGoClick}>{_("go")}</a>
    </div>

    <script>
        require("./parconcordance-result-options-sort.scss")
        require("concordance/context-selector/context-selector.tag")

        this.mixin("feature-child")


        this.attrList = [].concat(this.store.attrList, this.store.refList).filter(attr => !attr.isLc)
        this.attr = "word"
        this.ctx = "0"
        this.bward = false
        this.icase = false


        onOptionChange(value, name) {
            if (name == "ctx") value = String(value)
            this[name] = value
        }

        onGoClick() {
            this.data.closeFeatureToolbar = true
            this.store.searchAndAddToHistory({
                sort: [{
                    corpname: this.opts.corpname,
                    attr: this.attr,
                    ctx: this.ctx,
                    icase: !!this.icase ? "i" : "",
                    bward: !!this.bward ? "r" : ""
                }],
                page: 1
            })
        }
    </script>
</parconcordance-result-options-sort>
