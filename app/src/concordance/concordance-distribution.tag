<concordance-distribution class="concordance-distribution">
    <frequency-distribution just-chart={opts.justChart}
            width={opts.width}
            height={opts.height}
            granularity={opts.granularity || 50}
            get-data={getData}
            on-click={onClick}></frequency-distribution>


    <script>
        this.mixin("feature-child")

        getData(granularity) {
            let data = {
                corpname: this.corpus.corpname,
                concordance_query: this.opts.concordanceQuery || this.store.getConcordanceQuery(),
                res: granularity,
                normalize: 0,
                format: "json"
            }

            ;["reload", "lpos", "wpos", "default_attr",
                    "fc_lemword_window_type", "attrs", "structs", "refs",
                    "attr_allpos", "fc_lemword_wsize",
                    "fc_lemword", "fc_lemword_type", "fc_pos_window_type",
                    "fc_pos_wsize", "fc_pos_type", "usesubcorp",
                    "viewmode"].forEach((a) => {
                if (typeof this.data[a] != "undefined") {
                    data[a] = this.data[a]
                }
            })
            return data
        }

        onClick(item){
            isFun(this.opts.onClick) && this.opts.onClick(item)
            this.store.filter({
                pnfilter: "p",
                queryselector: "cqlrow",
                inclkwic: true,
                filfpos: 0,
                filtpos: 0,
                cql: `[#${item.beg}-${item.end}]`
            })
            this.store.searchAndAddToHistory({
                results_screen: "concordance",
                page: 1
            })
        }
    </script>
</concordance-distribution>
