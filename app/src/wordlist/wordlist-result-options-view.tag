<wordlist-result-options-view class="wordlist-result-options-view">
    <div>
        <ui-checkbox label-id="singleColumn"
                name="onecolumn"
                disabled={data.isEmpty || data.isLoading}
                checked={data.onecolumn}
                tooltip="t_id:wl_r_view_onecolumn"
                on-change={onOptionChange}></ui-checkbox>
        <ui-checkbox name="showLineNumbers"
                label-id="showLineNumbers"
                disabled={data.isEmpty || data.isLoading}
                checked={data.showLineNumbers}
                tooltip="t_id:wl_r_show_view_line_numbers"
                on-change={onOptionChange}></ui-checkbox>
    </div>
    <div>
        <ui-checkbox
                name="values"
                label-id="wl.absfreq"
                disabled={data.isEmpty || data.isLoading}
                checked={data.values}
                tooltip="t_id:wl_r_view_absfreq"
                on-change={onOptionChange}></ui-checkbox>
        <ui-checkbox if={!data.histid && data.raw.concsize == data.raw.fullsize}
                name="relfreq"
                label-id="relFreq"
                disabled={data.isEmpty || data.isLoading || data.wlnums == "arf"}
                checked={data.relfreq}
                tooltip="t_id:wl_r_view_relfreq"
                on-change={onOptionChange}></ui-checkbox>
        <ui-checkbox if={!data.histid}
                name="bars"
                label-id="wl.bars"
                disabled={data.isEmpty || data.isLoading || data.wlstruct_attr1 === ""}
                checked={data.bars}
                tooltip="t_id:wl_r_view_bars"
                on-change={onBarsChange}></ui-checkbox>
        <ui-checkbox if={data.histid}
                name="showratio"
                label-id="showRatio"
                checked={data.showratio}
                on-change={onOptionChange}></ui-checkbox>
        <ui-checkbox if={data.histid}
                name="showrank"
                label-id="showRank"
                checked={data.showrank}
                on-change={onOptionChange}></ui-checkbox>
    </div>
    <div if={!data.histid}>
        <ui-radio options={wlnumsList}
            name="wlnums"
            disabled={data.isEmpty || data.isLoading || (data.tab == "advanced" && data.viewAs == 2)}
            value={data.wlnums}
            tooltip="t_id:wl_r_view_wlnums"
            on-change={onWlnumsChange}></ui-radio>
    </div>

    <script>
        require("./wordlist-result-options.scss")
        const Meta = require("./Wordlist.meta.js")

        this.mixin("feature-child")

        this.wlnumsList = Meta.wlnumsList
        this.optionsList = [{
            id: "view",
            icon: "visibility",
            iconClass: "material-icons",
            tag: "wordlist-result-options-view",
            label: "changeDisplayOptions"
        }]

        onOptionChange(value, name){
            this.store.changeValue(value, name)
            this.store.saveUserOptions([name])
            this.store.updateUrl(true)
        }

        onWlnumsChange(wlnums){
            this.store.searchAndAddToHistory({
                wlnums: wlnums,
                relfreq: false,
                page: 1
            })
            this.store.saveUserOptions(["wlnums"])
        }

        onBarsChange(bars){
            this.store.searchAndAddToHistory({bars: bars})
            this.store.saveUserOptions(["bars"])
        }
    </script>

</wordlist-result-options-view>
