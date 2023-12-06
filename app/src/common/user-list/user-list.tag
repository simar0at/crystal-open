<user-list>
    <ui-filtering-list ref="users"
        inline=1
        loading={loadingUserList}
        floating-dropdown=1
        options={userList}
        size={20}
        name="users"
        on-change={opts.onChange}
        on-input={onInput}
        on-submit={opts.onSubmit}
        filter={userListFilter}
        value-in-search=1
        on-input={onInput}
        footer-content={userListFooter}></ui-filtering-list>

    <script>
        const {Connection} = require('core/Connection.js')

        this.userList = []
        this.userListFooter = "" // temporary disabled,
        this.userListRequest = null

        userListFilter(searchWord, option){
            return true // turn off default filtering, server filters users
        }

        this.debounceHandle = null
        onInput(value){
            clearTimeout(window.debounceHandle)
            window.debounceHandle = setTimeout(this.loadUsers.bind(this), 300)
            isFun(this.opts.onInput) && this.opts.onInput(value)
        }

        loadUsers(){
            let query = this.refs.users ? this.refs.users.inputValue : ""
            if(query === ""){
                return
            }
            this.userListRequest && Connection.abortRequest(this.userListRequest)
            this.userListRequest = Connection.get({
                url: window.config.URL_CA + "users?q=" + query,
                done: function(payload, request){
                    let total = request.xhr.getResponseHeader("X-Total-Count") * 1
                    this.userList = payload.data.map(u => {
                        return {
                            label: `${u.full_name} (${u.username})`,
                            username: u.username,
                            value: u.id + ""
                        }
                    })
                    /*this.userListFooter = ""
                    if((this.userList.length + 1) < total){
                        this.userListFooter = _("ca.totalUsers", [Formatter.num(total * 1)])
                    }*/
                    this.loadingUserList = false
                    this.update()
                }.bind(this),
                fail: payload => {
                    SkE.showError("Could not load user list", getPayloadError(payload))
                },
                always: function(){
                    this.userListRequest = null
                }.bind(this)
            })
            this.loadingUserList = true
            this.update()
        }

        cancelRequest(){
            this.userListRequest && Connection.abortRequest(this.userListRequest)
        }
    </script>
</user-list>
