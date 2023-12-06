<wordlist-criteria class="wordlist-criteria">
    <div class="row mb-0 relative">
        <div class="col s12">
            <label>&nbsp;</label>
        </div>
        <div class="col s12" if={!showCriteriaList}>
            <div if={options.criteria.length || hasFilterListActiveOption} class="{hasCriteria:options.criteria.length}">
                <div each={criterion in options.criteria} class="chip black-text" onclick={onCriterionClick} key={criterion.filter}>
                    <i class="material-icons close" onclick={onRemoveCriterionClick}>close</i>
                    {_(criterion.filter)}
                    <span if={criterion.value}>"{parent.getCriterionValue(criterion.value)}"</span>
                </div>
                <div if={options.criteria.length && hasFilterListActiveOption} class="input-field inline-block">
                    <a id="btnAddCriterion"
                        class="btn-floating"
                        onclick={onAddCriterionClick}>
                        <i class="material-icons">add</i>
                    </a>
                </div>
            </div>

            <div if={options.criteria.length > 1}>
                <span>{_("wl.criteriaJoinBefore")}</span>
                <ui-select inline=1
                    options={operatorSelectOptions}
                    on-change={onCriteriaOperatorChange}
                    name="criteriaOperator"
                    value={options.criteriaOperator}
                    style="margin-bottom: 10px;"></ui-select>
                <span>{_("criteriaJoinAfter")}</span>
            </div>
        </div>

        <div if={showCriteriaList || !options.criteria.length} class="row">
            <div class="col" style="min-width: 270px;">
                <a if={options.criteria.length}
                    id="btnCloseCriteriaList"
                    class="closeList btn btn-floating btn-flat"
                    onclick={onCloseListClick}>
                    <i class="material-icons text-darken-1 grey-text">close</i>
                </a>
                <ui-list options={filterList}
                    ref="filter"
                    disabled={opts.disabled}
                    value={options.filter}
                    name="filter"
                    on-change={onFilterChange}
                    style="max-width: 250px;"></ui-list>
            </div>
            <div class="col" style="min-width: 265px;">
                <ui-textarea if={showKeyword && options.filter != "regex"}
                    placeholder={_("abc")}
                    class="left criteria-keyword"
                    name="keyword"
                    required=true
                    validate=true
                    value={options.keyword}
                    on-input={onKeywordInput}
                    on-submit={onCriterionSubmitClick}></ui-textarea>
                <expandable-textarea if={showKeyword && options.filter == "regex"}
                        monospace=1
                        placeholder=".*v.*"
                        class="left criteria-keyword"
                        name="keyword"
                        required=true
                        validate=true
                        value={options.keyword}
                        on-input={onKeywordInput}
                        on-change={update}
                        on-submit={onCriterionSubmitClick}
                        rows=1
                        dialog-title={_("matchingRegex")}
                        style="margin-right: 10px;"></expandable-textarea>
                <expandable-textarea if={options.filter == "fromList"}
                        class="left"
                        name="wlfile"
                        required=true
                        validate=true
                        value={options.wlfile}
                        label={_("wl.pasteListHere")}
                        on-input={onWlfileInput}
                        on-change={update}
                        rows=1
                        tooltip="t_id:wl_a_from_list"
                        dialog-title={_("fromList")}
                        style="width: 220px; margin-right: 10px;"></expandable-textarea>
                <div class="clearfix"></div>
                <div if={options.filter == "regex"}>
                    <insert-characters ref="characters"
                            characters={characterList}
                            field=".criteria-keyword textarea"
                            on-insert={onCharacterInsert}></insert-characters>
                    <a if={options.find == "tag"}
                            href="javascript:void(0);"
                            class="btn white-text vertical-top"
                            onclick={onTagsHelpClick}>{_("tagP")}</a>
                    <br>
                    <a href={externalLink("regexManual")} target="_blank">
                        {_("help")}
                        <i class="material-icons inlineIcon">open_in_new</i>
                    </a>
                </div>
                <div class="input-field center-align">
                    <a class="btn"
                        if={showKeyword && options.filter != "regex"}
                        id="btnAddCriterionSubmit"
                        onclick={onCriterionSubmitClick}>
                        {_(isEditingCriterion ? "ok" : "wl.addMultipleCriteria")}
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./wordlist-criteria.scss")
        const Meta = require("./Wordlist.meta.js")

        this.mixin("feature-child")

        this.showCriteriaList = false
        this.hasFilterListActiveOption = false
        this.filterList = this.store.getFilterList("advanced")
        this.isEditingCriterion = false // if user clicked criterion to edit it

        this.operatorSelectOptions = [{
            label: "all",
            value: Meta.operators.AND
        }, {
            labelId: "any",
            value: Meta.operators.OR
        }]

        this.characterList = ["[]", "{}", "|", "^", "\\"]

        isFilterOptionDisabled(option){
            let selectedFilters = new Set()
            this.options.criteria.forEach((criterion) => {
                selectedFilters.add(criterion.filter)
            })
            const forbiddenPairs = [["regex", "startingWith"], ["regex", "endingWith"], ["regex", "containing"]]
            return selectedFilters.has(option) //is already selected
                    || ((option == "all" || option == "fromList") && selectedFilters.size > 0) // cannot be combinet with anything else
                    || option == "fromList" && this.options.exclude
                    || forbiddenPairs.some((pair) => {
                        return (option == pair[0] && selectedFilters.has(pair[1]))
                                || option == pair[1] && selectedFilters.has(pair[0])
                    })
        }

        refreshFilterList(){
            this.hasFilterListActiveOption = false
            this.filterList.forEach((item) => {
                if(this.isFilterOptionDisabled(item.value)){
                    item.disabled = true
                } else{
                    this.hasFilterListActiveOption = true
                    delete item.disabled
                }
            })
        }

        getCriterionValue(value){
            return value.length > 30 ? value.substr(0, 30) + "..." : value
        }

        updateAttributes(){
            this.options = this.parent.options
            const filterMeta = Meta.filters[this.options.filter]
            this.showKeyword = filterMeta ? filterMeta.keyword : false
            this.refreshFilterList()
        }
        this.updateAttributes()

        onRemoveCriterionClick(evt){
            evt.stopPropagation()
            let filter = evt.item.criterion.filter
            this.options.criteria = this.options.criteria.filter((c) => {
                return c.filter != filter
            })
            this.update()
        }

        onAddCriterionClick(){
            this.showCriteriaList = true
        }

        onCloseListClick(evt){
            this.showCriteriaList = false
            if(this.isEditingCriterion){
                evt.preventUpdate = true
                this.onCriterionSubmitClick()
            }
        }

        onCriterionSubmitClick(){
            // add selected filter and keyword to criteria list
            if(this.options.keyword !== ""){
                this.showCriteriaList = false
                this.options.criteria.push({
                    filter: this.options.filter,
                    value: this.options.keyword
                })
                this.options.filter = "all"
                this.options.keyword = ""
                this.isEditingCriterion = false
                this.update()
            }
        }

        onFilterChange(filter, name){
            this.options.filter = filter || "all"
            if(filter != "fromList"){
                this.options.wlfile = ""
            }
            if(filter == "regex"){
                this.options.wlicase = false
                this.options.include_nonwords = true
            }
            if (filter == "all") {
                this.options.include_nonwords = false
            }
            this.parent.update()
            this.focusInput()
        }

        onWlfileInput(wlfile){
            this.options.wlfile = wlfile
            this.parent.refreshSearchButtonDisable()
        }

        onCriteriaOperatorChange(operator){
            this.options.criteriaOperator = operator
        }

        onKeywordInput(keyword){
            keyword = keyword.trim()
            let change = !keyword != !this.options.keyword
            this.options.keyword = keyword
            if(change){ // only if keyword changes from empty string to non empty string or vice versa
                this.parent.turnOnIncludeNonwords(this.options.keyword)
                this.updateAddCriterionButtonDisabled()
                this.parent.refreshSearchButtonDisable()
            }
        }

        onCriterionClick(evt){
            this.options.filter = evt.item.criterion.filter
            this.options.keyword = evt.item.criterion.value
            this.showCriteriaList = true
            this.isEditingCriterion = true
            this.onRemoveCriterionClick(evt) // calls update()
            this.focusInput()
        }

        onCharacterInsert(character, value){
            this.options.keyword = value
            this.parent.refreshSearchButtonDisable()
        }

        onTagsHelpClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                tag: "tags-dialog",
                opts:{
                    wposlist: this.corpus.wposlist,
                    tagsetdoc: this.corpus.tagsetdoc,
                    onTagClick: function(tag){
                        this.refs.characters.insert(tag)
                        Dispatcher.trigger("closeDialog")
                        this.update()
                    }.bind(this)
                },
                small: true,
                fixedFooter: true
            })
        }

        updateAddCriterionButtonDisabled(){
            let disabled = this.options.filter == ""
                || this.options.filter == "all"
                || (this.showKeyword && this.options.keyword == "")
            $("#btnAddCriterionSubmit").toggleClass("disabled", disabled)
        }

        focusInput(){
            delay(() => {
                $("input[name=\"keyword\"], textarea[name=\"wlfile\"], .searchBtn .btn", ".wordlist-tab-advanced").first().focus()
            }, 10)
        }

        this.on("updated", this.updateAddCriterionButtonDisabled)
        this.on("update", this.updateAttributes)
        this.on("mount", this.focusInput)
    </script>
</wordlist-criteria>
