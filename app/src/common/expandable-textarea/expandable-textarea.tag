<expandable-textarea class="expandable-textarea {opts.class}">
    <span class="inline-block relative">
        <ui-textarea ref="textarea"
                name={opts.name}
                opts={opts}
                copy-opts=1></ui-textarea>
        <i if={!opts.disabled}
                class="material-icons material-clickable expandIcon"
                onclick={onExpandClick}>open_with</i>
    </span>

    <script>
        require("./expandable-textarea.scss")

        onExpandClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                title: this.opts.dialogTitle || getLabel(this.opts),
                tag: "ui-textarea",
                tall: true,
                opts: {
                    riotValue: this.refs.textarea.getValue()
                },
                fixedFooter: true,
                dismissible: false,
                onOpen: (dialog, modal) => {
                    let textarea = $(".materialize-textarea", dialog.contentNode)
                    let height = textarea.closest(".modal-content").height() - textarea.closest(".modal-content").find("h4").height() - 60 // paddings
                    textarea.height(height).focus()
                },
                buttons: [{
                    label: _("save"),
                    class: "btn-primary",
                    onClick: (dialog, modal) => {
                        let value = dialog.contentTag.getValue()
                        this.refs.textarea.update({
                            opts: {
                                riotValue: value
                            }
                        })
                        isFun(this.opts.onInput) && this.opts.onInput(value, this.opts.name, evt, this)
                        isFun(this.opts.onChange) && this.opts.onChange(value, this.opts.name, evt, this)
                        modal.close()
                    }
                }]
            })
        }
    </script>
</expandable-textarea>
