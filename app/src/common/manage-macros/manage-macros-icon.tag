<manage-macros-icon class="manage-macros-icon">
    <i class="material-icons material-clickable tooltipped"
            data-tooltip={_("manageMacros")}
            onclick={onClick}>
        flash_on
    </i>

    <script>
        require("./manage-macros-dialog.tag")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        require("./manage-macros.scss")

        onClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                title: _("macros"),
                tag: "manage-macros-dialog",
                opts:{
                    store: this.store
                },
                onClose: this.callChange
            })
        }

        callChange(){
            isFun(this.opts.onChange) && this.opts.onChange()
        }
    </script>
</manage-macros-icon>
