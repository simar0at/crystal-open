const {Connection} = require('core/Connection.js')
const {AppStore} = require("core/AppStore.js")
const {StoreMixin} = require("core/StoreMixin.js")

class TextTypesStoreClass {
    constructor() {
        riot.observable(this)

        this.data = {
            isTextTypesLoading: false,
            isTextTypesLoaded: false,
            hasTextTypes: false,
            textTypes: [],
            openToolbar: false
        }
        this.corpname = AppStore.getActualCorpname()

        AppStore.on("corpusChanged", this._onCorpusChanged.bind(this))
    }

    getTextType(textTypeName){
        return this.data.textTypes.find((tt) => {
            return tt.name == textTypeName
        })
    }

    getQueryFromTextTypes(selection){
        let query = {}
        for(let textType in selection){
            if(selection[textType][0].startsWith("%RE%")){
                query["fsca_"+ textType] = selection[textType][0].substring(4)
            } else{
                query["sca_"+ textType] = selection[textType]
            }
        }
        return query
    }

    loadTextTypes(force) {
        let corpname = AppStore.getActualCorpname()
        if (!corpname || (!force && (this.data.isTextTypesLoaded || this.data.isTextTypesLoading))) {
            return
        }
        this.data.isTextTypesLoading = true
        return Connection.get({
            url: window.config.URL_BONITO + "texttypes_with_norms",
            data: {
                corpname: corpname
            },
            done: (payload) => {
                // list of all text types loaded
                // {Blocks: [{Line: [{Values:[], name:, ...]}]

                this.data.isTextTypesLoaded = true
                this.data.textTypes = []
                if (!isDef(payload.error)) {
                    payload.Blocks.forEach((block) => {
                        block.Line.forEach((line) => {
                            if (isDef(line.textboxlength)) {
                                // initialize dynamic loaded textypes
                                Object.assign(line, {
                                    dynamic: true,
                                    avmaxitems: 15,
                                    avfrom: 0,
                                    filter: "",
                                })
                            } else {
                                line.dynamic = false
                            }
                            this.data.textTypes.push(line)
                        })
                    })
                } else {
                    SkE.showError(_("textTypesLoadFail", [payload.error]))
                }
                this.data.hasTextTypes = this.data.textTypes.length
                !isDef(payload.error) && this.trigger("textTypesLoaded", this.data.textTypes)
            },
            always: () => {
                this.data.isTextTypesLoading = false
                this.trigger("listChanged")
            },
            fail: payload => {
                SkE.showError(_("textTypesLoadFail", [payload.error]))
            }
        }).xhr
    }

    loadTextType(textTypeName, textTypeObj) {
        textTypeObj = textTypeObj || {}
        return Connection.get({
            url: window.config.URL_BONITO + "attr_vals",
            textTypeName: textTypeName,
            data: {
                corpname: AppStore.getActualCorpname(),
                avattr: textTypeName,
                avmaxitems: textTypeObj.avmaxitems || 10000,
                avfrom: textTypeObj.avfrom || 0,
                avpat: textTypeObj.filter || ".*",
                icase: isDef(textTypeObj.matchCase) ? !textTypeObj.matchCase : true,
                ajax: 1
            },
            fail: payload => {
                SkE.showError("Could not load text type", payload.error)
            }
        }).xhr
    }


    _onCorpusChanged() {
        this.corpname = AppStore.getActualCorpname()
        this.data.isTextTypesLoaded = false
        this.loadTextTypes()
    }
}

export let TextTypesStore = new TextTypesStoreClass()
