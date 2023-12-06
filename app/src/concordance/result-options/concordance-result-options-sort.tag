<concordance-result-options-sort class="concordance-result-options-sort">
    <external-text text="conc_r_sort"></external-text>
    <br>
    <div class="sortContainer">
        <label if={!data.sort.length} class="sortLabel">{_("cc.sortBy")}:</label>
        <div if={data.sort.length} class="currentSorts">
            <div each={sort, idx in data.sort} class="sortLine">
                <label if={idx == 0} class="sortLabel">{_("cc.sortFirstBy")} </label>
                <label if={idx > 0} class="sortLabel">{_("cc.andThenBy")} </label>
                <span class="chip">
                    <i class="close material-icons" onclick={onRemoveClick}>close</i>
                    <span class="context">
                        <span each={i, idx in Array(7)} class={active: ((sort.ctx * 1 * (corpus.righttoleft ? -1 : 1) + 3) == idx)}></span>
                    </span>
                    <span class="sortAttr">{sort.attr} </span>
                    <span class="sortParams">
                        {parent.getSortParams(sort)}
                    </span>
                </span>
            </div>
        </div>
        <div if={!showForm} class="center-align">
            <a id="btnAddSortShow" class="waves-effect waves-light btn btn-smalltext" onclick={onAddClick}>
                {_("cc.addNextCriterion")}
            </a>
        </div>

        <div if={showForm} class="sortForm">
            <context-selector range=3
                name="spos"
                on-change={onOptionChange}
                disabled={contextSelectorDisabled}
                tooltip="t_id:conc_r_sort_context"
                riot-value={spos}></context-selector>
            <br>
            <div class="sortOptions">
                <ui-filtering-list name="attr"
                    label={_("sortAttribute")}
                    inline=1
                    value={attr}
                    options={attrList}
                    on-change={onAttrChange}
                    open-on-focus={true}
                    deselect-on-click={false}
                    value-in-search={true}
                    tooltip="t_id:conc_r_sort_attribute"
                    floating-dropdown={true}></ui-filtering-list>
                <br><br>
                <ui-checkbox name="icase"
                    if={!corpus.unicameral}
                    label-id="ignoreCase"
                    tooltip="t_id:conc_r_sort_icase"
                    on-change={onOptionChange}></ui-checkbox>
                <ui-checkbox name="bward"
                    label-id="retrograde"
                    name="bward"
                    tooltip="t_id:conc_r_sort_retrograde"
                    on-change={onOptionChange}></ui-checkbox>
            </div>

            <div class="center-align">
                <a id="btnAddSortSubmit" class="waves-effect waves-light btn btn-smalltext tooltipped"
                    disabled={!isValid}
                    onclick={onAddSubmitClick}
                    data-tooltip="t_id:conc_r_sort_addcrit">
                    {_("cc.addMultipleSorting")}
                </a>
            </div>
        </div>
    </div>

    <div class="buttonGo">
        <a id="btnGoSort" class="{disabled: !data.sort.length && !isValid} btn contrast" onclick={onSortClick}>{_("go")}</a>
    </div>

    <script>
        require("./concordance-result-options-sort.scss")
        require("concordance/context-selector/context-selector.tag")

        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.attr = "word"
        this.attrList = [].concat(this.store.attrList, this.store.refList)
        this.spos = "0"
        this.bward = false
        this.icase = false
        this.showForm = !this.data.sort.length
        this.contextSelectorDisabled = false

        getSortParams(sort){
            let arr = []
            sort.icase && arr.push(_("icase"))
            sort.bward && arr.push(_("retrograde"))
            let str = arr.join(", ")
            return str ? `(${str})` : ""
        }

        getValue(){
            let skey = "kw"
            let rtl = this.corpus.righttoleft
            if(this.spos != 0){
                skey = (this.spos < 0 && !rtl || this.spos > 0 && rtl) ? "lc" : "rc"
            }
            return {
                skey: skey,
                attr: this.attr,
                ctx: this.spos * (rtl ? -1 : 1) + "",
                bward: !!this.bward ? "r" : "",
                icase: !!this.icase ? "i" : ""
            }
        }

        updateAttributes(){
            this.contextSelectorDisabled = !AppStore.getAttributeByName(this.attr)
            if(this.contextSelectorDisabled){
                this.spos = 0
            }
            this.isValid = !!(this.attr && (this.contextSelectorDisabled || this.spos !== null))
        }
        this.updateAttributes()

        onAttrChange(value){
            this.attr = value
            this.update()
        }

        onOptionChange(value, name){
            this[name] = value
        }

        onSortClick(){
            if(this.isValid){
                if(this.showForm){
                    this.data.sort.push(this.getValue())
                }
                this.store.searchAndAddToHistory({
                    sort: this.data.sort,
                    page: 1
                })
            }
        }

        onAddSubmitClick(){
            this.data.sort.push(this.getValue())
            this.showForm = false
        }

        onAddClick(){
            this.showForm = true
            delay(() => {
                $("#sortCancelBtn", this.root).show()
                $(".sortForm", this.root).addClass("z-depth-3")
            }, 0)
        }

        onRemoveClick(sort){
            this.data.sort = this.data.sort.filter(s => {
                return !objectEquals(s, sort.item.sort)
            })
            if(!this.data.sort.length){
                this.showForm = true;
            }
        }

        this.on("update", this.updateAttributes)
    </script>
</concordance-result-options-sort>
