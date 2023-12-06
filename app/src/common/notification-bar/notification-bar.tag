<notification-bar class="notification-bar">
    <div ref="container" class="nb-container">
        <div class="nb-item center-align z-depth-1" each={notification in notifications}>
            <i class="nb-info-icon material-icons">info_outline</i>
            <span class="nb-content">
                <span if={!notification.tag} class="nb-message" ref="content">
                    <raw-html content={notification.message}></raw-html>
                </span>
                <span if={notification.tag} class="nb-message" data-is={notification.tag} params={notification.opts}></span>
                <button class="btn btn-primary" onclick={onNotificationClick} if={!notification.permanent}>
                    {notification.buttonLabel || _("dismiss")}  {(typeof notification.timeLeft != "undefined" ?  ("&nbsp;" + notification.timeLeft) : "")}
                </button>
                </span>
            </span>
        </div>
    </div>
    <script>
        require("./notification-bar.scss")

        this.notifications = []

        onNotificationClick(evt){
            let notification = evt.item.notification
            if(isFun(notification.onButtonClick)){
                notification.onButtonClick(this, notification)
            } else{
                this.hideNotification(notification)
            }
        }

        addNotification(notification){
            if(!this.notifications.find((n) => {
                // dont display same message twice
                return n.message == notification.message
            })){
                this.notifications.push(notification)
                if(notification.timeout){
                    notification.timeLeft = notification.timeout
                    this.startTicking()
                }
                this.update()
            }
            this.updateSideNavPosition()
        }

        hideNotification(notification){
            let idx = ""
            if(typeof notification == "string"){
                idx = this.notifications.findIndex(n => {
                    return n.id == notification
                })
            } else{
                idx = this.notifications.indexOf(notification)
            }
            if(idx != -1){
                this.notifications.splice(idx, 1)
                this.update()
                this.updateSideNavPosition()
            }
        }

        startTicking(){
            if(!this.isTicking){
                this.isTicking = true
                this.intervalHandle = setInterval(this.tick, 1000)
            }
        }

        endTicking(){
            clearInterval(this.intervalHandle)
            this.isTicking = false
        }

        tick(){
            let isSomeTicking = false
            this.notifications.forEach((notification) => {
                if(typeof notification.timeLeft != "undefined"){
                    isSomeTicking = true
                    if(notification.timeLeft == 1){
                        this.hideNotification(notification)
                    } else{
                        notification.timeLeft--
                    }
                }
            })
            if(!isSomeTicking){
                this.endTicking()
            }
            this.update()
        }

        updateSideNavPosition(){
            let top = $(this.refs.container).height()
            $("#side-nav, .crystal-app").css({"margin-top": top})
        }

        Dispatcher.on("SHOW_NOTIFICATION", this.addNotification)
        Dispatcher.on("HIDE_NOTIFICATION", this.hideNotification)

    </script>
</notification-bar>
