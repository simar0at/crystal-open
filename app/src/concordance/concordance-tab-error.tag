<concordance-tab-error class="concordance-tab-error relative">
    <a onclick={onResetClick}
            data-tooltip={_("resetOptionsTip")}
            class="cffTooltip resetOptions btn btn-floating btn-flat">
        <i class="material-icons color-blue-800">settings_backup_restore</i>
    </a>
    <preloader-spinner if={isLoading}
            overlay=1
            center=1></preloader-spinner>
    <div if={!isLoading}
            class="row">
        <div class="col s12 m6 l4">
            <ui-select options={errTypeOptions}
                    name="errcorr_switch"
                    riot-value={data.errcorr_switch}
                    on-change={onErrCorrSwitch}></ui-select>
        </div>
        <div class="col s11 m5 l4">
            <ui-select if={data.errcorr_switch == "err"}
                    label-id="cc.errCode"
                    options={store.errCodeList}
                    riot-value={data.cup_err_code}
                    name="cup_err_code"
                    on-change={onInput}>
            </ui-select>
            <ui-select  if={data.errcorr_switch == "corr"}
                    label-id="cc.corrCode"
                    options={store.corrCodeList}
                    riot-value={data.cup_err_code}
                    name="cup_err_code"
                    on-change={onInput}>
            </ui-select>
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

    <text-types ref="texttypes"
                collapsible=1
                selection={data.tts}
                on-change={onTtsChange}></text-types>

    <div class="primaryButtons">
        <a id="btnSearchError"
                class="btn btn-primary leftPad"
                onclick={onSearch}>{_("search")}</a>
    </div>
    <floating-button id="btnErrorGoFloat"
            on-click={onSearch}
            refnodeid="btnSearchError"
            periodic="1">
    </floating-button>

    <script>
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        this.mixin("feature-child")

        this.isLoading = this.store.errCodeList === null || this.store.corrCodeList === null

        resetCupErrCodeValue(){
            let activeList = this.store[this.data.errcorr_switch == "err" ? "errCodeList" : "corrCodeList"]
            if(activeList && activeList.length){
                this.data.cup_err_code = activeList[0].value
            }
        }

        refreshErrTypeList(){
            this.errTypeOptions = []
            if(this.store.corrCodeList && this.store.corrCodeList.length){
                this.errTypeOptions.push({
                    "value": "corr",
                    "label": _("cc.corrCode")
                })
            }
            if(this.store.errCodeList && this.store.errCodeList.length){
                this.errTypeOptions.push({
                    "value": "err",
                    "label": _("cc.errCode")
                })
            }
        }
        this.refreshErrTypeList()

        this.hlOptions = ["q", "e", "c", "b"].map(o => ({
            label: _('cc.hlOpt' + o),
            value: o
        }))

        onErrCorrSwitch(value){
            this.store.changeValue(value, "errcorr_switch")
            this.resetCupErrCodeValue()
        }

        onInput(value, name, event) {
            this.store.changeValue(value, name)
        }

        onTtsChange(tts){
            this.store.data.tts = tts
        }

        onSearch(){
            this.data.closeFeatureToolbar = true
            this.store.searchAndAddToHistory()
        }

        onResetClick(){
            this.store.setDefaultSearchOptions()
            ;["errcorr_switch", "cup_err", "cup_corr", "cup_hl"].forEach(option => {
                this.data[option] = this.store.defaults[option]
            })
            this.resetCupErrCodeValue()
            this.update()
            this.refs.texttypes.reset()
        }

        onErrCorrListLoaded(){
            this.isLoading = !this.store.corrCodeList || !this.store.errCodeList
            this.refreshErrTypeList()
            !this.data.cup_err_code && this.resetCupErrCodeValue()
            this.update()
        }

        this.on("mount", () => {
            this.store.on("errCorrListLoaded", this.onErrCorrListLoaded)
            delay(() => {
                $('input[name="cup_err"]:visible', this.root).focus()
            }, 1)
        })

        this.on("before-unmount", () => {
            this.store.off("errCorrListLoaded", this.onErrCorrListLoaded)
        })
    </script>
</concordance-tab-error>
