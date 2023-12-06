<parconcordance-collocations-result class="parconcordance.collocations-result t_m-{corpIdx}">
    <div ref="tabs" class="optsContent z-depth-3 background-color-blue-100" style="display: none">
        <collocations-tabs class="collocations-tabs"></collocations-tabs>
    </div>
    <collocations-result on-toggle-show-form={onToggleShowForm}></collocations-result>

    <script>
        require("concordance/collocations/collocations-tabs.tag")
        require("concordance/collocations/collocations-result.tag")

        this.mixin("feature-child")

        // for testing purpose
        this.corpIdx = this.data.alignedCorpname ? (this.data.formparts.findIndex(c => c.corpname == this.data.alignedCorpname) + 2) : 1

        onToggleShowForm(evt){
            evt.preventUpdate = true
            $(this.refs.tabs).slideToggle()
        }

        hideForm(){
            $(this.refs.tabs).hide()
        }

        this.on("mount", () => {
            this.store.on("c_dataLoaded", this.hideForm)
        })

        this.on("unmount", () => {
            this.store.off("c_dataLoaded", this.hideForm)
        })
    </script>
</parconcordance-collocations-result>

