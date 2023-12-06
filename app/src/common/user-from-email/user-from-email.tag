<user-from-email class="user-from-email {opts.class}">
    <ui-input
        ref="email"
        label={_("userEmailAddress")}
        size={opts.size}
        on-input={onInputChangedDebounced}
        suffix-icon={isLoading ? "access_time" : "alternate_email"}></ui-input>
    <div style="position: relative; top:-16px;">
        <span if={!isLoading && query}>
            <span if={found} class="green-text">{_("emailValid")}</span>
            <span if={!found && isEmail} class="red-text">{_("emailNotFound")}</span>
            <span if={!isEmail} class="red-text">{_("enterUserEmail")}</span>
        </span>
        <span if={isLoading} class="grey-text">{_("checking")}</span>
    </div>


    <script>
        const {Connection} = require('core/Connection.js')

        this.users = []
        this.query = ""
        this.isEmail = false
        this.isLoading = false
        this.found = false
        this.request = null

        this.debounceHandle = null
        onInputChangedDebounced(){
            clearTimeout(window.debounceHandle)
            window.debounceHandle = setTimeout(this.loadUsers.bind(this), 500)
        }

        getUsers(){
            if(this.found){
                return this.users
            }
            return null
        }

        reset(){
            this.refs.email.refs.input.value = ""
            this.query = ""
            this.users = []
            this.isEmail = false
            this.found = false
            this.callValidChange()
            this.update()
        }

        loadUsers(){
            this.query = this.refs.email ? this.refs.email.getValue() : ""
            this.isEmail = isEmail(this.query)
            this.users = []
            this.found = false
            if(this.isEmail){
                this.request && Connection.abortRequest(this.request)
                this.request = Connection.get({
                    url: window.config.URL_CA + "users?email=" + this.query,
                    done: function(payload){
                        if(!payload.error){
                            this.users = payload.data.map(user => {
                                user.email = this.query
                                return user
                            }, this)
                            this.found = this.users.length
                        }
                        this.isLoading = false
                        this.callValidChange()
                        this.update()
                    }.bind(this),
                    fail: payload => {
                        SkE.showError("Could not load user list", getPayloadError(payload))
                    },
                    always: function(){
                        this.request = null
                        this.isLoading = false
                        this.update()
                    }.bind(this)
                })
                this.isLoading = true
            }
            this.callValidChange()
            this.update()
        }

        callValidChange(){
            isFun(this.opts.onValidChange) && this.opts.onValidChange(this.found)
        }
    </script>
</user-from-email>
