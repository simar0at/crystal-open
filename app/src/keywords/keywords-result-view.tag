<keywords-result-view>
    <div class="row">
        <div class="col m6 s12">
            <ui-checkbox
                    name="showLineNumbers"
                    label-id="showLineNumbers"
                    disabled={isLoading}
                    checked={data.showLineNumbers}
                    tooltip="t_id:kw_r_view_show_line_numbers"
                    on-change={onOptionChange}>
            </ui-checkbox>
        </div>
        <div class="col m6 s12">
            <ui-checkbox
                    name="showcounts"
                    label-id="showCounts"
                    disabled={isLoading}
                    checked={data.showcounts}
                    tooltip="t_id:kw_r_view_show_counts"
                    on-change={onOptionChange}>
            </ui-checkbox>
        </div>
        <div class="col m6 s12">
            <ui-checkbox
                    label-id="showRelFrq"
                    name="showrelfrq"
                    disabled={isLoading}
                    checked={data.showrelfrq}
                    tooltip="t_id:kw_r_view_show_relfrq"
                    on-change={onOptionChange}>
            </ui-checkbox>
        </div>
        <div class="col m6 s12">
            <ui-checkbox
                    label-id="showScores"
                    name="showscores"
                    disabled={isLoading}
                    checked={data.showscores}
                    tooltip="t_id:kw_r_view_show_scores"
                    on-change={onOptionChange}>
            </ui-checkbox>
        </div>
        <div class="col m6 s12">
            <ui-checkbox
                    label-id="kw.showWikiSearch"
                    name="showwikisearch"
                    disabled={isLoading}
                    checked={data.showwikisearch}
                    tooltip="t_id:kw_r_view_show_wiki"
                    on-change={onOptionChange}>
            </ui-checkbox>
        </div>
    </div>

    <script>
        this.mixin("feature-child")
        this.isLoading = this.store.t_isLoading || this.store.k_isLoading

        onOptionChange(value, name) {
            this.store.changeValue(!!value, name)
            this.store.updateUrl()
            this.store.saveUserOptions([name])
        }
    </script>
</keywords-result-view>
