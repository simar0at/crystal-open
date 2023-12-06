require("./elexis-agreement-dialog/elexis-agreement-dialog.tag")
require("./elexis-splash-dialog/elexis-splash-dialog.tag")
const {Auth} = require("core/Auth.js")

window.elexis = {}

window.elexis.showElexisSplashScreen = () => {
    // display splash screen only once a month
    if(!window.Cookies.get("elexisSplashDisplayed")){
        Dispatcher.trigger("openDialog", {
            tag: "elexis-splash-dialog",
            width: 650,
            onClose: () => {
                window.Cookies.set("elexisSplashDisplayed", "1", 30)
            }
        })
    }
}

Dispatcher.on("GDPR_AGREED", () => {
    let elexis = Auth.getElexis()
    if(!Auth.isLoggedAs() && elexis.is){
        if(!elexis.agreed){
            Dispatcher.trigger("openDialog", {
                id: "elexisAgreement",
                tag: "elexis-agreement-dialog",
                dismissible: false,
                showCloseButton: false,
                width: 650,
            })
        } else{
            window.elexis.showElexisSplashScreen()
        }
    }
})


