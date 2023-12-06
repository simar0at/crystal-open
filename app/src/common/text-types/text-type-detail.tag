<text-type-detail class="text-type-detail">
    <a class="btnCloseDetail btn btn-large btn-floating btn-flat" onclick={onCloseDetail}>
        <i class="material-icons grey-text text-darken-1">close</i>
    </a>
    <h5>
        {opts.textType.label}
    </h5>
    <div class="row">
        <div class="col s12 m5">
            <text-type-list ref="textTypeList"
                text-type={opts.textType}
                size=10></text-type-list>
        </div>
        <div class="buttons col s12 m2 center">
            <div class="hide-on-small-only" style="min-height: 80px;"></div>
            <div>
                <a id="btnSelectAll" class="btn btn-large btn-floating btn-flat" onclick={onSelectAll}>
                    <i class="hide-on-med-and-up material-icons grey-text text-darken-1">keyboard_arrow_down<br>keyboard_arrow_down</i>
                    <i class="hide-on-small-only material-icons grey-text text-darken-1">keyboard_arrow_right keyboard_arrow_right</i>
                </a>
            </div>
            <div>
                <a id="btnDeselectAll" class="btn btn-large btn-floating btn-flat" onclick={onDeselectAll}>
                    <i class="hide-on-med-and-up material-icons grey-text text-darken-1">keyboard_arrow_up<br>keyboard_arrow_up</i>
                    <i class="hide-on-small-only material-icons grey-text text-darken-1">keyboard_arrow_left keyboard_arrow_left</i>
                </a>
            </div>
        </div>

        <div class="col s12 m5">
            <div class="hide-on-small-only" style="min-height: 65px;"></div>
            <div each={textType, idx in selection}
                    class="chip {tooltipped: textType.length > 17 }"
                    data-tooltip={textType}>
                <i class="close material-icons"
                        onclick={onRemoveTextType}>close</i>
                {textType.startsWith("%RE%") ? (_("valuesMatching", [textType.substr(4)])) : truncate(textType, 17)}
            </div>
            <div if={!selection.length}
                    class="emptyContent">
                <i class="material-icons">space_bar</i>
                <div class="title">
                    {_("nothingHere")}
                </div>
            </div>
        </div>
    </div>
    <div class="center mt-10">
        <a id="btnCloseDetail" class="btn" onclick={onCloseDetail}>
            {_("close")}
        </a>
    </div>
    <script>
        require("./text-type-detail.scss")
        this.textTypesTag = this.parent
        this.textTypeName = this.opts.textType.name

        getListOptions(){
            return this.textTypesTag.getTextTypeOptionsList(this.textTypeName)
        }

        onRemoveTextType(evt){
            evt.stopPropagation()
            this.textTypesTag.removeTextType(this.opts.textType.name, evt.item.textType)
        }

        updateAttributes(){
            this.selection = this.textTypesTag.getSelection(this.textTypeName) || []
            this.selection.sort()
        }
        this.updateAttributes()

        onSelectAll(){
            let all = this.refs.textTypeList.getAllOptions()
            this.textTypesTag.addTextType(this.textTypeName, all)
        }

        onDeselectAll(){
            let selected = this.textTypesTag.selection[this.opts.textType.name]
            this.textTypesTag.removeTextType(this.textTypeName, selected)
        }

        onTextTypeChange(textType){
            textType.name == this.textTypeName && this.update()
        }

        onCloseDetail(){
            this.textTypesTag.toggleDetail(null)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.textTypesTag.on("textTypeChange", this.onTextTypeChange)
            $("body")[0].scrollTop = $(this.root).offset().top;
        })

        this.on("unmount", () => {
            this.textTypesTag.off("textTypeChange", this.onTextTypeChange)
        })

    </script>
</text-type-detail>
