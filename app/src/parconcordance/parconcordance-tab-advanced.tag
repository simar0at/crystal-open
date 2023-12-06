<parconcordance-tab-advanced class="parconcordance-tab-advanced">
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")}
            class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons dark">settings_backup_restore</i>
    </a>
    <div class="parconcordance-tab-advanced card-content">
        <div class="row">
            <div class="col m6 l6 xl4 s12">
                <ui-filtering-list
                        options={data.corplist}
                        name="corpname"
                        riot-value={store.corpus.corpname}
                        label-id="pc.searchIn"
                        close-on-select={true}
                        value-in-search={true}
                        floating-dropdown={true}
                        open-on-focus={true}
                        on-change={store.onPrimaryCorpusChange.bind(store)}
                        deselect-on-click={false}>
                </ui-filtering-list>
                <query-types
                        riot-value={options.formValue}
                        on-change={onQueryTypesChange}
                        on-valid-change={onQueryTypesValidChange}
                        on-submit={onSubmit}
                        show-video={false}>
                </query-types>
                <subcorpus-select
                        name="usesubcorp"
                        on-change={onUsesubcorpChange}
                        riot-value={options.usesubcorp}
                        tooltip="t_id:parc_a_usesubcorp">
                </subcorpus-select>
            </div>
            <div each={part, i in options.formparts} class="col m6 l6 xl4 s12 posrel">
                <a if={options.formparts.length > 1} onclick={onRmClick}
                        style="z-index: 1000;">
                    <i class="material-icons small-help">close</i>
                </a>
                <ui-filtering-list
                        options={data.aligned}
                        name={i}
                        riot-value={part.corpname}
                        label-id="pc.where"
                        close-on-select={true}
                        value-in-search={true}
                        floating-dropdown={true}
                        open-on-focus={true}
                        on-change={onAlignedCorpusChange}
                        deselect-on-click={false}>
                </ui-filtering-list>
                <div style="margin-top: .5em;">
                    <ui-select name={i}
                            options={pcqPosNegOptions}
                            inline={1}
                            riot-value={part.formValue.pcq_pos_neg}
                            classes="notopmarg"
                            on-change={pcqPosNegOnChange}>
                    </ui-select>
                    {_("pc.pcqPosNeg")}
                </div>
                <query-types
                        riot-value={part.formValue}
                        name={i}
                        haslemma={options.aligned_props[part.corpname] &&
                                options.aligned_props[part.corpname].hasLemma}
                        hascase={options.aligned_props[part.corpname] &&
                                options.aligned_props[part.corpname].hasCase}
                        wposlist={options.aligned_props[part.corpname] &&
                                options.aligned_props[part.corpname].wposlist}
                        lposlist={options.aligned_props[part.corpname] &&
                                options.aligned_props[part.corpname].lposlist}
                        tagsetdoc={options.aligned_props[part.corpname] &&
                                options.aligned_props[part.corpname].tagsetdoc}
                        on-change={onAlignedQueryTypesChange}
                        on-submit={onSubmit}
                        show-video={false}>
                </query-types>
                <ui-checkbox name="filterNonEmpty"
                        label-id="pc.filterNonEmpty"
                        checked={part.formValue.filter_nonempty}
                        on-change={onChangeFilterNonEmpty}
                        tooltip="t_id:parc_a_filter_nonempty">
                </ui-checkbox>
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
        <text-types-collapsible></text-types-collapsible>
        <div class="center-align row" id="ctb_searchButton_adv">
            <div class="col m{4 * (options.formparts.length + 1)} l{3 * (options.formparts.length + 1)} s12">
                <a class="waves-effect waves-light btn contrast" disabled={isSearchDisabled} onclick={onSubmit}>{_("search")}</a>
            </div>
        </div>
        <floating-button disabled={isSearchDisabled} onclick={onSubmit}
                refnodeid="ctb_searchButton_adv" periodic="1">
        </floating-button>
    </div>

    <script>
        require('../concordance/query-types/query-types.tag')
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.pcqPosNegOptions = [{
                label: _("pc.pcqPos"),
                value: true
            }, {
                label: _("pc.pcqNeg"),
                value: false
            },
        ]

        updateAttributes(){
            this.options = {
                formValue: this.data.formValue,
                formparts: this.data.formparts,
                aligned_props: this.data.aligned_props,
                usesubcorp: this.data.usesubcorp,
            }
            this.isSearchDisabled = !this.options.formValue.keyword && !this.options.formValue.cql
        }
        this.updateAttributes()

        onSubmit(){
            this.store.initResetAndSearch(this.options)
        }

        onResetClick(){
            this.store.setDefaultSearchOptions()
            this.store.resetGivenOptions(this.options)
            this.update()
            this.setDisabled(true)
        }

        onChangeFilterNonEmpty(value, name, event) {
            this.options.formparts[event.item.i].formValue.filter_nonempty = value
        }

        pcqPosNegOnChange(value, name, node, value2, event) {
            this.options.formparts[name].formValue.pcq_pos_neg = value
            this.store.updateUrl()
            this.update()
        }

        onUsesubcorpChange(usesubcorp) {
            this.options.usesubcorp = usesubcorp
        }

        onQueryTypesChange(formValue) {
            this.isSearchDisabled = !formValue.keyword && !formValue.cql
            this.options.formValue = formValue
        }

        onQueryTypesValidChange(isValid){
            this.isSearchDisabled == isValid && this.setDisabled(!isValid)
        }

        onAlignedQueryTypesChange(d, i) {
            this.options.formparts[i].formValue = d
        }

        onAlignedCorpusChange(value, name) {
            this.options.formparts[name]["corpname"] = value
            this.options.formparts[name].formValue.keyword = ""
            this.options.formparts[name].formValue.cql = ""
            this.update()
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

        setDisabled(disabled){
            this.isSearchDisabled = disabled
            this.update()
        }

        this.on("mount", () => {
            this.store.on("change", this.dataChanged)
            delay(() => {$("input[name=\"keyword\"]", this.root).focus()}, 10)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</parconcordance-tab-advanced>
