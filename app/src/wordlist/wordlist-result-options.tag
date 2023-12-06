<wordlist-result-options class="wordlist-result-options">
    <span class="inlineBlock" if={!isAttribute}>
        <subcorpus-chip></subcorpus-chip>
        <h4 class="ro-title text-primary pull-left">{resultsFor}</h4>
        <span class="totalItems" if={totalitems || data.totalfrq}>
            (<span if={totalitems}>{totalitems}&nbsp;{_("wl.items")}</span>
            <span if={totalitems && data.totalfrq}>| </span>
            <span if={data.totalfrq}>{window.Formatter.num(data.totalfrq)}&nbsp;{_("totalFrq")}</span>)
        </span>
        <a href="javascript:void(0);"
                if={data.raw.concsize && data.raw.concsize < data.raw.fullsize}
                id="wlRandomToggleBtn"
                class="randomBtn btn btn-floating btn-flat btn-small orange"
                onclick={onRandomClick}>
            <i class="material-icons white-text tooltipped"
                    data-tooltip={_(data.random ? "usingRandom10M" : "usingFirst10M")}
                    style="vertical-align: text-bottom;">
                {data.random ? "trending_flat" : "shuffle"}
            </i>
        </a>
    </span>

    <span if={isAttribute} class="attributeHeader">
        <ui-select optgroups={optgroups}
            classes="headerSelect"
            name="wlattr"
            inline={true}
            value={data.wlattr}
            on-change={onWlattrChange}></ui-select>
        <span class="totalItems" if={totalitems}>
            ({_("wl.items")}:&nbsp;<b>{totalitems}</b>,&nbsp;{_("totalFrq")}: <b>{window.Formatter.num(data.totalfrq)}</b>)
        </span>

        <span style="white-space:nowrap;margin-right:30px;">
            <label>{_("show")}</label>
            <ui-select options={wlnumsOptions}
                    inline=1
                    name="wlnums"
                    riot-value={data.wlnums}
                    on-change={onWlnumsChange}></ui-select>
        </span>
        <span style="white-space:nowrap;">
            <label>{_("find")}</label>&nbsp;
            <ui-input ref="filter"
                    riot-value={data.keyword}
                    inline=1
                    suffix-icon="search"
                    on-suffix-icon-click={onFilterSubmit}
                    on-submit={onFilterSubmit}></ui-input>
        </span>
    </span>

    <feature-toolbar ref="feature-toolbar"
        store={store}
        pulse-id={isEmpty ? "settings" : null}
        feature-page="wordlist"
        formats={["csv", "xls", "xml"]}
        options={isAttribute ? [] : optionsList}
        settings-tag={isAttribute ? null : "wordlist-tabs"}></feature-toolbar>

    <script>
        require("./wordlist-result-options.scss")
        require("wordlist/wordlist-tabs.tag")
        require("wordlist/wordlist-result-options-view.tag")
        require("wordlist/wordlist-result-options-info.tag")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.totalitems = 0
        this.optgroups = []

        this.corpus.structures.forEach(struct => {
            if(struct.attributes.length){
                this.optgroups.push({
                    label: struct.label || struct.name,
                    options: struct.attributes.map(attr => {
                        return {
                            label: struct.name + " - " + (attr.label || attr.name),
                            value: struct.name + "." +attr.name
                        }
                    })
                })
            }
        })

        this.optionsList = [
            {
                id: "view",
                icon: "visibility",
                iconClass: "material-icons",
                contentTag: "wordlist-result-options-view",
                labelId: "changeDisplayOptions"
            },
            {
                id: "info",
                contentTag: 'wordlist-result-options-info',
                iconClass: "material-icons",
                icon: "info_outline",
                labelId: 'wl.labelInfo'
            }
        ]

        this.wlnumsOptions = [{
            value: "docf",
            labelId: "wl.docf"
        }, {
            value: "frq",
            labelId: "tokens"
        }]

        onFilterSubmit(){
            this.store.searchAndAddToHistory({
                keyword: this.refs.filter.getValue(),
                filter: "containing"
            })
        }

        onRandomClick(){
            this.store.searchAndAddToHistory({
                random: !this.store.data.random * 1 // numeric value 1/0
            })
        }

        updateAttributes(){
            this.isAttribute = this.data.tab == "attribute" // showing attribute frequencies from corpinfo page
            this.resultsFor =  this.store.getFindLabel(this.data.find)
            this.totalitems = isNaN(this.data.totalitems) ? "" : window.Formatter.num(this.data.totalitems)
            this.isEmpty = !this.data.items.length && !this.store.data.jobid
        }
        this.updateAttributes()

        onWlattrChange(value){
            this.store.searchAndAddToHistory({
                wlattr: value,
                onecolumn: true
            })
        }

        onWlnumsChange(wlnums){
            this.store.searchAndAddToHistory({
                wlnums: wlnums
            })
        }

        this.on("update", this.updateAttributes)
    </script>
</wordlist-result-options>
