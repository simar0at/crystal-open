<text-type-analysis-result-table class="text-type-analysis-result-table">
    <div ref="printChart"
            class="printChart"></div>
    <span class="formBlock card-panel inline-block vertical-top">
        <span class="listWrapper">
            <ui-list label-id="textTypeSelect"
                    options={options}
                    classes="headerSelect"
                    name="wlattr"
                    inline={true}
                    riot-value={data.wlattr}
                    on-change={onWlattrChange}
                    help-dialog="tt_select"></ui-list>
        </span>
        <span>
            <ui-select options={wlsortOptions}
                    label-id="show"
                    inline=1
                    name="wlsort"
                    riot-value={data.wlsort}
                    on-change={onWlsortChange}
                    help-dialog="tt_show"></ui-select>
        </span>
        <span>
            <subcorpus-select ref="usesubcorp"
                    riot-value={data.usesubcorp}
                    name="usesubcorp"
                    label={_("subcorpus")}
                    on-change={onSubcorpusChange}></subcorpus-select>
        </span>
        <span>
            <filter-input ref="filter"
                    name="filter"
                    label-id="filterResults"
                    query={query}
                    mode={data.filter}
                    match-case={matchCase}
                    inline=1
                    on-input={onFilterInput}
                    on-change={onFilterChange}
                    on-submit={onFilterSubmit}></filter-input>
            <button class="btn tooltipped"
                    id="btnSubmitFilter"
                    data-tooltip={capitalize(_("filter"))}
                    onclick={onFilterSubmit}>
                <i class="material-icons">filter_list</i>
            </button>
            <button class="btn tooltipped"
                    id="btnCancelFilter"
                    data-tooltip={_("clearFilter")}
                    onclick={onFilterClear}>
                <i class="material-icons">close</i>
            </button>
        </span>
        <div class="analyzeMultipleTTBtn color-blue-710 mt-12"
                    onclick={onOpenFrequencyClick}>{_("analyzeMultipleTT")}</div>
    </span>

    <span class="chartBlock inline-block card-panel">
        <span class="left">
            <div class="totalItems m-5"
                    if={data.totalitems}>
                {capitalize(_("wl.items"))}:&nbsp;
                <b>{window.Formatter.num(data.totalitems)}</b>,
                &nbsp;{capitalize(_("totalFrq"))}:
                <b>{window.Formatter.num(data.totalfrq)}</b>
            </div>
        </span>

        <div class="buttons m-4 right-align">
            <span id="btnToggleViewOpts"
                    class="btn btn-floating btn-flat inline-block vertical-top tooltipped"
                    data-tooltip={_("changeViewOpts")}>
                <i class="material-icons"
                        onclick={onChartSettingsClick}>
                    settings
                </i>
            </span>
            <span class="btn btn-floating btn-flat inline-block vertical-top tooltipped"
                    data-tooltip={_("download")}>
                <i class="material-icons" onclick={onChartDownloadClick}>
                    cloud_download
                </i>
            </span>
            <div ref="chartSettings"
                    class="mr-4 mt-1 align-right"
                    style="display: none;">
                <ui-slider ref="chartitems"
                        inline=1
                        name="chartitems"
                        label-id="ttsInChart"
                        riot-value={data.chartitems}
                        labels={labels}
                        left-label=1
                        right-label=20
                        disableinput=1
                        min=1
                        max=20
                        on-change={onChartitemsChange}></ui-slider>
            </div>
            <div ref="chartDownloads"
                    class="downloads mt-1 align-right"
                    style="display: none;">
                <a class="btn btn-flat tooltipped ml-4 wite-text"
                        onclick={onDownloadTableClick}
                        data-tooltip={_(format + "Warning")}
                        each={format in formats}>
                    <i class="ske-icons skeico_{format}"></i>
                    {format.toUpperCase()}
                </a>
                <a class="btn btn-flat ml-4 whte-text"
                        onclick={onDownloadChartClick}
                        download="chart.png">
                    <i class="material-icons">donut_large</i>
                    {_("chart")}
                </a>
            </div>
        </div>
        <div ref="chart" class="chart"></div>
    </span>

    <div if={data.items.length}
            class="resultBlock oneColumn vertical-top card-panel">
        <column-table ref="table"
                show-line-nums={data.showLineNumbers}
                items={data.showItems}
                col-meta={colMeta}
                start-index={data.showResultsFrom}></column-table>

        <div class="row">
            <div class="inline-block right">
                <ui-pagination
                    if={data.items.length > 10}
                    count={data.items.length}
                    items-per-page={data.itemsPerPage}
                    actual={data.page}
                    on-change={store.changePage.bind(store)}
                    on-items-per-page-change={store.changeItemsPerPage.bind(store)}
                    show-prev-next={true}></ui-pagination>
            </div>
        </div>

        <interfeature-menu ref="interfeatureMenu"
                features={["concordance", "concordanceMacro"]}
                is-Feature-link-active={isFeatureLinkActive}
                get-feature-link-params={getFeatureLinkParams}></interfeature-menu>
    </div>


    <script>
        require("./text-type-analysis-result-table.scss")
        const {AppStore} = require("core/AppStore.js")
        const {Connection} = require("core/Connection.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.googleChartsLoaded = false
        if(this.data.filter == "all"){
            this.data.filter = "containing"
        }
        this.labels = [5, 10, 15].map(i =>{
            return {
                text: i,
                value: i
            }
        })
        this.query = this.data.keyword
        this.mode = this.data.filter == "all" ? "containing" : this.data.filter
        this.matchCase = !this.data.wlicase
        this.docstructure = AppStore.get("corpus.docstructure")
        this.formats = ["csv", "xlsx", "xml"]
        this.wlsortOptions = [{
            value: "frq",
            labelId: "structureFrequency"
        }, {
            value: "token:l",
            labelId: "tokenCoverage"
        }]

        updateAttributes(){
            this.options = []
            this.corpus.structures.forEach(struct => {
                if(struct.attributes.length){
                    struct.attributes.forEach(attr => {
                        this.options.push({
                            label: struct.name + " - " + (attr.label || attr.name),
                            value: struct.name + "." + attr.name
                        })
                    }, this)
                }
            }, this)
            this.options.forEach(o => {
                if(AppStore.data.corpus.subcorpattrs.includes(o.value)){
                    o.toTop = true
                }
            })
            this.options.sort((a, b) => {
                if(a.toTop == b.toTop){
                    return a.label.localeCompare(b.label)
                } else if(a.toTop){
                    return -1
                } else{
                    return 1
                }
            })
            this.options.splice(this.options.map(o => o.toTop).lastIndexOf(true), 0, {
                value: "DIVIDER",
                label: "",
                class: "listDivider"
            })
        }
        this.updateAttributes()
        if(!this.options.find(o => o.value == this.store.data.wlattr)){
            this.store.data.wlattr = AppStore.getFirstWlattr()
        }

        refreshTitle(){
            let attr = this.options.find(o => o.value == this.data.wlattr)
            this.title = attr ? attr.label : ""
        }
        this.refreshTitle()

        onFilterInput(query){
            this.query = query
        }

        onFilterChange(query, mode, matchCase){
            this.query = query
            this.mode = mode
            this.matchCase = matchCase
            this.onFilterSubmit()
        }

        onFilterSubmit(){
            if((this.query != this.data.keyword)
                || (this.query !== ""
                    && (this.mode != this.data.filter
                        || this.matchCase == this.data.wlicase
                        )
                    )
                ){
                this.store.searchAndAddToHistory({
                    keyword: this.query,
                    filter: this.mode,
                    wlicase: !this.matchCase
                })
            }
        }

        onFilterClear(){
            this.query = ""
            this.onFilterSubmit()
        }

        onWlattrChange(value){
            this.store.searchAndAddToHistory({
                wlattr: value,
                onecolumn: true
            })
            this.refreshTitle()
        }

        onSubcorpusChange(value){
            this.store.searchAndAddToHistory({
                usesubcorp: value
            })
        }

        onWlsortChange(wlsort){
            this.store.searchAndAddToHistory({
                wlsort: wlsort
            })
        }

        onChartitemsChange(value){
            this.data.chartitems = value
            this.drawChart()
            this.store.updateUrl()
        }

        onChartSettingsClick(evt){
            evt.preventUpdate = true
            $(this.refs.chartDownloads).slideUp()
            $(this.refs.chartSettings).slideToggle()
        }

        onChartDownloadClick(evt){
            evt.preventUpdate = true
            $(this.refs.chartSettings).slideUp()
            $(this.refs.chartDownloads).slideToggle()
        }

        onDownloadTableClick(evt){
            Connection.download(this.store.getDownloadRequest(0), evt.item.format)
        }

        onOpenFrequencyClick(evt){
            evt.preventUpdate = true
            window.location.href = window.stores.concordance.getUrlToResultPage({
                f_tab: "advanced",
                queryselector: "cql",
                cql: `<${this.docstructure}>`,
                f_freqml: [{attr: this.data.wlattr, "context": "0", base: "kwic"},
                        {attr: AppStore.data.corpus.defaultattr, "context": "0", base: "kwic"}]
            })
            window.stores.concordance.one("onDataLoadAlways", () => {
                Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "frequency")
            })
        }

        getFeatureLinkParams(feature, item){
            let options = this.data
            let cql = `<${this.data.wlattr.replace(".", " ")}=="${item.str}">[]`
            return {
                tab: 'advanced',
                queryselector: "cql",
                default_attr: "word",
                usesubcorp: options.usesubcorp,
                selection: options.tts,
                cql: cql
            }
        }

        setColMeta(){
            this.colMeta = []
            let countLabel = _(this.wlsortOptions.find(w => w.value == this.data.wlsort).labelId)
            this.colMeta = [{
                id: "str",
                label:  _("wl.attrValue"),
                "class": "_t word"
            }]
            this.colMeta.push({
                id: this.data.wlsort,
                class: "frq",
                label: countLabel,
                num: true,
                formatter: window.Formatter.num.bind(Formatter),
                tooltip: "t_id:wl_r_" + this.data.wlsort.split(":")[0]
            })

            this.colMeta.push({
                id: "menu",
                "class": "menuColumn col-tab-menu",
                label: "",
                generator: () => {
                    return "<a class=\"iconButton btn btn-flat btn-floating\"><i class=\"material-icons menuIcon\" >more_horiz</i></a>"
                },
                onclick: function(item, colMeta, evt){
                    this.refs.interfeatureMenu.onOpenMenuButtonClick(evt, item)
                }.bind(this)
            })
        }
        this.setColMeta()

        onDownloadChartClick(){
            let win = window.open()
            let chart = this.drawChart(this.refs.printChart, {width: 1200, height:600})
            let src = chart.getImageURI()
            let fileName = this.title.replace(" - ", "_").replace(/\W/g,'_') + ".png"
            let title = this.title + " | Sketch Engine"
            setTimeout(function(){
                let btnStyle = ' style="line-height: 31px;height: 30px;padding: 0 12px;color: #FFF;text-decoration: none;text-align: center;letter-spacing: .5px;transition: background-color .2s ease-out;cursor: pointer;font-size: 14px;outline: 0;border: none;border-radius: 2px;display: inline-block;text-transform: uppercase;vertical-align: middle;-webkit-tap-highlight-color: transparent;margin:0 10px;font-family:sans-serif"'
                let content = '<img src="' + src  + '" style="border:0; display: block; margin: auto;" allowfullscreen loading="lazy">'
                        + '<div style="text-align:center;">'
                        + '<a href="' + src.replace(/^data:image\/[^;]+/, 'data:application/octet-stream')  + '" download="' + fileName + '" ' + btnStyle + '>download</a>'
                        + '<a class="background-color-blue-800" onclick="window.printChart()" ' + btnStyle + '>print</a>'
                        + '</div>'
                        + '<script>window.printChart = function(){window.print()}</scr' + 'ipt>' //split script tag - otherwise riot compiler fails
                win.document.write(content)
                win.document.title = title
            }, 100)
        }

        drawChart(node, chartOptions) {
            let attr = this.data.wlsort
            node = node || this.refs.chart
            if(!this.googleChartsLoaded || !node || !this.data.items.length){
                return
            }
            let total = this.data.items.reduce((total, item) => {
                return total += item[attr]
            }, 0)
            let items = this.data.items
            if(items.length > this.data.chartitems){
                items = this.data.items.slice(0, this.data.chartitems)
            }
            let inputData = items.map(item => [item.str, item[attr]])
            inputData.unshift(["", ""])
            let slices = {}
            if(this.data.items.length > this.data.chartitems){
                // other value = total - value of displayed items
                let otherValue = items.reduce((total, item) => {
                    return total -= item[attr]
                }, total)
                otherValue && inputData.push([capitalize(_("other")), otherValue])
                slices = {
                    [inputData.length - 2]: { // header and index shift
                        color: 'rgb(204, 204, 204)'
                    }
                }
            }
            let data = google.visualization.arrayToDataTable(inputData)

            let options = Object.assign({
                title: this.title,
                pieHole: 0.4,
                backgroundColor: "transparent",
                slices: slices,
                sliceVisibilityThreshold: 0,
                chartArea:{
                    margin: "auto",
                    width: '80%',
                    height: '80%'
                }
            }, chartOptions || {})

            let chart = new google.visualization.PieChart(node)
            chart.draw(data, options)
            return chart
        }

        onResizeDebounced(){
            this.timer && clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                clearTimeout(this.timer)
                this.drawChart()
            }, 200)
        }

        $.ajax({
              url: 'https://www.gstatic.com/charts/loader.js',
              dataType: 'script',
              cache: true,
              success: function() {
                    google.charts.load("current", {packages:["corechart"]})
                    google.charts.setOnLoadCallback(() => {
                        this.googleChartsLoaded = true
                        this.drawChart()
                    })
              }.bind(this)
            })

        this.on("update", this.updateAttributes)

        this.on("updated", () => {
            this.setColMeta()
            this.drawChart()
        })

        this.on("mount", () => {
            window.addEventListener('resize', this.onResizeDebounced)
        })

        this.on("unmount", () => {
            window.removeEventListener('resize', this.onResizeDebounced)
        })
    </script>
</text-type-analysis-result-table>
