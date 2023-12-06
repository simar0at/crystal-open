<kwicsen class="kwicsen">
    <a id="kwicsen_chip" class="chip waves-effect waves-light tooltipped"
            href="javascript:void(0);" data-target="kwicsen_list"
            data-tooltip={options[sel].tooltip}>
        {options[sel].label}
        <i class="material-icons">arrow_drop_down</i>
    </a>
    <ul id="kwicsen_list" class="dropdown-content">
        <li onclick={onClick} class="tooltipped"
                each={o in Object.keys(options)}
                if={o != sel}
                data-tooltip={options[o].tooltip}>
            <a pos={o}>{options[o].label}</a>
        </li>
    </ul>

    <script>
        this.mixin("tooltip-mixin")

        this.options = {
            "kwic": {
                "label": "KWIC",
                "tooltip": _("cc.kwicTooltip")
            },
            "sen": {
                "label": _("sentence"),
                "tooltip": _("cc.sentenceTooltip")
            },
            "align": {
                "label": _("pc.align"),
                "tooltip": _("pc.alignTooltip")
            }
        }

        this.sel = this.opts.sel || "align"

        onClick(event) {
            isFun(this.opts.onClick) &&
                    this.opts.onClick(event.target.attributes.pos.value)
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
