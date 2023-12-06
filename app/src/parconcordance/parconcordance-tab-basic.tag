<parconcordance-tab-basic>
    <div class="parconcordance-tab-basic card-content">
        <div class="row">
            <div class="col xl4 l6 m6 s12">
                <div class="inlineBlock">
                    <ui-input placeholder={_("abc")}
                            label-id="search"
                            class="bigInput"
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
                        on-change={store.onPrimaryCorpusChange.bind(store)}
                        deselect-on-click={false}>
                </ui-filtering-list>
            </div>
            <div each={part, i in options.formparts}
                    class="col xl4 l6 m6 s12 posrel">
                <a if={options.formparts.length > 1} onclick={onRmClick}>
                    <i class="close material-icons"
                            title={_("pc.rmAlignCorp")}>close</i>
                </a>
                <div class="inlineBlock">
                    <ui-input placeholder={_("pc.anything")}
                            label-id="pc.translated_as"
                            class="bigInput"
                            riot-value={part.formValue.keyword}
                            name={i}
                            on-input={onAlignedKeywordChange}
                            on-submit={onSearch}
                            tooltip="t_id:parc_b_translated_as">
                    </ui-input>
                </div>
                <ui-filtering-list
                        options={data.aligned}
                        name={i}
                        riot-value={part.corpname}
                        label-id="pc.in"
                        close-on-select={true}
                        value-in-search={true}
                        open-on-focus={true}
                        floating-dropdown={true}
                        on-change={onAlignedCorpusChange}
                        deselect-on-click={false}>
                </ui-filtering-list>
            </div>
            <div class="col s2"
                    if={options.formparts.length < data.aligned.length}>
                <a id="btnAddLanguage"
                        class="waves-effect waves-light btn btn-floating tooltipped"
                        onclick={onAddClick}
                        data-tooltip="t_id:parc_a_add">
                    <i class="material-icons">add</i>
                </a>
            </div>
        </div>
        <div class="center-align row" id="ctb_searchButton">
            <div class="col m{4 * (options.formparts.length + 1)} l{3 * (options.formparts.length + 1)} s12">
                <a class="waves-effect waves-light btn contrast" disabled={isSearchDisabled} onclick={onSearch}>{_("search")}</a>
            </div>
        </div>
        <floating-button disabled={isSearchDisabled} onclick={onSearch}
                refnodeid="ctb_searchButton" periodic="1">
        </floating-button>
    </div>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        onSearch() {
            this.store.initResetAndSearch(this.options)
        }

        updateAttributes() {
            this.options = {
                formparts: this.data.formparts,
                formValue: this.data.formValue
            }
            this.isSearchDisabled = !this.options.formValue.keyword
        }
        this.updateAttributes()

        onKeywordChange(value) {
            this.options.formValue.keyword = value
        }

        onAlignedKeywordChange(value, name) {
            this.options.formparts[name].formValue.keyword = value
            this.options.formparts[name].formValue.filter_nonempty = true
        }

        onAlignedCorpusChange(value, i) {
            this.options.formparts[i].corpname = value
            this.options.formparts[i].formValue.filter_nonempty = true
        }

        onInput(value) {
            let wasDisabled = this.isSearchDisabled
            this.isSearchDisabled = value === ""
            if(wasDisabled != this.isSearchDisabled){
                this.update()
            }
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
                    qmcase: '',
                    cql: '',
                    usesubcorp: '',
                    filter_nonempty: true,
                    pcq_pos_neg: true
                }
            })
            this.store.updateUrl()
        }

        onRmClick(event) {
            this.options.formparts = this.options.formparts.filter(function (e) {
                return e.corpname != event.item.part.corpname
            })
        }

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

        this.on("mount", () => {
            delay(() => {$("input[name=\"keyword\"]", this.root).focus()}, 10)
            this.store.on("change", this.dataChanged)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</parconcordance-tab-basic>
