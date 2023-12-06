<concordance-subcorpus-dialog>
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
        <div class="center-align">
            <a href="#ca-subcorpora" class="btn">
                {_("manageMySubcorpora")}
            </a>
            <div class="btn contrast" onclick={createSubc}>
                {_("createSubcorpus")}
            </div>
        </div>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")
        const {ConcordanceStore} = require('./ConcordanceStore.js')

        this.structures = AppStore.get("corpus.structures").filter(structure => {
            return structure.name != "g"
        }).map(structure => {
            return {
                label: structure.name,
                value: structure.label || structure.name
            }
        })

        this.subcstruct = this.structures.length ? this.structures[0].value : ""

        createSubc() {
            if(AppStore.getSubcorpus(this.refs.subcname.getValue())){
                SkE.showToast(_("msg.subcorpAlreadyExists"))
                return
            }
            let q = ConcordanceStore.data.raw.q.reduce((str, q) => {
                if (str) {
                    str += '&'
                }
                return str += 'q=' + encodeURIComponent(q)
            }, "")
            AppStore.createSubcorpus(this.refs.subcname.getValue(), {
                q: q,
                struct: this.refs.subcstruct.value
            })
            this.refs.subcname.refs.input.value = ''
            // TODO: wait until the subcorpus is successfully created
            this.parent.closeOptions()
        }

        this.on("mount", () => {
            delay(() => {$(this.refs.subcname.refs.input).focus()})
        })
    </script>
</concordance-subcorpus-dialog>


