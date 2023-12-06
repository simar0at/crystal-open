<subcorpus-select>
    <div>
        <ui-select options={subcorpora}
            label-id="subcorpus"
            riot-value={opts.riotValue}
            disabled={opts.disabled}
            on-change={opts.onChange}
            help-dialog={opts.helpDialog}
            tooltip={opts.tooltip}
            name={opts.name}
            inline=1
            style="width:calc(100% - 45px);"></ui-select>
        <a class="btn btn-flat btn-floating scsTooltip {disabled: opts.disabled}"
                if={hasTextTypes}
                onclick={onAddClick}
                data-tooltip={_("createSubcorpusTip")}>
            <i class="material-icons">add</i>
        </a>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        const Dialogs = require("dialogs/dialogs.js")

        this.tooltipClass = ".scsTooltip"
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.hasTextTypes = TextTypesStore.get("hasTextTypes")
            this.subcorpora = AppStore.get("subcorpora")
        }
        this.updateAttributes()

        onAddClick(){
            Dialogs.showCreateSubcorpus(true)
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            TextTypesStore.loadTextTypes()
            AppStore.on("subcorporaChanged", this.update)
            TextTypesStore.on("change", this.update)
        })

        this.on("unmount", () => {
            AppStore.off("subcorporaChanged", this.update)
            TextTypesStore.off("change", this.update)
        })
    </script>
</subcorpus-select>
