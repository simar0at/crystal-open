<keywords-result-view class="keywords-result-view">
    <div class="wrapper">
        <div class="mr-10 dividerRight pr-10">
            <ui-switch
                    name="showLineNumbers"
                    label-id="showLineNumbers"
                    disabled={isLoading}
                    riot-value={data.showLineNumbers}
                    tooltip="t_id:kw_r_view_show_line_numbers"
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    name="showcounts"
                    label-id="showCounts"
                    disabled={isLoading}
                    riot-value={data.showcounts}
                    tooltip="t_id:frequency"
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    label-id="showRefValues"
                    name="showrefvalues"
                    disabled={isLoading}
                    riot-value={data.showrefvalues}
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    label-id="showRelFrq"
                    name="showrelfrq"
                    disabled={isLoading}
                    riot-value={data.showrelfrq}
                    tooltip="t_id:relfreq"
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    if={corpus.hasDocfAttr}
                    ref="showdocf"
                    label-id={corpus.hasStarAttr ? "showMR" : "showDocfreq"}
                    name="showdocf"
                    disabled={isLoading}
                    riot-value={data.showdocf}
                    tooltip={corpus.hasStarAttr ? "t_id:mr" : "t_id:docf"}
                    on-change={onAddfreqsChange}
                    class="lever-right">
            </ui-switch>
        </div>
        <div>
            <ui-switch
                    if={corpus.hasDocfAttr}
                    ref="showreldocf"
                    label-id={corpus.hasStarAttr ? "showRelMR" : "showReldocfreq"}
                    name="showreldocf"
                    disabled={isLoading}
                    riot-value={data.showreldocf}
                    tooltip={corpus.hasStarAttr ? "t_id:relmr" : "t_id:reldocf"}
                    on-change={onAddfreqsChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    ref="showarf"
                    label-id="showARF"
                    name="showarf"
                    disabled={isLoading}
                    riot-value={data.showarf}
                    tooltip="t_id:arf"
                    on-change={onAddfreqsChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    ref="showaldf"
                    label-id="showALDF"
                    name="showaldf"
                    disabled={isLoading}
                    riot-value={data.showaldf}
                    tooltip="t_id:aldf"
                    on-change={onAddfreqsChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    if={corpus.hasStarAttr}
                    ref="showavgstar"
                    label-id="showAvgstar"
                    name="showavgstar"
                    disabled={isLoading}
                    riot-value={data.showavgstar}
                    tooltip="t_id:star"
                    on-change={onAddfreqsChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    label-id="showScores"
                    name="showscores"
                    disabled={isLoading}
                    riot-value={data.showscores}
                    tooltip="t_id:kw_r_view_show_scores"
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
            <ui-switch
                    label-id="kw.showWikiSearch"
                    name="showwikisearch"
                    disabled={isLoading}
                    riot-value={data.showwikisearch}
                    tooltip="t_id:kw_r_view_show_wiki"
                    on-change={onOptionChange}
                    class="lever-right">
            </ui-switch>
        </div>
    </div>

    <script>
        this.mixin("feature-child")
        this.isLoading = this.store.t_isLoading || this.store.k_isLoading

        onOptionChange(value, name) {
            this.store.data[name] = !!value
            this.store.updateAllResultTags()
            this.store.updateUrl()
            this.store.saveUserOptions([name])
        }

        onAddfreqsChange(checked, name){
            this.store.data[name] = checked
            let needReload = checked
                    && (!this.data.k_items.length
                            || (this.data.showavgstar && !isDef(this.data.k_items[0].star1))
                            || (this.data.showdocf && !isDef(this.data.k_items[0].docf1))
                            || (this.data.showreldocf && !isDef(this.data.k_items[0].rel_docf1))
                            || (this.data.showarf && !isDef(this.data.k_items[0].arf1))
                            || (this.data.showaldf && !isDef(this.data.k_items[0].aldf1))
                        )
            if(needReload){
                this.store.searchAndAddToHistory({
                    page: 1
                })
            } else {
                this.store.updateAllResultTags()
            }
            this.store.saveUserOptions([name])
            this.store.updateUrl(true)
        }
    </script>
</keywords-result-view>

