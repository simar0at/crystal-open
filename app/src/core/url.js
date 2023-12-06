import route from 'riot-route'

class UrlClass {

    constructor(){}

    create(page, query){
        return this.getOrigin() + "#" + page + this.stringifyQuery(query)
    }

    getOrigin(url){
        return this._getParts(url).origin
    }

    getPage(url){
        return this._getParts(url).page
    }

    getQuery(url){
        return this.parseQuery(this._getParts(url).query)
    }

    setQuery(query, addToHistory, forceUpdate){
        let url = this.create(this.getPage(), query)
        if(forceUpdate || window.location.href != url){
            if(addToHistory){
                history.pushState(null, null, url)
                route.base() // need to update route's "current" value in
                             //order to browser back button works correctly
            } else{
                history.replaceState(null, null, url)
            }
        }
    }

    updateQuery(query, addToHistory, forceUpdate){
        let updatedQuery = Object.assign(this.getQuery(), query)
        this.setQuery(updatedQuery, addToHistory, forceUpdate)
    }

    stringifyQuery(query){
        let str = ""
        let value
        let urlValue

        for(let key in query){
            value = query[key]
            urlValue = (typeof value == "boolean") ? (value * 1) : value
            if(key){
                str += (str ? "&" : "") + key + "=" + encodeURIComponent(urlValue)
            }
        }

        return str ? ("?" + str) : ""
    }

    parseQuery(str){
        let query = {}
        if(str && str.indexOf("=") != -1){
            str.split('&').forEach(part => {
                let pair = part.split('=')
                query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
            })
        }
        return query
    }


    _getParts(url){
        url = url || window.location.href
        let tmp = url.split("?")
        let tmp2 = tmp[0].split("#")
        return {
            origin: tmp2[0],
            page: tmp2[1] || "",
            query: tmp[1] || ""
        }
    }

}

export let Url = new UrlClass()
