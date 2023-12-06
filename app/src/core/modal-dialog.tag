<modal-dialog class="modal-dialogs">
    <div each={dialog, idx in dialogs}
            ref="dlg_{idx}"
            id={dialog.id}
            class="modal-dialog {dialog.class} {small:dialog.small} {big:dialog.big} {large:dialog.large} {tall:dialog.tall} {fullScreen: dialog.fullScreen}">
        <span if={dialog.fullScreen && isDef(dialog.dismissible) ? dialog.dismissible : true} class="fullScreenClose">
            <i class="material-icons material-clickable" onclick={onCloseClick}>close</i>
        </span>
            <div id="dialog_{idx}"
                    ref="modal"
                    class="modal {modal-fixed-footer: dialog.fixedFooter} {bottom-sheet: dialog.bottom} {dialog.type} {autowidth: dialog.autowidth} {onTop: dialog.onTop}">
            <div class="{modal-center: dialog.autowidth}">
                <div class="modal-content">
                    <h4 if={dialog.title}
                        class={"red-text text-lighten-1": dialog.type=="error", "orange-text text-lighten-1": dialog.type=="warning"}>
                        <i if={dialog.icon} class="header-icon material-icons left">{dialog.icon}</i>
                        {dialog.title}
                    </h4>
                    <div ref="content" class="clearfix dialogContent"></div>
                </div>

                <div class="modal-footer" if={!dialog.fullScreen && (dialog.showCloseButton || dialog.buttons.length)}>
                    <a if={dialog.showCloseButton} class="btn modal-action modal-close waves-effect btn-flat">{_("close")}</a>
                    <a each={button in dialog.buttons || []}
                        id={button.id}
                        href={button.href}
                        class="btn modal-action waves-effect btn-flat {button.class}"
                        onclick={onButtonClick.bind(this, dialog)}>{button.label}</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./modal-dialog.scss")
        this.dialogs = []

        /*
            options = {
                id: string - optional, used for closing dialog
                title: string - optional
                type: string -warning|error|info - optional
                tag: string - name of tag to use for dialog content, optional
                opts: Object - opts for content tag - optional
                content: string - alternative to tag for simple content
                showCloseButton: Bool -
                buttons: array [{label: string, class: string, href: string, onClick: function},...]
                autowidth: center with fit-to-content width,

            }
         */
        open(dialog){
            if(this.dialogs.find((d) => {return (d.content && d.content == dialog.content) || (d.id && d.id == dialog.id)})){
                return // already displayed
            }
            if(this.isMounted){
                if(["error", "warning", "info"].includes(dialog.type)){
                    dialog.icon = dialog.type + "_outline"
                }
                dialog.showCloseButton = isDef(dialog.showCloseButton) ? dialog.showCloseButton : true
                this.dialogs.push(dialog)

                this.update()

                dialog.node = $("#" + "dialog_" + (this.dialogs.length - 1))
                dialog.contentNode = dialog.node.find(".dialogContent")
                if(dialog.tag){
                    dialog.contentTag = riot.mount(dialog.contentNode, dialog.tag, dialog.opts || {})[0]
                    dialog.contentTag.modalParent = this
                } else if(dialog.content){
                    dialog.contentNode.html(dialog.content)
                }
                dialog.htmlScroll = $("html").scrollTop()
                dialog.htmlScroll && $("html").scrollTop(0) // fix of misplaced dialog, if html element is scrolled
                dialog.node.modal({
                    onCloseStart: this.onCloseStart.bind(this, dialog),
                    onCloseEnd: this.onCloseEnd.bind(this, dialog),
                    onOpenEnd: this.onDialogOpen.bind(this, dialog),
                    dismissible: isDef(dialog.dismissible) ? dialog.dismissible : true,
                    inDuration: dialog.fullScreen ? 500 : 250,
                    outDuration: dialog.fullScreen ? 500 : 250
                }).modal('open')
                dialog.width && dialog.node.css("max-width", dialog.width) // after dialog is open -> avoid style override
            }
        }

        close(dialogId){
            if(this.dialogs.length){
                let dialog
                if(!dialogId){
                    dialog = this.dialogs[this.dialogs.length -1]
                } else{
                    dialog = this.dialogs.find(d => {
                        return d.id == dialogId
                    })
                }
                dialog && dialog.node[0].M_Modal && dialog.node.modal('close')
                dialog.htmlScroll && $("html").scrollTop(dialog.htmlScroll)
            }
        }

        closeAll(){
            this.dialogs.forEach(d => {
                this.close()
            })
        }

        onButtonClick(dialog, evt){
            evt.item.button.onClick && evt.item.button.onClick(dialog, this)
        }

        onCloseStart(dialog){
            isFun(dialog.onCloseStart) && dialog.onCloseStart(dialog, this)
            this.dialogs = this.dialogs.filter(d => {
                return d != dialog
            })
        }

        onCloseEnd(dialog){
            isFun(dialog.onClose) && dialog.onClose(dialog, this)
            dialog.contentTag && dialog.contentTag.unmount(true)
            this.update()
        }

        onDialogOpen(dialog){
            if(isFun(dialog.onOpen)){
                dialog.onOpen(dialog, this)
            }
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            evt.target.classList.add("hidden")
            this.close()
        }

        Dispatcher.on("openDialog", this.open.bind(this))
        Dispatcher.on("closeDialog", this.close.bind(this))
        Dispatcher.on("closeAllDialogs", this.closeAll.bind(this))
        window.addEventListener("popstate", this.closeAll.bind(this))
    </script>
</modal-dialog>
