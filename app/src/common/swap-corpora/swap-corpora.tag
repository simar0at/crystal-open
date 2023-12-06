<swap-corpora class="swap-corpora">
    <div if={opts.corpusName}
            class="refCorpus">
        <a href={opts.url}
                class="btn btn-floating tooltipped btnSwap"
                data-tooltip={_("switchRefCorp")}>
            <i class="material-icons">swap_horiz</i>
        </a>
        <span class="label">
            {_("refCorpus")}:
        </span>
        {opts.corpusName}
        <span if={opts.subcorpusName}
                class="subcorpus">
            &nbsp;
            <span class="label">
                {_("subcorpus")}:
            </span>
            {opts.subcorpusName}
        </span>
    </div>

    <script>
        require("./swap-corpora.scss")

        this.mixin("tooltip-mixin")
    </script>
</swap-corpora>
