<profile-dialog class="profile-dialog">
    <br>
    <h4>{user.full_name} <span class="headerId"style="">(ID: {user.id})</span></h4>
    <a href="{window.config.URL_RASPI}#account/overview" class="btn">{_("subscriptionInvoicing")}</a>
    <a href="javascript:void(0);" class="btn" onclick={onChangePasswordClick}>{_("changePassword")}</a>
    <br><br>

    <div class="row">
        <div class="col m5 s12">{_("username")}</div>
        <div class="col m7 s12">{user.username}</div>
    </div>
    <div class="row">
        <div class="col m5 s12">{_("email")}</div>
        <div class="col m7 s12">{user.email}</div>
    </div>
    <div class="row">
        <div class="col m5 s12">{_("licenceType")}</div>
        <div class="col m7 s12">{_(user.licence_type)}</div>
    </div>
    <div class="row" if={isSiteLicence && session.site_licence.end_date}>
        <div class="col m5 s12">{_("licenceEndDate")}</div>
        <div class="col m7 s12">{window.Formatter.date(new Date(session.site_licence.end_date))}</div>
    </div>
    <div class="row">
        <div class="col m5 s12">{_("spaceUsage")}</div>
        <div class="col m7 s12">
            {space.used_str} {_("of")} {space.total_str} ({space.percent}%)
            <a href="javascript:void(0);"
                    if={isSiteLicence}
                    class="btn btn-small btn-floating requestMoreSpaceBtn"
                    onclick={onRequestMoreSpaceClick}>
                <i class="material-icons">add</i>
            </a>
        </div>
    </div>
    <div class="row" if={user.academic}>
        <div class="col m5 s12">{_("academicUser")}</div>
        <div class="col m7 s12">{_("yes")}</div>
    </div>
    <div class="row" if={user.elexis}>
        <div class="col m5 s12">{_("elexisUser")}</div>
        <div class="col m7 s12">{_("yes")}</div>
    </div>
    <div class="row">
        <div class="col m5 s12">{_("skeApiKey")}</div>
        <div class="col m7 s12 key"> {user.api_key}</div>
    </div>
    <div class="row">
        <div class="col offset-m5 offset-s12 m7 s12">
            <a href="javascript:void(0);" onclick={onGenNewApiKey}>{_("genNewSkEApiKey")}</a>
        </div>
    </div>

    <script>
        require("./profile-dialog.scss")
        const {Connection} = require("core/Connection.js")
        const {Auth} = require("core/Auth.js")
        const Dialogs = require("dialogs/dialogs.js")

        this.user = Auth.getUser()
        this.space = Auth.getSpace()
        this.isSiteLicence = Auth.isSiteLicence()
        this.session = Auth.getSession()

        onChangePasswordClick(){
            Dialogs.showChangePasswordDialog()
        }

        onGenNewApiKey(){
            Connection.get({
                query: "",
                loadingId: "generateNewApiKey",
                url: window.config.URL_CA + "/users/me/generate_api_key",
                xhrParams: {
                    method: "post",
                    data: JSON.stringify({}),
                    contentType: "application/json"
                },
                done: (payload) => {
                    this.user.api_key = payload.result
                    this.update()
                }
            })
        }

        onRequestMoreSpaceClick(evt){
            Dialogs.showRequestMoreSpaceDialog()
        }

        Dispatcher.trigger("RELOAD_USER_SPACE")
        Dispatcher.one("USER_SPACE_RELOADED", (space) => {
            this.space = space
            this.update()
        })
    </script>
</profile-dialog>
