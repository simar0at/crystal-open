<subcorpus-select class="subcorpus-select">
    <div>
        <ui-select options={subcorpora}
            ref="subcorpus"
            label-id={opts.labelId || "subcorpus"}
            riot-value={opts.riotValue}
            disabled={opts.disabled}
            on-change={onChange}
            help-dialog={opts.helpDialog}
            tooltip={opts.tooltip}
            name={opts.name}
            inline=1></ui-select>
        <i if={isFullAccount}
                ref="lock"
                onclick={onLockToggleClick}
                class="material-icons material-clickable scsTooltip {disabled: opts.disabled || opts.riotValue === ''} {locked: locked}"
                data-tooltip={_("keepSubcorpusTip")}>
            {locked ? "lock" : "lock_open"}
        </i>
        <i if={hasTextTypes && !isAnonymous}
                class="material-icons material-clickable scsTooltip {disabled: opts.disabled}"
                onclick={onAddClick}
                data-tooltip={_("createSubcorpusTip")}>
            add
        </i>
    </div>

    <script>
        const {Auth} = require("core/Auth.js")
        const {AppStore} = require("core/AppStore.js")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        const {UserDataStore} = require('core/UserDataStore.js')
        const Dialogs = require("dialogs/dialogs.js")

        require("./subcorpus-select.scss")

        this.isFullAccount = Auth.isFullAccount()
        this.isAnonymous = Auth.isAnonymous()
        this.tooltipClass = ".scsTooltip"
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.hasTextTypes = TextTypesStore.data.hasTextTypes
            this.subcorpora = AppStore.get("subcorpora")
            this.corpname = this.opts.corpus || AppStore.getActualCorpname()
            let defaultSubcorpus = UserDataStore.getCorpusData(this.corpname, "defaultSubcorpus")
            this.locked = defaultSubcorpus && defaultSubcorpus == this.opts.riotValue
        }
        this.updateAttributes()

        onChange(value, name, label, evt){
            if(this.isFullAccount){
                this.refs.lock.classList.toggle("disabled", value === "")
                this.setLocked(false)
            }
            this.opts.onChange(value, this.opts.name, evt, this)
        }

        onLockToggleClick(){
            if(!this.opts.disabled && this.opts.riotValue !== ''){
                this.setLocked(!this.locked)
            }
        }

        onAddClick(){
            !this.opts.disabled && Dialogs.showCreateSubcorpus(true)
        }

        setLocked(locked){
            this.locked = locked
            this.refs.lock.innerHTML = this.locked ? "lock" : "lock_open"
            UserDataStore.saveCorpusData(this.corpname, "defaultSubcorpus", locked ? this.refs.subcorpus.getValue() : "")
        }
        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            TextTypesStore.loadTextTypes()
            AppStore.on("subcorporaChanged", this.update)
            TextTypesStore.on("listChanged", this.update)
        })

        this.on("unmount", () => {
            AppStore.off("subcorporaChanged", this.update)
            TextTypesStore.off("listChanged", this.update)
        })
    </script>
</subcorpus-select>
