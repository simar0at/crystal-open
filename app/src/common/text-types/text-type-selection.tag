<text-type-selection class="text-type-selection">
    <div if={selection.length}>
        <div class="chip {tooltipped: textType.length > 17 }" each={textType, idx in selection} if={idx <= 3} data-tooltip={textType}>
            <i class="close material-icons" onclick={onTextTypeClick}>close</i>
            {textType.startsWith("%RE%") ? ("RegEx: " + textType.substr(4)) : truncate(textType, 17)}
        </div>
        <div class="chip btnMore btn-floating" if={selection.length > 4} onclick={onMoreClick}>
            + {selection.length - 4} {_("more")}
        </div>
        <a if={selection.length}
                href="javascript:void(0);"
                class="btn btn-flat btn-floating tooltipped btnRemoveAll"
                onclick={onRemoveClick}
                data-tooltip={_("removeAllTextTypes")}>
            <i class="material-icons">delete_sweep</i>
        </a>
    </div>

    <script>
        this.mixin("tooltip-mixin")
        require("./text-type-selection.scss")
        const {TextTypesStore} = require("./TextTypesStore.js")

        this.textTypeName = opts.textType.name

        onTextTypeClick(evt){
            TextTypesStore.removeTextType(this.textTypeName, evt.item.textType)
            // we remove chip manualy -> prevent material to remove it.
            // Otherwise it colides with riot engine
            evt.stopPropagation()
        }

        onRemoveClick(){
            TextTypesStore.removeTextType(this.textTypeName, this.selection)
        }

        updateAttributes(){
            this.selection = TextTypesStore.getSelection(this.textTypeName) || []
        }
        this.updateAttributes()

        onMoreClick(){
            TextTypesStore.toggleDetail(this.opts.textType)
        }

        refreshCompressed(){
            /*setTimeout(function(){
                $(".scale-transition", this.root).addClass("scale-in")
            }, 100)*/
            let node  = $(this.root)
            let isCompressed = node.hasClass("compressed")
            if(node.height() > 75  && !isCompressed){
                node.addClass("compressed")
            } else if(node.height() <= 55 && isCompressed){
                node.removeClass("compressed")
            }
        }

        this.on("update", () => {
            this.updateAttributes()
        })

        this.on("updated", this.refreshCompressed)

        onTextTypeChange(textType){
            textType.name == this.textTypeName && this.update()
        }

        this.on("mount", () => {
            TextTypesStore.on("textTypeChange", this.onTextTypeChange)
            this.refreshCompressed()
        })

        this.on("unmount", () => {
            TextTypesStore.off("textTypeChange", this.onTextTypeChange)
        })

    </script>
</text-type-selection>
