<parconcordance-result-options-distribution class="parconcordance-result-options-distribution">
    <frequency-distribution just-chart={opts.justChart}
            width={opts.width}
            height={opts.height}
            granularity={opts.granularity || 100}
            get-data={getData}
            on-click={onClick}></frequency-distribution>


    <script>

        this.mixin("feature-child")


        getData(granularity) {
            this.data.alignedCorpname = this.opts.corpname.split("/")[1]
            let data = {
                corpname: this.corpus.corpname,
                concordance_query: this.store.getParconcordanceQuery(),
                res: granularity,
                normalize: 0,
                format: "json"
            }
            this.data.alignedCorpname = ""

            this.store.xhrOptions.forEach(attr => {
                if(isDef(this.data[attr])){
                    data[attr] = this.data[attr]
                }
            })
            this.store._addTextTypesToData(data)
            return data
        }

        onClick(item){
            let cql = `[#${item.beg}-${item.end}]`
            this.store.filter({
                pnfilter: "p",
                queryselector: "cqlrow",
                inclkwic: true,
                filfpos: 0,
                filtpos: 0,
                cql: cql
            }, cql, this.corpus.corpname)
            this.store.searchAndAddToHistory({
                results_screen: "concordance",
                page: 1
            })
        }
    </script>
</parconcordance-result-options-distribution>
