<ca-space-dialog class="ca-space-dialog">
    {opts.message || _("notEnoughSpace")}
    <br><br>

    <div class="center-align">
        <a href="#corpus?tab=advanced&cat=my" class="cardBtn card-panel" onclick={onDeleteClick}>
            <i class="material-icons">delete</i>
            <div class="title">{_("deleteSomeData")}</div>
            <div class="desc">{_("deleteSomeDataDesc")}</div>
        </a>

        <a if={site} class="cardBtn card-panel siteLicence" onclick={onRequestMoreSpaceClick}>
            <i class="material-icons">account_box</i>
            <div class="title">{_("getMoreSpace")}</div>
            <div class="desc">{_("getMoreSpaceDescSite")}</div>
        </a>

        <a if={!site} href={window.config.URL_RASPI + "#account/overview"} class="cardBtn card-panel">
            <i class="material-icons">shopping_cart</i>
            <div class="title">{_("getMoreSpace")}</div>
            <div class="desc">{_("getMoreSpaceDesc")}</div>
        </a>
    </div>
    <script>
        const {Auth} = require("core/Auth.js")
        const Dialogs = require("dialogs/dialogs.js")

        require("./ca-space-dialog.scss")

        this.user = Auth.getUser()
        this.site = this.user.licence_type == "site"

        onDeleteClick(){
            Dispatcher.trigger("closeDialog")
        }

        onRequestMoreSpaceClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("closeDialog")
            Dialogs.showRequestMoreSpaceDialog()
        }
    </script>
</ca-space-dialog>
