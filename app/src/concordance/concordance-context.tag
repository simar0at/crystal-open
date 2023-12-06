<concordance-context class="concordance-context">
    <div class="card">
        <div class="card-content">
            <ui-radio
                name="context"
                riot-value={store.data.showcontext}
                options={contextList}
                on-change={onContextChange}
                ></ui-radio>
            <div if={store.data.showcontext == "lemma"} class="context-type">
                <div class="context-label">{_("cc.onlyKeepLines")}</div>
                <div>
                    <ui-select inline
                        name="fc_lemword_type"
                        value={store.data.fc_lemword_type}
                        on-change={onOptionChange}
                        options={quantityList}
                        width=65></ui-select>
                    <span class="inline-text">{_("of")}</span>
                    <ui-input inline
                        name="fc_lemword"
                        value={store.data.fc_lemword}
                        on-input={onOptionChange}
                        placeholder={_(hasLemma ? "cc.contextLemmaPlaceholder" : "cc.contextWordPlaceholder")}
                        width=300></ui-input>
                    <span class="inline-text">{_("within")}</span>
                    <ui-select inline
                        name="fc_lemword_wsize"
                        value={store.data.fc_lemword_wsize}
                        on-change={onOptionChange}
                        options={tokenList}
                        width=55></ui-select>
                    <span class="inline-text">{_("tokens")}</span>
                    <ui-select inline
                        name="fc_lemword_window_type"
                        value={store.data.fc_lemword_window_type}
                        on-change={onOptionChange}
                        options={positionList}
                        width=150></ui-select>
                </div>
            </div>

            <div if={store.data.showcontext == "pos" && wposlistList.length} class="context-type">
                <div class="context-label">{_("cc.onlyKeepLines")}</div>
                <ui-select inline
                    name="fc_pos_type"
                    value={store.data.fc_pos_type}
                    on-change={onOptionChange}
                    options={quantityList}
                    width=65></ui-select>
                <span class="inline-text">{_("of")}</span>
                <ui-list inline
                    size=3
                    name="fc_pos"
                    multiple={true}
                    value={store.data.fc_pos}
                    on-change={onOptionChange}
                    options={wposlistList}
                    width=200></ui-list>
                <span class="inline-text">{_("within")}</span>
                <ui-select inline
                    name="fc_pos_wsize"
                    value={store.data.fc_pos_wsize}
                    on-change={onOptionChange}
                    options={tokenList}
                    width=55></ui-select>
                <span class="inline-text">{_("tokens")}</span>
                <ui-select inline
                    name="fc_pos_window_type"
                    value={store.data.fc_pos_window_type}
                    on-change={onOptionChange}
                    options={positionList}
                    width=150></ui-select>
            </div>
        </div>
    </div>


    <script>
        const {AppStore} = require("core/AppStore.js")

        require("concordance/concordance-context.scss")

        this.store = this.opts.store

        updateAttributes(){
            this.wposlistList = this.store.corpus.wposlist
            this.hasLemma = !!AppStore.getAttributeByName("lemma")
            this.contextList = [{
                label: _("cc.noContext"),
                value: "none"
            }, {
                label: _(this.hasLemma ? "lemmaContext" : "cc.wordContext"),
                value: "lemma"
            }]
            if(this.wposlistList.length){
                this.contextList.push({
                    label: _("cc.posContext"),
                    value: "pos"
                })
            }
        }
        this.updateAttributes()

        this.quantityList = [{
            value: "all",
            label: _("all")
        }, {
            value: "any",
            label: _("any")
        }, {
            value: "none",
            label: _("none")
        }]

        this.positionList = [{
            value: "left",
            label: _("left")
        }, {
            value: "right",
            label: _("right")
        }, {
            value: "both",
            label: _("leftAndRight")
        }]

        this.tokenList = [1, 2, 3, 4, 5, 7, 10, 15].map((item) => {
            return {
                value: item,
                label: item
            }
        })

        onContextChange(value){
            this._setValue("showcontext", value)
            this.update()
        }

        onOptionChange(value, name){
            this._setValue(name, value)
        }

        _setValue(name, value){
            this.store.data[name] = value
            this.isValid = this._isValid()
            isFun(this.opts.onChange) && this.opts.onChange(this.isValid)
        }

        _isValid(){
            if(this.store.data.showcontext == "lemma"){
                return this.store.data.fc_lemword !== ""
            } else if(this.store.data.showcontext == "pos"){
                return !!this.store.data.fc_pos.length
            }
            return true // no context
        }

        this.on("update", this.updateAttributes)
    </script>
</concordance-context>
