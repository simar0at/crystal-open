<result-preloader-spinner>
    <preloader-spinner if={opts.store.data.isLoading && !opts.store.data.jobid}
            on-cancel={opts.store.onLoadingCancel.bind(opts.store)}
            overlay=1
            fixed=1
            browser-indicator=1
            show-academic-warning=1></preloader-spinner>
</result-preloader-spinner>
