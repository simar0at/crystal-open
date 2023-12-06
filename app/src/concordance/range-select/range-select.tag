<range-select class="range-select">
    <ui-range
        label={isDef(opts.label) ? opts.lable : _("range")}
        riot-value={opts.riotValue}
        range={rangeOptions}
        on-change={opts.onChange}
        tooltip={opts.tooltip}></ui-range>

    <script>
        require("./range-select.scss")

        let list = [-5, -4, -3, -2, -1]
                .concat(this.opts.kwicActive ? ["kwic"] : [])
                .concat([1, 2, 3, 4, 5])
        this.rangeOptions = list.map(o => {
            return {
                label: o,
                value: o
            }
        })

        this.on("mount", () => {
            !this.opts.kwicActive && $(".ui-range .btn-selector:nth-child(5)", this.root).after('<span class="kwicIcon">KWIC</span>')
        })
    </script>
</range-select>
