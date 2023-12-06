<keywords-tab-basic class="keywords-tab-basic">
    <div class="card-content">
        <div>
            <div class="row">
                {_("kw.text4")}
                {_("kw.text5")}
            </div>
            <div class="row">
                <div class="col s6">
                    <b>{_("keywords")}</b><br />
                    {_("kw.text2")}
                </div>
                <div class="col s6">
                    <b>{_("terms")}</b><br />
                    {_("kw.text3")}
                </div>
            </div>
        </div>
        <div if={store.corpus.preloaded} style="padding-top: 2em;">
            <div class="row"><b>{_("kw.prelCorpWarnTitle")}</b><br />
            {_("kw.prelCorpWarnText")}</div>
            <div class="center-align" style="padding-top: 1em;">
                <button id="btnGoBasic"
                        class="btn btn-primary contrast"
                        onclick={initAndRun}>
                    {_("kw.prelCorpWarnOK")}
                </button>
            </div>
        </div>
        <div class="center-align" style="padding-top: 1em;">
            <button if={!store.corpus.preloaded}
                    id="btnGoBasic"
                    class="btn btn-primary contrast"
                    onclick={initAndRun}>{_("go")}</button>
        </div>
    </div>

    <script>
        this.mixin("feature-child")
        const {AppStore} = require("core/AppStore.js")
        const {Auth} = require('core/Auth.js')

        initAndRun() {
            this.store.data.do_wipo = Auth.isWIPO()
            this.store.resetSearchAndAddToHistory({
                k_ref_corpname: this.store.corpus.refKeywordsCorpname || "",
                t_ref_corpname: this.store.corpus.refTermsCorpname || "",
                attr: !!AppStore.getAttributeByName("lemma") && "lemma" || "word"
            })
        }
    </script>
</keywords-tab-basic>
