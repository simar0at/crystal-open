<concordance-frequency-tab-advanced class="frequency-tab-advanced">
    <div class="card-content">
        <a onclick={onResetClick} class="resetOptions btn btn-floating btn-flat">
            <i class="material-icons color-blue-800">settings_backup_restore</i>
        </a>
        <div class="columns">
            <div class="freqmlContainer inline-block leftColumn">
                <div each={freq, idx in freqml} class="card">
                    <div class="card-content">
                        <i if={idx != 0 || freqml.length > 1}
                                class="close material-icons grey-text material-clickable"
                                onclick={parent.onRemoveClick.bind(this, idx)}>close</i>
                        <div>
                            <ui-filtering-list
                                inline={true}
                                label={_("frq.freqDistAttr")}
                                riot-value={freq.attr}
                                name="attr"
                                floating-dropdown=1
                                value-in-search=1
                                open-on-focus=1
                                options={attrList}
                                size={maxAttrLength}
                                tooltip="t_id:conc_r_freq_a_attribute"
                                on-change={onAttrChange.bind(this, idx)}>
                            </ui-filtering-list>
                        </div>
                        <context-selector
                            if={showContextSelector(freq.attr)}
                            data-idx={idx}
                            range=6
                            riot-value={freq.ctx}
                            name="ctx"
                            kwic-label={getContextKwicLabel(freq.base)}
                            label-id="position"
                            on-change={onCtxChange.bind(this, idx)}></context-selector>
                        <div class="baseSelect">
                            <ui-select class="narrowCtx"
                                    label="Base"
                                    name="base"
                                    inline=1
                                    riot-value={getContextKwicLabel(freq.base)}
                                    options={baseList}
                                    on-change={onBaseChange.bind(this, idx)}></ui-select>
                        </div>
                        <ul id='dd_freqBase_{idx}' class='dropdown-content'>
                            <li each={item in baseList} onclick={onBaseChange.bind(this, idx, item.value)}>
                                <span>{item.label}</span>
                            </li>
                        </ul>
                    </div>
                </div>
                <div class="center-align">
                    <a if={freqml.length < 4}
                            id="btnAddFrequency"
                            class="btn btn-floating btn-small"
                            onclick={onAddClick}>
                        <i class="material-icons color-blue-800">add</i>
                    </a>
                </div>
                <div if={freqml.length == 4} class="columnLimit">{_("frq.freqmlLimit")}</div>
                <br>

                <ui-checkbox name="f_group"
                        checked={data.f_group}
                        label-id="groupByFirstCol"
                        disabled={freqml.length < 2}
                        on-change={onGroupChange}></ui-checkbox>
                <div class="primaryButtons buttonGo">
                    <a id="btnGoFreqAdv" class="btn btn-primary" disabled={data.isLoading} onclick={onSearch}>{_("go")}</a>
                </div>
            </div>
            <div class="frequency-quick-list">
                <frequency-links-column column={presetLinksColumn}></frequency-links-column>
            </div>
        </div>
    </div>
    <floating-button on-click={onSearch}
        name="btnGoFloat"
        periodic=1
        refnodeid="btnGoFreqAdv"></floating-button>

    <script>
        require("./frequency-tab-advanced.scss")
        require("./frequency-links-column.tag")
        require("concordance/context-selector/context-selector.tag")

        this.mixin("feature-child")

        this.maxAttrLength = Math.max(...this.store.attrList.map(a => a.label.length)) || ""
        this.freqml = copy(this.data.f_freqml)
        this.base = {
            value: "kwic",
            label: "KWIC"
        }
        this.baseList = [{
            value: "kwic",
            label: "KWIC"
        }, {
            value: "first_kwic_word",
            label: _("firstKwicWord")
        }, {
            value: "last_kwic_word",
            label: _("lastKwicWord")
        }]
        if(this.data.raw){
            for(let i = 1; i <= this.data.raw.numofcolls; i++){
                this.baseList.push({
                    value: i,
                    label: _("nthCollocation", [i])
                })
            }
        }

        let structList = copy(this.store.structList).filter(s => s.value != "g").map(s => {
            s.label = s.label + " IDs"
            return s
        })
        this.attrList = this.store.attrList.concat(this.store.refList).concat(structList)

        let textTypes = this.store.getAllTextTypes()

        let links = [{
            id: "words_kwic",
            labelId: "frq.kwicForms",
            tooltip: "t_id:conc_r_freq_words_kwic",
            href: this.store.f_getContextLink(0, "kwic", "word", "advanced")
        }, {
            id: "tags_kwic",
            labelId: "frq.kwicTags",
            tooltip: "t_id:conc_r_freq_tags_kwic",
            href: this.store.f_getContextLink(0, "kwic", "tag", "advanced")
        }, {
            id: "lemmas_kwic",
            labelId: "kwicLemmas",
            tooltip: "t_id:conc_r_freq_lemmas_kwic",
            href: this.store.f_getContextLink(0, "kwic", "lemma", "advanced")
        }]
        textTypes.length && links.push({
            id: "textTypes",
            labelId: "textTypes",
            tooltip: "t_id:conc_r_freq_text_types",
            href: this.store.f_getLink({
                f_texttypes: textTypes
            }, "texttypes", "advanced")
        })
        let lineDetails = this.store.f_getLineDetailsTextTypes()
        links.push({
            id: "lineDetails",
            labelId: "lineDetails",
            tooltip: "t_id:conc_r_freq_line_details",
            disabled: !lineDetails.length,
            href: this.store.f_getLink({
                f_texttypes: lineDetails
            }, "texttypes", "advanced")
        })
        this.presetLinksColumn = {
            labelId: "frq.morePresets",
            links: links
        }

        onSearch(){
            this.store.f_searchAndAddToHistory({
                f_texttypes: [],
                f_freqml: this.freqml,
                f_mode: "multilevel",
                f_page:1
            })
        }

        onResetClick(evt){
            this.reset()
        }

        onAttrChange(idx, attr){
            this.freqml[idx].attr = attr || "word"
            this.update()
        }

        onCtxChange(idx, ctx, name, evt){
            this.freqml[idx].ctx = ctx
            this.update()
        }

        onGroupChange(checked){
            this.data.f_group = checked ? 1 : null
        }

        onAddClick(){
            this.freqml.push({
                ctx: 0,
                base: "kwic",
                attr: "word"
            })
            this.initDropdown()
        }

        onRemoveClick(idx, evt){
            evt.stopPropagation()
            this.freqml.splice(idx, 1)
        }

        onBaseChange(idx, base){
            this.freqml[idx].base = base
            this.update()
        }

        reset(){
            this.freqml = copy(this.store.defaults.f_freqml)
            this.f_group = this.store.defaults.f_group
        }

        initDropdown(){
            $("context-selector", this.root).each(function(idx, contextElem){
                if(!$(contextElem).find(".dropdown-trigger").length){
                    let rowIdx = $(contextElem).data("idx")
                    let btn = $("<a href=\"\" class=\"dropdown-trigger kwicBaseDropdown\" data-target=\"dd_freqBase_" + rowIdx + "\"> <i class=\"material-icons\" >arrow_drop_down</i></a>")
                    btn.insertAfter($(contextElem).find(".kwicBtn"))
                    btn.dropdown({
                        alignment: 'right',
                        constrainWidth: false
                    })
                }
            }.bind(this))
        }

        getContextKwicLabel(base){
            return this.baseList.find(i => {
                return i.value == base
            }).label
        }

        showContextSelector(attr){
            return this.store.attrList.findIndex(a => a.value == attr) != -1
        }

        this.on("updated", () => {
            this.initDropdown()
        })

        this.on("before-mount", () => {
            !this.data.f_freqml.length && this.reset()
        })

        this.on("mount", () => {
            this.initDropdown()
        })
    </script>
</concordance-frequency-tab-advanced>
