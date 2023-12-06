const {Connection} = require('core/Connection.js')


class AsyncResultsClass {
    constructor(){
        this.interval = 3000
        this.timeoutHandle = null
        this.settings = null
        this.request = null // active request

        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))
    }

    isChecking(){
        return !!this.settings
    }

    check(settings, payload){
        // url
        // xhrParams [optional]
        // interval [optional] - period in miliseconds to check results
        // isFinished(payload) - returns T/F if all data are available or not
        // onBegin() [optional] - called before first request is sent
        // onData() [optional] - called after every check, when new data is available
        // onComplete() - called when results are complete

        if(this.timeoutHandle){
            this.stop()
        }
        this.settings = settings
        if(payload && settings.isFinished(payload)){
            this.stop()
            settings.onComplete(payload)
        } else{
            settings.onBegin && settings.onBegin(payload)
            if(settings.checkOnStart){
                this._sendRequest()
            } else{
                this._delayedRequest(0)
            }
        }
    }

    stop(){
        clearTimeout(this.timeoutHandle)
        this.request && Connection.abortRequest(this.request)
        this.settings && isFun(this.settings.onStop) && this.settings.onStop()
        this.settings = null
        this.request = null
    }

    _delayedRequest(timeout){
        this.timeoutHandle = setTimeout(function(){
            if(!this.request){ // prevent multiple active request at the same time
                this._sendRequest()
            }
        }.bind(this), timeout)
    }

    _sendRequest(){
        this.settings.beforeCheck && this.settings.beforeCheck()
        this.request = Connection.get({
            url: this.settings.url,
            data: this.settings.data || {},
            xhrParams: this.settings.xhrParams || {},
            always: this._onData.bind(this)
        })
    }

    _onData(payload){
        this.request = null
        if(this.settings){
            if(this.settings.isFinished(payload)){
                this.settings.onComplete(payload)
                this.stop()
            } else{
                let timeout = this.interval
                if(isFun(this.settings.nextTimeout)){
                    timeout = this.settings.nextTimeout(payload)
                } else if(this.settings.interval){
                    if(this.settings.intervalStep && this.settings.interval < this.settings.intervalMax){
                        this.settings.interval += this.settings.intervalStep
                    }
                    timeout = this.settings.interval
                }
                this._delayedRequest(timeout)
                this.settings.onData && this.settings.onData(payload)
            }
        }
    }

    _onPageChange(){
        if(this.isChecking() && !this.settings.continueOnPageChange){
            this.stop()
        }
    }
}

export let AsyncResults = AsyncResultsClass
