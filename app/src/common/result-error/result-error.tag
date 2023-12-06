<result-error class="result-error">
    <h4 class="center-align">{_("somethingWentWrong")}</h4>
    <div class="center-align newSearch">
        <!-- TODO: open change criteria instead -->
        <a href="#{opts.page}" class="btn btn-large" onclick={onReset}>
            <i class="material-icons right">youtube_searched_for</i>
            {opts.buttonLabel || _("newSearch")}
        </a>
    </div>
    <div class="center-align">
        <a if={!showDetails && opts.error}
                onclick={onShowErrorDetailsClick}
                class="link center-align">{_("moreDetails")}</a>
    </div>
    <div if={showDetails} class="errorDetails card">
        <div class="card-content">
            {opts.error}
        </div>
    </div>

    <script>
        require("./result-error.scss")
        this.showDetails = false

        onShowErrorDetailsClick(){
            this.showDetails = true
        }

        onReset() {
            let parent = getPageParent (this)
            if (!parent)
                return
            Dispatcher.trigger("RESET_STORE", parent.__.tagName.substr(5))
        }
    </script>
</result-error>
