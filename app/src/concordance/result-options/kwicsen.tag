<kwicsen class="kwicsen" data-value={sel}>
    <a id="kwicsen_chip"
            ref="link"
            class="chip waves-effect waves-light tooltipped"
            href="javascript:void(0);"
            data-target="kwicsen_list"
            data-tooltip={options[sel].tooltip}
            onclick={onKwicSenClick}>
        {options[sel].label}
        <i class="material-icons">arrow_drop_down</i>
    </a>
    <ul id="kwicsen_list" class="dropdown-content">
        <li onclick={onClick} class="tooltipped" data-tooltip={options[altSel].tooltip}>
            <a pos={altSel}>
                {options[altSel].label}
            </a>
        </li>
    </ul>
    <script>
    this.tooltipExitDelay = 0
    this.mixin("tooltip-mixin")
    require("./kwicsen.scss")
    this.options = {
        "kwic": {
            "label": "KWIC",
            "tooltip": _("cc.kwicTooltip")
        },
        "sen": {
            "label": _("sentence"),
            "tooltip": _("cc.sentenceTooltip")
        }
    }
    this.sel = this.opts.sel || "kwic"
    this.altSel = this.sel == "kwic" && "sen" || "kwic"

    onClick(event) {
        this.sel = event.target.attributes.pos.value
        this.altSel = this.sel == "kwic" && "sen" || "kwic"
        if (isFun(this.opts.onClick))
            this.opts.onClick(this.sel);
    }

    onKwicSenClick(evt){
        evt.preventUpdate = true
        M.Tooltip.getInstance(this.refs.link).close()
    }

    initDropdown(){
        initDropdown('#kwicsen_chip', this.root, {
            constrainWidth: false,
            coverTrigger: false
        })
    }

    this.on("mount", this.initDropdown)
    </script>
</kwicsen>
