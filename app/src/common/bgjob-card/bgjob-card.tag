<bgjob-card>
    <div class="row">
        <div class="col xl6">
            <div class="card">
                <div class="card-content">
                    <span class="right">
                        <preloader-spinner if={opts.data.isLoading} small=1></preloader-spinner>
                    </span>
                    <span class="card-title">{_("bj.bgJob")}</span>
                    <p>{_("bj.bgJobStarted")} <i style="vertical-align: bottom; color: #279FD2"
                            class="material-icons">timelapse</i></p>
                    <div class="progress" style="opacity: 0.7; margin-bottom: 0; margin-top: 1em;">
                        <div class="determinate"
                                style="width: {Math.max(parseInt(opts.data.raw.processing), 1)}%"></div>
                    </div>
                    <!--
                    <br />
                    <ui-checkbox
                            label={_("bj.notifyEmail")}
                            name="notify"
                            checked={notify}
                            disabled={!email}
                            on-change={onToggleNotif}>
                    </ui-checkbox>
                    -->
                </div>
                <div class="card-action">
                    <a href="#bgjobs" class="btn btn-flat grey lighten-3">
                        {_("bj.manage")}
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require("core/Auth.js")

        this.notify = !!this.opts.data.raw.bgjob_notification
        this.email = false

        onToggleNotif() {
            let self = this
            Connection.get({
                url: window.config.URL_BONITO + "jobproxy",
                query: {
                    task: "job_change",
                    jobid: self.opts.data.jobid,
                    key: self.notify ? "notifyrm" : "notify"
                },
                success: (payload) => {
                    self.notify = !self.notify
                    self.update()
                }
            })
        }
    </script>
</bgjob-card>
