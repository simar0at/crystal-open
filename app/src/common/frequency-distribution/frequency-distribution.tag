<frequency-distribution class="frequency-distribution">
    <external-text if={!opts.justChart} text="conc_r_distribution"></external-text>
    <br>
    <div class="distributionContainer">
        <div if={!isLoading && !error} ref="svg" class="svgChart"></div>

        <div if={isLoading} class="center-align">
            <preloader-spinner></preloader-spinner>
        </div>
    </div>
    <ui-slider
            if={!opts.justChart && !error}
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

    <script>
        const {Connection} = require('core/Connection.js')
        require('./frequency-distribution.scss')

        var d3Selection = require('d3-selection')
        var d3Formatting = require('d3-format')
        var d3Scaling = require('d3-scale')
        var d3Axis = require('d3-axis')
        var d3Array = require('d3-array')

        this.mixin("feature-child")

        this.granularity = this.opts.granularity || 50
        this.renderedWith = 0
        this.isLoading = true
        this.error = ''
        this.margin = {
            top: 30,
            right: 20,
            bottom: 40,
            left: 60
        }

        onChangeGran(v) {
            this.granularity = Math.min(Math.max(10, v), 1000)
            this.redraw()
            this.update()
        }

        getDataAndDraw() {
            let self = this
            let request = Connection.get({
                url: window.config.URL_BONITO + 'freq_distrib',
                data: this.opts.getData(this.granularity),
                done: (payload) => {
                    self.isLoading = false
                    if (payload.dots) {
                        this.update()
                        self.draw(payload.dots)
                        self.renderedWith = this.granularity
                    }
                    else {
                        this.error = payload.error
                        this.update()
                    }
                },
                fail: payload => {
                    SkE.showError("Could not load distribution data.", getPayloadError(payload))
                },
                always: () => {
                    self.isLoading = true
                }
            })
        }

        redraw() {
            if (this.renderedWith != this.granularity) {
                this.getDataAndDraw()
            }
        }

        draw(data) {
            let self = this
            var widths = self.dyn_sizes(data.length)
            var width = widths.chart - this.margin.right - this.margin.left
            var height = (this.opts.height || 280) - this.margin.top - this.margin.bottom
            var frmtPerc = d3Formatting.format(".0%")
            var max = Math.max(...data.map(d => {return d.frq}))
            var x = d3Scaling.scaleLinear().range([0, width])
            var y = d3Scaling.scaleLinear().range([height, 0])
            var xAxis = d3Axis.axisBottom().scale(x).tickFormat(frmtPerc)
            var yAxis = d3Axis.axisLeft().scale(y).ticks(height / 30)
            var svg = d3Selection.select(this.refs.svg).append("svg")
                .attr("width", widths.chart)
                .attr("height", height + this.margin.top + this.margin.bottom).append("g")
                .attr("transform", "translate("+this.margin.left+","+this.margin.top+")")
            x.domain([0, Math.round(d3Array.max(data, function(d) { return d.pos }))])
            y.domain([0, max])
            svg.selectAll(".bar").data(data).enter().append("rect").attr("class", "bar")
                .attr("x", function(d) { return x(d.pos) })
                .attr("width", widths.bar)
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
                        isFun(this.opts.onClick) && this.opts.onClick(d)
                    }
                }.bind(this))
            let ticks = Math.min(Math.round(width / 50), 11) // at least 50 px per label, maximum 11 labels (every 10%)
            svg.append("g").attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")").call(xAxis.ticks(ticks))
                .append("text").attr("x", width).attr("y", 35).attr("class", "legend")
                .style("text-anchor","end").text(_('position'))
            svg.append("g").attr("class", "y axis").call(yAxis).append("text")
                .attr("y", -15).attr("dy", ".71em")
                .attr("class", "legend").style("text-anchor", "end")
                .text(_('frequency'))
        }

        dyn_sizes(res) {
            let chart
            let bar
            let margin = this.margin.left + this.margin.right
            if(this.opts.width){
                chart = this.opts.width
                bar = Math.max(Math.round((this.opts.width - margin) / this.granularity) - 1, 1)
            } else {
                let idealWidth = 700 + Math.round((res - 100) * 1.3) - margin
                bar = Math.min(Math.max(Math.round(idealWidth / this.granularity), 3), 10)
                chart = (bar + 1) * res + margin
            }
            return {
                chart: chart,
                bar: bar
            }
        }

        this.on("mount", this.redraw)
    </script>
</frequency-distribution>
