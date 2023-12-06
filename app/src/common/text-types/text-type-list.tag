<text-type-list>
    <ui-filtering-list ref="list"
        show-all=1
        options={optionList}
        name={textTypeName}
        loading={opts.textType.isLoading}
        filter={filterFunction}
        on-change={onListChange}
        deselect-on-click={false}
        on-search-word-change={onSearchWordChange}
        on-scroll-to-bottom={opts.textType.dynamic ? onScrolledToBottom: null}></ui-filtering-list>

    <script>
        const {TextTypesStore} = require("./TextTypesStore.js")

        this.textTypeName = opts.textType.name
        this.searchWord = ""

        textTypeListFilter(option){
            if(this.searchWord === "" || this.opts.textType.dynamic || option.value.startsWith("%RE%")){
                return true
            }
            let regex = new RegExp(".*" + this.searchWord.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split(" ").join(".*") + ".*")
            let label = option.label.toLowerCase()
            if(label.indexOf(this.searchWord.toLowerCase()) != -1 || label.match(regex)){ //search substring or regex
                return true
            }
            return false
        }

        updateAttributes(){
            this.isEmpty = !TextTypesStore.getSelection(this.textTypeName).length
            this.optionList = this.searchWord && this.isEmpty ? [{
                generator: () => {
                    return '<span class="useAsRegEx">'
                        + _('useAsRegex', ['<b>' + this.searchWord + '</b>'])
                        + '</span>'
                },
                value: "%RE%" + this.searchWord
            }] : [];
            let filteredList = TextTypesStore.getTextTypeOptionsList(this.textTypeName).filter(this.textTypeListFilter)
            this.optionList = this.optionList.concat(filteredList)
        }
        this.updateAttributes()

        getAllOptions(){
            return this.optionList.map((option) => {
                return option.value
            })
        }

        onListChange(value){
            TextTypesStore.addTextType(this.textTypeName, value)
            this.update()
        }

        onScrolledToBottom(textTypeName){
            TextTypesStore.loadMoreTextType(textTypeName)
        }

        this.debounceHandle = null
        onSearchWordChangedDebounced(){
            TextTypesStore.changeTextType(this.textTypeName, {
                filter: this.refs.list.searchWord,
                isLoading: true
            })
            clearTimeout(window.debounceHandle)
            window.debounceHandle = setTimeout(this.onChangedTextTypeListFilter.bind(this), 500)
        }

        onChangedTextTypeListFilter(){
            TextTypesStore.loadTextType(this.textTypeName)
        }

        onSearchWordChange(searchWord){
            this.searchWord = searchWord
            if(this.opts.textType.dynamic) {
                this.onSearchWordChangedDebounced()
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
