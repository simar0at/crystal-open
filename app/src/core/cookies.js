class CookiesClass {
    constructor(){
        this.prefix = "SKE_";
    }

    set(name, value, expirationDays) {
        let date = new Date()
        date.setTime(date.getTime() + (expirationDays * 24 * 60 * 60 * 1000))
        let expires = "expires="+ date.toUTCString()
        document.cookie = name + "=" + value + ";" + expires + ";path=/"
    }

    get(name) {
        name = name + "="
        let decodedCookie = decodeURIComponent(document.cookie)
        let cookies = decodedCookie.split(';')
        for(let i = 0; i < cookies.length; i++) {
            let cookie = cookies[i].trim()
            if (cookie.indexOf(name) == 0) {
                return cookie.substring(name.length, cookie.length)
            }
        }
        return ""
    }
}

window.Cookies = new CookiesClass()
