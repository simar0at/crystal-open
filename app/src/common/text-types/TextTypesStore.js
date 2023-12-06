const {Connection} = require('core/Connection.js')
const {AppStore} = require("core/AppStore.js")
const {StoreMixin} = require("core/StoreMixin.js")

class TextTypesStoreClass extends StoreMixin {

    constructor(){
        super()

        this.data = {
            isTextTypesLoading: false,
            isTextTypesLoaded: false,
            hasTextTypes: false,
            disabled: false,
            textTypes: [],
            selection: {},
            detail: null
        }

        Dispatcher.on("ROUTER_CHANGE", this.reset.bind(this))
        AppStore.on("corpusChanged", this._onCorpusChanged.bind(this))
    }

    getTextType(textTypeName){
        return this.data.textTypes.find((tt) => {
            return tt.name == textTypeName
        })
    }

    getSelection(textTypeName){
        // retun selected items of one specified texttype
        return this.data.selection[textTypeName] ? this.data.selection[textTypeName].slice() : []
    }

    getSelectionQuery(){
        let query = {}
        let selection = this.data.selection
        for(let textType in selection){
            if(selection[textType][0].startsWith("%RE%")){
                query["fsca_"+ textType] = selection[textType][0].substring(4)
            } else{
                query["sca_"+ textType] = selection[textType]
            }
        }
        return query
    }

    getTextTypeOptionsList(textTypeName){
        // return list of loaded options of given text type. Used for lists - select
        // from which user choose text types
        let options = []
        let textTypeObj = this.getTextType(textTypeName)
        if(textTypeObj.Values){
            if(textTypeObj.hierarchical){
                this._addHierarchicalTextTypesToOptionsList(textTypeObj, textTypeObj.Values, options, "", 0)
            } else{
                textTypeObj.Values.forEach((value) => {
                    // dont show selected texttypes in textype list
                    if(!this._isItemSelected(textTypeName, value.v)){
                        options.push({
                            label: value.v,
                            value: value.v
                        })
                    }
                })
            }
        }
        return options
    }

    _addHierarchicalTextTypesToOptionsList(textTypeObj, values, options, parentValue, level){
        Object.keys(values).sort((a,b) => {return a.localeCompare(b)}).forEach(key => {
            let value = (parentValue ? (parentValue + textTypeObj.hierarchical) : "") + key
            if(!this._isItemSelected(textTypeObj.name, value)){
                let label = (level > 0 ? "└ " : "") + key
                if($.isEmptyObject(values[key])){
                    options.push({
                        label: label,
                        value: value,
                        class: "level_" + level
                    })
                } else{
                    options.push({
                        label: label,
                        value: value,
                        class: "level_" + level,
                        parent: 1
                    })
                    this._addHierarchicalTextTypesToOptionsList(textTypeObj, values[key], options, value, level + 1)
                }
            }
        }, this)
    }

    setDisabled(disabled){
        this.data.disabled = disabled
        if(disabled){
            this.data.textTypes.forEach(tt => {
                tt.expanded = false
            })
        }
        this.trigger("change")
    }

    loadTextTypes(){
        if(this.data.isTextTypesLoaded || this.data.isTextTypesLoading){
            return
        }
        this._changeListLoading(true)

        Connection.get({
            url: window.config.URL_BONITO + "texttypes_with_norms",
            query: {
                corpname: AppStore.getActualCorpname()
            },
            done: this._onChangeListLoaded.bind(this),
            always: this._changeListLoading.bind(this, false)
        })
    }

    loadTextType(textTypeName){
        const textTypeObj = this.getTextType(textTypeName)
        if(textTypeObj.isLoading){
            return
        }

        this._onChangeOneLoading(textTypeName, true)
        Connection.get({
            url: window.config.URL_BONITO + "attr_vals",
            textTypeName: textTypeName,
            query: {
                corpname: AppStore.getActualCorpname(),
                avattr: textTypeName,
                avmaxitems: textTypeObj.avmaxitems,
                avfrom: textTypeObj.avfrom,
                avpat: textTypeObj.filter || "",
                ajax: 1
            },
            done: this._onChangeOneLoaded.bind(this),
            fail:(payload, request) => {
                this._onChangeOneLoading(request.textTypeName, false)
            }
        })
    }

    addTextType(textTypeName, value){
        let textTypeObj = this.getTextType(textTypeName)
        let values = Array.isArray(value) ? value : [value]
        this._onSelectionAdd(textTypeName, values)
        // after each selection there is less items in list. Make sure, there is no
        // less items than 15
        if(textTypeObj.dynamic && this.getTextTypeOptionsList(textTypeName).length < 15){
            this.loadMoreTextType(textTypeName)
        }
        this.trigger("textTypeChange", this.getTextType(textTypeName))
        this.trigger("selectionChange", this.data.selection)
    }

    removeTextType(textTypeName, value){
        this._onSelectionRemove(textTypeName, value)
        this.trigger("textTypeChange", this.getTextType(textTypeName))
        this.trigger("selectionChange", this.data.selection)
    }

