<alt-lposlist>
    <a class="chip al-dropdown" href="javascript:void(0);" data-target="alt_lposes">
        <span if={opts.lemma}>
            <span class="red-text">{opts.lemma}</span>
            {_("as")}&nbsp;
        </span>
        {getLpos(opts.lpos)} {format(opts.freq)}&times;
        <i if={opts.alt_lposes.length != 0} class="material-icons">arrow_drop_down</i>
    </a>
    <ul id="alt_lposes" class="dropdown-content">
        <li each={a in opts.alt_lposes} onclick={onClick}>
            <a>
                {getLpos(a.pos)} {a.frq != -1 ? (format(a.frq) + "&times;") : ""}
            </a>
        </li>
    </ul>
    <script>
    require("./alt-lposlist.scss")

    getLpos(lpos){
        let str = this.opts.wspos_dict && this.opts.wspos_dict[lpos] || lpos
        return _(str, {"_": str})
    }

    onClick(event) {
        if (isFun(this.opts.onClick)){
            this.opts.onClick(event.item.a.pos);
        }
    }

    format(x) {
        return window.Formatter.num(x)
    }

    initDropdown(){
        initDropdown('.al-dropdown', this.root, {
            constrainWidth: false,
            coverTrigger: false,
            alignment: "right"
        })
    }

    this.on("updated",  this.initDropdown)

    this.on("mount", this.initDropdown)
    </script>
</alt-lposlist>
