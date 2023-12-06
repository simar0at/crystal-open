class WorkIndicatorClass {
    constructor(){
        this.handle = null
        this.frames = ["●∙∙", "∙●∙", "∙∙●"]
        //this.frames = ["▖","▘","▝","▗"]
        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))
    }

    start(){
        if(!this.handle){
            this.cnt = 0
            this.title = document.title.startsWith("✓ ") ? document.title.substr(2) : document.title
            this._updateTitle()
            this.handle = setInterval(() => {
                this.cnt++
                if(this.cnt == this.frames.length){
                    this.cnt = 0
                }
                this._updateTitle()
            }, 1000)
        }
    }

    stop(){
        if(this.handle){
            clearInterval(this.handle)
            this.handle = null
            document.title = "✓ " + this.title
            $(document).one("mousemove keypress", function(){
                this.clear()
            }.bind(this))
        }
    }

    clear(){
        document.title = this.title
    }

    _onPageChange(){
        clearInterval(this.handle)
        this.handle = null        
    }

    _updateTitle(){
        document.title = this.frames[this.cnt] + " " + this.title
    }
}

window.WorkIndicator = new WorkIndicatorClass()


