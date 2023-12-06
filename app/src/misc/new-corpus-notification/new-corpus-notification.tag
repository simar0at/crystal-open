<new-corpus-notification>
    <span>
        {_("msg.newCorp1")}
        <a href="javascript:void(0);" onclick={onNewCorpusClick}>{_("msg.newCorp2")}</a>.
        {_("msg.newCorp3")}
        <a href={corpus.infohref} target="_blank">{_("msg.newCorp4")}</a>.
    </span>
    <script>
        const {AppStore} = require("core/AppStore.js")
        this.corpus = this.opts.params.corpus

        onNewCorpusClick(){
            let latest = AppStore.getLatestCorpusVersion(this.corpus).corpname
            AppStore.checkAndChangeCorpus(latest)
            this.parent.hideNotification("oldCorpus")

        }
    </script>
</new-corpus-notification>
