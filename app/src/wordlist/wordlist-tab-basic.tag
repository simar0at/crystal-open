<wordlist-tab-basic class="wordlist-tab-basic">
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")} class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons dark">settings_backup_restore</i>
    </a>
    <div class="card-content">
        <div class="row">
            <div class="col l1 m2 s12">
                <span class="columnShow">
                    <span class="tooltipped" data-tooltip="t_id:wl_b_find">
                        {_("find")}
                        <sup>?</sup>
                    </span>
                </span>
            </div>
            <div class="col l4 m4 s12">
                <ui-list options={findList}
                    riot-value={options.find}
                    name="find"
                    on-change={onFindChange}
                    style="max-width: 250px;"></ui-list>
            </div>

            <div class="col l4 m4 s12">
                <ui-list options={filterList}
                    riot-value={options.filter}
                    name="filter"
                    on-change={onFilterChange}
                    style="max-width: 250px;"></ui-list>
            </div>
            <div class="col l3 m2 s12" if={typeof options.filter != "undefined" && options.filter != "all"}>
                <ui-input placeholder={_("abc")}
                    id="keyword"
                    name="keyword"
                    required=true
                    validate=true
                    riot-value={options.keyword}
                    on-input={onKeywordInput}
                    on-submit={onSearch}
                    style="max-width: 100px;" ></ui-input>
            </div>
        </div>

        <div class="searchBtn center-align">
            <a id="btnGoBasic" class="waves-effect waves-light btn contrast" disabled={data.isLoading} onclick={onSearch}>{_("go")}</a>
        </div>
    </div>

    <script>
        require("./wordlist-tab-basic.scss")
        const Meta = require("./Wordlist.meta.js")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.filterList = this.store.getFilterList("basic")

        const lposList = this.corpus.lposlist || []
        const attributes = this.corpus.attributes || []
        const showFirst = ["word", "lemma"]
        this.findList = []
        attributes.forEach((attr) => {
            if(!attr.isLc && showFirst.indexOf(attr.label) != -1){
                this.findList.push({
                    type: "attr",
                    label: attr.labelP || attr.label,
                    value: attr.name
                })
            }
        })

        lposList.forEach((lpos) => {
            this.findList.push({
                type: "lpos",
                label: lpos.labelP || lpos.label,
                value: lpos.value
            })
        })

        updateAttributes(){
            this.options = {
                find: this.data.find,
                filter: this.data.filter,
                keyword: this.data.keyword,
                include_nonwords: AppStore.data.wattrs.indexOf(this.data.find) >= 0 ? 0 : 1
            }
        }
        this.updateAttributes()

        onSearch(){
            if (this.options.keyword) this.options.include_nonwords = 1
            this.options.page = 1
            this.store.resetSearchAndAddToHistory(this.options)
        }

        onResetClick(){
            this.store.resetGivenOptions(this.options)
        }

        onFindChange(value, name, label, option){
            this.options.find = value || "word"
            this.update()
        }

        onFilterChange(value){
            this.options.filter = value || Meta.filters.all.value
            if(value == "all"){
                this.options.keyword = ""
            }
            this.update()
            this.refreshSearchButtonDisable()
            this.focusInput()
        }

        onKeywordInput(value){
            this.options.keyword = value
            this.refreshSearchButtonDisable()
        }

        refreshSearchButtonDisable(options){
            let filter = isDef(this.options.filter) ? this.options.filter : this.data.filter
            let keyword = isDef(this.options.keyword) ? this.options.keyword : this.data.keyword
            $("#btnGoBasic").toggleClass("disabled", !!(Meta.filters[filter].keyword && keyword === ""))
        }

        focusInput(){
            delay(() => {
                $("input[name=\"keyword\"]:visible, .searchBtn .btn", this.root).first().focus()
            }, 0)
        }

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

        this.on("mount", () => {
            this.focusInput()
            this.refreshSearchButtonDisable()
            // nutne, pro setDataFromUrl - stranka je namountovana (prvni obsluha
            // ROUTER_CHANGE v page-router.tag), druhe volani je ve
            // FeatureStoreMixin _onPageChange
            this.store.on("change", this.dataChanged)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</wordlist-tab-basic>
