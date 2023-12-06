<concordance-distribution>
    <external-text text="conc_r_distribution"></external-text>
    <br>
    <div class="distributionContainer">
        <div if={!isLoading && !error} id="svg_plot"></div>

        <div if={isLoading} class="center-align">
            <preloader-spinner></preloader-spinner>
        </div>
    </div>
    <ui-slider
            if={!error}
            left-label={_("cc.coarse")}
            right-label={_("cc.fine")}
            disabled={isLoading}
            label={_("cc.granularity")}
            min="10"
            max="1000"
            step="10"
            value={granularity}
            name="granularity"
            on-change={onChangeGran}>
    </ui-slider>
    <p if={error}>{error}</p>

    <style>
        .distributionContainer{
            overflow: auto;
        }
        #svg_plot{
            max-width: 1px;
        }
        .axis path,
        .axis line {
            fill: none;
            stroke: #CCC;
            shape-rendering: crispEdges;
        }
        .axis text.legend {
            display: block;
            fill: black !important;
        }
        .axis text {
            fill: #555;
        }
        .bar {
            fill: #4682B4;
        }
        .bar.active {
            fill: #B22222;
            cursor: pointer;
        }
    </style>

    <script>
        const {Connection} = require('core/Connection.js')

        var d3Selection = require('d3-selection')
        var d3Formatting = require('d3-format')
        var d3Scaling = require('d3-scale')
        var d3Axis = require('d3-axis')
        var d3Array = require('d3-array')

        this.mixin("feature-child")

        this.granularity = 100
        this.renderedWith = 0
        this.isLoading = true
        this.error = ''

        onChangeGran(v) {
            this.granularity = v
            this.redraw()
            this.update()
        }

        getDataAndDraw(granularity) {
            let self = this
            let request = Connection.get({
                url: window.config.URL_BONITO + 'freq_distrib?corpname=' + this.corpus.corpname,
                xhrParams: {
                    method: "POST",
                    data: self._getConcordanceData(),
                },
                query: {
                    corpname: this.corpus.corpname
                },
                done: (payload) => {
                    self.isLoading = false
                    if (payload.dots) {
                        this.update()
                        self.draw(payload.dots)
                        self.renderedWith = granularity
                    }
                    else {
                        this.error = payload.error
                        this.update()
                    }
                },
                always: () => {
                    self.isLoading = true
                }
            })
        }

        _getConcordanceData () {
            let data = {
                corpname: this.corpus.corpname,
                concordance_query: this.store.getConcordanceQuery(),
                res: this.granularity,
                format: "json"
            }

            ;["reload", "lpos", "wpos", "default_attr",
                    "fc_lemword_window_type", "attrs", "structs", "refs",
                    "ctxattrs", "attr_allpos", "fc_lemword_wsize",
                    "fc_lemword", "fc_lemword_type", "fc_pos_window_type",
                    "fc_pos_wsize", "fc_pos_type", "usesubcorp",
                    "viewmode"].forEach((a) => {
                if (typeof this.data[a] != "undefined") {
                    data[a] = this.data[a]
                }
            })
            return 'json=' + encodeURIComponent(JSON.stringify(data))
        }

        redraw() {
            if (this.renderedWith != this.granularity) {
                this.getDataAndDraw(this.granularity)
            }
        }

        draw(data) {
            let self = this
            var margin = {top: 10, right: 20, bottom: 40, left: 30}
            var width = self.dyn_sizes(data.length, 'svg') - margin.left - margin.right
            var height = 250 - margin.top - margin.bottom
            var frmtPerc = d3Formatting.format(".0%")
            var x = d3Scaling.scaleLinear().range([0, width])
            var y = d3Scaling.scaleLinear().range([height, 0])
            var xAxis = d3Axis.axisBottom().scale(x).tickFormat(frmtPerc)
            var yAxis = d3Axis.axisRight().scale(y).ticks(0)
            var svg = d3Selection.select("#svg_plot").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom).append("g")
                .attr("transform", "translate("+margin.left+","+margin.top+")")
            x.domain([0, Math.round(d3Array.max(data, function(d) { return d.pos }))])
            y.domain([0, d3Array.max(data, function(d) { return d.frq })])
            svg.selectAll(".bar").data(data).enter().append("rect").attr("class", "bar")
                .attr("x", function(d) { return x(d.pos) })
                .attr("width", function(d) { return self.dyn_sizes(data.length, 'bar') })
                .attr("y", function(d) { return y(d.frq) })
                .attr("height", function(d) { return height - y(d.frq) })
                .on("mouseover", function (d) {
                    d3Selection.select(this).classed('active', true)
                })
                .on('mouseout', function (d) {
                    d3Selection.select(this).classed('active', false)
                })
                .on('click', function (d) {
                    if (d.beg < d.end) {
                        this.store.filter({
                            pnfilter: "p",
                            queryselector: "cqlrow",
                            inclkwic: true,
                            filfpos: 0,
                            filtpos: 0,
                            cql: `[#${d.beg}-${d.end}]`
                        })
                        this.store.searchAndAddToHistory({
                            results_screen: "concordance",
                            page: 1
                        })
                    }
                }.bind(this))
            svg.append("g").attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")").call(xAxis)
                .append("text").attr("x", width).attr("y", 35).attr("class", "legend")
                .style("text-anchor","end").text(_('position'))
            svg.append("g").attr("class", "y axis").call(yAxis).append("text")
                .attr("transform", "rotate(-90)").attr("y", -20).attr("dy", ".71em")
                .attr("class", "legend").style("text-anchor", "end")
                .text(_('frequency'))
        }

        dyn_sizes(res, what) {
            if (what == 'svg') return 700 + Math.round(((res-100)/900)*1200)
            if (what == 'bar') return Math.max(1, 5-Math.ceil(((res-100)/900)*5))
        }

        this.on("mount", this.redraw)
    </script>
</concordance-distribution>
