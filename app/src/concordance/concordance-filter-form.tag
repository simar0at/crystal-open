<concordance-filter-form class="concordance-filter-form">
    <a onclick={onResetClick}
            data-tooltip={_("resetOptionsTip")}
            class="cffTooltip resetOptions btn btn-floating btn-flat">
        <i class="material-icons dark">settings_backup_restore</i>
    </a>
    <div class="filterRow dividerBottomDotted">
        <div class="flexContainer">
            <div class="inlineBlock" style="flex: 3;">
                <div class="filterCol">
                    <ui-list options={queryselectorOptions}
                        ref="queryselector"
                        label-id="cc.queryType"
                        name="querySelector"
                        riot-value={value.queryselector}
                        on-change={onQueryselectorChange}></ui-list>
                </div>
                <div class="inlineBlock">
                    <div class="filterCol" if={value.queryselector == "lemma" }>
                        <ui-list
                            name="lpos"
                            label-id="pos"
                            options={lposOptions}
                            riot-value={lpos}
                            on-change={onLposChange}
                        ></ui-list>
                    </div>
                    <div class="filterCol" if={value.queryselector == "word"}>
                        <ui-list
                            name="wpos"
                            label-id="pos"
                            options={wposOptions}
                            riot-value={wpos}
                            on-change={onWposChange}
                        ></ui-list>
                    </div>
                    <div class="filterCol" if={value.queryselector != "cql"}>
                        <ui-input placeholder={_("abc")}
                            ref="keyword"
                            size=20
                            on-submit={onSubmit}
                            on-input={refreshDisabled}
                            on-change={onOptionChange}
                            name="keyword"
                            label-id={value.queryselector}
                            value={value.keyword}></ui-input>
                        <ui-checkbox if={!corpus.unicameral && value.queryselector == "word"}
                            name="qmcase"
                            checked={value.qmcase == 0}
                            on-change={onQmcaseChange}
                            tooltip="t_id:wlicase"
                            label={_("ignoreCase")}></ui-checkbox>
                    </div>
                    <div if={value.queryselector == "cql"}
                            class="filterCqlCol">
                        <ui-textarea placeholder={_("cc.cqlPlaceholder")}
                            inline=1
                            monospace=1
                            ref="cql"
                            label="cql"
                            value={value.cql}
                            name="cql"
                            rows=1
                            on-input={refreshDisabled}
                            on-change={onOptionChange}
                            onkeydown={onCqlKeyDown}
                            style="width: 100%; max-width: 600px;"></ui-textarea>

                        <div class="cqlBar">
                            <label>{_("insert")}</label>
                            <span class="btn btn-flat cffTooltip"
                                    data-tooltip={_("cc.squareBracketTip")}
                                    onclick={insertIntoCQL.bind(this, "[]")}>[]</span>
                            <span class="btn btn-flat cffTooltip"
                                    data-tooltip={_("cc.curlyBracketTip")}
                                    onclick={insertIntoCQL.bind(this, "{}")}>{"{}"}</span>
                            <span class="btn btn-flat cffTooltip"
                                    data-tooltip={_("cc.quotesTip")}
                                    onclick={insertIntoCQL.bind(this, '""')}>""</span>
                            <span class="btn btn-flat cffTooltip"
                                    data-tooltip={_("cc.pipeTip")}
                                    onclick={insertIntoCQL.bind(this, "|")}>|</span>
                            <span class="btn btn-flat cffTooltip"
                                    data-tooltip={_("cc.ampBracketTip")}
                                    onclick={insertIntoCQL.bind(this, "&")}
                                    style="margin-right: 20px;">&amp;</span>
                            <a href="javascript:void(0);"
                                    class="btn white-text"
                                    onclick={onTagsHelpClick}>{_("tagP")}</a>
                        </div>
                        <br>
                        <a id="btnCqlBuilder" class="btn btn-floating btn-flat hidden">
                            <i class="material-icons grey-text">build</i>
                        </a>
                        <br>
                        <ui-select
                            inline=1
                            name="default_attr"
                            label-id="cc.defaultAttr"
                            options={defaultAttrOptions}
                            riot-value={value.default_attr}
                            on-change={onOptionChange}></ui-select>
                    </div>
                </div>


                <div class="clearfix"></div>
                <subcorpus-select
                        name="usesubcorp"
                        riot-value={value.usesubcorp}
                        on-change={onOptionChange}></subcorpus-select>
                <br>
            </div>

            <div if={value.queryselector == "cql"}
                    class="cqlYoutube inlineBlock hidden">
                <div class="youtubeVideoContainer">
                    <iframe width="560"
                            height="315"
                            src={externalLink("sketchEngineIntro")}
                            frameborder="0"
                            allow="autoplay; encrypted-media"
                            allowfullscreen></iframe>
                </div>
            </div>
        </div>
    </div>

    <!-- so there is no two concordance-context components - in two tabs-->
    <ui-collapsible label={_("cc.filterContext")} if={opts.isDisplayed && (!isDef(opts.showContext) || opts.showContext)}
        tag="concordance-context"
        opts={{store: store}}
        open={false}>
    </ui-collapsible>

    <text-types-collapsible></text-types-collapsible>


    <div class="center-align">
        <a id="btnGoFilter" class="waves-effect waves-light btn contrast leftPad" disabled={isSearchDisabled} onclick={onSubmit}>{_("go")}</a>
    </div>

    <floating-button disabled={isSearchDisabled}
        name="btnGoFloat"
        onclick={onSubmit}
        refnodeid="btnGoFilter"
        periodic="1"></floating-button>

    <script>
        require("./concordance-context.tag")
        require("./query-types/concordance-tags-help.tag")
        const {AppStore} = require("core/AppStore.js")

        this.tooltipClass = ".cffTooltip"
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.value = this.opts.riotValue
        this.defaultAttrOptions = this.corpus.attributes
        let hasLemma = !!AppStore.getAttributeByName("lemma")
        this.queryselectorOptions = ["iquery"].concat(hasLemma ? ["lemma"] : []).concat(["phrase", "word", "char", "cql"]).map((option) => {
            return {
                label: _(option),
                value: option
            }
        })

        updateAttributes(){
            if(!this.value.queryselector){
                this.value.queryselector = "iquery"
            }
            this.wposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.wposlist)
            this.lposOptions = [{labelId: "any", value: "any"}].concat(this.corpus.lposlist)
            this.lpos = this.value.lpos == "" ? "any" : this.value.lpos
            this.wpos = this.value.wpos == "" ? "any" : this.value.wpos
        }
        this.updateAttributes()
        this.isSearchDisabled = this.value.queryselector == "cql" ? !this.value.cql : !this.value.keyword

        onSubmit(){
            let what = this.value.queryselector == "cql" ? "cql" : "keyword"
            this.changeOptions({
                [what]: this.refs[what].getValue(),
            })
            this.opts.onSubmit()
        }

        onCqlKeyDown(evt){
            if(evt.keyCode == 13){
                evt.preventDefault()
                if(this.refs.cql.getValue()){
                    this.onSubmit()
                }
            }
        }

        onQmcaseChange(checked){
            this.changeOptions({
                qmcase: checked ? 0 : 1
            })
        }

        onQueryselectorChange(value){
            if(!value){
                value = "iquery"
            }
            this.changeOptions({
                queryselector: value,
                lpos: "",
                wpos: ""
            })
            this.focusInput()
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
                    wposlist: this.corpus.wposlist,
                    tagsetdoc: this.corpus.tagsetdoc,
                    onTagClick: function(tag){
                        this.insertIntoCQL(tag)
                        Dispatcher.trigger("closeDialog")
                        this.update()
                    }.bind(this)
                },
                small: true,
                fixedFooter: true
            })
        }

        insertIntoCQL(insertStr, evt){
            let ta = this.refs.cql.refs.textarea
            let cursorPos = getCaretPosition(ta)
            let textBefore = ta.value.substring(0,  cursorPos)
            let textAfter  = ta.value.substring(cursorPos, ta.value.length)
            this.value.cql = textBefore + insertStr + textAfter
            delay(function(){
                setCaretPosition(ta, cursorPos + 1)
            }.bind(this), 0)
        }

        changeOptions(options){
            Object.assign(this.value, options)
            this.opts.onChange(this.value)
            this.update()
        }

        focusInput(){
            delay(() => {
                $("input[name=\"keyword\"]:visible, textarea[name=\"cql\"]:visible", this.root).first().focus()
            }, 10)
        }

        onResetClick(){
            this.store.setDefaultSearchOptions()
            for(let key in this.value){
                this.value[key] = this.data[key]
            }
            this.update()
            this.refreshDisabled()
        }

        refreshDisabled(evt){
            evt.preventUpdate = true
            if(this.isMounted){
                let wasDisabled = this.isSearchDisabled
                if(this.refs.queryselector.value == "cql"){
                    this.isSearchDisabled = this.refs.cql.getValue() === ""
                } else{
                    this.isSearchDisabled = this.refs.keyword.getValue() === ""
                }
                if(wasDisabled != this.isSearchDisabled){
                    this.update()
                }
            }
        }

        this.on("update", this.updateAttributes)
        this.on("mount", this.focusInput)
    </script>
</concordance-filter-form>
