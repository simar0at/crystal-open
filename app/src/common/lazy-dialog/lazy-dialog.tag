<lazy-dialog class="lazy-dialog">
    <i class="material-icons material-clickable" onclick={inIconClick}>{opts.icon || "help_outline"}</i>

    <script>
        require("./lazy-dialog.scss")

        inIconClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            Dispatcher.trigger("openDialog", {
                class: "lazy-dialog-dialog",
                small: this.opts.small,
                big: this.opts.big,
                large: this.opts.large,
                tag: "preloader-spinner",
                opts: {center: 1},
                onOpen: (dialog, modal) => {
                    $(modal).find(".preloader-container").addClass("centerSpinner")
                    window.TextLoader.loadAndInsert(this.opts.file, modal.refs.content)
                }
            })
        }
    </script>
</lazy-dialog>
