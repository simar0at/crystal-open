<oct-langs class="oct-langs">
    <span if={corpora.length == 0} class="error">{_("OCTnoAlignedCorpora")}</span>
    <div if={corpora.length > 0} class="mt-8">
        <p>{_("sourceCorpus")}: <b>{corpus.name}</b></p>
        <p if={corpora.length == 1}>{_("targetCorpus")}: <b>{corpora[0].name}</b></p>
        <p if={corpora.length > 1}>
            {_("selectTargetCorpus")}:
            <select class="browser-default langSelect" name="l2" id="l2_select" ref="l2_select">
                <option value={t.id} each={t in corpora}>
                    {t.name}
                </option>
            </select>
        </p>
        <button class="btn btn-primary mt-4" onclick={extractBiterms}>{_("extractBiterms")}</button>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")
        this.corpora = []

        initData() {
            this.corpus = AppStore.get("corpus")
            let languages = AppStore.get('languageList') || []
            this.oct_languages = languages.filter(l => l.reference_corpus && l.has_term_grammar).map(l => l.name)
            let aligned = this.corpus.aligned_details.map(c => ({ ...c, id: this.corpus.aligned_details.indexOf(c)}))
            let alignedLangs = this.corpus.owner_id !== null ? this.oct_languages : AppStore.langsWithBiterms
            this.corpora = aligned.filter(ac => alignedLangs.includes(ac.language_name))
            this.update()
        }

        extractBiterms() {
            let corpname = this.corpus.corpname
            let corpname2 = ''
            let prefix = corpname.substring(0, corpname.lastIndexOf('/'))
            if (this.corpora.length == 1) {
                corpname2 = this.corpus.aligned[this.corpora[0].id]
            }
            else if (this.corpora.length > 1) {
              let id = this.refs.l2_select.value
              corpname2 = this.corpus.aligned[id]
            }
            window.open(`${config.URL_OCT}results-aligned?corpname=${corpname}&corpname2=${prefix}/${corpname2}`, '_blank')
            this.modalParent.close()
        }


        this.on('mount', () => {
            this.initData()
        })

    </script>
</oct-langs>
