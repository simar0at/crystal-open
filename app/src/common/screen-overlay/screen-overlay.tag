<screen-overlay class="screen-overlay">
    <preloader-spinner if={isLoading || opts.isLoading}
            show-academic-warning={opts.showAcademicWarning}
            center=1
            overlay=1
            big=1>

    <script>
        require("./screen-overlay.scss")
        this.isLoading = false


        if(this.opts.multiple){ // allow component to react to multiple async event
            this.activeSet = new Set() // set of requests in progress. After last finishes, loading overlay is hidden
            if(this.opts.activeLoadings){
                this.opts.activeLoadings.forEach((source) => {
                    this.activeSet.add(source)
                })
            }
        }

        onLoadingChanged(isLoading, source){
            if(this.opts.multiple){
                if(isLoading){
                    this.activeSet.add(source)
                } else{
                    this.activeSet.delete(source)
                }
            }

            if(this.isMounted){
                this.isLoading = this.opts.multiple ? !!this.activeSet.size : isLoading
                this.update()
            }
        }

        Dispatcher.on(this.opts.eventName, this.onLoadingChanged)
    </script>
</screen-overlay>
