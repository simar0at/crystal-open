<add-subcorpus-dialog>
    <h4 class="inline-block">{_("createSubcorpus")}</h4>
    <a if={opts.showManageBtn}
            href="#ca-subcorpora"
            class="btn right"
            onclick={onClick}
            style="margin-right: 60px;">{_("manageMySubcorpora")}</a>
    <div>
        <ui-input
                size="15"
                inline=1
                class="subcname"
                ref="subcname"
                name="subcname"
                validate=1
                required={inputType == 'tts'}
                on-input={refreshCreateSubcorpusButtonDisabled}
                label={_("subcname")}></ui-input>
        <span class="inline-block ml-6">
            <ui-radio riot-value={inputType}
                    on-change={onInputTypeChange}
                    options={inputOptions}></ui-radio>
        </span>
    </div>
    <div class="mt-10 pt-10 dividerTop">
        <div if={inputType == 'concordance'}>
            <div class="center-align">
                <a href="#concordance?tab=advanced&queryselector=cql"
                        class="btn btn-primary">
                    {_("ca.goToConcordance")}
                </a>
            </div>
            <div class="card-panel align-left mt-10" style="max-width: 660px; margin: 0 auto;">
                <external-text text="create_subc_help"></external-text>
            </div>
        </div>
        <text-types if={inputType == 'tts'}
                ref="texttypes"
                disable-structure-mixing=1
                on-change={onTtsChange}
                on-detail-toggle={onTextTypesDetailToggle}></text-types>
        <span id="subcCreateBtnWrapper"
                ref="createBtnWrapper"
                class="fixed-action-btn {hidden: isDetailOpen}"
                style="z-index: 1200;">
            <a ref="createBtn" href="javascript:void(0);"
                    class="btn btn-primary btn-large btn-floating disabled tooltipped"
                    data-tooltip={_("createSubcorpus")}
                    onclick={onCreateClick}>
                <i class="material-icons">save</i>
            </a>
        </span>
    </div>

    <script>
        require("common/text-types/text-types.tag")
        const {AppStore} = require("core/AppStore.js")
        const {TextTypesStore} = require('common/text-types/TextTypesStore.js')

        this.tooltipPosition = "left"
        this.mixin("tooltip-mixin")
        this.isDetailOpen = false
        this.inputOptions = [{
            label: _("subcFromTT"),
            value: 'tts'
        }, {
            label: _("subcFromConc"),
            value: 'concordance'
        }]
        this.inputType = 'tts'

        refreshCreateSubcorpusButtonDisabled(){
            let disabled = this.inputType != 'tts' || this.refs.subcname.getValue() === '' || $.isEmptyObject(this.tts)
            $(this.refs.createBtn).toggleClass("disabled", disabled).toggleClass("pulse", !disabled)
        }

        onTtsChange(tts){
            this.tts = tts
            this.refreshCreateSubcorpusButtonDisabled()
        }

        onInputTypeChange(inputType){
            this.inputType = inputType
            this.update()
            this.refreshCreateSubcorpusButtonDisabled()
        }

        onClick(){
            Dispatcher.trigger("closeDialog")
        }

        onCreateClick(){
            let subcname = this.refs.subcname.getValue()
            let textTypes = TextTypesStore.getQueryFromTextTypes(this.tts)
            if(AppStore.getSubcorpus(subcname)){
                SkE.showToast(_("msg.subcorpAlreadyExists"))
            } else{
                Dispatcher.trigger("closeDialog", "createSubcorpus")
            }
            AppStore.createSubcorpus(subcname, textTypes)
        }

        onTextTypesDetailToggle(isDetailOpen){
            this.isDetailOpen = isDetailOpen
            this.update()
        }

        this.on("mount", () => {
            document.body.appendChild(this.refs.createBtnWrapper)
            delay(() => {$(this.refs.subcname.refs.input).focus()})
            this.refreshCreateSubcorpusButtonDisabled()
        })

        this.on("before-unmount", () => {
            document.getElementById("subcCreateBtnWrapper").remove()
        })
    </script>
</add-subcorpus-dialog>
