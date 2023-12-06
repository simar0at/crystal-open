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
            <label>{_(value.queryselector)}</label>
            <ui-input placeholder={_("abc")}
                class="bigInput"
                ref="keyword"
                on-submit={onSubmit}
                on-input={onInput}
                on-change={onOptionChange}
                name="keyword"
                riot-value={value.keyword}></ui-input>
            <ui-checkbox if={isQmcaseDisplayed()}
                class="bigInput"
                name="qmcase"
                disabled={!hasCase}
                checked={value.qmcase == 0}
                on-change={onQmcaseChange}
                tooltip="t_id:wlicase"
                label={_("ignoreCase")}></ui-checkbox>
        </div>
        <div class="filterCol" style="flex:2;" if={value.queryselector == "cql"}
                class="filterCqlCol">
            <ui-textarea placeholder={_("cc.cqlPlaceholder")}
                class="cql-textarea-{ta_id}"
                monospace=1
                inline=1
                ref="cql"
                label-id="cql"
                riot-value={value.cql}
                name="cql"
                rows=1
                on-input={onCqlInput}
                on-change={onOptionChange}
                onkeydown={onCqlKeyDown}
                style="width: {cbEdit ? 'calc(100% - 60px);' : '100%;'}"></ui-textarea>
                <button if={cbEdit}
                    class="inlineBlock btn cbButton ui cffTooltip"
                    data-tooltip={_("editCQLBtnTip")}
                    onclick={onEditCQLBuilderClick}>
                    <i class="material-icons">edit</i>
                </button>

            <insert-characters ref="characters"
                    characters={charactersList}
                    field=".cql-textarea-{ta_id} textarea"
                    on-insert={onCharacterInsert}></insert-characters>
            <a href="javascript:void(0);"
                    class="btn white-text"
                    onclick={onTagsHelpClick}
                    style="vertical-align: top;">{_("tagP")}</a>
            <cql-builder ref="builder"
                    on-submit={onCQLBuilderSubmit}
                    style="vertical-align: top;"></cql-builder>
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
                class="filterCol"
                style="min-width: 300px;" >
            <div  class="cqlYoutube inlineBlock">
                <div class="youtubeVideoContainer">
                    <iframe width="560"
                            height="315"
                            src={externalLink("cqlIntro")}
                            frameborder="0"
                            allow="autoplay; encrypted-media"
                            allowfullscreen></iframe>
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
        require("./concordance-tags-help.tag")
        const {AppStore} = require("core/AppStore.js")

        this.tooltipClass = ".cffTooltip"
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.defaultAttrOptions = this.corpus.attributes
        this.isValid = null
        this.ta_id = Math.round(Math.random() * 1000000)

        this.charactersList = [
            ["[]", "cc.squareBracketTip"],
            ["{}", "cc.curlyBracketTip"],
            ["<>", "cc.angleBracketTip"],
            ["\"\"", "cc.quotesTip"],
            ["&", "cc.ampBracketTip"],
            "\\",
            ["|", "cc.pipeTip"],
            "~", "#"
        ]
        this.cbCQL = this.opts.riotValue.cql
        this.cbEdit = !!this.cbCQL

        this.showVideo = isDef(this.opts.showVideo) ? this.opts.showVideo : true

        updateAttributes(){
            this.value = this.opts.riotValue
            if(!this.value.queryselector){
                this.value.queryselector = "iquery"
            }
            this.hasCase = typeof this.opts.hascase !== 'undefined' ? this.opts.hascase :
                    !AppStore.data.unicameral
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
            }
            else {
                this.wposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.wposlist)
            }
            if (typeof this.opts.lposlist !== 'undefined') {
                let l = this.opts.lposlist.map(w => {
                    return {value: w.v, label: w.n}
                })
                this.lposOptions = [{labelId: "any", value: "any"}].concat(l)
            }
            else {
                this.lposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.lposlist)
            }
            this.lpos = this.value.lpos == "" ? "any" : this.value.lpos
            this.wpos = this.value.wpos == "" ? "any" : this.value.wpos
        }
        this.updateAttributes()

        reset(){
            this.refs.keyword && (this.refs.keyword.refs.input.value = "")
            this.refs.cql && (this.refs.keyword.cql.textarea.value = "")
        }

        onSubmit(){
            let key = this.value.queryselector == "cql" ? "cql" : "keyword"
            this.changeOptions({
                [key]: this.refs[key].getValue(),
            })
            this.opts.onSubmit()
        }

        onCqlKeyDown(evt){
            evt.preventUpdate = true
            if(evt.keyCode == 13){
                evt.preventDefault()
                if(this.refs.cql.getValue()){
                    this.onSubmit()
                }
            }
        }

        onCqlInput(value){
            let wasEdit = this.cbEdit
            this.cbEdit = value == this.cbCQL
            wasEdit != this.cbEdit && this.update()
            this.refreshIsValid()
        }

        onEditCQLBuilderClick(evt){
            evt.preventUpdate = true
            this.refs.builder.openDialogWithData(this.value.cb)
        }

        onCQLBuilderSubmit(data, stringified){
            this.cbCQL = data
            this.cbEdit = true
            this.changeOptions({
                cql: data,
                cb: stringified
            })
            this.update()
        }

        onQmcaseChange(checked){
            this.changeOptions({
                qmcase: checked ? 0 : 1
            })
        }

        onQueryselectorChange(value){
            this.changeOptions({
                queryselector: value || "iquery",
                lpos: "",
                wpos: ""
            })
            this.focusInput()
            this.refreshIsValid()
            this.update()
        }

        onLposChange(value){
            this.changeOptions({
                lpos: value == "any" ? "" : value,
                qmcase: 0
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

        onTagsHelpClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                tag: "concordance-tags-help",
                opts:{
                    wposlist: this.wposOptions.slice(1),
                    tagsetdoc: this.opts.tagsetdoc || this.corpus.tagsetdoc,
                    onTagClick: function(tag){
                        this.refs.characters.insert(tag)// insertIntoCQL(tag)
                        Dispatcher.trigger("closeDialog")
                        this.update()
                    }.bind(this)
                },
                small: true,
                fixedFooter: true
            })
        }

        onInput(value, name, evt){
            this.refreshIsValid()
        }

        isQmcaseDisplayed(){
            if(this.value.queryselector == "phrase" && this.hasCase){
                return true
            }
            let attr = AppStore.getAttributeByName(this.value.queryselector)
            return attr
                    && (this.value.queryselector == "word" || this.value.queryselector == "lemma")
                    && attr.ignoreCaseAllowed
        }

        refreshIsValid(){
            this.isValid = !!(this.refs.keyword && this.refs.keyword.getValue()
                    || this.refs.cql && this.refs.cql.getValue())
            this.opts.onValidChange && this.opts.onValidChange(this.isValid)
        }

        onCharacterInsert(character, value){
            this.value.cql = value
            this.refreshIsValid()
            this.update()
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
