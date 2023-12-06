<query-types class="query-types">
    <div class="flexContainer">
        <div class="filterCol" style="max-width: 250px;">
            <ui-list options={queryselectorOptions}
                    ref="queryselector"
                    label-id="cc.queryType"
                    name="querySelector"
                    riot-value={value.queryselector}
                    help-dialog="conc_query_types"
                    on-change={onQueryselectorChange}></ui-list>
        </div>

        <div class="filterCol" if={value.queryselector == "lemma"} style="max-width: 250px;">
            <ui-list
                    name="lpos"
                    label-id="pos"
                    options={lposOptions}
                    riot-value={lpos}
                    on-change={onLposChange}
            ></ui-list>
        </div>

        <div class="filterCol" if={value.queryselector == "word"} style="max-width: 250px;">
            <ui-list
                    name="wpos"
                    label-id="pos"
                    options={wposOptions}
                    riot-value={wpos}
                    on-change={onWposChange}
            ></ui-list>
        </div>

        <div class="filterCol"  if={value.queryselector != "cql"}>
            <ui-input placeholder={_("abc")}
                    class="bigInput mainFormField"
                    ref="keyword"
                    on-submit={onSubmit}
                    on-input={refreshIsValid}
                    on-change={onOptionChange}
                    name="keyword"
                    riot-value={value.keyword}
                    label={_(value.queryselector)}></ui-input>
            <ui-checkbox if={isQmcaseDisplayed()}
                    class="bigInput"
                    name="qmcase"
                    disabled={!hasCase}
                    checked={!value.qmcase}
                    on-change={onQmcaseChange}
                    tooltip="t_id:wlicase"
                    label={_("ignoreCase")}></ui-checkbox>
        </div>
        <div if={value.queryselector == "cql"}
                class="filterCol"
                style="flex:2;">
            <cql-textarea ref="cql"
                    riot-value={value.cql}
                    cb-value={value.cb}
                    name="cql"
                    corpus={corpus}
                    wpos-options={wposOptions}
                    tagsetdoc={opts.tagsetdoc}
                    on-input={refreshIsValid}
                    on-submit={onSubmit}
                    on-cb-change={onCBChange}
                    on-change={onCQLChange}></cql-textarea>
            <br><br>

            <ui-select
                    inline=1
                    name="default_attr"
                    label-id="cc.defaultAttr"
                    tooltip="t_id:conc_a_cql_def_attr"
                    options={defaultAttrOptions}
                    disabled={opts.fixeddefattr}
                    riot-value={opts.fixeddefattr || value.default_attr}
                    on-change={onOptionChange}></ui-select>
        </div>


        <div if={showVideo && value.queryselector == "cql"}
                class="filterCol "
                style="min-width: 300px;" >
            <div  class="cqlYoutube inline-block ">
                <div class="youtubeVideoContainer hide-on-med-and-down">
                    <a if={window.config.DISABLE_EMBEDDED_YOUTUBE}
                            href={externalLink("cqlIntro")}
                            target="_blank"
                            class="youtubePlaceholder">
                        <img src="images/youtube-placeholder.jpg"
                                loading="lazy"
                                alt="Sketch Engine CQL Intro">
                    </a>
                    <iframe if={!window.config.DISABLE_EMBEDDED_YOUTUBE}
                            width="560"
                            height="315"
                            src={externalLink("cqlIntro")}
                            frameborder="0"
                            allow="autoplay; encrypted-media"
                            allowfullscreen
                            loading="lazy"></iframe>
                </div>
                <div class="cqlYoutubeLink hide-on-large-only">
                    <a href={externalLink("cqlIntro")}
                            target="_blank">
                        {_("concordanceCQLYT")}
                        <i class="material-icons">open_in_new</i>
                    </a>
                </div>
                <div class="cqlManual">
                    <a href={externalLink("cqlManual")} target="_blank">
                        {_("cqlManual")}
                        <i class="material-icons">open_in_new</i>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./query-types.scss")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.defaultAttrOptions = this.corpus.attributes
        this.isValid = null
        this.showVideo = isDef(this.opts.showVideo) ? this.opts.showVideo : true

        updateAttributes(){
            this.value = this.opts.riotValue
            if(!this.value.queryselector){
                this.value.queryselector = "iquery"
            }
            this.hasCase = typeof this.opts.hascase !== 'undefined' ? this.opts.hascase :
                    !AppStore.data.corpus.unicameral
            this.hasLemma = typeof this.opts.haslemma !== 'undefined' ? this.opts.haslemma :
                    !!AppStore.getAttributeByName("lemma")
            this.queryselectorOptions = ["iquery"].concat(this.hasLemma ? ["lemma"] : [])
                    .concat(["phrase", "word", "char", "cql"]).map((option) => {
                        return {
                            label: _(option),
                            value: option
                        }
                    })
            if (typeof this.opts.wposlist !== 'undefined') {
                let l = this.opts.wposlist.map(w => {
                    return {value: w.v, label: w.n}
                })
                this.wposOptions = [{labelId: "any", value: "any"}].concat(l)
            } else {
                this.wposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.wposlist)
            }
            if (typeof this.opts.lposlist !== 'undefined') {
                let l = this.opts.lposlist.map(w => {
                    return {value: w.v, label: w.n}
                })
                this.lposOptions = [{labelId: "any", value: "any"}].concat(l)
            } else {
                this.lposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.lposlist)
            }
            this.lpos = this.value.lpos == "" ? "any" : this.value.lpos
            this.wpos = this.value.wpos == "" ? "any" : this.value.wpos
        }
        this.updateAttributes()

        reset(){
            this.refs.keyword && (this.refs.keyword.refs.input.value = "")
        }

        onSubmit(value, name){
            Object.assign(this.value, {[name]: value})
            this.opts.onSubmit(this.value)
        }

        onCBChange(cbCQL){
            this.value.cb = cbCQL
            this.update()
        }

        onQmcaseChange(checked){
            this.changeOptions({
                qmcase: !checked
            })
        }

        onQueryselectorChange(value){
            this.changeOptions({
                queryselector: value || "iquery",
                lpos: "",
                wpos: ""
            })
            this.focusInput()
            this.update()
            this.refreshIsValid()
        }

        onLposChange(value){
            this.changeOptions({
                lpos: value == "any" ? "" : value,
                qmcase: false
            })
            this.focusInput()
        }

        onWposChange(value){
            this.changeOptions({
                wpos: value == "any" ? "" : value
            })
            this.focusInput()
        }

        onOptionChange(value, name){
            this.changeOptions({
                [name]: value.trim()
            })
        }

        onCQLChange(value){
            this.onOptionChange(value, "cql")
            this.refreshIsValid()
        }

        isQmcaseDisplayed(){
            if(!this.hasCase){
                return false
            }
            if(this.value.queryselector == "phrase"){
                return true
            }
            let attr = AppStore.getAttributeByName(this.value.queryselector)
            return attr && (this.value.queryselector == "word" || this.value.queryselector == "lemma")
        }

        refreshIsValid(){
            this.isValid = !!(this.refs.keyword && this.refs.keyword.getValue()
                    || this.refs.cql && this.refs.cql.getValue())
            this.opts.onValidChange && this.opts.onValidChange(this.isValid)
        }

        changeOptions(options){
            Object.assign(this.value, options)
            this.opts.onChange(this.value, this.opts.name)
        }

        focusInput(){
            delay(() => {
                $("input[name=\"keyword\"]:visible, textarea[name=\"cql\"]:visible", this.root).first().focus()
            }, 10)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.refreshIsValid()
            this.focusInput()
        })
    </script>
</query-types>
