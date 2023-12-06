<concordance-result-options-sample class="concordance-result-options-sample">
    <external-text text="conc_r_sample"></external-text>
    <div class="primaryButtons">
        <ui-input ref="sampleCount"
            name="sample"
            type="number"
            validate={true}
            inline=1
            min=1
            placeholder="200"
            riot-value=200
            required={true}
            on-submit={onRandomSampleSubmit}
            size=8></ui-input>
        &nbsp;
        <a id="btnGoSample" class="btn btn-primary" onclick={onRandomSampleSubmit}>{_("go")}</a>
    </div>

    <script>
        this.mixin("feature-child")

        onRandomSampleSubmit(){
            let count = this.refs.sampleCount.getValue()
            if(count){
                this.store.addOperationAndSearch({
                    name: "sample",
                    arg: count,
                    query: {
                        q: "r" + count || 10
                    }
                })
            }
        }

        this.on("mount", () => {
            $("input", this.root).focus()
        })
    </script>
</concordance-result-options-sample>
