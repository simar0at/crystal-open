const {Auth} = require("core/Auth.js")
const {Connection} = require("core/Connection.js")

class NotifierClass {
    constructor(){
        Dispatcher.on("APP_READY_CHANGED", (ready) => {
            if(ready){
                this._checkReadOnly()
                this._showNotificationFromConfig()
                if(window.config.URL_PAY && Auth.isFullAccount()){
                    setTimeout(() => {
                        Connection.get({
                            url: window.config.URL_PAY,
                            query:{
                                c: "user"
                            },
                            done: (payload) => {
                                if(payload.data.last_base_order_status == "failed"){
                                    let response = payload.data.last_base_order_response
                                    Dispatcher.trigger("SHOW_NOTIFICATION", {
                                        message: (response ? _("lastPaymentFailed1a", [response]) : _("lastPaymentFailed1b"))
                                                + "&nbsp;"
                                                + _("lastPaymentFailed2", ["<br>",
                                                    new Date(payload.data.end_date).toLocaleDateString(),
                                                    '<a href="' + config.URL_RASPI + '#account/overview" target="_blank">' + _("extend") + '</a>'])
                                    })
                                }
                            }
                        })
                    }, 2000)
                }
            }
        })
    }

    _checkReadOnly(){
        if(config.READ_ONLY){
            Dispatcher.trigger("SHOW_NOTIFICATION", {
                message: config.READ_ONLY_MSG,
                permanent: true
            })
        }
    }

    _showNotificationFromConfig(){
        if(config.NOTIFICATION && !window.Cookies.get("hideNotification")){
            Dispatcher.trigger("SHOW_NOTIFICATION", {
                message: config.NOTIFICATION,
                onButtonClick: (notifcationBar, notification) => {
                    window.Cookies.set("hideNotification", "1", 1)
                    notifcationBar.hideNotification(notification)
                }
            })
        }
    }
}

const notifier = new NotifierClass()
