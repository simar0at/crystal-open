<concordance-parconc-dialog>
    <div>{_("concTranslateDesc")}</div>
    <br>
    <ui-filtering-list
            options={langCorplist}
            name="corpname"
            label-id="language"
            close-on-select={true}
            on-change={onLangSelect}></ui-filtering-list>

    <script>
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")
        const {AppStore} = require("core/AppStore.js")

        this.langCorplist = AppStore.data.corpusList.filter(corpus => {
            return ConcordanceStore.corpus.aligned.includes(corpus.corpname.substr(corpus.corpname.lastIndexOf("/") + 1))
        }).map(corpus => {
            return {
                value: corpus.corpname,
                label: corpus.language_name
            }
        })

        onLangSelect(corpname){
            let alignedCorpname = corpname.substr(corpname.lastIndexOf("/") + 1)
            let d = ConcordanceStore.data
            let operations = copy(d.operations)
            Object.assign(operations[0].query, {
                sel_aligned: [alignedCorpname],
                "cql": d.cql,
                "iquery": d.keyword,
                ["queryselector_" + alignedCorpname]: d.queryselector + "row"
            })
            let query = {
                corpname: ConcordanceStore.corpus.corpname,
                tab: "basic",
                formValue: {
                    queryselector: d.queryselector,
                    keyword: d.keyword,
                    lpos: d.lpos,
                    wpos: d.wpos,
                    default_attr: d.default_attr,
                    qmcase: d.qmcase,
                    cql: d.cql
                },
                formparts: [{
                    corpname:  alignedCorpname,
                    formValue: {}
                }],
                operations: operations
            }
            Dispatcher.trigger("closeDialog")
            window.location.href = window.stores.parconcordance.getUrlToResultPage(query)
        }
    </script>
</concordance-parconc-dialog>
