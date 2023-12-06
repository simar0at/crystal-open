<keywords-tab-advanced class="keywords-tab-advanced">
    <a onclick={onResetClick.bind(this, 'advanced')}
            data-tooltip={_("kw.resetOptionsTip")}
            class="tooltipped tabFormResetBtn btn btn-floating btn-flat">
        <i class="material-icons text-darken-1 grey-text">settings_backup_restore</i>
    </a>
    <div class="card-content">
        <div class="mainForm">
            <div class="fixedWidthForm">
                <div class="row">
                    <div class="col m12 l4">
                        <subcorpus-select
                                label-id="focusSubcorpus"
                                on-change={onUsesubcorpChange}
                                riot-value={options.usesubcorp}
                                tooltip="t_id:kw_a_usesubcorp"
                                disabled={!$.isEmptyObject(options.tts)}
                                name="usesubcorp">
                        </subcorpus-select>
                        <br>
                        <ui-filtering-list
                                ref="ref_corpname"
                                options={refCorpnameList}
                                name="ref_corpname"
                                label-id="refCorpus"
                                close-on-select={true}
                                value-in-search={true}
                                open-on-focus={true}
                                on-change={onChangeRefCorp}
                                floating-dropdown={true}
                                loading={!refCorpnameList.length}
                                tooltip="t_id:kw_a_ref_corpname"
                                riot-value={options.ref_corpname}>
                        </ui-filtering-list>
                        <br>
                        <ui-filtering-list
                                options={refSubcorpora}
                                disabled={subcLoading || !refSubcorpora.length}
                                name="ref_usesubcorp"
                                label-id="kw.refSubcorpus"
                                value-in-search={true}
                                close-on-select={true}
                                open-on-focus={true}
                                on-change={onOptionChange}
                                floating-dropdown={true}
                                tooltip="t_id:kw_a_ref_usesubcorp"
                                riot-value={options.ref_usesubcorp}>
                        </ui-filtering-list>
                        <br>
                    </div>
                    <div class="col m12 l4 dividerLeft dividerRight hideDividersMedDown">
                        <simple-math-slider riot-value={options.simple_n} on-change={onOptionChange}></simple-math-slider>
                        <ui-input name="minfreq"
                                inline=1
                                validate=1
                                label-id="minFreq"
                                size=8
                                on-change={onOptionChange}
                                min="0"
                                type="number"
                                tooltip="t_id:kw_a_minfreq"
                                riot-value={options.minfreq}>
                        </ui-input>
                        &nbsp;
                        <ui-input name="maxfreq"
                                inline=1
                                validate=1
                                label-id="maxFreq"
                                size=8
                                on-change={onOptionChange}
                                min="0"
                                type="number"
                                tooltip="t_id:kw_a_maxfreq"
                                riot-value={options.maxfreq}>
                        </ui-input>
                        <br>
                        <ui-input
                                validate=1
                                name="max_items"
                                label-id="maxItems"
                                on-change={onOptionChange}
                                size=7
                                type="number"
                                min="0"
                                tooltip="t_id:kw_a_max_keywords"
                                riot-value={options.max_items}>
                        </ui-input>
                        <br>
                    </div>
                    <div class="col m12 l4">
                        <ui-checkbox name="icase"
                                label-id="ignoreCase"
                                class="inline-block"
                                on-change={onOptionChange}
                                tooltip="t_id:wlicase"
                                checked={options.icase}>
                        </ui-checkbox>
                        <br>
                        <ui-checkbox name="onealpha"
                                label-id="kw.onealpha"
                                class="inline-block"
                                on-change={onOptionChange}
                                tooltip="t_id:kw_a_onealpha"
                                checked={options.onealpha}>
                        </ui-checkbox>
                        <br>
                        <ui-checkbox name="alnum"
                                label-id="kw.alnum"
                                class="inline-block"
                                on-change={onOptionChange}
                                tooltip="t_id:kw_a_alnum"
                                checked={options.alnum}>
                        </ui-checkbox>
                        <br>
                        <ui-checkbox name="include_nonwords"
                                label-id="includeNonwords"
                                class="inline-block"
                                on-change={onOptionChange}
                                tooltip="t_id:include_nonwords"
                                checked={options.include_nonwords}>
                        </ui-checkbox>
                        <br>
                        <ui-checkbox
                                label-id="wl.excludeWords"
                                name="exclude"
                                checked={options.exclude}
                                tooltip="t_id:kw_a_exclude"
                                on-change={onExcludeWordsClicked}>
                        </ui-checkbox>
                        <div class="pl-5">
                            <expandable-textarea
                                    if={options.exclude}
                                    ref="wlblacklist"
                                    required="required"
                                    validate="1"
                                    name="wlblacklist"
                                    value={typeof options.wlblacklist === "string" ?
                                            options.wlblacklist :
                                            options.wlblacklist.join("\n")}
                                    rows="1"
                                    label-id={options.exclude ? "ng.pasteListHere" : ""}
                                    on-change={onOptionChange}
                                    dialog-title={_("wl.excludeWords")}
                                    style="max-width: 250px;">
                            </expandable-textarea>
                        </div>
                        <ui-checkbox
                                label-id="ng.fromList"
                                name="fromList"
                                checked={options.fromList}
                                on-change={onFromListClicked}
                                tooltip="t_id:kw_a_from_list">
                        </ui-checkbox>
                        <div class="pl-5">
                            <expandable-textarea
                                    if={options.fromList}
                                    ref="wlfile"
                                    required="required"
                                    validate="1"
                                    name="wlfile"
                                    value={typeof options.wlfile === "string" ?
                                            options.wlfile :
                                            options.wlfile.join("\n")}
                                    rows="1"
                                    label-id={options.fromList ? "ng.pasteListHere" : ""}
                                    on-change={onOptionChange}
                                    dialog-title={_("ng.fromList")}
                                    style="max-width: 250px;">
                            </expandable-textarea>
                        </div>
                        <br>
                    </div>
                </div>

                <div class="featureSettingsRow row dividerTop">
                    <div class="col s12 m7 l4">
                        <br>
                        <ui-checkbox name="usekeywords"
                                label-id="useKeywords"
                                class="inline-block mb-0"
                                on-change={onUseFeatureChange.bind(this, "keywords")}
                                checked={options.usekeywords}>
                        </ui-checkbox>
                        <div class="card-panel" style="{options.usekeywords ? '' : 'opacity: 0.3;'}"
                                ref="keywords_settings">
                            <h6 class="mb-8">Keywords settings</h6>
                            <ui-select
                                    label-id="attribute"
                                    options={attributes}
                                    name="k_attr"
                                    on-change={onOptionChange}
                                    tooltip="t_id:kw_a_attr"
                                    riot-value={options.k_attr}>
                            </ui-select>
                            <br>
                            <ui-input name="k_wlpat"
                                    label-id="matchingRegex"
                                    on-change={onOptionChange}
                                    type="text"
                                    tooltip="t_id:kw_a_wlpat"
                                    riot-value={options.k_wlpat}>
                            </ui-input>
                        </div>
                    </div>
                    <div class="col s12 m7 l4">
                        <br>
                        <ui-checkbox name="useterms"
                                label-id="useTerms"
                                disabled={!termsAvailable}
                                class="inline-block mb-0"
                                on-change={onUseFeatureChange.bind(this, "terms")}
                                checked={options.useterms && termsAvailable}>
                        </ui-checkbox>
                        <div class="card-panel" style="{options.useterms && termsAvailable ? '' : 'opacity: 0.3;'}"
                                ref="terms_settings">
                            <h6 class="mb-8">Terms settings</h6>
                            <ui-input name="t_wlpat"
                                    label-id="matchingRegex"
                                    on-change={onOptionChange}
                                    type="text"
                                    tooltip="t_id:kw_a_wlpat"
                                    riot-value={options.t_wlpat}>
                            </ui-input>
                        </div>
                    </div>
                    <div class="col s12 m7 l4">
                        <br>
                        <ui-checkbox name="usengrams"
                                label-id="useNgrams"
                                class="inline-block mb-0"
                                on-change={onUseFeatureChange.bind(this, "ngrams")}
                                checked={options.usengrams}>
                        </ui-checkbox>
                        <div class="card-panel" style="{options.usengrams ? '' : 'opacity: 0.3;'}"
                                ref="ngrams_settings">
                            <h6 class="mb-8">N-grams settings</h6>
                            <ui-select
                                    label-id="attribute"
                                    options={attributes}
                                    name="n_attr"
                                    on-change={onOptionChange}
                                    tooltip="t_id:kw_a_attr"
                                    riot-value={options.n_attr}>
                            </ui-select>
                            <br>
                            <ui-input name="n_wlpat"
                                    label-id="matchingRegex"
                                    on-change={onOptionChange}
                                    type="text"
                                    tooltip="t_id:kw_a_wlpat"
                                    riot-value={options.n_wlpat}>
                            </ui-input>
                            <div>
                                <label>
                                    {_("ng.ngramLength")}
                                </label>
                                <ui-range min={2} max={6}
                                        riot-value={{
                                            from: options.n_ngrams_n,
                                            to: options.n_ngrams_max_n
                                        }}
                                        on-change={onRangeChange}>
                                </ui-range>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <text-types if={!isAnonymous}
                ref="texttypes"
                disabled={options.usesubcorp !== ""}
                collapsible=1
                disable-structure-mixing=1
                selection={options.tts}
                on-change={onTtsChange}
                note={options.usesubcorp ?_("subcorpusAndTTWarning") : ""}></text-types>

        <div class="primaryButtons searchBtn">
            <a id="btnGoAdv"
                    class="btn btn-primary"
                    disabled={isSearchDisabled}
                    onclick={onAdvSearch}>{_("go")}</a>
        </div>
    </div>

    <script>
        const {Connection} = require('core/Connection.js')
        const {AppStore} = require("core/AppStore.js")
        const {Auth} = require('core/Auth.js')
        const {UserDataStore} = require("core/UserDataStore.js")

        this.mixin("feature-child")
        this.isAnonymous = Auth.isAnonymous()
        this.attributes = AppStore.getActualCorpus().attributes
        this.subcorpList = []

        this.compTooltips = {
            // kw_0 - kw incompatible are not in the list
            'kw_1': 't_id:kw_part_comp',
            'kw_2': 't_id:kw_full_comp',
            'terms_0': 't_id:terms_na',
            'terms_1': 't_id:terms_part_comp',
            'terms_2': 't_id:terms_full_comp'
        }

        _refreshSubcorpusList(){
            let scl = this.subcorpList.slice()

            if(this.options.ref_corpname == this.store.corpus.corpname && this.options.usesubcorp){
                scl.unshift({labelId: "restOfCorpus", value: "== the rest of the corpus =="})
            }
            scl.unshift({
                label: _('fullCorpus'),
                value: ''
            })
            this.refSubcorpora = scl
        }

        updateAttributes(){
            this.options = {};
            ["k_attr", "minfreq", "maxfreq", "simple_n", "onealpha",
                "alnum", "max_items",
                "t_notAvailable", "t_wlpat", "k_wlpat", "n_wlpat",
                "n_ngrams_n", "n_ngrams_max_n", "icase", "exclude",
                "wlblacklist", "fromList", "wlfile", "n_attr", "usekeywords", "useterms", "usengrams",
                "ref_corpname", "ref_usesubcorp", "include_nonwords"].forEach(name => {
                this.options[name] = this.store.data[name]
            })
            this.termsAvailable = false
            if(this.options.ref_corpname){
                let refCorpus = AppStore.getCorpusByCorpname(this.options.ref_corpname)
                this.termsAvailable = refCorpus && !!refCorpus.termdef && !!this.corpus.termdef
            }
            if(!this.termsAvailable){
                this.options.useterms = false
            }
            this.options.tts = copy(this.store.data.tts)
            this.options.usesubcorp = UserDataStore.getCorpusData(this.corpus.corpname, "defaultSubcorpus") || this.data.usesubcorp
        }
        this.updateAttributes()

        onAdvSearch() {
            this.store.data.do_wipo = Auth.isWIPO()
            // check if attr is available
            if (!AppStore.getAttributeByName(this.options.k_attr)) {
                // TODO: use DEFAULTATTR
                this.options.k_attr = "word"
                this.store.updateUrl()
            }
            this.store.resetSearchAndAddToHistory(Object.assign(this.options, {
                onlywipo: false,
                useterms: this.options.useterms && this.termsAvailable,
                t_page: 1,
                k_page: 1
            }))
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", null)
        }

        getRefSubc(corpname) {
            this.subcLoading = true
            Connection.get({
                url: window.config.URL_BONITO + "subcorp",
                skipDefaultCallbacks: true,
                data: { corpname: corpname },
                done: (data) => {
                    if(this.data.error){
                        this.refSubcorpora = []
                        SkE.showError(getPayloadError(data))
                    } else {
                        this.subcorpList = data.SubcorpList.map(c => {
                            return {
                                label: c.n,
                                value: c.n
                            }
                        })
                        this._refreshSubcorpusList()
                    }
                    this.subcLoading = false
                    this.update()
                },
                fail: (data) => {
                    this.refSubcorpora = []
                    data.error && SkE.showError(getPayloadError(data))
                }
            })
        }

        this.refSubcorpora = [{value: "", label: _("fullCorpus")}]
        this.options.ref_corpname && this.getRefSubc(this.options.ref_corpname)

        onChangeRefCorp(value, name, label, option){
            this.termsAvailable = !!option.termsComp && !!this.corpus.termdef
            this.options.useterms = this.termsAvailable
            this.options.ref_corpname = value
            this.options.ref_usesubcorp = ""
            this.store.updateUrl()
            this.refreshSearchBtnDisabled()
            this.update()
            this.getRefSubc(value)
        }

        onResetClick() {
            let changed = this.options.ref_corpname != AppStore.data.corpus.refKeywordsCorpname
            this.store.resetGivenOptions(this.options)
            this.options.ref_corpname = AppStore.data.corpus.refKeywordsCorpname
            changed && this.getRefSubc(this.options.ref_corpname)

            this.refs.texttypes && this.refs.texttypes.reset()
            this.store.updateUrl()
        }

        onOptionChange(value, name) {
            this.options[name] = value
            if ((name == "k_attr" || name == "alnum") && this.options.k_attr.indexOf('lempos') == 0 && this.options["alnum"]) {
                Dispatcher.trigger("openDialog", {
                    small: true,
                    title: _("kw.confirmWarning"),
                    tag: "raw-html",
                    opts:{
                        content: _("kw.confirmAlnumText")
                    },
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
            if(this.options.ref_usesubcorp == "== the rest of the corpus =="){
                this.options.ref_usesubcorp = ""
            }
            this._refreshSubcorpusList()
            this.refs.texttypes && this.refs.texttypes.setDisabled(usesubcorp !== "")
            this.update()
        }

        onExcludeWordsClicked(checked) {
            this.onOptionChange(checked, 'exclude')
            if(!checked){
                this.options.wlblacklist = ""
            }
            checked && $("textarea[name=\"wlblacklist\"]").focus()
        }

        onFromListClicked(checked){
            this.onOptionChange(checked, 'fromList')
            if(!checked){
                this.options.wlfile = ""
            }
            checked && $("textarea[name=\"wlfile\"]").focus()
        }

        onRangeChange(range){
            this.options.n_ngrams_n = range.from
            this.options.n_ngrams_max_n = range.to
        }

        onUseFeatureChange(feature, checked){
            this.options["use" + feature] = checked
            this.refreshSearchBtnDisabled()
            this.update()
        }

        setCompatibleCorpora(refCorpList) {
            this.refreshRefCorpnameList()
            this.options.ref_corpname = AppStore.data.corpus.refKeywordsCorpname
                    || (refCorpList.length && refCorpList[0].value)
            this.store.updateUrl()
            this.update()
            this.getRefSubc(this.options.ref_corpname)
        }

        generator(option){
            return  `<span class="refCorpOption">
                <span class="t_sc">
                    ${option.label}
                </span>
                <span class="compLevels">
                    <span class="compLevel comp_${option.kwComp}" data-tooltip-id="kw_${option.kwComp}">KW</span>
                    <span class="compLevel comp_${option.termsComp}" data-tooltip-id="terms_${option.termsComp}">T</span>
                </span>
            </span>`
        }

        refreshRefCorpnameList(){
            this.refCorpnameList = copy(AppStore.data.compRefCorpList)
            this.refCorpnameList.forEach(o => o.generator = this.generator)
        }
        this.refreshRefCorpnameList()

        refreshSearchBtnDisabled(){
            this.isSearchDisabled = !this.options.ref_corpname
                    || (!this.options.usekeywords && !this.options.useterms && !this.options.usengrams)
        }
        this.refreshSearchBtnDisabled()

        dataChanged(){
            this.updateAttributes()
            this.update()
        }

        onTtsChange(tts){
            this.options.tts = tts
            this.update()
        }

        showTooltip(evt){
            let path = evt.path || evt.composedPath()
            let el = path.find(node => node.classList && node.classList.contains("compLevel"))
            if(el){
                this.actualTooltip = showTooltip(el, this.compTooltips[$(el).data("tooltipId")], 500)
            }
        }

        hideTooltip(){
            this.actualTooltip && this.actualTooltip.close()
            this.actualTooltip = null
        }

        onRefCorpnameListOpen(){
            this.refs.ref_corpname.refs.list.root.addEventListener("mouseover", this.showTooltip)
            this.refs.ref_corpname.refs.list.root.addEventListener("mouselave", this.hideTooltip)
        }

        onRefCorpnameListClose(){
            this.refs.ref_corpname.refs.list.root.removeEventListener("mouseover", this.showTooltip)
            this.refs.ref_corpname.refs.list.root.removeEventListener("mouselave", this.hideTooltip)
        }

        this.on("mount", () => {
            AppStore.on("compatibleCorporaListChanged", this.setCompatibleCorpora)
            AppStore.on('subcorporaChanged', this.update)
            this.store.on("change", this.dataChanged)
            this.refs.ref_corpname.on("open", this.onRefCorpnameListOpen)
            this.refs.ref_corpname.on("close", this.onRefCorpnameListClose)
        })

        this.on("update", this.hideTooltip)

        this.on("unmount", () => {
            AppStore.off("compatibleCorporaListChanged", this.setCompatibleCorpora)
            AppStore.off('subcorporaChanged', this.update)
            this.store.off("change", this.dataChanged)
        })
    </script>
</keywords-tab-advanced>
