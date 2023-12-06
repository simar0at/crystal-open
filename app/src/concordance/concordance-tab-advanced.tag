<concordance-tab-advanced>
    <div class="concordance-tab-advanced card-content">
        <a onclick={onResetClick}
                data-tooltip={_("resetOptionsTip")}
                class="cffTooltip resetOptions btn btn-floating btn-flat">
            <i class="material-icons dark">settings_backup_restore</i>
        </a>
        <div class="dividerBottomDotted" style="display: flex; flex-wrap: wrap;">
            <query-types ref="queryTypes"
                riot-value={options}
                on-change={onQueryTypesChange}
                on-valid-change={onQueryTypesValidChange}
                on-submit={onSubmit}
                btn-label={_("search")}></query-types>
        </div>

        <br>
        <subcorpus-select
                name="usesubcorp"
                riot-value={options.usesubcorp}
                help-dialog="conc_subcorpus"
                on-change={onUsesubcorpChange}></subcorpus-select>

        <ui-collapsible label={_("cc.filterContext")}
                ref="filterContextCollapsible"
                tag="concordance-context"
                opts={{store: store}}
                open={data.showcontext != "none"}
                help-dialog="conc_a_context"
                is-displayed={data.tab=="advanced"}>
        </ui-collapsible>

        <text-types-collapsible></text-types-collapsible>


        <div class="center-align">
            <a id="btnGoAdv" class="waves-effect waves-light btn contrast leftPad" disabled={isSearchDisabled} onclick={onSubmit}>{_("go")}</a>
        </div>

        <floating-button disabled={isSearchDisabled}
            name="btnGoFloat"
            onclick={onSubmit}
            refnodeid="btnGoAdv"
            periodic="1"></floating-button>
    </div>

    <script>
        require("./concordance-context.tag")
        require("./concordance-tab-advanced.scss")
        require("./query-types/query-types.tag")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        this.mixin("feature-child")

        updateAttributes(){
            this.options = {
                queryselector: this.data.queryselector,
                keyword: this.data.keyword,
                lpos: this.data.lpos,
                wpos: this.data.wpos,
                default_attr: this.data.default_attr || this.store.getCQLDefaultAttr(),
                qmcase: this.data.qmcase,
                cql: this.data.cql,
                cb: this.data.cb,
                usesubcorp: this.data.usesubcorp
            }
        }
        this.updateAttributes()

        onQueryTypesChange(data){
            Object.assign(this.options, data)
        }

        onUsesubcorpChange(usesubcorp){
            this.options.usesubcorp = usesubcorp
        }

        onSubmit(){
            Object.assign(this.options, this.store.getContext())
            this.store.initResetAndSearch(this.options)
        }

        onQueryTypesValidChange(isValid){
            this.isSearchDisabled == isValid && this.setDisabled(!isValid)
        }

        setDisabled(disabled){
            this.isSearchDisabled = disabled
            this.update()
        }

        onResetClick(){
            this.store.setDefaultSearchOptions()
            this.store.resetGivenOptions(this.options)
            TextTypesStore.reset()
            this.refs.filterContextCollapsible.contentTag[0].update()
            this.update()
            this.refs.queryTypes.reset()
            this.setDisabled(true)
        }

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

        this.on("mount", () => {
            this.store.on("change", this.dataChanged)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</concordance-tab-advanced>
