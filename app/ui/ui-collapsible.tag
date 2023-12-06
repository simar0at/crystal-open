<ui-collapsible class="ui ui-collapsible">
    <ul ref="list" class="collapsible" disabled={opts.disabled} data-collapsible="accordion">
        <li class="{center-align: opts.center} {active: open}">
            <div class="collapsible-header left-align">
                <span class="{tooltipped: opts.tooltip}" data-tooltip={opts.tooltip}>
                    {opts.label}
                    <sup if={opts.tooltip}>?</sup>
                </span>
                <i class="material-icons helpIcon material-clickable" if={opts.tooltipHtml} ref="helpIcon" onclick={onHelpIconClick}>help_outline</i>
                <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
                <i ref="icon" class="material-icons arrow {rotate: open}">keyboard_arrow_down</i>
            </div>
            <div class="collapsible-body left-align">
                <div ref="content"></div>
            </div>
        </li>
    </ul>

    <script>
        this.mixin('ui-mixin')

        this.open = this.opts.open

        onOpen(){
            this.open = true
            $(this.refs.icon).addClass("rotate")
            if (typeof this.opts.onOpen == "function") {
                this.opts.onOpen()
            }
        }

        onClose(a){
            this.open = false
            $(this.refs.icon).removeClass("rotate")
            if (typeof this.opts.onClose == "function") {
                this.opts.onClose()
            }
        }

        onHelpIconClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            window.showTooltip(this.refs.helpIcon, this.opts.tooltipHtml)
        }

        this.on("mount", () => {
            this.contentTag = riot.mount(this.refs.content, opts.tag, opts.opts || {})
            this.node = $(this.refs.list)
            this.node.collapsible({
                accordion: false, // A setting that changes the collapsible behavior to expandable instead of the default accordion style
                onOpenStart: this.onOpen,
                onCloseStart: this.onClose
            })
        })

        this.on("update", () => {
            this.contentTag[0].update()
        })

        this.on("unmount", () => {
            if(this.contentTag){
                this.contentTag[0].unmount(true)
            }
        })
    </script>
</ui-collapsible>
