<user-limit>
    <div class="inline-block left">
        <div class="mb-3">
            <div if={opts.wllimit} class="align-left text-hint">
                {_( opts.wllimit > opts.screenLimit ? "wl.limit2" : "wl.limit", {
                        limit: window.Formatter.num(opts.wllimit),
                        screenlimit: window.Formatter.num(opts.screenLimit)
                    })}
                <a href={externalLink("wl_download_limits")} target="_blank">
                    {_("links.wl_download_limits")}
                </a>
            </div>
            <div if={!opts.wllimit && opts.total > opts.screenLimit}
                    class="align-left text-hint">
                {_("wl.limit3", [window.Formatter.num(opts.wllimit || opts.screenLimit)])}
                <a class="btn btn-flat btn-floating" onclick={onDownloadClick}>
                    <i class="material-icons blue-text">file_download</i>
                </a>
            </div>
        </div>
    </div>

    <script>
        onDownloadClick(){
            window.scrollTo(0, 0)
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "download")
        }
    </script>
</user-limit>
