<ui-filtering-list class="ui ui-filtering-list {opts.class}">
    <div class="{floatingDropdown: opts.floatingDropdown, disabled:opts.disabled}">
        <label if={opts.label || opts.labelId}
                ref="label"
                class="label {tooltipped: opts.tooltip}"
                data-tooltip={ui_getDataTooltip()}>
            {getLabel(opts)}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
            <span class="selectedCount" ref="selectedCount">
                <a if={opts.multiple}
                        class="btn btn-floating btn-flat btn-small tooltipped"
                        onclick={onSelectedCountClick}
                        data-tooltip={_("showOnlySelected")}>
                    <i class="material-icons">filter_list</i>
                </a>
                <span ref="count"></span>
            </span>
        </label>
        <filter-input if={opts.showFilterOptions}
                ref="input"
                inline={opts.inline}
                disabled={opts.disabled}
                query={inputValue}
                mode={mode}
                match-case={opts.matchCase}
                on-input={onInput}
                on-click={onInputClick}
                on-change={onFilterChange}></filter-input>
        <ui-input if={!opts.showFilterOptions}
                ref="input"
                inline={opts.inline}
                dynamic-width={opts.dynamicWidth}
                min-width={opts.minWidth}
                riot-value={inputValue}
                white={opts.white}
                disabled={opts.disabled}
                autocomplete={false}
                on-focus={onFocus}
                on-key-up={onKeyUp}
                on-key-down={onKeyDown}
                on-input={onInput}
                on-click={onInputClick}
                no-blur-on-esc={true}
                validate={opts.validate}
                pattern={opts.pattern}
                pattern-mismatch-message={opts.patternMismatchMessage}
                suffix-icon={opts.suffixIcon || "search"}
                on-suffix-icon-click={opts.onSuffixIconClick}
                placeholder={_(opts.placeholder || "ui.typeToSearch")}
                size={opts.size}></ui-input>
        <span ref="listContainer" class={hidden: opts.floatingDropdown}>
            <div class="listWrapper">
                <ui-list ref="list"
                    classes={"z-depth-2": opts.floatingDropdown}
                    name={opts.name}
                    riot-value={opts.riotValue}
                    multiple={opts.multiple}
                    disable-tooltips={opts.disableTooltips}
                    size={opts.listSize}
                    full-height={opts.fullHeight}
                    show-all={opts.showAll}
                    loading={opts.loading}
                    on-scroll-to-bottom={opts.onScrollToBottom}
                    on-show-more={opts.onShowMore}
                    deselect-on-click={opts.deselectOnClick}
                    options={filtered}
                    filter={opts.filter}
                    on-change={onChange}
                    footer-content={opts.footerContent}
                    special-node-text-id={specialNodeTextId}
                    ></ui-list>
            </div>
        </span>
    </div>

    <script>
        this.mixin('ui-mixin')
        this.mixin('tooltip-mixin')

        this.showList = false
        this.isFocused = false
        this.showSelected = false
        this.specialNodeTextId = ""


        getValue(){
            return this.refs.list.value
        }

        filter(){
            this.filtered = []
            if(this.inputValue !== ""){
                this.filtered = this.opts.options.filter((option, idx) => {
                    return this.filterItem(option)
                })
                if(this.opts.addNotFound && this.getOptionIndexByValue(this.inputValue) == -1){
                    this.filtered.push({
                        label: _("addNotFound", [this.opts.notFoundLabel.toLowerCase(), this.inputValue]),
                        class: "addNotFound",
                        value: this.inputValue,
                        addValueOption: true
                    })
                }
            } else{
                this.filtered = this.opts.options
            }
            if(this.opts.addNotFound){
                $(this.refs.list).toggleClass("hidden", !this.filtered.length)
            }
            this.specialNodeTextId = ""
            if(!this.opts.loading && !this.opts.addNotFound){
                if(!this.opts.options.length){
                    this.specialNodeTextId = "empty"
                } else if(!this.filtered.length){
                    this.specialNodeTextId = "nothingFound"
                }
            }
        }

        filterItem(option){
            if(this.opts.filter){
                return this.opts.filter(this.inputValue, option)
            }
            let icase = !this.opts.showFilterOptions || !this.matchCase
            let searchWord = icase ? this.inputValue.toLowerCase() : this.inputValue
            let re = window.getFilterRegEx(searchWord, this.mode)
            let label = this.getLabel(option)
            if(icase){
                label = label.toLowerCase()
            }
            if(label.match(re)){ //search substring or regex
                return true
            }
            if(option.search){
                // additional strings to search in
                return option.search.some((item) => {
                    return item.match(re)
                })
            }
            return false
        }

        open(){
            if(this.opts.floatingDropdown && !this.showList && !this.opts.disabled){
                this.filter()
                this.update()
                this.showList = true
                this.isFocused = true
                document.addEventListener('click', this.handleClickOutside)
                $(this.refs.listContainer).removeClass("hidden")
                this.trigger("open")
            }
        }

        close(){
            if(this.opts.floatingDropdown && this.showList){
                document.removeEventListener('click', this.handleClickOutside)
                this.showList = false
                $(this.refs.listContainer).addClass("hidden")
                $(this.refs.list.root).css({
                    left: "",
                    right: "",
                    listwidth: "",
                    "margin-left": 0,
                    "margin-right": 0
                }).removeClass("wrapLines")
                this.trigger("close")
            }
        }

        onKeyDown(evt){
            evt.preventUpdate = true
            if(this.showSelected){
                this.toggleShowSelected()
            }
            // prevent screen scroll
            this.refs.list.onKeyDown(evt)
            evt.keyCode == 9 && this.onBlur()
        }

        onKeyUp(evt){
            evt.preventUpdate = true
            if(evt.keyCode == 27){ //esc
                this.showList ? this.close() : $("input", this.root).blur()
                return
            }
            let moveKey = [38, 40, 33, 34].includes(evt.keyCode)
            if(moveKey || [13, 32].includes(evt.keyCode)){ // send navigation to list
                moveKey && this.open(evt)
                if(evt.keyCode == 13 && !this.refs.list.isAnyItemSelected() && isFun(this.opts.onSubmit)){
                    // enter without highlighted item in list -> submit value in input
                    evt.stopPropagation()
                    this.opts.onSubmit(this.refs.input.value, this.opts.name, this.evt, this)
                }
                this.refs.list.onKeyUp(evt)
            }
        }

        onInput(value, name, evt){
            this.isValid = this.refs.input.isValid
            this.inputValue = value
            this.open()
            this.filter()
            !this.opts.filter && this.update()
            isFun(this.opts.onInput) && this.opts.onInput(value, this.opts.name, evt, this)
        }

        onInputClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            this.open()
        }

        onFocus(evt){
            evt.preventUpdate = true
            if(!this.isFocused){
                this.isFocused = true
                if(!isDef(this.opts.clearOnFocus) || this.opts.clearOnFocus){
                    this.inputValue = ""
                    this.refs.input.refs.input.value = ""
                }
            }
            this.opts.openOnFocus && this.open()
        }

        onBlur(){
            if(this.isMounted){
                this.isFocused = false
                this.opts.floatingDropdown && this.close()
                this.setValueInSearchIfNeeded()
            }
        }

        onChange(value, name, label, option, evt){
            this.isValid = this.refs.input.isValid
            this.opts.riotValue = value
            !this.opts.multiple && this.onBlur()
            this.refreshCount()
            if (option && option.hasOwnProperty('addValueOption')){
                this.inputValue =  option.addValueOption ? value : label
            }
            this.setValueInSearchIfNeeded()
            isFun(opts.onChange) && opts.onChange(value, name, label, option, evt, this)
        }

        onFilterChange(query, mode, matchCase){
            this.inputValue = query
            this.mode = mode
            this.matchCase = matchCase

            this.filter()
            isFun(this.opts.onFilterChange) && this.opts.onFilterChange(query, mode, matchCase)
            this.update()
        }

        onSelectedCountClick(evt){
            evt.preventUpdate = true
            this.toggleShowSelected()
            this.opts.onShowSelectedChange && this.opts.onShowSelectedChange(evt, this)
        }

        handleClickOutside(evt){
            evt.preventUpdate = true
            if (!this.root.contains(evt.target)){
                this.onBlur(evt)
            }
        }

        updateListPosition(){
            if(!this.showList){
                return
            }
            let node = $(this.refs.list.root)
            let listwidth = node.outerWidth()
            let screenWidth = $(window).width()

            if(listwidth >= screenWidth){
                node.offset({"left": 0})
                node.css({
                    "min-width": screenWidth,
                    right: "unset"
                })
                node.addClass("wrapLines")
            } else{
                let leftOffset = node.offset().left
                let rightOffset = screenWidth - leftOffset - listwidth
                let leftOverlap = leftOffset < 0 ? leftOffset * -1 : 0
                let rightOverlap = rightOffset < 0 ? rightOffset * -1 : 0
                node.css({
                    "min-width": listwidth,
                    "margin-left": -rightOverlap,
                    "margin-right": -leftOverlap
                })
            }
        }

        getOptionIndexByValue(value){
            // return index of option with specific value in array of options
            return this.opts.options.findIndex(o => o.value + "" === value + "")
        }

        setValueInSearchIfNeeded(){
            if(this.opts.valueInSearch){
                if(!this.opts.addNotFound || this.getOptionIndexByValue(this.getValue()) != -1){
                    let value = this.getValueLabel(this.opts.riotValue)
                    this.inputValue = value
                    this.refs.input.refs.input.value = value
                }
            }
        }

        getValueLabel(value){
            return isDef(value) ? this.getLabel(this.opts.options.find(o => {
                return o.value === value
            })) : "" // if value is undefined
        }

        refreshCount(){
            if(this.refs.count && this.opts.multiple){
                this.refs.count.innerHTML = this.opts.riotValue.length ? `(${this.opts.riotValue.length})` : ""
                if(!this.opts.riotValue.length){
                    $(this.refs.list.root).removeClass("showSelected")
                    $(this.refs.selectedCount).removeClass("active").hide()
                } else{
                    $(this.refs.selectedCount).show()
                }
            }
        }

        toggleShowSelected(){
            this.showSelected = !this.showSelected
            $(this.refs.list.root).toggleClass("showSelected", this.showSelected)
            $(this.refs.selectedCount).toggleClass("active", this.showSelected)
        }

        this.inputValue = isDef(this.opts.query) ? this.opts.query : this.getValueLabel(this.opts.riotValue)
        this.mode = this.opts.mode || "containing"
        this.matchCase = isDef(this.opts.matchCase) ? this.opts.matchCase : false
        this.lastValueLabel = this.inputValue
        this.optionsLength = this.opts.options.length


        this.filter()

        this.on("update", () => {
            if(!this.opts.showFilterOptions){
                if(this.opts.options.length != this.optionsLength){
                    // options could be set after mount
                    this.optionsLength = this.opts.options.length
                    let label = this.getValueLabel(this.getValue())
                    if(label !== ""){
                        this.inputValue = label
                        this.refs.input.refs.input.value = this.inputValue
                    }
                }
                let label = this.getValueLabel(this.opts.riotValue)
                if(this.lastValueLabel !== label && label !== ""){
                    this.lastValueLabel = label
                    this.setValueInSearchIfNeeded()
                }
            }
        })

        this.on("update", this.filter)

        this.on("updated", () => {
            this.refreshCount()
            this.updateListPosition()
        })

        this.on("mount", this.refreshCount)
    </script>
</ui-filtering-list>
