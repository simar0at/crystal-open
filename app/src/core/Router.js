const {RoutingMeta} = require('core/Meta/Routing.meta.js')
const {Auth} = require("core/Auth.js");
const {AppStore} = require("core/AppStore.js")
import route from 'riot-route'

class RouterClass{
    constructor(){
        Dispatcher.on("SESSION_LOADED", this._onSessionLoaded.bind(this))
        Dispatcher.on("ROUTER_GO_TO", this._onPageChange.bind(this))
        Dispatcher.on("APP_READY_CHANGED", function(ready){
            ready && this._onAppReady()
        }.bind(this))
    }

    createUrl(page, query){
        return "#" + page + this._getStringFromQuery(query)
    }

    getActualPage(){
        return this._actualPage
    }

    getActualPageLabel(){
        let meta = this._getPageActualMeta()
        return meta ? getLabel(meta) : ""
    }

    getActualFeature(){
        // acording to actual page returns feature, to which page belongs (wordlist-result->wordlist)
        return this._getPageFeature(this._actualPage)
    }

    getUrlQuery(){
        return this._getQueryFromString(window.location.href)
    }

    updateUrlQuery(query, addToHistory, forceUpdate){
        // serialize object queryObject and adds it to url query - ?param=value&param2=...
        let url = this._getUrlBase() + this.createUrl(this._actualPage, query)
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

    _initRouter(){
        route.create()
        route(this._onPageChange.bind(this))
        route.parser(function(path){
            return [path.split("?")[0], this._getQueryFromString(path)]
        }.bind(this))
        route.start(false)
    }

    _onPageChange(pageId, queryObj){
        queryObj = queryObj || {}
        // user clicked on link, insert url address or navigate browser back/forward
        if(queryObj.corpname){
            const corpus = AppStore.getActualCorpus()
            if(!corpus || corpus.corpname != queryObj.corpname){
                // corpus is defined and its not actual corpus -> need to load new corpus
                AppStore.changeCorpus(queryObj.corpname)
                AppStore.one("corpusChanged", this._checkAndSetPage.bind(this, pageId, queryObj))
                return
            }
        }
        this._checkAndSetPage(pageId, queryObj)
    }

    _onSessionLoaded(payload){
        if(!Auth.isLogged()){
            window.location.href = window.config.URL_RASPI + "?next=" + encodeURIComponent(window.location.href)
        } else{
            this._initRouter()
        }
    }

    _checkAndSetPage(pageId, queryObj){
        let page = this._getPageToNaviagateTo(pageId)
        // keep url and router state synchronized
        let q = page == pageId ? queryObj : {}
        let url = this._getUrlBase() + this.createUrl(page, q)
        history.replaceState(null, null, url)
        route.base()
        this._actualPage = page
        this._setDocumentTitle()
        Dispatcher.trigger("ROUTER_CHANGE", this._actualPage, q)
    }

    _getPageToNaviagateTo(page){
        // check, if navigation to desired page is allowed.
        // Otherwise return page to route to
        let isLogged = Auth.isLogged()
        let isFullAccount = Auth.isFullAccount()
        let isAnonymous = Auth.isAnonymous()
        let corpus = AppStore.getActualCorpus()
        let urlCorpus = this.getUrlQuery().corpname
        let pageFeature = this._getPageFeature(page)
        if(!window.config.NO_CA){ // in NO_CA mode user can access everything
            if(!isLogged
                || (isAnonymous && page != "open" && !corpus && !urlCorpus && page != "404" && page != "not-allowed")){
                window.location.href = window.config.URL_RASPI + "?next=" + encodeURIComponent(window.location.href)
            }
        }
        if(!RoutingMeta.table[page]){
            debugger
            page = RoutingMeta.notFound
        }
        if(isFullAccount){
            if(page == "open"){
                page = "corpus"
            }
        }
        if(isAnonymous){
            if(page == "corpus"){
                page = "open"
            }
        }
        if(isDef(window.permissions[page]) && !window.permissions[page]){
            page = "not-allowed"
        }
        if(this._pageNeedCorpus(page)){
            if(!corpus){
                delay(SkE.showToast.bind(null, _("msg.selectCorpusFirst")), 500)
                page = "corpus"
            } else{
                if(corpus.isCompiled){
                    if(pageFeature && !AppStore.hasCorpusFeature(pageFeature)){
                        delay(SkE.showToast.bind(null, _("msg.corpusHasNotThisFeature")), 500)
                        page = "dashboard"
                    }
                } else if(corpus.isReady){
                    delay(SkE.showToast.bind(null, _("msg.corpusNeedsCompile")), 500)
                    page = "ca-compile"
                } else if (corpus.isCompiling){
                    delay(SkE.showToast.bind(null, _("msg.corpusIsCompiling")), 500)
                    page = "ca-compile"
                } else if(corpus.isEmpty){
                    delay(SkE.showToast.bind(null, _("msg.corpusIsEmpty")), 500)
                    page = "dashboard"
                }
            }
        }
        return page
    }

    _onAppReady(){
        // user is logged and corpus is loaded (if there is specified corpus)
        this._initPage()
    }

    _pageNeedCorpus(pageId){
        // page is feature -> it needs corpus
        return !!this._getPageFeature(pageId)
    }

    _getPageActualMeta(){
        return RoutingMeta.table[this._actualPage]
    }

    _getPageFeature(pageId){
        let meta = RoutingMeta.table[pageId]
        return meta ? meta.feature : null
    }

    _initPage(){
        let corpus = AppStore.getActualCorpus()
        let page = this._getPageFromUrl() || (corpus ? "dashboard" : "corpus")
        this._checkAndSetPage(page, this._getActualQuery())
    }

    _getPageFromUrl(url){
        // returns ID of page in param url if provided or in address bar
        return (url || window.location.href).split("?")[0].split("#")[1]
    }

    _getUrlBase(){
        return window.location.href.split("?")[0].split("#")[0]
    }

    _getActualQuery(){
        // returns object of parameters in url (?param=value&param2=value2 => {param:value, param2:value2})
        let query = route.query()
        for(let key in query){
            query[key] = decodeURIComponent(query[key])
        }
        return query
    }

    _getQueryFromString(str){
        let queryObject = {}
        let idx = str.indexOf("?")
        let queryStr = idx != -1 ? str.substring(idx + 1) : str
        // queryStr - everything after first "?"
        if(queryStr && queryStr.indexOf("=") != -1){
            queryStr.split('&').forEach(part => {
                let pair = part.split('=')
                queryObject[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
            })
        }
        return queryObject
    }

    _getStringFromQuery(query){
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

    _setDocumentTitle(){
        document.title =  [this.getActualPageLabel(), "Sketch Engine"].join(" | ")
    }
}

export let Router = new RouterClass()
