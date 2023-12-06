<ca-corpus-edit-dialog>
    <br>
    <ui-input
        ref="name"
        class="ca-edit-name"
        label-id="name"
        name="name"
        validate=1
        required=1
        on-input={refreshBtnSaveDisabled}
        riot-value={corpus.name}></ui-input>

        <ui-textarea
            class="ca-edit-info"
            label-id="description"
            name="info"
            riot-value={corpus.info}></ui-textarea>

    <script>
        const {AppStore} = require("core/AppStore.js")
        this.corpus = AppStore.getActualCorpus()

        refreshBtnSaveDisabled(){
            $("#corpusEditSaveBtn").attr("disabled", this.refs.name.getValue() === "")
        }

        this.on("mount", () => {
            this.refreshBtnSaveDisabled()
            delay(() => {$(".ca-edit-name input").focus()}, 1)
        })
    </script>
</ca-corpus-edit-dialog>
