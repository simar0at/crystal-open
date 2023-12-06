const {Auth} = require("core/Auth.js")
const {Connection} = require("core/Connection.js")

require("./notifier.scss")

class NotifierClass {
    constructor(){
        Dispatcher.on("APP_READY_CHANGED", (ready) => {
            if(ready){
                this._checkReadOnly()
                this._showNotificationFromConfig()
                this._showBolognaUniversityInfo()
                if(window.config.URL_PAY && Auth.isFullAccount()){
                    setTimeout(() => {
                        Connection.get({
                            url: window.config.URL_PAY,
                            data:{
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
                                if(payload.data.display_resubscribe_message === true){
                                    Dispatcher.trigger("openDialog", {
                                        title: 'Keep access to Sketch Engine',
                                        content: 'The automatic renewal of your account has been terminated due to changes in the online payment system. We are sorry for this inconvenience which we could not influence. We kindly ask you to set up a new subscription to keep your account open'
                                                + '<div class="center-align" style="margin: 30px 0;"><a href="https://auth.sketchengine.eu/#pay/subscribe?cancel_subscription=1" class="btn btn-primary">create subscription</a></div>'
                                                + 'Without a new subscription, your account will close when the current subscription expires. An expired account can also be re-opened later.'
                                    })
                                }
                                Dispatcher.trigger("PAY_USER_DATA_LOADED", payload)
                            }
                        })
                    }, 2000)
                }
            }
        })
    }

    _checkReadOnly(){
        if(config.READ_ONLY && config.READ_ONLY_MSG){
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


    _showBolognaUniversityInfo(){
        let siteLicence = Auth.getSiteLicence()
        if(siteLicence && siteLicence.id == "BolognaUni_ELEXIS"){
            Dispatcher.trigger("openDialog", {
                class: "bologneUniDialog",
                fixedFooter: true,
                tag: "preloader-spinner",
                opts: {center: 1},
                onOpen: (dialog, modal) => {
                    $(modal).find(".preloader-container").addClass("centerSpinner")
                    window.TextLoader.loadAndInsert("bolognaUniInfo.html", dialog.contentNode[0].parentNode)
                }
            })
        }

    }
}

const notifier = new NotifierClass()
