<confirm-filter-alnum>
    <p>{_("kw.confirmAlnumText")}</p>
</confirm-filter-alnum>

<keywords-tab-advanced class="keywords-tab-advanced">
    <a onclick={onResetClick.bind(this, 'advanced')}
            data-tooltip={_("kw.resetOptionsTip")}
            class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons text-darken-1 grey-text">settings_backup_restore</i>
    </a>
    <div class="card-content">
        <div class="mainForm">
            <div class="row">
                <div class="col s12 m6">
                    <subcorpus-select
                            label-id="subcorpus"
                            on-change={onUsesubcorpChange}
                            riot-value={options.usesubcorp}
                            tooltip="t_id:kw_a_usesubcorp"
                            disabled={!$.isEmptyObject(options.tts)}
                            name="usesubcorp">
                    </subcorpus-select>
                </div>
                <div class="col s12 m6">
                    <ui-slider name="simple_n"
                            hfill={true}
                            label-id="focusOn"
                            left-label={_("rare")}
                            right-label={_("common")}
                            on-change={onOptionChange}
                            slider-to-input={sliderToInput}
                            input-to-slider={inputToSlider}
                            type="number"
                            step=1
                            slider-min=1
                            slider-max={sliderValues.length}
                            input-min=0.00001
                            input.max=1000000000
                            tooltip="t_id:kw_a_simple_n"
                            riot-value={options.simple_n}>
                    </ui-slider>
                </div>
            </div>
            <div class="row">
                <div class="col s6 m3">
                    <ui-input name="minfreq"
                            validate=1
                            label-id="minFreq"
                            size=8
                            on-change={onOptionChange}
                            min="0"
                            type="number"
                            tooltip="t_id:kw_a_minfreq"
                            riot-value={options.minfreq}>
                    </ui-input>
                </div>
                <div class="col s6 m5">
                    <ui-checkbox name="onealpha"
                            label-id='kw.onealpha'
                            class="inlineBlock"
                            on-change={onOptionChange}
                            tooltip="t_id:kw_a_onealpha"
                            checked={options.onealpha}>
                    </ui-checkbox>
                </div>
                <div class="col s6 m4">
                    <ui-checkbox name="alnum"
                            label-id='kw.alnum'
                            class="inlineBlock"
                            on-change={onOptionChange}
                            tooltip="t_id:kw_a_alnum"
                            checked={options.alnum}>
                    </ui-checkbox>
                </div>
            </div>
            <div class="row kwTermsRow">
                <div class="col s12 {m6: !window.config.NO_SKE}">
                    <div class="card-panel">
                        <h6>{_("kw.keywordsSettings")}</h6>
                        <div class="row">
                            <div class="col s12">
                                <ui-filtering-list
                                        options={compKeywordsCorpList}
                                        name="k_ref_corpname"
                                        label-id="refCorpus"
                                        close-on-select={true}
                                        value-in-search={true}
                                        open-on-focus={true}
                                        on-change={onChangeKeyRefCorp}
                                        floating-dropdown={true}
                                        loading={!compKeywordsCorpList.length}
                                        tooltip="t_id:kw_a_k_ref_corpname"
                                        riot-value={options.k_ref_corpname}
                                        deselect-on-click={false}>
                                </ui-filtering-list>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col s12">
                                <ui-filtering-list
                                        options={refKeySubcorpora}
                                        disabled={refKeySubcLoading || !refKeySubcorpora.length}
                                        name="k_ref_subcorp"
                                        label-id="kw.refSubcorpus"
                                        value-in-search={true}
                                        close-on-select={true}
                                        open-on-focus={true}
                                        on-change={onOptionChange}
                                        floating-dropdown={true}
                                        tooltip="t_id:kw_a_k_ref_subcorp"
                                        riot-value={options.k_ref_subcorp}
                                        deselect-on-click={false}>
                                </ui-filtering-list>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col s5">
                                <ui-input
                                        validate=1
                                        name="max_keywords"
                                        label-id="maxItems"
                                        on-change={onOptionChange}
                                        size=7
                                        type="number"
                                        min="0"
                                        tooltip="t_id:kw_a_max_keywords"
                                        riot-value={options.max_keywords}>
                                </ui-input>
                            </div>
                            <div class="col s7">
                                <ui-select
                                        label-id="kw.attr"
                                        options={attributes}
                                        name="attr"
                                        on-change={onOptionChange}
                                        tooltip="t_id:kw_a_attr"
                                        riot-value={options.attr}>
                                </ui-select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col s12">
                                <ui-input name="k_wlpat"
                                        label-id="matchingRegex"
                                        on-change={onOptionChange}
                                        type="text"
                                        tooltip="t_id:kw_a_k_wlpat"
                                        riot-value={options.k_wlpat}>
                                </ui-input>
                            </div>
                        </div>
                    </div>
                </div>
                <div if={!window.config.NO_SKE} class="col s12 m6">
                    <div class="card-panel">
                        <div if={options.t_notAvailable || !compTermsCorpList.length}>
                            <h5 class="termsNA">{_("kw.termsNA")}</h5>
                        </div>
                        <div if={!options.t_notAvailable && compTermsCorpList.length}>
                            <h6>{_("kw.termsSettings")}</h6>
                            <div class="row">
                                <div class="col s12">
                                    <ui-filtering-list
                                            options={compTermsCorpList}
                                            name="t_ref_corpname"
                                            label-id="refCorpus"
                                            close-on-select={true}
                                            value-in-search={true}
                                            open-on-focus={true}
                                            on-change={onChangeTermsRefCorp}
                                            floating-dropdown={true}
                                            loading={!compTermsCorpList.length}
                                            tooltip="t_id:kw_a_t_ref_corpname"
                                            riot-value={options.t_ref_corpname}
                                            deselect-on-click={false}>
                                    </ui-filtering-list>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col s12">
                                    <ui-filtering-list
                                            options={refTermsSubcorpora}
                                            disabled={refTermsSubcLoading || !refTermsSubcorpora.length}
                                            name="t_ref_subcorp"
                                            label-id="kw.refSubcorpus"
                                            on-change={onOptionChange}
                                            close-on-select={true}
                                            value-in-search={true}
                                            floating-dropdown={true}
                                            open-on-focus={true}
                                            tooltip="t_id:kw_a_t_ref_subcorp"
                                            riot-value={options.t_ref_subcorp}
                                            deselect-on-click={false}>
                                    </ui-filtering-list>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col s6">
                                    <ui-input
                                            validate=1
                                            name="max_terms"
                                            label-id="maxItems"
                                            on-change={onOptionChange}
                                            size=8
                                            type="number"
                                            min="0"
                                            tooltip="t_id:kw_a_max_terms"
                                            riot-value={options.max_terms}>
                                    </ui-input>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col s12">
                                    <ui-input name="t_wlpat"
                                            label-id="matchingRegex"
                                            on-change={onOptionChange}
                                            type="text"
                                            tooltip="t_id:kw_a_t_wlpat"
                                            riot-value={options.t_wlpat}>
                                    </ui-input>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <text-types-collapsible opts={options.usesubcorp ? {note: _("subcorpusAndTTWarning")} : null}></text-types-collapsible>

        <div class="searchBtn center-align">
            <a id="btnGoAdv"
                    class="waves-effect waves-light btn contrast"
                    disabled={isSearchDisabled}
                    onclick={onAdvSearch}>{_("go")}</a>
        </div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {AppStore} = require("core/AppStore.js")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        const {Auth} = require('core/Auth.js')

        this.mixin("feature-child")
        this.attributes = AppStore.getActualCorpus().attributes
        this.compKeywordsCorpList = AppStore.data.compKeywordsCorpList
        this.compTermsCorpList = AppStore.data.compTermsCorpList
        this.sliderValues = [0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000]

        sliderToInput(value){
            return this.sliderValues[value - 1]
        }

        inputToSlider(value){
            let ret = 0
            let max = this.sliderValues[this.sliderValues.length - 1]
            if(value >= max){
                return max
            }
            while(ret < this.sliderValues.length && ((this.sliderValues[ret] + this.sliderValues[ret + 1]) / 2) < value){
                ret ++
            }
            return ret

        }

        updateAttributes(){
            this.options = {};
            ["usesubcorp", "attr", "minfreq", "simple_n", "onealpha", "alnum",
                "max_terms", "max_keywords", "k_ref_subcorp", "t_ref_subcorp",
                "t_notAvailable",
                "t_wlpat", "k_wlpat", "k_ref_corpname", "t_ref_corpname"].forEach(name => {
                this.options[name] = this.store.data[name]
            })
            this.options.tts = copy(this.store.data.tts)
        }
        this.updateAttributes()

        onAdvSearch() {
            this.store.data.do_wipo = Auth.isWIPO()
            // check if attr is available
            if (!AppStore.getAttributeByName(this.options.attr)) {
                // TODO: use DEFAULTATTR
                this.options.attr = "word"
                this.store.updateUrl()
            }
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
            this.store.resetSearchAndAddToHistory(Object.assign(this.options, {
                t_page: 1,
                k_page: 1
            }))
        }

        getRefSubc(corpname, type) {
            // TODO: do not run twice if key and term ref corpora are the same
            if (!corpname || (type == "t" && this.options.t_notAvailable)) {
                return
            }
            if (type == 'k') {
                this.refKeySubcLoading = true
            }
            if (type == 't') {
                this.refTermsSubcLoading = true
            }
            let self = this
            Connection.get({
                url: window.config.URL_BONITO + "subcorp",
                skipDefaultCallbacks: true,
                query: { corpname: corpname },
                done: (data) => {
                    let scl = data.SubcorpList
                    for (let i=0; i<scl.length; i++) {
                        scl[i]['label'] = scl[i].n
                        scl[i]['value'] = scl[i].n
                    }
                    scl.unshift({
                        label: _('fullCorpus'),
                        value: ''
                    })
                    if (type == 'k') {
                        self.refKeySubcorpora = scl
                        self.refKeySubcLoading = false
                    }
                    if (type == 't') {
                        self.refTermsSubcorpora = scl
                        self.refTermsSubcLoading = false
                    }
                    self.update()
                },
                fail: (data) => {
                    if (type == "k") self.refKeySubcorpora = []
                    if (type == "t") self.refTermsSubcorpora = []
                    data.error && SkE.showError(data.error)
                }
            })
        }

        this.refKeySubcorpora = [{value: "", label: _("fullCorpus")}]
        if (this.options.k_ref_corpname) {
            this.getRefSubc(this.options.k_ref_corpname, 'k')
        }
        this.refTermsSubcorpora = [{value: "", label: _("fullCorpus")}]
        if (this.options.t_ref_corpname) {
            this.getRefSubc(this.options.t_ref_corpname, 't')
        }

        onChangeKeyRefCorp(value, name, label) {
            this.options.k_ref_corpname = value
            this.store.updateUrl()
            this.refreshSearchBtnDisabled()
            this.update()
            this.getRefSubc(value, 'k')
        }

        onChangeTermsRefCorp(value, name, label) {
            this.options.t_ref_corpname = value
            this.store.updateUrl()
            this.refreshSearchBtnDisabled()
            this.update()
            this.getRefSubc(value, 't')
        }

        onResetClick() {
            TextTypesStore.reset()
            let t_changed = this.options.t_ref_corpname != AppStore.data.corpus.refTermsCorpname
            let k_changed = this.options.k_ref_corpname != AppStore.data.corpus.refKeywordsCorpname
            this.store.resetGivenOptions(this.options)
            this.options.k_ref_corpname = AppStore.data.corpus.refKeywordsCorpname
            this.options.t_ref_corpname = AppStore.data.corpus.refTermsCorpname
            k_changed && this.getRefSubc(this.options.k_ref_corpname, 'k')
            t_changed && this.getRefSubc(this.options.t_ref_corpname, 't')

            this.store.updateUrl()
            this.update()
        }

        onOptionChange(value, name) {
            this.options[name] = value
            if (name == "attr" && value.indexOf('lempos') == 0 && this.options["alnum"]) {
                Dispatcher.trigger("openDialog", {
                    small: true,
                    title: _("kw.confirmWarning"),
                    tag: "confirm-filter-alnum",
                    showCloseButton: false,
                    buttons: [{
                        id: "filterAlnum",
                        label: _("kw.confirm"),
                        onClick: function(dialog, modal) {
                            modal.close()
                        }.bind(this)
                    }]
                })
            }
            this.store.updateUrl()
            this.update()
        }

        onUsesubcorpChange(usesubcorp){
            this.options.usesubcorp = usesubcorp
            TextTypesStore.setDisabled(usesubcorp !== "")
        }

        setCompatibleCorpora(o) {
            this.compKeywordsCorpList = o.k
            this.compTermsCorpList = o.t
            if (!o.t.length) {
                this.data.t_notAvailable = true
            }
            this.options.k_ref_corpname = AppStore.data.corpus.refKeywordsCorpname
                    || (o.k.length && o.k[0].value)
            this.options.t_ref_corpname = AppStore.data.corpus.refTermsCorpname
                    || (o.t.length && o.t[0].value)
            this.store.updateUrl()
            this.update()
            this.getRefSubc(this.options.k_ref_corpname, 'k')
            this.getRefSubc(this.options.t_ref_corpname, 't')
        }

        refreshSearchBtnDisabled(){
            this.isSearchDisabled = !this.options.k_ref_corpname
                    || (this.compTermsCorpList.length && (this.data.t_notAvailable || !this.options.t_ref_corpname))
        }
        this.refreshSearchBtnDisabled()

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

       onTextTypesSelectionChange(selection){
            this.options.tts = selection
            this.update()
        }

        this.on("mount", () => {
            AppStore.on("compatibleCorporaListChanged", this.setCompatibleCorpora)
            AppStore.on('subcorporaChanged', this.update)
            TextTypesStore.on("selectionChange", this.onTextTypesSelectionChange)
            this.store.on("change", this.dataChanged)
        })

        this.on("unmount", () => {
            AppStore.off("compatibleCorporaListChanged", this.setCompatibleCorpora)
            AppStore.off('subcorporaChanged', this.update)
            TextTypesStore.off("selectionChange", this.onTextTypesSelectionChange)
            this.store.off("change", this.dataChanged)
        })
    </script>
</keywords-tab-advanced>
