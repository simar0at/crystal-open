<page-bgjobs class="background-jobs">
    <div class="card" if={isLoading}>
       <div class="card-content" style="text-align: center;">
            <preloader-spinner></preloader-spinner>
        </div>
    </div>
    <table if={!isLoading && jobs.length} class="table">
        <thead>
            <th>{_("description")}</th>
            <th>{_("bj.started")}</th>
            <th>{_("bj.estimation")}</th>
            <th>{_("bj.duration")}</th>
            <th>{_("bj.status")}</th>
            <th>{_("bj.progress")}</th>
            <th></th>
        </thead>
        <tbody each={job, idx in showJobs}>
            <tr class={inactive: job.actions == "N/A" && job.status[1] != "Completed"}>
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
                    <virtual if={job.starttime && job.endtime}>
                        {new Date((new Date(job.endtime) - new Date(job.starttime))).toISOString().slice(11, -5)}
                    </virtual>
                </td>
                <td>
                    <span class="status status_{job.status[0]}">
                        {job.status[1].replace('Uninterruptible sleep', 'Running')}
                    </span>
                    <i if={isSuperUser}
                            class="material-icons material-clickable jobDetail"
                            onclick={onStatusDetailClick}>help_outline</i>
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
            <tr if={job.options && job.feature}>
                <td colspan="7" class="featureOptions">
                    <span class="feature">{getFeatureLabel(job.feature)}</span>
                    <span each={option in job.options}>
                        {_(option[0])}: <b>{String(option[1]).length > 50 ? (option[1].substring(0, 47) + "...") : option[1]}</b>
                    </span>
                    <span if={!job.options.length}>
                        {_("defaultOptions")}
                    </span>
                </td>
            </tr>
        </tbody>
    </table>
    <ui-pagination if={jobs.length > 10}
            actual={page}
            count={jobs.length}
            items-per-page={itemsPerPage}
            show-prev-next=1
            on-change={onPageChange}
            on-items-per-page-change={onItemsPerPageChange}></ui-pagination>
    <div if={!jobs.length && !isLoading} class="empty">
        <i class="material-icons">work_outline</i>
        <h4>{_("bj.noBgJobs")}</h4>
    </div>

    <script>
        require("./bgjobs.scss")
        const {AppStore} = require('core/AppStore.js')
        const {Connection} = require('core/Connection.js')
        const {Auth} = require('core/Auth.js')
        const {UserDataStore} = require('core/UserDataStore.js')
        const {Url} = require("core/url.js")


        this.tooltipClass = ".bjTooltip"
        this.mixin("tooltip-mixin")

        this.jobs = []
        this.isLoading = true
        this.isSuperUser = Auth.isSuperUser()
        this.page = (Url.getQuery().page * 1)|| 1
        this.itemsPerPage = (Url.getQuery().size * 1) || UserDataStore.getOtherData("pageBgjobsItemsPerPage") || 20

        reload(jobs) {
            this.isLoading = false
            this.jobs = jobs
            if(this.page > Math.ceil(this.jobs.length / this.itemsPerPage)){
                this.page = 1 // probably wrong page from url
            }
            this.calculatePagination()
            this.update()
        }

        onStatusDetailClick(evt){
            evt.preventUpdate = true
            let content = "<b>cmd:</b><br>" + htmlEscape(evt.item.job.cmd).replaceAll("\n", "<br>") + "<br>"
                    + "<b>jobid:</b><br>" + htmlEscape(evt.item.job.jobid).replaceAll("\n", "<br>") + "<br>"
                    + (evt.item.job.stderr ? ("<b>stderr:</b><br>" + htmlEscape(evt.item.job.stderr).replaceAll("\n", "<br>")) : "")
                    + (evt.item.job.stdout ? ("<br><br><b>stdout:</b><br>" + htmlEscape(evt.item.job.stdout).replaceAll("\n", "<br>")) : "")
            Dispatcher.trigger("openDialog", {
                tag: "raw-html",
                opts: {
                    content: content
                }
            })
        }

        calculatePagination(){
            this.showJobs = this.jobs.slice((this.page - 1) * this.itemsPerPage, this.page * this.itemsPerPage)
        }

        onPageChange(page){
            this.page = page
            this.calculatePagination()
            this.update()
            Url.updateQuery({page: page})
        }

        onItemsPerPageChange(itemsPerPage){
            this.itemsPerPage = itemsPerPage
            this.calculatePagination()
            this.update()
            Url.updateQuery({size: itemsPerPage})
            UserDataStore.saveOtherData({
                pageBgjobsItemsPerPage: itemsPerPage
            })
        }

        prevPage(){
            if(this.page > 1){
                this.onPageChange(this.page - 1)
            }
        }

        nextPage(){
            if(this.page < Math.ceil(this.jobs.length / this.itemsPerPage)){
                this.onPageChange(this.page + 1)
            }
        }

        this.on("before-mount", () => {
            AppStore.data.bgJobsNotify = false // shown => hide red dot notification
            Dispatcher.trigger('BGJOBS_UPDATED') // redraw header
        })

        this.on('mount', () => {
            AppStore.loadBgJobs()
            AppStore.data.bgJobsNotify = false // shown => no red notification
            AppStore.data.bgJobsPrev = []
            if (AppStore.data.bgJobs && AppStore.data.bgJobs.length) {
                this.reload(AppStore.data.bgJobs)
            }
            Dispatcher.on('BGJOBS_UPDATED', this.reload)
            Dispatcher.on("RESULT_PREV_PAGE", this.prevPage.bind(this))
            Dispatcher.on("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        })

        this.on('before-unmount', () => {
            Dispatcher.off('BGJOBS_UPDATED', this.reload)
            Dispatcher.off("RESULT_PREV_PAGE", this.prevPage.bind(this))
            Dispatcher.off("RESULT_NEXT_PAGE", this.nextPage.bind(this))
        })
    </script>
</page-bgjobs>