    changeTextType(textTypeName, valueObj){
        this._onChangeOne(textTypeName, valueObj)
    }

    toggleDetail(textType){
        this.data.detail = textType ? textType : null
        this.trigger("change", this.data.textTypes)
    }

    toggleExpand(textTypeName){
        let textTypeObj = this.getTextType(textTypeName)
        this._onChangeOne(textTypeName, {
            expanded: !textTypeObj.expanded
        })

        if(textTypeObj.expanded && textTypeObj.dynamic && !textTypeObj.Values){
            this.loadTextType(textTypeName)
        }
    }

    toggleExpandAll(expanded){
        this.data.textTypes.forEach((textTypeObj) => {
            textTypeObj.expanded = expanded
        })
        this.trigger("change", this.data.textTypes)
    }

    setSelection(selection){
        this.data.selection = selection
        this.trigger("change", this.data.textTypes)
    }

    reset(){
        this._onReset()
        this.trigger("selectionChange", this.data.selection)
    }

    loadMoreTextType(textTypeName){
        const textTypeObj = this.getTextType(textTypeName)
        if(!textTypeObj.no_more_values){
            this._onChangeOne(textTypeName, {
                avfrom: textTypeObj.avfrom + textTypeObj.avmaxitems
            })
            this.loadTextType(textTypeName)
        }
    }

    _isItemSelected(textTypeName, item){
        // return true, if item is in selection of given textType
        let selection = this.data.selection[textTypeName]
        if(selection){
            return selection.includes(item)
        }
        return false
    }

    _onCorpusChanged(){
        this.data.isTextTypesLoaded = false
        this.loadTextTypes()
        this._onReset()
    }

    _onReset(){
        this.data.selection = {}
        this.data.detail = null
        this.data.disabled = false
        this.data.textTypes.forEach((textType) => {
            delete textType.filter
            delete textType.expanded
        })
        this.trigger("change")
    }

    _changeListLoading(loading){
        // changed loading of list of all text types
        this.data.isTextTypesLoading = loading
        this.trigger("change")
    }

    _onChangeListLoaded(payload){
        // list of all text types loaded
        // {Blocks: [{Line: [{Values:[], name:, ...]}]

        this.data.isTextTypesLoaded = true
        this.data.textTypes = []
        if(!isDef(payload.error)){
            payload.Blocks.forEach((block) => {
                block.Line.forEach((line) => {
                    if(isDef(line.textboxlength)){
                        // initialize dynamic loaded textypes
                        Object.assign(line, {
                            dynamic: true,
                            avmaxitems: 15,
                            avfrom: 0,
                            filter: "",
                        })
                    } else{
                        line.dynamic = false
                    }
                    this.data.textTypes.push(line)
                })
            })
        }
        this.data.hasTextTypes = this.data.textTypes.length
        !isDef(payload.error) && this.trigger("textTypesLoaded", this.data.textTypes)
        this.trigger("change", this.data.textTypes)
    }

    _onChangeOneLoading(textTypeName, loading){
        let textTypeObj = this.getTextType(textTypeName)
        textTypeObj.isLoading = loading
        this.trigger("textTypeChange", textTypeObj)
    }

    _onChangeOneLoaded(payload, request){
        // data for one specific text type loaded. When items in tt are dynamically
        // loaded, results are added to end of list of values (tt.Values)
        let textTypeObj = this.getTextType(request.textTypeName)
        if(!textTypeObj.Values){
            textTypeObj.Values = []
        }
        payload.suggestions.forEach((value) => {
            textTypeObj.Values.push({
                v: value
            })
        })
        textTypeObj.no_more_values = payload.no_more_values
        this._onChangeOneLoading(request.textTypeName, false) // triggers textTypeChange

    }

    _onSelectionAdd(textTypeName, values){
        // user clicked on text type value - > add to list of selected
        // value - array of text type values
        let selection =  this.getSelection(textTypeName) || []
        selection = selection.concat(values)
        this.data.selection[textTypeName] = selection
    }

    _onSelectionRemove(textTypeName, value){
        let selection =  this.getSelection(textTypeName) || []
        let values = Array.isArray(value) ? value : [value]
        selection = selection.filter((tt) => {
            return !values.includes(tt)
        })
        if(selection.length){
            this.data.selection[textTypeName] = selection
        } else{
            delete this.data.selection[textTypeName]
        }
    }

    _onChangeOne(textTypeName, valueObj){
        const textType = this.getTextType(textTypeName)
        if(isDef(valueObj.filter) && textType.filter != valueObj.filter){
            textType.Values = []
            textType.avmaxitems = 50
            textType.avfrom = 0
            textType.filter = valueObj.filter
        } else{
            Object.assign(textType, valueObj)
        }
        this.trigger("textTypeChange", textType)
    }
}

export let TextTypesStore = new TextTypesStoreClass()
