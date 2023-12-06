<concordance-tab-basic>
    <div class="concordance-tab-basic card-content">
        <div class="row">
            <div class="col s12 m5">
                <ui-input placeholder={_("abc")}
                    class="bigInput"
                    label-id="cc.simpleSearch"
                    riot-value={options.keyword}
                    name="keyword"
                    on-submit={onSearch}
                    help-dialog="conc_b_simple"
                    on-input={onInput}></ui-input>
            </div>
            <div class="col s12 m7 youtubeCol">
                <div  class="basicYoutube inlineBlock">
                    <div class="youtubeVideoContainer">
                        <iframe width="560"
                                height="315"
                                src={externalLink("concordanceBasicVideo")}
                                frameborder="0"
                                allow="autoplay; encrypted-media"
                                allowfullscreen></iframe>
                    </div>
                </div>
            </div>
        </div>
        <text-types-collapsible if={data.tab=="basic"}></text-types-collapsible>
        <div class="center-align">
            <a id="btnSearchBasic" class="waves-effect waves-light btn contrast"
                    onclick={onSearch}>{_("search")}</a>
        </div>
        <floating-button id="btnGoFloat" onclick={onSearch}
                refnodeid="btnSearchBasic" periodic="1"></floating-button>
    </div>

    <script>
        require("./concordance-tab-basic.scss")

        this.mixin("feature-child")

        updateAttributes(){
            this.options = {
                queryselector: "iquery",
                keyword: this.data.keyword
            }
        }
        this.updateAttributes()

        onInput(value){
            this.options.keyword = value
            this.refreshSearchButtonDisable()
        }

        onSearch(){
            this.store.initResetAndSearch(this.options)
        }

        refreshSearchButtonDisable(){
            $("#btnSearchBasic, #btnGoFloat a").toggleClass("disabled", this.options.keyword === "")
        }

        focusInput(){
            delay(() => {
                $("input[name=\"keyword\"]", this.root).focus()
            }, 1) // call asynchronously so child tags are mounted
        }

        this.on("update", this.updateAttributes)
        this.on("updated", this.refreshSearchButtonDisable)

        this.on("mount", () => {
            this.focusInput()
            this.refreshSearchButtonDisable()
        })
    </script>
</concordance-tab-basic>
