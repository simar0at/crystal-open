<concordance-tab-advanced>
    <div class="concordance-tab-advanced card-content">
        <a onclick={onResetClick}
                data-tooltip={_("resetOptionsTip")}
                class="cffTooltip resetOptions btn btn-floating btn-flat">
            <i class="material-icons color-blue-800">settings_backup_restore</i>
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
        <macro-select if={isFullAccount}
                riot-value={options.macro}></macro-select>

        <ui-collapsible label={_("cc.filterContext")}
                ref="filterContextCollapsible"
                tag="concordance-context"
                opts={{store: store}}
                is-open={data.showcontext != "none"}
                help-dialog="conc_a_context"
                is-displayed={data.tab=="advanced"}>
        </ui-collapsible>

        <text-types ref="texttypes"
                collapsible=1
                selection={options.tts}
                on-change={onTtsChange}></text-types>

        <div class="primaryButtons">
            <a id="btnGoAdv" class="btn btn-primary leftPad" disabled={isSearchDisabled} onclick={onSubmit}>{_("go")}</a>
        </div>

        <floating-button disabled={isSearchDisabled}
            name="btnAdvGoFloat"
            on-click={onSubmit}
            refnodeid="btnGoAdv"
            periodic="1"></floating-button>
    </div>

    <script>
        const {Auth} = require("core/Auth.js")
        const {MacroStore} = require("common/manage-macros/macrostore.js")
        const {UserDataStore} = require("core/UserDataStore.js")

        require("./concordance-context.tag")
        require("./concordance-tab-advanced.scss")
        require("./query-types/query-types.tag")

        this.mixin("feature-child")
        this.isSearchDisabled = true
        this.macroStore = MacroStore

        updateAttributes(){
            this.isFullAccount = Auth.isFullAccount()
            this.options = {
                queryselector: this.data.queryselector,
                keyword: this.data.keyword,
                lpos: this.data.lpos,
                wpos: this.data.wpos,
                default_attr: this.data.default_attr || this.store.getCQLDefaultAttr(),
                qmcase: this.data.qmcase,
                cql: this.data.cql,
                cb: this.data.cb,
                tts: this.data.tts,
                macro: this.data.macro
            }
            this.options.usesubcorp = UserDataStore.getCorpusData(this.corpus.corpname, "defaultSubcorpus") || this.data.usesubcorp
        }
        this.updateAttributes()

        onQueryTypesChange(data){
            Object.assign(this.options, data)
        }

        onUsesubcorpChange(usesubcorp){
            this.options.usesubcorp = usesubcorp
            this.update()
        }

        onTtsChange(tts){
            this.options.tts = tts
        }

        onSubmit(){
            this.data.closeFeatureToolbar = true
            let macro = this.macroStore.data.macro
            if(macro){
                this.store.setMacroOptionsAndReload(macro, this.options)
            } else {
                Object.assign(this.options, this.store.getContext())
                this.store.initResetAndSearch(this.options)
            }
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
            this.refs.filterContextCollapsible.contentTag[0].update()
            this.update()
            this.refs.queryTypes.reset()
            this.refs.texttypes.reset()
            this.macroStore.changeMacro("")
            this.setDisabled(true)
        }

        dataChanged(){
            !objectEquals(this.options.tts, this.store.data.tts) && this.refs.texttypes.setSelection(this.store.data.tts)
            this.updateAttributes()
            this.update()
        }

        macroChanged(macro){
            if(macro){
                this.options.macro = macro.id
                this.options.tts = macro.options.tts
                this.refs.texttypes.setSelection(macro.options.tts)
            } else {
                this.store.resetGivenOptions(this.options)
                this.store.resetContext()
                this.refs.filterContextCollapsible.contentTag[0].update()
                this.refs.queryTypes.reset()
                this.refs.texttypes.reset()
                this.setDisabled(true)
            }
            this.update()
            this.refs.texttypes.toggleOpen(!$.isEmptyObject(this.data.tts))
            this.refs.queryTypes.refreshIsValid()
        }

        this.on("mount", () => {
            this.store.on("change", this.dataChanged)
            this.macroStore.on("macroChange", this.macroChanged)
        })

        this.on("before-unmount", () => {
            this.store.off("change", this.dataChanged)
            this.macroStore.off("macroChange", this.macroChanged)
        })
    </script>
</concordance-tab-advanced>
