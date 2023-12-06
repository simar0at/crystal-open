<ca-corpus-edit-dialog>
    <br>
    <div class="row">
        <ui-input
            ref="name"
            class="ca-edit-name"
            label-id="name"
            name="name"
            validate=1
            required=1
            on-input={refreshBtnSaveDisabled}
            riot-value={corpus.name}></ui-input>
    </div>
    <div class="row">
        <ui-textarea
            class="ca-edit-info"
            label-id="description"
            name="info"
            riot-value={corpus.info}
            rows=2></ui-textarea>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")
        this.corpus = AppStore.getActualCorpus()

        refreshBtnSaveDisabled(){
            $("#corpusEditSaveBtn").toggleClass("disabled", this.refs.name.getValue() === "")
        }

        this.on("mount", () => {
            this.refreshBtnSaveDisabled()
            delay(() => {$(".ca-edit-name input").focus()}, 1)
        })
    </script>
</ca-corpus-edit-dialog>
