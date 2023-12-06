<text-types class="text-types">
    <div if={opts.note} class="note">
        {opts.note}
    </div>
    <div if={isLoaded}>
        <div if={!detailView}>
            <div class="row toggleExpand hide-on-small-only {disabled: opts.disabled}" if={textTypes.length > 1}>
                <div class="col right">
                    <a onclick={toggleExpandAll.bind(this, true)}>{_("cc.expandAll")}</a>
                    <a onclick={toggleExpandAll.bind(this, false)}>{_("cc.collapseAll")}</a>
                </div>
            </div>
            <div class="row">
                <text-type each={textType in textTypes} text-type={textType} ></text-type>
                <div if={!textTypes.length} class="col s12 grey-text">
                    {_("cc.noTextTypes")}
                </div>
            </div>
        </div>

        <div if={detailView} class="shadowOverlay">
            <div ref="dialog" class="card-panel grey lighten-3 fullScreen">
                <text-type-detail text-type={detailView}></text-type-detail>
            </div>
        </div>
    </div>

    <div if={isLoading} class="center-align">
        <preloader-spinner></preloader-spinner>
    </div>

    <script>
        require("./text-type.tag")
        require("./text-type-selection.tag")
        require("./text-type-list.tag")
        require("./text-type-detail.tag")
        require("./text-types.scss")
        const {TextTypesStore} = require("./TextTypesStore.js")

        updateAttributes(){
            this.detailView = TextTypesStore.get("detail")
            this.isLoaded = TextTypesStore.get("isTextTypesLoaded")
            this.isLoading = TextTypesStore.get("isTextTypesLoading")
            this.textTypes = TextTypesStore.get("textTypes")
        }
        this.updateAttributes()

        onTextTypesLoaded(textTypes){
            if(textTypes.length){
                textTypes.forEach((tt) => {
                    if(isDef(tt.dynamic) && !tt.Values){
                        TextTypesStore.loadTextType(tt.name)
                    }
                })
            }
            this.update()
        }

        toggleExpandAll(expanded){
            !TextTypesStore.data.disabled && TextTypesStore.toggleExpandAll(expanded)
        }

        refreshListsHeight(){
            if(this.refs.dialog){
                let dialog = $(this.refs.dialog)
                let lists = $("ul", this.root)
                let dialogOffset = dialog.offset().top
                let dialogHeight = dialog.height()
                if($(window).width() < 600){
                    let space = dialogOffset + dialogHeight - lists.first().offset().top - 100 //buttons
                    lists.each((idx, elm) => {
                        $(elm).css("max-height", space / 2)
                    })
                } else{
                    lists.each((idx, elm) => {
                        let listOffset = $(elm).offset().top
                        let maxHeight = dialogOffset + dialogHeight - listOffset - 50 // buttons
                        $(elm).css("max-height", maxHeight)
                    })
                }
            }
        }

        this.on("update", () => {
            this.updateAttributes()
        })

        this.on("updated", this.refreshListsHeight)

        this.on("mount", () => {
            TextTypesStore.on("change", this.update)
            TextTypesStore.on("textTypesLoaded", this.onTextTypesLoaded)
            TextTypesStore.loadTextTypes()
        })

        this.on("unmount", () => {
            TextTypesStore.off("change", this.update)
            TextTypesStore.off("textTypesLoaded", this.onTextTypesLoaded)
        })
    </script>
</text-types>
