<concordance-filter-form class="concordance-filter-form">
    <a onclick={onResetClick}
            data-tooltip={_("resetOptionsTip")}
            class="cffTooltip resetOptions btn btn-floating btn-flat">
        <i class="material-icons color-blue-800">settings_backup_restore</i>
    </a>
    <div class="filterRow dividerBottomDotted">
        <div class="flexContainer">
            <div class="inline-block" style="flex: 3;">
                <div class="filterCol">
                    <ui-list options={queryselectorOptions}
                        ref="queryselector"
                        label-id="cc.queryType"
                        name="querySelector"
                        riot-value={value.queryselector}
                        on-change={onQueryselectorChange}></ui-list>
                </div>
                <div class="inline-block">
                    <div class="filterCol" if={value.queryselector == "lemma" }>
                        <ui-list
                            name="lpos"
                            label={capitalize(_("pos"))}
                            options={lposOptions}
                            riot-value={lpos}
                            on-change={onLposChange}
                        ></ui-list>
                    </div>
                    <div class="filterCol" if={value.queryselector == "word"}>
                        <ui-list
                            name="wpos"
                            label={capitalize(_("pos"))}
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
                            checked={!value.qmcase}
                            on-change={onQmcaseChange}
                            tooltip="t_id:wlicase"
                            label={_("ignoreCase")}></ui-checkbox>
                    </div>
                    <div if={value.queryselector == "cql"}
                            class="filterCqlCol">

                        <cql-textarea riot-value={value.cql}
                                name="cql"
                                ref="cql"
                                on-input={refreshDisabled}
                                on-change={onOptionChange}
                                on-submit={onSubmit}></cql-textarea>
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
        </div>
    </div>

    <!-- so there is no two concordance-context components - in two tabs-->
    <ui-collapsible label={_("cc.filterContext")} if={opts.isDisplayed && (!isDef(opts.showContext) || opts.showContext)}
        tag="concordance-context"
        opts={{store: store}}
        is-open={false}>
    </ui-collapsible>

    <text-types ref="texttypes"
            collapsible=1
            on-change={onTtsChange}></text-types>


    <div class="primaryButtons">
        <a id="btnGoFilter" class="btn btn-primary leftPad" disabled={isSearchDisabled} onclick={onSubmit}>{_("go")}</a>
    </div>

    <floating-button disabled={isSearchDisabled}
        name="btnGoFloat"
        on-click={onSubmit}
        refnodeid="btnGoFilter"
        periodic="1"></floating-button>

    <script>
        require("./concordance-context.tag")
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

        onQmcaseChange(checked){
            this.changeOptions({
                qmcase: !checked
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

        onTtsChange(tts){
            this.changeOptions({
                tts: tts
            })
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
            this.isSearchDisabled = true
            this.update()
            isFun(this.opts.onReset) && this.opts.onReset()
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
