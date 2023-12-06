<page-unauthorized class="page-unauthorized">
    <div class="backgroundOverlay background-color-blue-600"></div>
    <div class="contentWrapper">
        <div class="flex">
            <img class="logo"
                    src="images/logo_white_300_uk.png" alt="Sketch engine">

            <span id="languageMenu"
                    class="dropdown-trigger white-text material-clickable"
                    data-target="language_menu">{language.label}</span>
        </div>
        <ul id="language_menu"
                class="dropdown-content">
            <li each={lang in languageList}
                    onclick={onLanguageChange}>
                <span>{lang.label}</span>
            </li>
        </ul>
        <div class="card">
            <div class="card-content">
                <div if={!showRegistration}>
                    <h4>
                        {_("pleaseLogIn")}
                    </h4>
                    <br>
                    <div class="center">
                        <button class="btnLogIn btn btn-primary"
                                onclick={onLoginClick}>
                            {_("logIn")}
                        </button>
                        <br><br>
                        <div if={window.config.URL_REGISTER_NEW_USER}>
                            <span class="grey-text">{_("noAccount")}</span>
                            <a class="blue-text cursor-pointer" onclick={onShowRegistrationClick}>{_("signUpNow")}</a>
                        </div>
                    </div>
                </div>

                <div if={showRegistration}>
                    <virtual if={!requestSent}>
                        <h4>
                            {_("registration")}
                        </h4>
                        <div class="grey-text">
                            {_("registrationDesc")}
                        </div>
                        <div class="columnForm">
                            <div class="row">
                                <label class="col m5 s12 required">{_("fullName")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="fullname"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=30
                                            on-input={onInput}
                                            name="fullname"></ui-input>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("username")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="username"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=50
                                            pattern="^[A-Za-z][A-Za-z0-9_.]*$"
                                            pattern-mismatch-message={_("invalidUsername")}
                                            on-input={onInput}
                                            name="username"></ui-input>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("password")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="password"
                                            type="password"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=30
                                            on-input={onPasswordInput}
                                            name="password"></ui-input>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("confirmPassword")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="password2"
                                            type="password"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=30
                                            on-input={onPasswordInput}
                                            name="password2"></ui-input>
                                    <span id="passwordInvalidWarning"
                                            class="red-text"
                                            style="display: none;">
                                        {_("passwordsNotSame")}
                                    </span>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("email")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="mail"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=50
                                            on-input={onMailInput}
                                            name="mail"></ui-input>
                                    <span id="mailInvalidWarning"
                                            class="red-text"
                                            style="display: none;">
                                        {_("invalidEmail")}
                                    </span>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("address")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="address"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=100
                                            on-input={onInput}
                                            name="address"></ui-input>
                                </span>
                            </div>
                            <div class="row">
                                <label class="col m5 s12 required">{_("phone")}</label>
                                <span class="col m7 s12">
                                    <ui-input ref="phone"
                                            size=15
                                            validate=1
                                            required=1
                                            maxlength=30
                                            on-input={onInput}
                                            name="phone"></ui-input>
                                </span>
                            </div>
                        </div>

                        <div class="center mt-6">
                            <button class="btn" onclick={onHideRegistrationClick}>
                                {_("back")}
                            </button>

                            <button ref="btnRegister"
                                    class="btn btn-primary disabled"
                                    onclick={onRegisterClick}>
                                {_("register")}
                            </button>
                        </div>
                    </virtual>

                    <virtual if={requestSent}>
                        <h4>
                            {_("done")}
                        </h4>
                        {_("requestSent")}
                    </virtual>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./page-unauthorized.scss")

        const {Connection} = require("core/Connection.js")
        const {Url} = require("core/url.js")
        const {SettingsStore} = require("core/SettingsStore.js")
        const {Localization} = require('core/Localization.js')
        const {LocalizationMeta, GetLangMeta} = require('core/Meta/Localization.meta.js')

        this.showRegistration = false

        this.language = GetLangMeta(Localization.getLocale())
        this.languageList = LocalizationMeta.langs

        onLanguageChange(evt){
            SettingsStore.changeSettings({
                language: evt.item.lang.id,
                noToast: true,
            })
        }

        onShowRegistrationClick(){
            this.showRegistration = true
            delay(() => {
                $(".columnForm input").first().focus()
            }, 0)
        }

        onHideRegistrationClick(){
            this.showRegistration = false
        }

        onLoginClick(){
            jQuery("#htmlLoading").show()
            let query = Url.getQuery()
            if(query.next){
                window.location.href = decodeURIComponent(query.next)
            } else {
                Dispatcher.trigger("ROUTER_GO_TO", "dashboard")
            }
            window.location.reload()
        }

        onMailInput(value){
            this.isMailValid = isEmail(value)
            this.refreshRegisterBtnDisabled()
            $("#emailInvalidWarning", this.root).toggle(!this.isMailValid)
        }

        onPasswordInput(){
            let password = this.refs.password.getValue()
            let password2 = this.refs.password2.getValue()
            this.passwordsNotSame = password !== password2
            $("#passwordInvalidWarning", this.root).toggle(password !== "" && password2 !== "" && this.passwordsNotSame)
            this.refreshRegisterBtnDisabled()
        }

        onInput(value, name, evt, tag){
            tag.validate()
            this.refreshRegisterBtnDisabled()
        }

        onRegisterClick(){
            let strQuery = Url.stringifyQuery({
                username: this.refs.username.getValue(),
                fullname: this.refs.fullname.getValue(),
                password: this.refs.password.getValue(),
                mail: this.refs.mail.getValue(),
                address: this.refs.address.getValue(),
                phone: this.refs.phone.getValue()
            })
            Connection.get({
                url: window.config.URL_REGISTER_NEW_USER + strQuery,
                loadingId: "user_registration",
                done: (payload) => {
                    if(payload.error){
                        SkE.showError(payload.error)
                    } else if (payload.status == "fail"){
                        SkE.showError(payload.message)
                    } else {
                        this.requestSent = true
                        this.update()
                    }
                },
                fail: (payload) => {
                    if(payload.error){
                        SkE.showError(payload.error)
                    } else {
                        SkE.showError(_("registrationFailed"))
                    }
                }
            })
        }

        refreshRegisterBtnDisabled(){
            let disabled = ["fullname", "username", "password" ,"password2",
                    "mail", "address", "phone"].reduce((disabled, item) => {
                            return disabled || !this.refs[item].isValid
                        }, false)
                    || !this.isMailValid
                    || this.passwordsNotSame
            $(this.refs.btnRegister).toggleClass("disabled", disabled)
        }

        onLocaleChange(locale){
            this.language = GetLangMeta(locale)
            this.update()
        }

        initDropdown() {
            $('#languageMenu').dropdown({constrainWidth: false})
        }

        this.on("updated", this.initDropdown)

        this.on("mount", () => {
            jQuery("#htmlLoading").fadeOut(600)
            Dispatcher.on("LOCALIZATION_CHANGE", this.onLocaleChange)
        })

        this.on("before-unmount", () => {
            Dispatcher.off("LOCALIZATION_CHANGE", this.onLocaleChange)
        })
    </script>
</page-unauthorized>
