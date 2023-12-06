<parconcordance-result-options-freq-advanced class="parconcordance-result-options-freq">
    <div class="card-content">
        <a onclick={onResetClick} class="resetOptions btn btn-floating btn-flat">
            <i class="material-icons color-blue-800">settings_backup_restore</i>
        </a>
        <div class="columns">
            <div class="freqmlContainer inline-block leftColumn">
                <div each={freq, idx in freqml} class="card">
                    <div class="card-content">
                        <i class="close material-icons grey-text material-clickable"
                                if={idx != 0}
                                onclick={onRemoveClick.bind(this, idx)}>close</i>
                        <div>
                            <ui-filtering-list inline={true}
                                    riot-value={freq.attr}
                                    name="attr"
                                    floating-dropdown=1
                                    value-in-search=1
                                    open-on-focus=1
                                    options={attrList}
                                    on-change={onAttrChange.bind(this, idx)}>
                            </ui-filtering-list>
                        </div>
                        <context-selector range=6
                                min-wdith=700
                                data-idx={idx}
                                range=6
                                riot-value={freq.ctx}
                                name="ctx"
                                kwic-label={getContextKwicLabel(freq.base)}
                                label-id="position"
                                on-change={onCtxChange.bind(this, idx)}></context-selector>
                        <ul id='dd_freqBase_{idx}' class='dropdown-content'>
                            <li each={item in baseList} onclick={onBaseChange.bind(this, idx, item.value)}>
                                <span>{item.label}</span>
                            </li>
                        </ul>
                    </div>
                </div>
                <div class="center-align">
                    <a if={freqml.length < 10}
                            id="btnAddFrequency"
                            class="btn btn-floating btn-small"
                            onclick={onAddClick}>
                        <i class="material-icons color-blue-800">add</i>
                    </a>
                </div>
                <div if={freqml.length == 10}>{_("frq.freqmlLimit")}</div>
                <br>

                <ui-checkbox name="f_group"
                        checked={data.f_group}
                        label-id="groupByFirstCol"
                        disabled={freqml.length < 2}
                        on-change={onGroupChange}></ui-checkbox>
                <div class="primaryButtons">
                    <button id="btnGoFreqAdv"
                            class="btn btn-primary"
                            onclick={onGoClick}>{_("go")}
                    </button>
                </div>
                <br />
            </div>
            <div class="frequency-quick-list pcfr-links">
                <frequency-links-column column={presetLinksColumn}></frequency-links-column>
            </div>
        </div>
    </div>
    <floating-button on-click={onGoClick}
            name="btnGoFloat"
            periodic=1
            refnodeid="btnGoFreqAdv">
    </floating-button>

    <script>
        require("./parconcordance-result-options-freq.scss")
        require("../concordance/context-selector/context-selector.tag")
        const {AppStore} = require('core/AppStore.js')
        this.mixin('feature-child')

        this.has_tags = !!AppStore.getAttributeByName("tag")
        this.has_lemmas = !!AppStore.getAttributeByName("lemma")
        this.freqml = this.data.freqml

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

        this.attrList = this.store.attrList.concat(this.store.refList)

        onResetClick(evt){
            this.freqml = copy(this.store.defaults.freqml)
            this.f_group = this.store.defaults.f_group
        }

        onGoClick() {
            let freqDesc = this.freqml.map(freq => {
                return freq.attr + " " + freq.ctx
            }).join(", ")
            this.store.data.freqDesc = freqDesc
            this.store.f_searchAndAddToHistory({
                f_mode: "multilevel",
                freqml: this.freqml,
                alignedCorpname: this.alignedCorpname
            })
        }

        this.alignedCorpname = this.parent.parent.opts.corpname
        let textTypes = this.store.getAllTextTypes()
        let links = [{
            id: "words_kwic",
            labelId: "frq.kwicForms",
            tooltip: "t_id:conc_r_freq_words_kwic",
            href: this.store.f_getContextLink(0, "kwic", "word", this.alignedCorpname, "advanced")
        }, {
            id: "tags_kwic",
            labelId: "frq.kwicTags",
            tooltip: "t_id:conc_r_freq_tags_kwic",
            href: this.store.f_getContextLink(0, "kwic", "tag", this.alignedCorpname, "advanced")
        }, {
            id: "lemmas_kwic",
            labelId: "kwicLemmas",
            tooltip: "t_id:conc_r_freq_lemmas_kwic",
            href: this.store.f_getContextLink(0, "kwic", "lemma", this.alignedCorpname, "advanced")
        }]
        textTypes.length && links.push({
            id: "words_kwic",
            labelId: "textTypes",
            tooltip: "t_id:conc_r_freq_text_types",
            href: this.store.f_getLink({
                f_texttypes: textTypes,
                alignedCorpname: this.alignedCorpname
            }, "texttypes", "advanced")
        })
        let lineDetails = this.store.f_getLineDetailsTextTypes()
        links.push({
            tooltip: "t_id:conc_r_freq_line_details",
            labelId: "lineDetails",
            disabled: !lineDetails.length,
            href: this.store.f_getLink({
                alignedCorpname: this.alignedCorpname,
                f_texttypes: lineDetails
            }, "texttypes", "advanced")
        })
        this.presetLinksColumn = {
            labelId: "frq.morePresets",
            links: links
        }

        onAttrChange(idx, attr){
            if(!attr){
                attr = "word"
            }
            this.freqml[idx].attr = attr
            this.update()
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

        onCtxChange(idx, ctx, name, evt){
            this.freqml[idx].ctx = ctx
            this.update()
        }

        onGroupChange(checked){
            this.data.f_group = checked ? 1 : null
        }

        onBaseChange(idx, base){
            this.freqml[idx].base = base
            this.update()
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

        this.on("updated", () => {
            this.initDropdown()
        })

        this.on("mount", () => {
            this.initDropdown()
        })
    </script>
</parconcordance-result-options-freq-advanced>
