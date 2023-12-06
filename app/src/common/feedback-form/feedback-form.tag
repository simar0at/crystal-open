<feedback-form class="feedback-form">
    <div class="columnForm">
        <div class="row" if={!unknownUser}>
            <label class="col s12 m3"
                    style="text-transform: capitalize; padding-top: 4px;">
                {_("from")}
            </label>
            <span class="col s12 m8 fieldCell">
                {user.email}
            </span>
        </div>
        <div class="row" if={unknownUser}>
            <label class="col s12 m3">{_("name")}</label>
            <div class="col s12 m8">
                <ui-input ref="name"
                    disabled={isSending}
                    required=1
                    validate=1
                    inline=1
                    size=20
                    on-input={onNameInput}></ui-input>
            </div>
        </div>
        <div class="row" if={unknownUser}>
            <label class="col s12 m3">{_("email")}</label>
            <div class="col s12 m8">
                <ui-input ref="email"
                    disabled={isSending}
                    inline=1
                    required=1
                    validate=1
                    size=20
                    placeholder="@"
                    on-input={onEmailInput}></ui-input>
                <span id="emailInvalidWarning"
                        class="red-text"
                        style="display: none;">
                    {_("invalidEmail")}
                </span>
            </div>
        </div>
        <div class="row">
            <label class="col s12 m3">{_("message")}</label>
            <span class="col s12 m8">
                <ui-textarea name="feedback"
                        ref="feedback"
                        disabled={isSending}
                        required={true}
                        validate={true}
                        on-input={refreshIsValid}></ui-textarea>
                <div class="grey-text" style="font-size: 13px;">
                    {_("fb.note")}
                </div>
            </span>
        </div>
    </div>

    <script>
        const {Connection} = require("core/Connection.js")
        const {Auth} = require("core/Auth.js")
        const {AppStore} = require("core/AppStore.js")

        this.isSending = false
        this.user = Auth.getUser()
        this.isEmailValid = false
        this.isNameValid = false
        this.email = this.user && this.user.email ? this.user.email : ""
        this.unknownUser = !this.email

        send(){
            if(!this.isSending && this.refs.feedback.isValid){
                if(window.config.URL_SKE_LI){
                    $.ajax({
                        url: window.config.URL_SKE_LI + "store",
                        data: {
                            url: encodeURI(window.location.href),
                            desc: "feedback"
                        },
                        headers: {
                            "X-SKELI-CRYSTAL": "crystal-api"
                        }
                    })
                    .always(function(payload){
                        this.send_feedback(payload.data ? ("https://ske.li/" + payload.data.hash) : "")
                    }.bind(this))
                } else{
                    this.send_feedback()
                }
            }
            this.isSending = true
            this.update()
        }

        send_feedback(url){
            url = url || window.location.href
            Connection.get({
                url: window.config.URL_BONITO + "/feedback",
                xhrParams: {
                    method: "POST",
                    data: this._getPostData(url)
                },
                done: this.onDone,
                fail: this.onFail
            })
        }

        onDone(payload){
            if(payload.error){
                this.onFail()
            } else{
                this.isSending = false
                this.update()
                this.opts.onDone()
            }
        }

        onFail(){
            this.isSending = false
            this.update()
            SkE.showError(_("feedbackFail", [window.config.links.supportMail]))
            this.opts.onFail()
        }

        onNameInput(name){
            this.isNameValid = name !== ""
            this.refreshIsValid()
        }

        onEmailInput(email){
            this.isEmailValid = isEmail(email)
            $("#emailInvalidWarning", this.root).toggle(!this.isEmailValid)
            this.refreshIsValid()
        }

        refreshIsValid(){
            let isValid = this.refs.feedback.getValue() !== ""
                    && (!this.unknownUser || (this.isEmailValid && this.isNameValid))
            this.opts.onValidChange && this.opts.onValidChange(isValid)
        }

        _getPostData(url){
            let data = {
                feedback_url: url,
                navigator: navigator.userAgent,
                feedback_corpname: AppStore.getActualCorpname(),
                feedback_text: this.refs.feedback.getValue(),
                feedback_email: this.email || this.refs.email.getValue(),
                feedback_fullname: this.unknownUser ? this.refs.name.getValue() : Auth.getUser().full_name
                //attachment (možné přiložit soubor)
                //feedback_error
            }
            return "json=" + encodeURIComponent(JSON.stringify(data))
        }


        this.on("mount", () => {
            delay(() => {
                 $("textarea, input", this.root).first().focus()
            }, 1)
            this.refreshIsValid()
        })
    </script>
</feedback-form>
