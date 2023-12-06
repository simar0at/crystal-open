require("./gdpr-agreement-dialog.tag")
const {Auth} = require("core/Auth.js")

Dispatcher.on("AUTH_LOGIN", () => {
    if(!Auth.isLoggedAs() && !Auth.getUser().privacy_consent){
        Dispatcher.trigger("openDialog", {
            id: "gdpr",
            tag: "gdpr-agreement-dialog",
            dismissible: false,
            showCloseButton: false,
            width: 650,
        })
    } else{
        Dispatcher.trigger("GDPR_AGREED")
    }
})
