const {Connection} = require('core/Connection.js')

class AppUpdaterClass {

    constructor(){
        this.CHECK_INTERVAL = 24 * 60 * 60 * 1000
        this._intervalHandle = null
        if(window.version != "@VERSION@"){
            this.startTimer()
        }
    }

    startTimer(){
        this._intervalHandle = setInterval(this.loadVersion.bind(this), this.CHECK_INTERVAL)
    }

    stopTimer(){
        clearInterval(this._intervalHandle)
        this._intervalHandle = null
    }

    checkNow(){
        if(this._intervalHandle){  // if checking was stopped do not do anything
            this.stopTimer()  // reset timer
            this.startTimer()
            this.loadVersion()
        }
    }

    loadVersion(){
        Connection.get({
            url: window.location.href.split("#")[0] + "version.txt?" + (Math.random(1000000) + "").substr(2),
            done: this.onData.bind(this)
        })
    }

    onData(actualVersion){
        if(typeof actualVersion != "string") {
            return
        }
        if(window.version.trim() != actualVersion.trim()){
            this.showNotification()
            $(".nb-content .btn").addClass("btn-primary")
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
        this.stopTimer()
    }
}

riot.tag("update-notification",
        '<div class="un-title color-blue-800">{_("newVerionAvailableTitle")}</div><div>{_("newVerionAvailable")}</div>',
        ".un-title{font-size:24px; margin-bottom: 5px;}")

window.appUpdater = new AppUpdaterClass()
