<macro-select class="macro-select">
    <ui-filtering-list label-id="macro"
            options={options}
            riot-value={macro ? macro.id : ""}
            size=30
            inline=1
            floating-dropdown=1
            clear-on-focus=1
            value-in-search=1
            open-on-focus=1
            tooltip="t_id:macros_help"
            on-change={onMacroChange}></ui-filtering-list>
    <i if={isFullAccount}
            ref="lock"
            onclick={onLockToggleClick}
            class="material-icons material-clickable tooltipped {disabled: opts.disabled || !macro} {locked: locked}"
            data-tooltip={_("keepMacroTip")}>
        {locked ? "lock" : "lock_open"}
    </i>
    <manage-macros-icon on-change={update}></manage-macros-icon>

    <script>
        require("./manage-macros.scss")
        require("./manage-macros-icon.tag")

        const {MacroStore} = require("./macrostore.js")
        const {Auth} = require("core/Auth.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")
        this.isFullAccount = Auth.isFullAccount()
        this.macroStore = MacroStore

        getMacro(macroId){
            return this.macros.find(m => m.id == macroId)
        }

        updateAttributes(){
            this.macro = this.macroStore.data.macro
            this.macros = this.macroStore.data.macros
            this.locked = this.macroStore.data.locked
            this.options = this.macros.map(macro => {
                return {
                    value: macro.id,
                    label: macro.name
                }
            })
            this.options.unshift({
                value: "",
                label: _("none")
            })
        }
        this.updateAttributes()

        onLockToggleClick(){
            if(!this.opts.disabled && this.macro){
                this.macroStore.setLocked(!this.locked)
            }
        }

        onMacroChange(macroId){
            this.macroStore.changeMacro(macroId)
        }

        onLockedChange(locked){
            this.locked = locked
            this.refs.lock.innerHTML = this.locked ? "lock" : "lock_open"
        }

        this.on("update", this.updateAttributes)


        this.on("mount", () => {
            this.macroStore.on("macroChange", this.update)
            this.macroStore.on("listChange", this.update)
            this.macroStore.on("lockedChange", this.onLockedChange)
        })

        this.on("before-unmount", () => {
            this.macroStore.off("macroChange", this.update)
            this.macroStore.off("listChange", this.update)
            this.macroStore.off("lockedChange", this.onLockedChange)
        })
    </script>
</macro-select>
