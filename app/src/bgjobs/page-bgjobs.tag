<page-bgjobs class="background-jobs">
    <div class="card" if={isLoading}>
       <div class="card-content" style="text-align: center;">
            <preloader-spinner></preloader-spinner>
        </div>
    </div>
    <table if={!isLoading && jobs.length} class="table striped highlight">
        <thead>
            <th>{_("description")}</th>
            <th>{_("bj.started")}</th>
            <th>{_("bj.estimation")}</th>
            <th>{_("bj.status")}</th>
            <th>{_("bj.progress")}</th>
            <th></th>
        </thead>
        <tbody>
            <tr each={job, idx in jobs}
                    class={inactive: job.actions == "N/A" && job.status[1] != "Completed"}>
                <td>
                    <a target="_blank" href={job.url}
                            if={job.status[1] == "Completed"}>{job.desc}</a>
                    <span if={job.status[1] != "Completed"}>{job.desc}</span>
                    ({job.corpus})
                </td>
                <td>{job.starttime.substr(0, 10)}
                    &nbsp;{job.starttime.substr(10, 9)}
                </td>
                <td>{job.status[1] == "Running" ? job.esttime : ""}</td>
                <td>
                    <span class="status status_{job.status[0]}">
                        {job.status[1].replace('Uninterruptible sleep', 'Waiting')}
                    </span>
                </td>
                <td>{job.progress}%</td>
                <td>
                    <a href={job.status[1] == "Completed" ? job.url : "javascript:void(0);"}
                            class="btn btn-flat bjTooltip {disabled: job.status[1] != 'Completed'}"
                            data-tooltip={_("showResults")}>
                        <i class="material-icons">visibility</i>
                    </a>
                </td>
            </tr>
        </tbody>
    </table>
    <!-- TODO pagination -->
    <div if={!jobs.length && !isLoading} class="empty">
        <i class="material-icons">work_outline</i>
        <h4>{_("bj.noBgJobs")}</h4>
    </div>

    <script>
        require("./bgjobs.scss")
        const {AppStore} = require('core/AppStore.js')
        const {Connection} = require('core/Connection.js')

        this.tooltipClass = ".bjTooltip"
        this.mixin("tooltip-mixin")

        this.jobs = []
        this.isLoading = true

        reload(jobs) {
            AppStore.data.bgJobsNotify = false // shown => no red notification
            this.isLoading = false
            this.jobs = jobs
            this.update()
        }

        this.on('mount', () => {
            AppStore.loadBgJobs()
            AppStore.data.bgJobsNotify = false // shown => no red notification
            AppStore.data.bgJobsPrev = []
            if (AppStore.data.bgJobs && AppStore.data.bgJobs.length) {
                this.reload(AppStore.data.bgJobs)
            }
            Dispatcher.on('BGJOBS_UPDATED', this.reload)
        })

        this.on('unmount', () => {
            Dispatcher.off('BGJOBS_UPDATED', this.reload)
        })
    </script>
</page-bgjobs>
