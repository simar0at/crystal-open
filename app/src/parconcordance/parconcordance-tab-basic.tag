<parconcordance-tab-basic>
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")} class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons color-blue-800">settings_backup_restore</i>
    </a>
    <div class="parconcordance-tab-basic card-content">
        <div class="row sortContainer">
            <div class="col xl4 l6 m6 s12">
                <div class="inline-block">
                    <ui-input placeholder={_("abc")}
                            label-id="search"
                            class="bigInput mainFormField"
                            riot-value={options.formValue.keyword}
                            name="keyword"
                            on-change={onKeywordChange}
                            on-submit={onSearch}
                            on-input={onInput}
                            help-dialog="parc_b_search">
                    </ui-input>
                </div>
                <ui-filtering-list
                        options={data.corplist}
                        name="corpname"
                        riot-value={store.corpus.corpname}
                        label-id="pc.in"
                        close-on-select={true}
                        value-in-search={true}
                        open-on-focus={true}
                        floating-dropdown={true}
                        on-change={store.onPrimaryCorpusChange.bind(store)}>
                </ui-filtering-list>
            </div>
            <div each={part, i in options.formparts}
                    class="col xl4 l6 m6 s12 posrel dragItem">
                <div  if={options.formparts.length > 1}
                            class="langButtons">
                    <a>
                        <i class="material-icons dragHandle"
                                title={_("dragToChangeOrder")}>swap_horiz</i>
                    </a>
                    <a onclick={onRmClick}>
                        <i class="close material-icons btnRemoveLanguage"
                                title={_("pc.rmAlignCorp")}>close</i>
                    </a>
                </div>
                <div class="inline-block">
                    <ui-input placeholder={_("pc.anything")}
                            label-id="pc.translated_as"
                            class="bigInput"
                            riot-value={part.formValue.keyword}
                            name="keyword"
                            on-input={onAlignedKeywordChange.bind(this, i)}
                            on-submit={onSearch}
                            tooltip="t_id:parc_b_translated_as">
                    </ui-input>
                </div>
                <ui-filtering-list
                        options={data.aligned}
                        name="corpname"
                        riot-value={part.corpname}
                        label-id="pc.in"
                        close-on-select={true}
                        value-in-search={true}
                        open-on-focus={true}
                        floating-dropdown={true}
                        on-change={onAlignedCorpusChange.bind(this, i)}>
                </ui-filtering-list>
            </div>
            <div class="col s2"
                    if={options.formparts.length < data.aligned.length}>
                <a id="btnAddLanguage"
                        class="btn btn-floating tooltipped"
                        onclick={onAddClick}
                        data-tooltip="t_id:parc_a_add">
                    <i class="material-icons">add</i>
                </a>
            </div>
        </div>
        <div class="center-align row" id="ctb_searchButton">
            <div class="primaryButtons col m{4 * (options.formparts.length + 1)} l{3 * (options.formparts.length + 1)} s12">
                <a id="btnGoBasic" class="btn btn-primary" disabled={isSearchDisabled} onclick={onSearch}>{_("search")}</a>
            </div>
        </div>
        <floating-button disabled={isSearchDisabled}
                on-click={onSearch}
                refnodeid="ctb_searchButton"
                periodic="1"></floating-button>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        onSearch() {
            this.data.closeFeatureToolbar = true
            this.store.initResetAndSearch(this.options)
        }

        updateAttributes() {
            //set all formValues except keyword to default, keep corpname
            this.options = {
                formparts: this.data.formparts.map(fp => {
                    let part = copy(this.store.defaults.formparts[0])
                    part.formValue.keyword = fp.formValue.keyword
                    part.corpname = fp.corpname
                    return part
                }, this),
                formValue: Object.assign(copy(this.store.defaults.formValue), {keyword: this.data.formValue.keyword})
            }
            this.isSearchDisabled = !this.options.formValue.keyword
        }
        this.updateAttributes()

        onKeywordChange(value) {
            this.options.formValue.keyword = value
            this.update()
        }

        onAlignedKeywordChange(i, value){
            this.options.formparts[i].formValue.keyword = value
            this.options.formparts[i].formValue.filter_nonempty = true
            this.update()
        }

        onAlignedCorpusChange(i, value) {
            this.options.formparts[i].corpname = value
            this.options.formparts[i].formValue.filter_nonempty = true
            this.update()
        }

        onInput(value) {
            let wasDisabled = this.isSearchDisabled
            this.isSearchDisabled = value === ""
            if(wasDisabled != this.isSearchDisabled){
                this.update()
            }
        }

        onResetClick(){
            this.store.resetGivenOptions(this.options)
        }

        onAddClick() {
            this.options.formparts.push({
                keyword: "",
                corpname: this.store.findUnused(this.options),
                formValue: {
                    queryselector: 'iquery',
                    keyword: '',
                    lpos: '',
                    wpos: '',
                    default_attr: '',
                    qmcase: false,
                    cql: '',
                    usesubcorp: '',
                    filter_nonempty: true,
                    pcq_pos_neg: "pos"
                }
            })
            this.store.updateUrl()
            this.update()
        }

        onRmClick(event) {
            this.options.formparts = this.options.formparts.filter(function (e) {
                return e.corpname != event.item.part.corpname
            })
            this.update()
        }

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

        initSortable(){
            var el = $(".parconcordance-tab-basic .sortContainer")[0]
            el && Sortable.create(el, {
                draggable: ".dragItem",
                handle: ".dragHandle",
                animation: 150,
                bubbleScroll: true,
                onEnd: function(evt) {
                    this.options.formparts.splice(evt.newDraggableIndex, 0, this.options.formparts.splice(evt.oldDraggableIndex, 1)[0])
                }.bind(this)
            })
        }

        this.on("updated", this.initSortable)

        this.on("mount", () => {
            this.initSortable()
            delay(() => {$("input[name=\"keyword\"]", this.root).focus()}, 10)
            this.store.on("change", this.dataChanged)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</parconcordance-tab-basic>
