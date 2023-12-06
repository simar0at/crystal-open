<subcorpus-chip class="subcorpus-chip {hidden: !subcorpus}">
    <span if={subcorpus}
            ref="dropdownTrigger"
            class="link chip tooltipped"
            data-target="subcorpChipList"
            data-tooltip={_("subcorpus") + "<br>" + subcorpus.label}>
            <span class="truncate">
                {subcorpus.label}
            </span>
        <i class="dd_arrow material-icons">arrow_drop_down</i>
        <i class="close material-icons" onclick={onCloseClick}>close</i>

        <ul id="subcorpChipList" class="dropdown-content">
            <li each={subcorp in subcorpora} onclick={onSubcorpChange} class={selected: subcorp.value == usesubcorp} data-value={subcorp.value}>
                <a>{subcorp.label}</a>
            </li>
        </ul>
    </span>

    <script>
        const {AppStore} = require("core/AppStore.js")
        require("./subcorpus-chip.scss")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.subcorpora = AppStore.get("subcorpora")

        updateAttributes(){
            this.usesubcorp = this.store.data.usesubcorp
            this.subcorpus = this.usesubcorp ? AppStore.getSubcorpus(this.usesubcorp) : null
        }
        this.updateAttributes()

        onSubcorpChange(evt){
            evt.preventUpdate = true
            this._changeSubcorpus(evt.item.subcorp.value)
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            this._changeSubcorpus("")
        }

        initDropdown(){
            this.subcorpus && $(this.refs.dropdownTrigger).dropdown({
                coverTrigger: false,
                constrainWidth: false
            })
        }

        _changeSubcorpus(subcorpus){
            this.opts.onChange ? this.opts.onChange(subcorpus)
                : this.store.searchAndAddToHistory({
                    usesubcorp: subcorpus
                })
        }

        this.on("update", this.updateAttributes)
        this.on("updated", this.initDropdown)
        this.on("mount", this.initDropdown)
    </script>
</subcorpus-chip>
