const {AppStore} = require("core/AppStore.js")

const CORPORA_LIST_CHECK_PERIOD = 60 //minutes

class CorporaListCheckerClass{
    constructor(){
        this.intervalHandle = null
        AppStore.on("corpusListChanged", this.resetInterval.bind(this))
    }

    startInterval(){
        this.intervalHandle = setInterval(() => {
            AppStore.loadCorpusList()
        }, CORPORA_LIST_CHECK_PERIOD * 60 * 1000)
    }

    resetInterval(){
        clearInterval(this.intervalHandle)
        this.startInterval()
    }
}

let corporaListChecker = new CorporaListCheckerClass()
