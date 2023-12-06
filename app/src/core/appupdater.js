const {AsyncResults} = require('core/asyncresults.js')

class AppUpdaterClass {

    constructor(){
        this.ar =  new AsyncResults()
        if(window.version != "@VERSION@"){
            this.startChecking()
        }
    }

    startChecking(){
        !this.ar.isChecking() && this.ar.check({
            url: window.location.href.split("#")[0] + "version.txt",
            isFinished: () => {
                return false
            },
            continueOnPageChange: true,
            interval: 24 * 60 * 60 * 1000,
            onData: this.onData.bind(this)
        })
    }

    stopChecking(){
        this.ar.stop()
    }

    onData(actualVersion){
        if(typeof actualVersion != "string") {
            return
        }
        if(this.normalizeVersion(window.version) < this.normalizeVersion(actualVersion)){
            this.showNotification()
            $(".nb-content .btn").addClass("contrast")
        }
    }

    showNotification(){
        Dispatcher.trigger("SHOW_NOTIFICATION", {
            tag: "update-notification",
            content: _("newVerionAvailable"),
            buttonLabel: _("reload"),
            onButtonClick: () => {
                window.location.reload()
            }
        })
        this.stopChecking()
    }

    normalizeVersion(version){
        return version.trim().split(".").map(part => {return part.padStart(5, 0)}).join("")
    }
}

riot.tag("update-notification",
        '<div class="un-title">{_("newVerionAvailableTitle")}</div><div>{_("newVerionAvailable")}</div>',
        ".un-title{color: #004b69; font-size:24px; margin-bottom: 5px;}")

window.appUpdater = new AppUpdaterClass()
