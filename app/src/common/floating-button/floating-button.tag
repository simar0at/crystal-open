<floating-button>
    <div class="floatingSearchBtn fixed-action-btn scale-transition scale-out" ref="floatingSearchButton" >
        <a href={opts.href}
                class="btn btn-primary btn-floating btn-large {opts.classes} {disabled: opts.disabled}"
                disabled={opts.disabled}
                onclick={opts.onClick}>
            <i class="large material-icons" if={!label}>{icon}</i>
            {label}
        </a>
    </div>
    <script>
        // Component for floating button.
        // Button is visible, when reference node is not visible and vice versa.
        // params: icon - material icon
        //         onClick - callback
        //         refnodeid - selector to get reference node - on this node is checked, if is visible
        //         periodic - test, if floating button should be displayed is run
        //                  every second. (for cases, when vieport is stretcch via javascript)
        this.icon = this.opts.icon || "send"

        updateAttributes(){
            this.label = isDef(this.opts.label) ? this.opts.label : _("go", {_: ""})
        }
        this.updateAttributes()

        this.onWindowScrollDebounce = debounce(function() {
             const refNode = $("#" + this.opts.refnodeid)
            if(refNode.length && isElementVisible(refNode, true) !== this.node.hasClass("scale-out")){
                this.node.toggleClass("scale-out")
            }
        }.bind(this), 1)

        this.on("update", this.updateAttributes)

        this.on("updated", () => {
            this.onWindowScrollDebounce()
        })

        this.on("mount", () => {
            this.node = $(this.refs.floatingSearchButton)
            window.addEventListener('scroll', this.onWindowScrollDebounce)

            let t = setTimeout(() => {
                this.onWindowScrollDebounce()
                clearTimeout(t)
            })
            if(this.opts.periodic){
                this.interval = setInterval(() => {
                    this.onWindowScrollDebounce()
                }, 1000)
            }
        })

        this.on("unmount", () => {
            window.removeEventListener('scroll', this.onWindowScrollDebounce)
            this.opts.periodic && clearInterval(this.interval)
        })
    </script>
</floating-button>
