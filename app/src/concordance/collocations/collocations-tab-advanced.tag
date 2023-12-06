<collocations-tab-advanced class="collocations-tab-advanced">
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")} class="tooltipped resetOptions btn btn-floating btn-flat">
        <i class="material-icons color-blue-800">settings_backup_restore</i>
    </a>
    <div class="columns">
        <collocations-form></collocations-form>

        <span class="inline-block colFuncs">
            <ui-list label-id="col.showFuncs"
                inline=1
                value={options.c_cbgrfns}
                name="cbgrfns"
                multiple=1
                options={funcList}
                tooltip="t_id:conc_r_coll_cbgrfns"
                on-change={onCbgrfnsChange}></ui-list>
        </span>
        <span class="inline-block">
            <div>
                <ui-input
                    inline=0
                    type="number"
                    min="0"
                    name="c_cminfreq"
                    size=4
                    on-change={onOptionChange}
                    label-id="col.cminfreq"
                    tooltip="t_id:conc_r_coll_cminfreq"
                    riot-value={options.c_cminfreq}></ui-input>
            </div>
            <div>
                <ui-input
                    inline=1
                    type="number"
                    min="0"
                    name="c_cminbgr"
                    size=4
                    on-change={onOptionChange}
                    label-id="col.cminbgr"
                    tooltip="t_id:conc_r_coll_cminbgr"
                    riot-value={options.c_cminbgr}></ui-input>
            </div>
            <div>
                <ui-checkbox label-id="singleColumn"
                    name="c_onecolumn"
                    checked={data.c_onecolumn}
                    tooltip="t_id:conc_r_coll_onecolumn"
                    on-change={onOneColumnChange}></ui-checkbox>
            </div>
        </span>
    </div>

    <div class="primaryButtons">
        <br>
        <a class="btn btn-primary" id="btnCollAGo" onclick={onSearch} disabled={data.c_isLoading}>{_("go")}</a>
    </div>
    <floating-button on-click={onSearch}
        name="btnGoFloat"
        periodic=1
        refnodeid="btnCollAGo"></floating-button>

    <script>
        this.mixin("feature-child")

        this.funcList = this.data.c_funlist.map( f => {
            return {
                label: this.store.c_getFunLabel(f),
                value: f
            }
        })
        this.options = {
            c_cattr: this.data.c_cattr,
            c_cbgrfns: this.data.c_cbgrfns,
            c_cminfreq: this.data.c_cminfreq,
            c_cminbgr: this.data.c_cminbgr,
            c_cfromw: this.corpus.righttoleft ? -this.data.c_ctow : this.data.c_cfromw,
            c_ctow: this.corpus.righttoleft ? -this.data.c_cfromw : this.data.c_ctow,
            c_customrange: this.data.c_customrange
        }

        onSearch(){
            let options = Object.assign({
                c_page: 1
            }, this.options)
            if(this.store.feature == "parconcordance"){
                options.alignedCorpname = this.parent.parent.parent.parent.opts.corpname
            }
            this.store.c_searchAndAddToHistory(options)
        }

        changeValue(value, name){
            this.changeData({
                [name]: value
            })
        }

        onResetClick(){
            this.store.resetGivenOptions(this.options)
            this.data.c_onecolumn = this.store.defaults.c_onecolumn
        }

        onOneColumnChange(onecolumn){
            this.store.changeValue(onecolumn, "c_onecolumn")
        }

        changeData(options){
            Object.assign(this.options, options)
            this.update()
        }

        onCbgrfnsChange(value){
             if(!value.length){
                value.push(this.data.c_funlist[0])
            }
            this.options.c_cbgrfns = value
        }

        onOptionChange(value, name){
            this.options[name] = value
        }
    </script>
</collocations-tab-advanced>
