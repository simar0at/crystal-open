<concordance-tab-error class="concordance-tab-error">
    <div class="row">
        <div class="col s12 m6 l4">
            <ui-select options={errOptions}
                    name="errcorr_switch"
                    riot-value={data.errcorr_switch}
                    on-change={onInput}></ui-select>
        </div>
        <div class="col s11 m5 l4">
            <!-- TODO: get attr_vals from Bonito and show ui-select -->
            <ui-input placeholder={_("abc")}
                    label-id={data.errcorr_switch == 'err' ? "cc.errCode" : 'cc.corrCode'}
                    riot-value={data.cup_err_code}
                    name="cup_err_code"
                    on-submit={onSearch}
                    ref="errcorr"
                    on-input={onInput}
                    size="8">
            </ui-input>
        </div>
        <div class="col s1 m1 l1">
            <a href={corpus.errsetdoc} target="_blank" title={_("cc.errCodeLink")}>
                <i class="material-icons"
                        style="line-height: 3em;">info_outline</i>
            </a>
        </div>
    </div>
    <div class="row">
        <div class="col s12 m6 l4">
            <ui-input name="cup_err" riot-value={data.cup_err}
                    on-submit={onSearch}
                    on-input={onInput}
                    label-id="cc.errWords">
            </ui-input>
        </div>
        <div class="col s12 m6 l4">
            <ui-input name="cup_corr" riot-value={data.cup_corr}
                    on-submit={onSearch}
                    on-input={onInput}
                    label-id="cc.corrWords">
            </ui-input>
        </div>
    <div class="row">
        <div class="col s12">
            <ui-radio name="cup_hl" riot-value={data.cup_hl} options={hlOptions}
                    label-id="cc.hlOptions" on-change={onInput}>
            </ui-radio>
        </div>
    </div>
    <text-types-collapsible if={data.tab=="error"}></text-types-collapsible>
    <a id="btnSearchError"
            class="btn contrast leftPad {disabled: !(data.cup_err+data.cup_corr)}"
            onclick={onSearch}>{_("search")}</a>
    <floating-button id="btnGoFloat" onclick={onSearch}
            refnodeid="btnSearchError" periodic="1">
    </floating-button>

    <script>
        this.mixin("feature-child")

        this.errOptions = [
            {
                "value": "err",
                "label": _("cc.errCode")
            },
            {
                "value": "corr",
                "label": _("cc.corrCode")
            }
        ]
        let hls = 'ecbq'
        this.hlOptions = []
        for (let i=0; i<hls.length; i++) {
            this.hlOptions.push({
                label: _('cc.hlOpt' + hls[i]),
                value: hls[i]
            })
        }

        onInput(value, name, event) {
            this.store.changeValue(value, name)
        }

        onSearch(){
            this.store.searchAndAddToHistory()
        }

        this.on("mount", () => {
            delay(() => {
                $('input[name="cup_err"]:visible', this.root).focus()
            }, 1)
        })
    </script>
</concordance-tab-error>
