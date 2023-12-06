<preloader-spinner class="preloader-spinner {overlay: opts.overlay} {fixed: opts.fixed}">
    <div class="preloader-container {centerSpinner: opts.center}">
        <div class="preloader-wrapper active {big: opts.big} {small: opts.small} {tiny: opts.tiny}">
            <div class="spinner-layer spinner-blue-only">
                <div class="circle-clipper left" style="float: left!important;">
                    <div class="circle"></div>
                </div>
                <div class="gap-patch">
                    <div class="circle"></div>
                </div>
                <div class="circle-clipper right" style="float: right!important;">
                    <div class="circle"></div>
                </div>
            </div>
        </div>
        <div if={opts.message} class="message">
            {opts.message}
        </div>
        <div if={opts.onCancel} ref="cancel" class="cancel hideCancel" onclick={opts.onCancel}>
            {_("cancel")}
            <i class="material-icons">close</i>
        </div>
        <div if={showAcademicWarning} class="academicWarning text-center mt-6">
            <a href={externalLink("academicSubscription")}
                    target="_blank"
                    class="inlineBlock">
                <span class="">
                    {_("academicUseOnly")}
                    <i class="material-icons material-clickable pl-2 vertical-middle">open_in_new</i>
                </span>
            </a>
        </div>
    </div>

    <script>
        const {Auth} = require("core/Auth.js")
        require('./preloader-spinner.scss')

        this.showAcademicWarning = this.opts.showAcademicWarning && Auth.isAcademic()

        this.opts.onCancel && this.on("mount", delay(function(){
            this.refs.cancel && this.refs.cancel.classList.remove("hideCancel")
        }.bind(this), 3000))

        if(this.opts.browserIndicator){
            this.on("mount", () => {
                window.WorkIndicator.start()
            })

            this.on("unmount", () => {
                window.WorkIndicator.stop()
            })
        }
    </script>
</preloader-spinner>
