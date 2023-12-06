<change-password-dialog class="change-password-dialog">
    <div class="columnForm">
        <div if={error} class="red-text">
            {error}
        </div>
        <div class="row">
            <label class="col m5 s12">{_("oldPassword")}</label>
            <div class="col m5 s12">
                <ui-input type="password"
                        name="old_password"
                        validate={true}
                        required={true}
                        on-input={refreshChangeBtnDisable}
                        ref="oldPassword"
                        on-submit={onPasswordChange}
                        class="cpd_oldPassword"></ui-input>
            </div>
        </div>
        <div class="row">
            <label class="col m5 s12">{_("newPassword")}</label>
            <div class="col m5 s12">
                <ui-input type="password"
                        name="new_password1"
                        validate={true}
                        required={true}
                        on-input={refreshChangeBtnDisable}
                        on-submit={onPasswordChange}
                        ref="newPassword"></ui-input>
            </div>
        </div>
        <div class="row">
            <label class="col m5 s12">{_("confirmPassword")}</label>
            <div class="col m5 s12">
                <ui-input type="password"
                        name="new_password2"
                        validate={true}
                        required={true}
                        on-input={refreshChangeBtnDisable}
                        on-submit={onPasswordChange}
                        ref="newPassword2"></ui-input>
            </div>
        </div>
    </div>


    <script>
        const {Connection} = require('core/Connection.js')
        const {Auth} = require("core/Auth.js")

        refreshChangeBtnDisable(){
            let oldPassword = this.refs.oldPassword.getValue()
            let newPassword1 = this.refs.newPassword.getValue()
            let newPassword2 = this.refs.newPassword2.getValue()

            $("#cpd_changeBtn").toggleClass("disabled", !oldPassword || !newPassword1 || newPassword1 != newPassword2)
        }

        onPasswordChange(){
            this.error = ""
            let oldPassword = this.refs.oldPassword.getValue()
            let newPassword = this.refs.newPassword.getValue()
            Connection.get({
                query: "",
                loadingId: "changePassword",
                url: window.config.URL_CA + "users/me/change_password",
                xhrParams: {
                    method: "post",
                    data: JSON.stringify({
                        "old_password": oldPassword,
                        "new_password": newPassword
                    }),
                    contentType: "application/json"
                },
                done: this._onPasswordChangeDone.bind(this),
                fail: this._onPasswordChangeFail.bind(this)
            })
        }

        _onPasswordChangeDone(){
            Dispatcher.trigger("closeDialog", "changePassword")
            SkE.showToast(_("passwordChanged"))
        }

        _onPasswordChangeFail(payload){
            this.error = payload.error
            this.update()
        }

        this.on("mount", () => {
            Dispatcher.on("changePassword", this.onPasswordChange)
            delay(function(){
                $(this.refs.oldPassword.refs.input).first().focus()
            }.bind(this), 1)
        })

        this.on("unmount", () => {
            Dispatcher.off("changePassword", this.onPasswordChange)
        })
    </script>
</change-password-dialog>
