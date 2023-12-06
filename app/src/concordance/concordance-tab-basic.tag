<concordance-tab-basic>
    <div class="concordance-tab-basic card-content">
        <div class="row">
            <div class="col s12 m5">
                <ui-input placeholder={_("abc")}
                    class="bigInput mainFormField"
                    label-id="cc.simpleSearch"
                    riot-value={options.keyword}
                    name="keyword"
                    on-submit={onSearch}
                    help-dialog="conc_b_simple"
                    on-input={onInput}></ui-input>
            </div>
            <div class="col s12 m7 youtubeCol ">
                <div  class="basicYoutube inline-block hide-on-small-only">
                    <div class="youtubeVideoContainer">
                        <a if={window.config.DISABLE_EMBEDDED_YOUTUBE}
                                href={externalLink("concordanceBasicVideo")}
                                target="_blank"
                                class="youtubePlaceholder"
                                style="max-width: 300px;">
                            <img src="images/youtube-placeholder.jpg"
                                    loading="lazy"
                                    alt="Sketch Engine Basics">
                        </a>
                        <iframe if={!window.config.DISABLE_EMBEDDED_YOUTUBE}
                                width="560"
                                height="315"
                                src={externalLink("concordanceBasicVideo")}
                                frameborder="0"
                                allow="autoplay; encrypted-media"
                                allowfullscreen
                                loading="lazy"></iframe>
                    </div>
                </div>
                <div class="hide-on-med-and-up text-left">
                    <a href={externalLink("concordanceBasicVideo")}
                            target="_blank"
                            class="youtubeLink">
                        {_("concordanceBasicsYT")}
                        <i class="material-icons">open_in_new</i>
                    </a>
                </div>
            </div>
        </div>
        <text-types collapsible=1
                selection={options.tts}
                on-change={onTtsChange}></text-types>
        <div class="primaryButtons">
            <a id="btnSearchBasic" class="btn btn-primary"
                    onclick={onSearch}>{_("search")}</a>
        </div>
        <floating-button id="btnBasicGoFloat"
                on-click={onSearch}
                refnodeid="btnSearchBasic"
                periodic="1"></floating-button>
    </div>

    <script>
        require("./concordance-tab-basic.scss")

        this.mixin("feature-child")

        updateAttributes(){
            this.options = {
                queryselector: "iquery",
                keyword: this.data.keyword,
                tts: this.store.data.tts
            }
        }
        this.updateAttributes()

        onInput(value){
            this.options.keyword = value
            this.refreshSearchButtonDisable()
        }

        onTtsChange(tts){
            this.options.tts = tts
        }

        onSearch(){
            this.data.closeFeatureToolbar = true
            this.store.initResetAndSearch(this.options)
        }

        refreshSearchButtonDisable(){
            $("#btnSearchBasic, #btnBasicGoFloat a").toggleClass("disabled", this.options.keyword === "")
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
