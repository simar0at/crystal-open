<text-type-list>
    <ui-filtering-list ref="list"
            show-all=1
            show-filter-options=1
            query={opts.textType.query}
            mode={opts.textType.mode}
            match-case={opts.textType.matchCase}
            options={optionList}
            name={textTypeName}
            loading={opts.textType.isLoading}
            filter={filterFunction}
            on-change={onListChange}
            on-filter-change={onFilterChange}
            on-input={onInput}
            on-scroll-to-bottom={opts.textType.dynamic ? onScrolledToBottom: null}></ui-filtering-list>
    <div if={optionList.length == (hasRegexOption ? 1 : 0) && query !== "" && !opts.textType.isLoading}
            class="emptyContent white">
        <i class="material-icons">space_bar</i>
        <div class="title">{_("nothingFound")}</div>
    </div>

    <script>
        this.textTypesTag = this.parent.textTypesTag
        this.textTypeName = this.opts.textType.name
        this.query = this.opts.textType.query || ""
        this.mode = this.opts.textType.mode || "containing"

        textTypeListFilter(option){
            if(this.query === "" || this.opts.textType.dynamic || option.value.startsWith("%RE%")){
                return true
            }
            let query = this.matchCase ? this.query : this.query.toLowerCase()
            let regex = getFilterRegEx(query, this.mode)
            let label = this.matchCase ? option.label : option.label.toLowerCase()
            return label.match(regex)
        }

        updateAttributes(){
            let modeLabel = {
                'startingWith': 'useAllValuesStartingWith',
                'endingWith': 'useAllValuesEndingWith',
                'containing': 'useAllValuesContaining',
                'matchingRegex': 'useAllMatchingValues'
            }[this.mode];
            this.isEmpty = !this.textTypesTag.getSelection(this.textTypeName).length
            this.optionList = []
            this.hasRegexOption = false
            if(this.query && this.isEmpty && this.mode != "exactMatch"){
                this.optionList = [{
                    generator: () => {
                        return '<span class="useAsRegEx">'
                            + _(modeLabel, ['<b>' + this.query + '</b>'])
                            + '</span>'
                    },
                    value: "%RE%" + (this.matchCase ? "" : "(?i)") + window.getFilterRegEx(this.query, this.mode, true)
                }]
                this.hasRegexOption = true
            }
            let filteredList = this.textTypesTag.getTextTypeOptionsList(this.textTypeName).filter(this.textTypeListFilter)
            this.optionList = this.optionList.concat(filteredList)
        }
        this.updateAttributes()

        getAllOptions(){
            return this.optionList.map((option) => {
                return option.value
            })
        }

        onListChange(value){
            this.textTypesTag.addTextType(this.textTypeName, value)
            this.update()
        }

        onScrolledToBottom(textTypeName){
            this.textTypesTag.loadMoreTextType(textTypeName)
        }

        this.debounceHandle = null
        onInputDebounced(){
            clearTimeout(window.debounceHandle)
            window.debounceHandle = setTimeout(this.changeTextType.bind(this), 500)
        }

        changeTextType(){
            let query = this.matchCase ? this.query : this.query.toLowerCase()
            let valueObj = {
                query: this.query,
                mode: this.mode,
                matchCase: this.matchCase,
                filter: getFilterRegEx(query, this.mode, true)
            }
            if(["filter", "mode", "matchCase"].some(key => {
                return valueObj[key] !== this.opts.textType[key]
            })){
                this.textTypesTag.changeTextType(this.textTypeName, valueObj)
                this.textTypesTag.loadTextType(this.textTypeName)
            }
        }

        onInput(query){
            this.query = query
            this.filter()
        }

        onFilterChange(query, mode, matchCase){
            if(this.query != query || this.mode !== mode || this.matchCase != matchCase){
                this.query = query
                this.mode = mode
                this.matchCase = matchCase
                this.filter()
            }
        }

        filter(){
            if(this.opts.textType.dynamic) {
                this.onInputDebounced()
            } else {
                this.update()
            }
        }

        filterFunction(){
            // disable default filtering
            return true
        }

        this.on("update", this.updateAttributes)
    </script>
</text-type-list>
