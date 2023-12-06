<elexis-agreement-dialog class="elexis-agreement-dialog">
    <div class="center">
        {_("elexis.dialog1_headline")}
    </div>

    <div style="font-size: 1.5em; margin: 20px 0; text-align: center;">{_("elexis.dialog1_title")}</div>

    <div class="description">
        {_("elexis.dialog1_description")}
    </div>
    <br><br>

    <div class="center">
        <label for="agreeLabel">
            <input type="checkbox"
                id="agreeLabel"
                onchange={onCheckboxChange} />
                <span>
                    <raw-html content={_("elexis.dialog1_checkbox1", ['<a href="' + elexisTermsURL + '" target="_blank">' + _("elexis.dialog1_checkbox2") +'</a>'])}></raw-html>
                </span>
        </label>
        <br><br>
        <a ref="btn" class="btn waves-effect waves-light white-text disabled" onclick={onAgreeClick}>{_("agree")}</a>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require("core/Auth.js")

        this.elexisTermsURL = "https://www.sketchengine.co.uk/elexis-terms/"

        onCheckboxChange(evt){
            $(this.refs.btn).toggleClass("disabled", !evt.target.checked)
        }

        onAgreeClick(){
            Connection.get({
                query: "",
                url: window.config.URL_CA + "/users/" + Auth.getUserId(),
                skipDefaultCallbacks: true,
                xhrParams: {
                    method: "put",
                    data: JSON.stringify({
                        elexis_agreed: true
                    }),
                    contentType: "application/json"
                }
            })
            Dispatcher.trigger("closeDialog", "elexisAgreement")
            elexis.showElexisSplashScreen()


        }
    </script>
</elexis-agreement-dialog>
