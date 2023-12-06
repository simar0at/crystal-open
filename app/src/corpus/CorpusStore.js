const {AppStore} = require('core/AppStore.js')
const {StoreMixin} = require("core/StoreMixin.js")
const {Router} = require("core/Router.js")

class CorpusStoreClass extends StoreMixin {

    constructor(){
        super()
        this.data = {
            tab: "basic",
            cat: "all",
            sketches: "0",
            lang: "",
            lang2: "",
            query: "",
            showOld: false
        }
        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))

        this.corpMenuItems = []
        if(!config.READ_ONLY){
            this.corpMenuItems = [
                { type: "delete",   icon: "delete",         labelId: "deleteCorpus"},
                { type: "enlarge",  icon: "add",            labelId: "enlargeCorpus"},
                { type: "manage",   icon: "build",          labelId: "manageCorpus"},
                { type: "share",    icon: "share",          labelId: "share"},
                { type: "download", icon: "cloud_download", labelId: "download"},
                { type: "info",     icon: "info",           labelId: "cp.info"}
            ]
        }
    }

    changeTab(tab) {
        this.data.tab = tab
        Router.updateUrlQuery(this.data)
    }

    sortByName(a, b) {
        return a.name.toLowerCase().localeCompare(b.name.toLowerCase())
    }

    sortBySize(a, b) {
        if (a.sizes && a.sizes.wordcount) {
            if (b.sizes && b.sizes.wordcount) {
                return a.sizes.wordcount > b.sizes.wordcount ? 1 : -1
            }
            return 1
        }
        return -1
    }

    sortByLang(a, b) {
        return a.language_name.localeCompare(b.language_name)
    }

    sort(data, sort){
        let sortFun = {
            size: this.sortBySize,
            name: this.sortByName,
            lang: this.sortByLang
        }[sort.orderBy]
        data.sort(sortFun)
        if (sort.sort == "desc") {
            data.reverse()
        }
        return data
    }

    openDownloadCorpusDialog(corpus){
        Dispatcher.trigger("openDialog", {
            id: "downloadCorpus",
            tag: "ca-corpus-download-dialog",
            opts: {
                corpus: corpus
            },
            title: _("downloadCorpus")
        })
    }

    showCorpMenu(event, listSelector) {
        event.preventUpdate = true
        event.stopPropagation()
        let corpus = event.item.corpus
        $('#tmpMyCorpMenu').remove()
        let listNode = $(event.target).closest('td').attr('data-target', 'tmpMyCorpMenu')
        let menu = $(listSelector).clone().attr('id', 'tmpMyCorpMenu').appendTo('body')

        let noSkeNoCa = window.config.NO_CA || window.config.NO_SKE
        let canManage = corpus.user_can_manage;
        [
            // id        is active                              onclick function
            ["delete",   canManage && !noSkeNoCa,               AppStore.deleteCorpus.bind(AppStore, corpus.id)],
            ["share",    window.permissions["ca-share"],        this.changeCorpusAndGoToPage.bind(this, corpus, "ca-share")],
            ["enlarge",  window.permissions["ca-add-content"],  this.changeCorpusAndGoToPage.bind(this, corpus, "ca-add-content")],
            ["manage",   window.permissions.ca,                 this.changeCorpusAndGoToPage.bind(this, corpus, "ca")],
            ["info",     true,                                  SkE.showCorpusInfo.bind(null, corpus.corpname)],
            ["download", !noSkeNoCa && corpus.user_can_manage,  this.openDownloadCorpusDialog.bind(this, corpus)]
        ].forEach(item => {
            let node = menu.find('[data-item="' + item[0] + '"]')
            if(item[1]){
                node.click(item[2])
            } else {
                node.addClass("disabled")
            }
        })

        $(listNode).dropdown({
            hover: false,
            constrainWidth: false,
            alignment: 'right'
        })
        $(listNode).dropdown('open')
    }

    changeCorpusAndGoToPage(corpus, pageId){
        if(corpus.corpname == AppStore.getActualCorpname()){
            Dispatcher.trigger("ROUTER_GO_TO", pageId)
        } else{
            AppStore.checkAndChangeCorpus(corpus.corpname)
            AppStore.one("corpusChanged", () => {
                Dispatcher.trigger("ROUTER_GO_TO", pageId)
            })
        }
    }

    selectCorpus(corpus){
        AppStore.checkAndChangeCorpus(corpus.corpname)
        AppStore.one('corpusChanged', () => {
            Dispatcher.trigger("ROUTER_GO_TO", "dashboard", {corpname: corpus.corpname})
        })
    }

    highlightOccurrences(data, refs, prefix=""){
        let el, row
        data.forEach(function(c, idx){
            row = refs[prefix + idx + "_r"]
            if(row){
                el = refs[prefix + idx + "_l"];
                el.innerHTML = c.h_lang ? c.h_lang : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')

                el = refs[prefix + idx + "_n"];
                el.innerHTML = c.h_corp ? c.h_corp : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')
            }
        }.bind(this))
    }

    _onPageChange(pageId, query) {
        if (pageId == "corpus") {
            for (let key in query) {
                this.data[key] = query[key] || this.data[key]
            }
            Router.updateUrlQuery(this.data)
        }
    }
}

export let CorpusStore = new CorpusStoreClass()
