<text-types-collapsible>
    <div if={isLoading}>
        <i>{_("loadingTT")}</i>
        <span class='dotsAnimation'><span>...</span></span>
    </div>
    <ui-collapsible if={hasTextTypes}
        label={_("textTypes") + countStr}
        tag="text-types"
        opts={opts.opts}
        tooltip="t_id:conc_text_types"
        open={isDef(opts.open) ? opts.open : count > 0}
        disabled={opts.disabled}
        on-open={onOpen}
        on-close={onClose}>
    </ui-collapsible>

    <script>
        require("./text-types.tag")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        updateAttributes(){
            this.isLoading = TextTypesStore.get("isTextTypesLoading")
            this.hasTextTypes = TextTypesStore.get("hasTextTypes")
            this.count = Object.keys(TextTypesStore.get("selection")).length
            this.countStr = this.count ? ` (${this.count})` : ""
        }
        this.updateAttributes()

        textTypeChanged(){
            if(this.count != Object.keys(TextTypesStore.get("selection")).length){
                this.update()
            }
        }

        onOpen() {
            $(this.root).parents(".form").addClass("wideForm")
        }
        onClose() {
            $(this.root).parents(".form").removeClass("wideForm")
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            TextTypesStore.on("change", this.update)
            TextTypesStore.on("textTypeChange", this.textTypeChanged)
            TextTypesStore.loadTextTypes()
        })

        this.on("unmount", () => {
            TextTypesStore.off("change", this.update)
            TextTypesStore.off("textTypeChange", this.textTypeChanged)
        })
    </script>
</text-types-collapsible>
