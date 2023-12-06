<ca-webcrawl-dialog>
    <div class="centerSpinner">
        <preloader-spinner if={isLoading}></preloader-spinner>
    </div>
    <div if={data}>
        <div if={data.web_crawl.seed_words.length}>
            {_("ca.seeds")}: <b>{data.web_crawl.seed_words.join(", ")}</b>
            <br><br>
        </div>

        <div if={data.web_crawl.site}>
            {_("ca.site")}: <a href={data.web_crawl.site} target="_blank">{data.web_crawl.site}</a>
            <br><br>
        </div>

        <div if={data.web_crawl.urls.length}>
            {_("ca.urls")}:
            <div each={url in data.web_crawl.urls}>
                <a href={url} target="_blank">{url}</a>
            </div>
        </div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')

        this.data = null
        this.isLoading = true

        Connection.get({
            url: window.config.URL_CA + "/corpora/" + opts.corpus_id + "/filesets/" + opts.fileset_id,
            xhrParams:{type: "GET"},
            done: function(payload){
                this.isLoading = false
                this.data = payload.data
                this.update()
            }.bind(this)
        })

    </script>
</ca-webcrawl-dialog>
