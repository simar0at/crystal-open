<ca-compiler-log class="ca-compiler-log">
    <div class="cardtitle">{_("ca.compilationLog")}</div>
    <div class="card-panel">
        <div ref="contentWrapper" class="logWrapper">
            <div ref="content">
                <virtual if={!log}>
                    <h3>{loading ? _("loading") : _("nothingFound")}</h3>
                </virtual>
                <div if={log} class="monospace">{log}</div>
            </div>
        </div>
    </div>

    <script>
        require("./ca-compiler-log.scss")
        const {CAStore} = require("ca/castore.js")

        refreshAttributes(){
            this.data = CAStore.data
            this.loading = !!this.data.asyncResults.log
            this.log = this.data.log
        }
        this.refreshAttributes()

        this.on("update", this.refreshAttributes)
        this.on("updated", () => {
            $(this.refs.contentWrapper).scrollTop( this.refs.content.offsetHeight)
        })
        this.on("mount", () => {
            CAStore.on("logChanged", this.update)
        })
        this.on("unmount", () => {
            CAStore.off("logChanged", this.update)
        })
    </script>
</ca-compiler-log>
