<add-subcorpus-dialog>
    <h4 class="inlineBlock">{_("createSubcorpus")}</h4>
    <a if={opts.showManageBtn}
            href="#ca-subcorpora"
            class="btn right"
            onclick={onClick}
            style="margin-right: 60px;">{_("manageMySubcorpora")}</a>
    <div>
        <ui-input
            size="15"
            class="subcname"
            ref="subcname"
            validate=1
            required=1
            on-input={refreshCreateSubcorpusButtonDisabled}
            label={_("subcname")}></ui-input>
        <br>
        <text-types ref="texttypes"></text-types>

        <span id="subcCreateBtnWrapper" ref="createBtnWrapper" class="fixed-action-btn {hidden: isDetailOpen}" style="z-index: 1200;">
            <a ref="createBtn" href="javascript:void(0);"
                    class="btn btn-large btn-floating contrast disabled tooltipped"
                    data-tooltip={_("createSubcorpus")}
                    onclick={onCreateClick}>
                <i class="material-icons">save</i>
            </a>
        </span>
    </div>

    <script>
        require("common/text-types/text-types.tag")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        const {AppStore} = require("core/AppStore.js")

        this.tooltipPosition = "left"
        this.mixin("tooltip-mixin")
        this.isDetailOpen = false

        refreshCreateSubcorpusButtonDisabled(){
            let disabled = this.refs.subcname.getValue() === "" || $.isEmptyObject(TextTypesStore.get("selection"))
            $(this.refs.createBtn).toggleClass("disabled", disabled).toggleClass("pulse", !disabled)
        }

        onSelectionChange(){
            this.refreshCreateSubcorpusButtonDisabled()
            let wasDisabled = false
            let selected = null
            for(selected in TextTypesStore.get("selection")){
                break
            }
            TextTypesStore.data.textTypes.forEach(textType => {
                wasDisabled = wasDisabled || textType.disabled
                textType.disabled = selected && (textType.name.split(".")[0] != selected.split(".")[0])
            })
            !wasDisabled != !selected && this.refs.texttypes.update()
        }

        onClick(){
            Dispatcher.trigger("closeDialog")
        }

        onCreateClick(){
            let subcname = this.refs.subcname.getValue()
            let textTypes = TextTypesStore.getSelectionQuery()
            if(AppStore.getSubcorpus(subcname)){
                SkE.showToast(_("msg.subcorpAlreadyExists"))
            } else{
                Dispatcher.trigger("closeDialog", "createSubcorpus")
                AppStore.createSubcorpus(subcname, {
                    textTypes: textTypes
                })
                TextTypesStore.reset()
            }
        }

        onTextTypeChange(){
            let isDetailOpen = TextTypesStore.data.detail
            if(isDetailOpen != this.isDetailOpen){
                this.isDetailOpen = isDetailOpen
                this.update()
            }
        }

        this.on("mount", () => {
            document.body.appendChild(this.refs.createBtnWrapper)
            TextTypesStore.on("selectionChange", this.onSelectionChange)
            TextTypesStore.on("change", this.onTextTypeChange)
            delay(() => {$(this.refs.subcname.refs.input).focus()})
            this.refreshCreateSubcorpusButtonDisabled()
        })

        this.on("unmount", () => {
            TextTypesStore.off("selectionChange", this.onSelectionChange)
            TextTypesStore.off("change", this.onTextTypeChange)
            document.getElementById("subcCreateBtnWrapper").remove()
        })
    </script>
</add-subcorpus-dialog>
