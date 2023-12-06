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
            <ui-list ref="selectedList"
                size=10
                name={opts.textType.name}
                options={options}
                on-change={onRemoveTextType}></ui-list>
        </div>
    </div>
    <div class="center">
        <a id="btnCloseDetail" class="btn" onclick={onCloseDetail}>
            {_("close")}
        </a>
    </div>
    <script>
        require("./text-type-detail.scss")
        const {TextTypesStore} = require("./TextTypesStore.js")
        this.textTypeName = opts.textType.name

        getListOptions(){
            return TextTypesStore.getTextTypeOptionsList(this.textTypeName)
        }

        onRemoveTextType(value, textTypeName){
            TextTypesStore.removeTextType(textTypeName, value)
        }

        updateAttributes(){
            let selection = TextTypesStore.getSelection(this.textTypeName) || []
            this.options = []
            selection.forEach((textType) => {
                this.options.push({
                    label: textType,
                    value: textType
                })
            })
        }
        this.updateAttributes()

        onSelectAll(){
            let all = this.refs.textTypeList.getAllOptions()
            TextTypesStore.addTextType(this.textTypeName, all)
        }

        onDeselectAll(){
            let selected = TextTypesStore.data.selection[this.opts.textType.name]
            TextTypesStore.removeTextType(this.textTypeName, selected)
        }

        onTextTypeChange(textType){
            textType.name == this.textTypeName && this.update()
        }

        onCloseDetail(){
            TextTypesStore.toggleDetail(null)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            TextTypesStore.on("textTypeChange", this.onTextTypeChange)
            $("body")[0].scrollTop = $(this.root).offset().top;
        })

        this.on("unmount", () => {
            TextTypesStore.off("textTypeChange", this.onTextTypeChange)
        })

    </script>
</text-type-detail>
