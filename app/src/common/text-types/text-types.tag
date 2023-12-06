<text-types class="text-types">
    <div if={isTextTypesLoadeding}>
        <i>{_("loadingTT")}</i>
        <span class='dotsAnimation'><span>...</span></span>
    </div>

    <div if={opts.note} class="note">
        {opts.note}
    </div>

    <div if={opts.collapsible} class="collapseToggle"
                onclick={onCollapsibleClick}>
        <span class="tooltipped"
                data-position="top"
                data-tooltip="t_id:conc_text_types">
            <span ref="label">
                {_("textTypes")}
            </span>
            <sup>?</sup>
        </span>
        <i ref="arrowIcon" class="material-icons arrow {rotate180: open}">keyboard_arrow_down</i>
    </div>

    <div if={isTextTypesLoaded}
            ref="content"
            class="t_textTypesContent {t_open: !opts.collapsible || open}"
            style="{opts.collapsible && !open ? 'display: none;' : ''}">
        <div if={!detail}>
            <div class="toggleExpand hide-on-small-only {disabled: disabled}" if={textTypes.length > 1}>
                <div>
                    <a onclick={onToggleExpandAllClick.bind(this, true)}>{_("cc.expandAll")}</a>
                    <a onclick={onToggleExpandAllClick.bind(this, false)}>{_("cc.collapseAll")}</a>
                </div>
            </div>
            <div class="textTypesFlexbox">
                <text-type each={textType in textTypes} text-type={textType} ></text-type>
                <div each={x in new Array(10)}></div> <!-- fake divs to fix last row layout -->
            </div>
            <div if={!textTypes.length} class="col s12 grey-text">
                {_("cc.noTextTypes")}
            </div>
        </div>

        <div if={detail} class="shadowOverlay">
            <div ref="dialog" class="card-panel grey lighten-3 fullScreen">
                <text-type-detail text-type={detail}></text-type-detail>
            </div>
        </div>
    </div>

    <div if={isTextTypesLoadeding} class="center-align">
        <preloader-spinner></preloader-spinner>
    </div>

    <script>
        const {TextTypesStore} = require("./TextTypesStore.js")

        require("./text-type.tag")
        require("./text-type-selection.tag")
        require("./text-type-list.tag")
        require("./text-type-detail.tag")
        require("./text-types.scss")


        this.disabled = this.opts.disabled
        this.textTypes = copy(TextTypesStore.data.textTypes)
        this.selection = this.opts.selection || {}
        this.detail = null
        this.open = !this.opts.collapsible || (this.opts.selection && !$.isEmptyObject(this.opts.selection)) || TextTypesStore.data.openToolbar
        this.isTextTypesLoaded = TextTypesStore.data.isTextTypesLoaded
        this.isTextTypesLoading = TextTypesStore.data.isTextTypesLoading
        this.hasTextTypes = TextTypesStore.data.hasTextTypes


        getTextType(textTypeName){
            return this.textTypes.find((tt) => {
                return tt.name == textTypeName
            })
        }

        getSelection(textTypeName){
            // retun selected items of one specified texttype
            return this.selection[textTypeName] ? this.selection[textTypeName].slice() : []
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

        setDisabled(disabled){
            this.disabled = disabled
            if(disabled){
                this.textTypes.forEach(tt => {
                    tt.expanded = false
                })
            }
            this.update()
        }

        setSelection(selection){
            this.selection = selection
            this.update()
            this._updateLabel()
        }

        reset(){
            this._onReset()
            this.onSelectionChange()
            this.update()
        }

        loadTextType(textTypeName){
            const textTypeObj = this.getTextType(textTypeName)
            if(textTypeObj.isLoading){
                return
            }

            this._onChangeOneLoading(textTypeName, true)
            TextTypesStore.loadTextType(textTypeName, textTypeObj)
                    .done(this._onChangeOneLoaded.bind(this, textTypeName))
                    .always(this._onChangeOneLoading.bind(this, textTypeName, false))
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
            this.onSelectionChange()
        }

        removeTextType(textTypeName, value){
            this._onSelectionRemove(textTypeName, value)
            this.trigger("textTypeChange", this.getTextType(textTypeName))
            this.onSelectionChange()
        }

        changeTextType(textTypeName, valueObj){
            this._onChangeOne(textTypeName, valueObj)
        }

        toggleDetail(textType){
            this.detail = textType ? textType : null
            this.update()
            isFun(this.opts.onDetailToggle) && this.opts.onDetailToggle(this.detail)
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

        loadMoreTextType(textTypeName){
            const textTypeObj = this.getTextType(textTypeName)
            if(!textTypeObj.no_more_values && !textTypeObj.isLoading){
                this._onChangeOne(textTypeName, {
                    avfrom: textTypeObj.avfrom + textTypeObj.avmaxitems
                })
                this.loadTextType(textTypeName)
            }
        }

        onTextTypesLoaded(textTypes){
            this.textTypes = copy(textTypes)
            if(textTypes.length){
                textTypes.forEach((tt) => {
                    if(isDef(tt.dynamic) && !tt.Values){
                        this.loadTextType(tt.name)
                    }
                })
            }
            this.update()
        }

        onSelectionChange(){
            this._refreshTextTypesDisabled()
            isFun(this.opts.onChange) && this.opts.onChange(this.selection)
            this._updateLabel()
        }

        onCollapsibleClick(evt){
            evt.preventUpdate = true
            this.toggleOpen()
        }

        toggleOpen(open){
            if(!isDef(open) || open != this.open){
                this.open = isDef(open) ? open : !this.open
                $(this.refs.content).slideToggle(this.open)
                        .toggleClass("t_open", this.open)
                $(this.root).parents(".form").toggleClass("wideForm", this.open)
                $(this.refs.arrowIcon).toggleClass("rotate180", this.open)
            }
        }

        onToggleExpandAllClick(expanded){
            if(!this.disabled){
                this.textTypes.forEach((textTypeObj) => {
                    textTypeObj.expanded = expanded
                })
                this.update()
            }
        }

        _isItemSelected(textTypeName, item){
            // return true, if item is in selection of given textType
            let selection = this.selection[textTypeName]
            if(selection){
                return selection.includes(item)
            }
            return false
        }

        _onTextTypesListChange(){
            this.textTypes = copy(TextTypesStore.data.textTypes)
            this.isTextTypesLoaded = TextTypesStore.data.isTextTypesLoaded
            this.isTextTypesLoading = TextTypesStore.data.isTextTypesLoading
            this.hasTextTypes = TextTypesStore.data.hasTextTypes
            this.update()
        }

        _onReset(){
            this.selection = {}
            this.detail = null
            this.disabled = false
            this.textTypes.forEach((textType) => {
                delete textType.disabled
                delete textType.filter
                delete textType.mode
                delete textType.expanded
                delete textType.matchCase
            })
        }

        _onChangeOneLoading(textTypeName, loading){
            let textTypeObj = this.getTextType(textTypeName)
            textTypeObj.isLoading = loading
            this.trigger("textTypeChange", textTypeObj)
        }

        _onChangeOneLoaded(textTypeName, payload){
            // data for one specific text type loaded. When items in tt are dynamically
            // loaded, results are added to end of list of values (tt.Values)
            let textTypeObj = this.getTextType(textTypeName)
            if(!textTypeObj.Values){
                textTypeObj.Values = []
            }
            payload.suggestions.filter(value => value != "").forEach(value => {
                textTypeObj.Values.push({
                    v: value
                })
            })
            textTypeObj.no_more_values = payload.no_more_values
        }

        _onSelectionAdd(textTypeName, values){
            // user clicked on text type value - > add to list of selected
            // value - array of text type values
            let selection =  this.getSelection(textTypeName) || []
            selection = selection.concat(values)
            this.selection[textTypeName] = selection
        }

        _onSelectionRemove(textTypeName, value){
            let selection =  this.getSelection(textTypeName) || []
            let values = Array.isArray(value) ? value : [value]
            selection = selection.filter((tt) => {
                return !values.includes(tt)
            })
            if(selection.length){
                this.selection[textTypeName] = selection
            } else{
                delete this.selection[textTypeName]
            }
        }

        _onChangeOne(textTypeName, valueObj){
            const textType = this.getTextType(textTypeName)
            let resetValues = ["filter", "mode", "matchCase"].reduce((ret, key) => {
                return ret || (isDef(valueObj[key]) && (textType[key] != valueObj[key]))
            }, false)
            Object.assign(textType, valueObj)
            if(resetValues){
                // new query, not only loading more items
                textType.Values = []
                textType.avmaxitems = 50
                textType.avfrom = 0
            }
            this.trigger("textTypeChange", textType)
        }

        _refreshTextTypesDisabled(){
            if(this.opts.disableStructureMixing){
                let selection = this.selection
                let wasDisabled = false
                let selected = null
                for(selected in selection){
                    break
                }
                this.textTypes.forEach(textType => {
                    wasDisabled = wasDisabled || textType.disabled
                    textType.disabled = selected && (textType.name.split(".")[0] != selected.split(".")[0])
                })
                !wasDisabled != !selected && this.update()
            }
        }
        this._refreshTextTypesDisabled()

        _refreshListsHeight(){
            if(this.refs.dialog){
                let dialog = $(this.refs.dialog)
                let lists = $("ul", this.root)
                let dialogOffset = dialog.offset().top
                let dialogHeight = dialog.height()
                if($(window).width() < 600){
                    let space = dialogOffset + dialogHeight - lists.first().offset().top - 100 //buttons
                    lists.each((idx, elm) => {
                        $(elm).css("max-height", space / 2)
                    })
                } else{
                    lists.each((idx, elm) => {
                        let listOffset = $(elm).offset().top
                        let maxHeight = dialogOffset + dialogHeight - listOffset - 50 // buttons
                        $(elm).css("max-height", maxHeight)
                    })
                }
            }
        }

        _addHierarchicalTextTypesToOptionsList(textTypeObj, values, options, parentValue, level){
            Object.keys(values).sort((a,b) => {return a.localeCompare(b)}).forEach(key => {
                let value = (parentValue ? (parentValue + textTypeObj.hierarchical) : "") + key
                if(!this._isItemSelected(textTypeObj.name, value)){
                    if($.isEmptyObject(values[key])){
                        options.push({
                            label: key,
                            value: value,
                            class: "level_" + level
                        })
                    } else{
                        options.push({
                            label: key,
                            value: value,
                            class: "level_" + level,
                            parent: 1
                        })
                        this._addHierarchicalTextTypesToOptionsList(textTypeObj, values[key], options, value, level + 1)
                    }
                }
            }, this)
        }

        _updateLabel(){
            if(this.refs.label){
                let count = Object.keys(this.selection).length
                this.refs.label.innerHTML = _("textTypes") + (count ? ` (${count})` : "")
            }
        }

        this.on("updated", this._refreshListsHeight)

        this.on("mount", () => {
            TextTypesStore.on("textTypesLoaded", this.onTextTypesLoaded)
            TextTypesStore.on("listChanged", this._onTextTypesListChange.bind(this))
            this._updateLabel()
            TextTypesStore.loadTextTypes()
        })

        this.on("unmount", () => {
            TextTypesStore.off("textTypesLoaded", this.onTextTypesLoaded)
            TextTypesStore.off("listChanged", this._onTextTypesListChange.bind(this))
        })
    </script>
</text-types>
