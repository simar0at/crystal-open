<keywords-tab-basic class="keywords-tab-basic">
    <div class="card-content">
        <div>
            <div class="row">
                {_("kw.text4")}
            </div>
            <div class="row pl-10 mt-4">
                <p class="mb-2">
                    <b>{_("keywords")}</b>
                    {_("kw.text2")}
                </p>
                <p class="mb-2">
                    <b>{_("terms")}</b>
                    {_("kw.text3")}
                </p>
                <p>
                    <b>{_("ngrams")}</b>
                    {_("kw.textNgrams")}
                </p>
            </div>
        </div>
        <div if={store.corpus.preloaded} style="padding-top: 2em;">
            <div class="row"><b>{_("kw.prelCorpWarnTitle")}</b><br />
            {_("kw.prelCorpWarnText")}</div>
            <div class="primaryButtons" style="padding-top: 1em;">
                <button id="btnGoBasic"
                        class="btn btn-primary"
                        onclick={initAndRun}>
                    {_("kw.prelCorpWarnOK")}
                </button>
            </div>
        </div>
        <div class="primaryButtons" style="padding-top: 1em;">
            <button if={!store.corpus.preloaded}
                    id="btnGoBasic"
                    class="btn btn-primary"
                    onclick={initAndRun}>{_("go")}</button>
        </div>
    </div>

    <script>
        this.mixin("feature-child")
        const {AppStore} = require("core/AppStore.js")
        const {Auth} = require('core/Auth.js')

        initAndRun() {
            this.store.data.do_wipo = Auth.isWIPO()
            let attr = !!AppStore.getAttributeByName("lemma") && "lemma" || "word"
            this.store.resetSearchAndAddToHistory({
                ref_corpname: this.store.corpus.refKeywordsCorpname || "",
                k_page: 1,
                k_attr: attr,
                n_attr: attr,
                onlywipo: false,
                useterms: !!this.store.corpus.termdef,
                usengrams: !this.store.corpus.termdef,
                closeFeatureToolbar: true
            })
        }
    </script>
</keywords-tab-basic>
