const {Connection} = require('core/Connection.js')
const {Url} = require('core/url.js')

class AuthClass{

    constructor(){
        this._isLogged = false
        this._user = {}
        this._session = {}
        this._space = {}
        this.loadSession()
        Dispatcher.on("CHECK_SESSION_AND_REDIRECT", this.checkSessionAndRedirect.bind(this))
        Dispatcher.on("RELOAD_USER_SPACE", this.reloadUserSpace.bind(this))
        Dispatcher.on("LOGOUT_AS", this.logoutAs.bind(this))
        Dispatcher.one("NO_ACTIVE_REQUEST", this.onNoActiveRequest.bind(this))
    }

    isLogged() {
        return this._isLogged
    }

    isSuperUser() {
        return this._session.superuser
    }

    isAnonymous(){
        return this._session.user_type == "ANONYMOUS"
    }

    isFullAccount(){
        return this._session.user_type == "FULL_ACCOUNT"
    }

    isSiteLicenceMember() {
        return this._session.user_type == "SITELICENCE_MEMBER"
    }

    isSiteLicenceAdmin() {
        return this._user.administered_site_licences && this._user.administered_site_licences.length > 0
    }

    isSiteLicence(){
        return this._user.licence_type == "site"
    }

    isAcademic(){
        return ["acorg", "acind"].includes(this._user.licence_type)
    }

    isLoggedAs(){
        return !!this._session.emulated_user
    }

    getSession(){
        return this._session
    }

    getUser(){
        return this._user
    }

    getUsername() {
        return this._user.username
    }

    getSiteLicence(){
        return this._session.site_licence
    }

    getUserId() {
        return this._user.id
    }

    getEmail(){
        return this._user.email
    }

    getSpace(){
        return this._space
    }

    isWIPO() {
        return this._user.wipo
    }

    getAnnotationGroup() {
        return this._user.annotation_group || ("user_" + this._user.username)
    }

    loadSession(){
        return Connection.get({
            query: "",
            url: window.config.URL_CA + "session",
            xhrParams: {
                method: "get",
                contentType: "application/json"
            },
            done: function(payload, request){
                if(payload.data && payload.data.user_type == "FULL_ACCOUNT"){
                    this._onLoginDone(payload)
                } else { // ANONYMOUS os SITELICENCE_MEMBER
                    this._isLogged = true
                    this._user = {}
                    this._session = payload.data
                    Dispatcher.trigger("AUTH_ANONYMOUS_LOGIN", payload)
                }
            }.bind(this),
            fail: payload => {
                SkE.showError("Could not load session.", getPayloadError(payload))
            },
            always: (payload) => {
                Dispatcher.trigger("SESSION_LOADED", payload)
            }
        })
    }

    checkSessionAndRedirect(callback){
        // checks, if user has active session. If not, user is redirected to login page.
        this.loadSession()
        Dispatcher.one("SESSION_LOADED", (payload) => {
            let authorized = payload.data && payload.data.user_type == "FULL_ACCOUNT"
            if(!authorized){
                if(window.config.URL_RASPI){
                    window.location.href = window.config.URL_RASPI + "?next=" + encodeURIComponent(window.location.href)
                } else {
                    Dispatcher.trigger("ROUTER_GO_TO", "unauthorized")
                }
            } else {
                callback && callback(authorized)
            }
        })
    }

    logout(){
        Connection.get({
            query: "",
            loadingId: "logout",
            url: window.config.URL_CA + "session",
            xhrParams: {
                method: 'DELETE',
                type: 'json'
            },
            always: () => {
                window.location.href = window.config.URL_RASPI
            }
       })
    }

    loginAs(username){
        Connection.get({
            query: "",
            loadingId: "login",
            url: window.config.URL_CA + "session",
            skipDefaultCallbacks: true,
            xhrParams: {
                method: "put",
                data: JSON.stringify({
                    emulated_user: username
                }),
                contentType: "application/json"
            },
            done: (payload) => {
                this._onLoginDone(payload)
                Dispatcher.trigger("ON_LOGIN_AS_DONE")
            },
            fail: (payload) => {
                SkE.showToast(payload.error)
                this._onLoginFail()
            }
        })
    }

    logoutAs(){
        if(this._session.emulated_user){
            this.loginAs(null)
            Dispatcher.trigger("ROUTER_GO_TO", "dashboard")
        }
    }

    reloadUserSpace(){
        !window.config.NO_CA &&Connection.get({
            query: "",
            url: window.config.URL_CA + "users/me/get_used_space",
            xhrParams: {
                method: "post",
                data: JSON.stringify({}),
                contentType: "application/json"
            },
            done: (payload) => {
                let s = payload.result
                this._space = {
                    total: s.space_total,
                    total_str: window.Formatter.num(s.space_total),
                    used: s.space_used,
                    used_str: window.Formatter.num(s.space_used),
                    percent: Math.floor(s.space_used / s.space_total * 100),
                    has_space: !s.space_total || (s.space_total > s.space_used)
                }
                Dispatcher.trigger("USER_SPACE_RELOADED", this._space)
            }
       })
    }

    onNoActiveRequest(){
        // try to login as once there is no active request (otherwise active
        // request would fail after logging-as in and redirect user to the login page)
        let loginAs = Url.getQuery().login_as
        if(this.isSuperUser() && loginAs){
            if(loginAs.indexOf("@") == -1){
                this.loginAs(loginAs)
            } else {
                Connection.get({
                    url: window.config.URL_CA + "users?q=" + loginAs,
                    done: function(payload){
                        if(payload.data && payload.data[0]){
                            this.loginAs(payload.data[0].username)
                        } else {
                            SkE.showToast(`User with email ${loginAs} not found.`)
                        }
                    }.bind(this)
                })
            }
        }
    }

    _onLoginDone(payload){
        if(payload.statusText == "error"){
            alert("Login failed.")
        } else if(payload.statusText == "UNAUTHORIZED"){
            Dispatcher.trigger("AUTH_LOGIN_FAIL", JSON.parse(payload.responseText))
        } else if(payload.data.user){
            if(this._user.username != payload.data.user.username){
                this.reloadUserSpace()
                this._isLogged = true
                this._user = payload.data.user
                this._session = payload.data
                Dispatcher.trigger("AUTH_LOGIN")
            }
        }
    }

    _onLoginFail(payload){
        Dispatcher.trigger("AUTH_LOGIN_FAIL", payload)
    }
}

export let Auth = new AuthClass()
