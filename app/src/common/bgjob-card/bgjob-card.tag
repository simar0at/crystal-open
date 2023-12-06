<bgjob-card>
    <div class="card-panel greyCard" style="max-width: 700px;">
        <span class="right">
            <preloader-spinner if={opts.isLoading} small=1></preloader-spinner>
        </span>
        <h5 class="card-title">{_("bj.bgJob")}</h5>
        <p>{_(window.permissions.bgjobs ? "bj.bgJobStarted" : "bj.bgJobStartedOpen")}
            <i style="vertical-align: bottom;"
                class="material-icons color-blue-600">timelapse</i>
        </p>
        <div class="progress" style="opacity: 0.7; margin-bottom: 0; margin-top: 1em;">
            <div class={window.permissions.bgjobs ? "determinate" : "indeterminate"}
                    style="width: {Math.max(parseInt(opts.progress), 1)}%"></div>
        </div>
        <div if={opts.desc}
                class="center grey-text"
                style="font-size: 14px;">
            {opts.desc}
        </div>
    </div>
    <div class="card-action mb-5" if={window.permissions.bgjobs}>
        <a href="#bgjobs" class="btn btn-flat grey lighten-3">
            {_("bj.manage")}
        </a>
    </div>
</bgjob-card>
