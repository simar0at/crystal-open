<login-as-dialog class="login-as-dialog">
    <div class="center">
        <br>
        <user-list ref="list"
                on-change={onUserChange}
                on-input={onUserInput}
                on-submit={onLoginAsClick}></user-list>
        <a id="btnDialogLoginAs"
            class="btn white-text"
            ref="btn"
            href="javascript:void(0);"
            onclick={onLoginAsClick}
            style="margin-left: 20px;position: relative; top:-1px;">{_("loginAs")}</a>
    </div>

    <script>
        const {Auth} = require("core/Auth.js")
        require("./login-as-dialog.scss")

        this.username = ""

        onUserChange(user, name, label, option){
            this.username = option.username
        }

        onUserInput(value){
            this.username = value
        }

        onLoginAsClick(){
            this.refs.list.cancelRequest()
            Auth.loginAs(this.username)
        }

        onLoginAsDone(){
            Dispatcher.trigger("closeAllDialogs")
            Dispatcher.trigger("ROUTER_GO_TO", "dashboard")
        }

        this.on("mount", () => {
            Dispatcher.on("ON_LOGIN_AS_DONE", this.onLoginAsDone)
            delay(() => {
                 $("input", this.root).focus()
            }, 10)
        })

        this.on("unmount", () => {
            Dispatcher.off("ON_LOGIN_AS_DONE", this.onLoginAsDone)
        })
    </script>
</login-as-dialog>
