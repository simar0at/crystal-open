<ui-collapsible class="ui ui-collapsible {opts.class}">
    <ul ref="list" class="collapsible" disabled={opts.disabled} data-collapsible="accordion">
        <li class="{center-align: opts.center} {active: isOpen}">
            <div class="collapsible-header left-align">
                <span class="{tooltipped: opts.tooltip}" data-tooltip={opts.tooltip}>
                    {opts.label}
                    <sup if={opts.tooltip}>?</sup>
                </span>
                <i class="material-icons helpIcon material-clickable" if={opts.tooltipHtml} ref="helpIcon" onclick={onHelpIconClick}>help_outline</i>
                <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
                <i ref="icon" class="material-icons arrow {rotate: isOpen}">keyboard_arrow_down</i>
            </div>
            <div class="collapsible-body left-align">
                <div ref="content"></div>
            </div>
        </li>
    </ul>

    <script>
        this.mixin('ui-mixin')

        this.isOpen = this.opts.isOpen

        open(){
            M.Collapsible.getInstance(this.node).open()
        }

        close(){
            M.Collapsible.getInstance(this.node).close()
        }

        onOpen(){
            this.isOpen = true
            $(this.refs.icon).addClass("rotate")
            if (typeof this.opts.onOpen == "function") {
                this.opts.onOpen()
            }
        }

        onClose(a){
            this.isOpen = false
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
            this.toggleOpen = isDef(this.opts.isOpen) && this.isOpen != this.opts.isOpen
            this.contentTag[0].update()
        })

        this.on("updated", () => {
            if(this.toggleOpen){
                this.toggleOpen = false
                if(this.isOpen){
                    this.close()
                } else {
                    this.open()
                }
            }
        })

        this.on("unmount", () => {
            if(this.contentTag){
                this.contentTag[0].unmount(true)
            }
        })
    </script>
</ui-collapsible>
