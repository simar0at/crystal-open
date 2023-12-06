<concordance-subcorpus-dialog>
    <preloader-spinner if={isLoading} overlay=1 center=1></preloader-spinner>
    <div style="max-width: 500px; margin: auto;">
        <ui-input
            class="subcname"
            ref="subcname"
            validate=1
            required=1
            label={_("subcname")}></ui-input>
        <ui-list
            classes="subcstruct"
            ref="subcstruct"
            options={structures}
            riot-value={subcstruct}
            required=1
            label={_("subcstruct")}></ui-list>
        <div class="center-aligned">
            <a href="#ca-subcorpora" class="btn">
                {_("manageMySubcorpora")}
            </a>
            <div class="btn btn-primary" onclick={createSubc}>
                {_("createSubcorpus")}
            </div>
        </div>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.subcorpora = []
        this.isLoading = false
        this.actualCorpname = AppStore.getActualCorpname()
        this.isActualCorpname = !this.opts.corpname || this.opts.corpname == this.actualCorpname
        this.structures = AppStore.get("corpus.structures").filter(structure => structure.name != "g")
                .map(structure => ({
                    label: structure.name,
                    value: structure.label || structure.name
                }))
        this.subcstruct = this.structures.findIndex(s => s.value == "s") != -1 ? "s" : this.structures[0].value

        createSubc() {
            let subcname = this.refs.subcname.getValue()
            if((this.isActualCorpname && AppStore.getSubcorpus(subcname))
                 || (!this.isActualCorpname && this.subcorpora.includes(subcname))){
                SkE.showToast(_("msg.subcorpAlreadyExists"))
                return
            }
            AppStore.createSubcorpus(subcname, {
                q: this.data.raw.q,
                struct: this.refs.subcstruct.value
            }, this.opts.corpname)
            this.refs.subcname.refs.input.value = ''
            // TODO: wait until the subcorpus is successfully created
            this.parent.closeOptions()
        }

        onCorpusLoaded(data){
            this.isLoading = false
            this.subcorpora = data.subcorpora.map(s => s.n)
            this.update()
        }

        if(!this.isActualCorpname){
            AppStore.loadAnyCorpus(this.opts.corpname)
            Dispatcher.one('ANY_CORPUS_LOADED', this.onCorpusLoaded)
            this.isLoading = true
        }

        this.on("mount", () => {
            delay(() => {$(this.refs.subcname.refs.input).focus()})
        })

        this.on("unmount", () => {
            Dispatcher.off('ANY_CORPUS_LOADED', this.onCorpusLoaded)
        })
    </script>
</concordance-subcorpus-dialog>


