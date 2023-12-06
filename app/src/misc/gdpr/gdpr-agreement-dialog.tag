<gdpr-agreement-dialog class="gdpr-agreement-dialog">
    <h4>
        {_("gdpr.headline")}
    </h4>

    <div>
        <raw-html content={_("gdpr.text", ['<a href="' + externalLink("privacyPolicy") + '" target="_blank">' + _("gdpr.link1") +'</a>'])}></raw-html>
    </div>
    <br><br>

    <div class="center">
        <a href="javascript:void(0);" class="btn waves-effect waves-light white-text" onclick={onAgreeClick}>{_("agree")}</a>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require("core/Auth.js")

        onAgreeClick(){
            Connection.get({
                query: "",
                url: window.config.URL_CA + "/users/" + Auth.getUserId(),
                skipDefaultCallbacks: true,
                xhrParams: {
                    method: "put",
                    data: JSON.stringify({
                        "privacy_consent": true
                    }),
                    contentType: "application/json"
                }
            })
            Dispatcher.trigger("closeDialog", "gdpr")
            Dispatcher.trigger("GDPR_AGREED")
        }
    </script>
</gdpr-agreement-dialog>
