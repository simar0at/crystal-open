<parconcordance-tab-advanced class="parconcordance-tab-advanced">
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")}
            class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons color-blue-800">settings_backup_restore</i>
    </a>
    <div class="parconcordance-tab-advanced card-content">
        <div class="row sortContainer">
            <div class="col m6 l6 xl4 s12 t_f-1">
                <ui-filtering-list
                        options={data.corplist}
                        name="corpname"
                        riot-value={store.corpus.corpname}
                        label-id="pc.searchIn"
                        close-on-select={true}
                        value-in-search={true}
                        floating-dropdown={true}
                        open-on-focus={true}
                        on-change={store.onPrimaryCorpusChange.bind(store)}>
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
            <div each={part, i in options.formparts}
                    class="col m6 l6 xl4 s12 posrel dragItem t_f-{i + 2}">
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
                <ui-filtering-list
                        options={data.aligned}
                        name="corpname"
                        riot-value={part.corpname}
                        label-id="pc.where"
                        close-on-select={true}
                        value-in-search={true}
                        floating-dropdown={true}
                        open-on-focus={true}
                        on-change={onAlignedCorpusChange.bind(this, i)}>
                </ui-filtering-list>
                <div style="margin-top: .5em;">
                    <ui-select name="pcq_pos_neg"
                            options={pcqPosNegOptions}
                            inline={1}
                            riot-value={part.formValue.pcq_pos_neg}
                            classes="notopmarg"
                            on-change={pcqPosNegOnChange.bind(this, i)}>
                    </ui-select>
                    {_("pc.pcqPosNeg")}
                </div>
                <query-types
                        riot-value={part.formValue}
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
                        on-change={onAlignedQueryTypesChange.bind(this, i)}
                        on-submit={onSubmit}
                        show-video={false}>
                </query-types>
                <ui-checkbox name="filterNonEmpty"
                        label-id="pc.filterNonEmpty"
                        checked={part.formValue.filter_nonempty}
                        on-change={onChangeFilterNonEmpty.bind(this, i)}
                        tooltip="t_id:parc_a_filter_nonempty">
                </ui-checkbox>
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

        <text-types ref="texttypes"
                collapsible=1
                selection={options.tts}
                on-change={onTtsChange}></text-types>

        <div class="center-align row" id="ctb_searchButton_adv">
            <div class="primaryButtons col m{4 * (options.formparts.length + 1)} l{3 * (options.formparts.length + 1)} s12">
                <a id="btnGoAdvanced" class="btn btn-primary" disabled={isSearchDisabled} onclick={onSubmit}>{_("search")}</a>
            </div>
        </div>
        <floating-button disabled={isSearchDisabled}
                on-click={onSubmit}
                refnodeid="ctb_searchButton_adv"
                periodic="1"></floating-button>
    </div>

    <script>
        require('../concordance/query-types/query-types.tag')
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        this.isSearchDisabled = true
        this.pcqPosNegOptions = [{
                label: _("pc.pcqPos"),
                value: "pos"
            }, {
                label: _("pc.pcqNeg"),
                value: "neg"
            },
        ]

        updateAttributes(){
            this.options = {
                formValue: this.data.formValue,
                formparts: this.data.formparts,
                aligned_props: this.data.aligned_props,
                usesubcorp: this.data.usesubcorp,
                tts: this.data.tts
            }
        }
        this.updateAttributes()

        onTtsChange(tts){
            this.options.tts = tts
        }

        onSubmit(){
            this.data.closeFeatureToolbar = true
            this.store.initResetAndSearch(this.options)
        }

        onResetClick(){
            this.store.setDefaultSearchOptions()
            this.store.resetGivenOptions(this.options)
            this.update()
            this.setDisabled(true)
            this.refs.texttypes.reset()
        }

        onChangeFilterNonEmpty(i, value) {
            this.options.formparts[i].formValue.filter_nonempty = value
        }

        pcqPosNegOnChange(i, value) {
            this.options.formparts[i].formValue.pcq_pos_neg = value
            this.store.updateUrl()
            this.update()
        }

        onUsesubcorpChange(usesubcorp) {
            this.options.usesubcorp = usesubcorp
            this.update()
        }

        onQueryTypesChange(formValue) {
            this.options.formValue = formValue
        }

        onQueryTypesValidChange(isValid){
            this.isSearchDisabled == isValid && this.setDisabled(!isValid)
        }

        onAlignedQueryTypesChange(i, value) {
            this.options.formparts[i].formValue = value
            this.update()
        }

        onAlignedCorpusChange(i, value) {
            this.options.formparts[i]["corpname"] = value
            this.options.formparts[i].formValue.keyword = ""
            this.options.formparts[i].formValue.cql = ""
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
                    qmcase: false,
                    cql: '',
                    usesubcorp: '',
                    filter_nonempty: true,
                    pcq_pos_neg: "pos"
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

        initSortable(){
            var el = $(".parconcordance-tab-advanced .sortContainer")[0]
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
            this.store.on("change", this.dataChanged)
            delay(() => {$("input[name=\"keyword\"]", this.root).focus()}, 10)
        })

        this.on("unmount", () => {
            this.store.off("change", this.dataChanged)
        })
    </script>
</parconcordance-tab-advanced>
