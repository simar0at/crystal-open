<collocations-tab-basic class="collocations-tab-basic">
    <a onclick={onResetClick} data-tooltip={_("resetOptionsTip")} class="tooltipped resetOptions btn btn-floating btn-flat">
        <i class="material-icons dark">settings_backup_restore</i>
    </a>
    <collocations-form hide-custom-range={true}></collocations-form>

    <div class="center-align">
        <br>
        <a class="btn contrast" id="btnCollBGo" onclick={onSearch} disabled={data.isLoading}>{_("go")}</a>
    </div>
    <floating-button onclick={onSearch}
        name="btnGoFloat"
        periodic=1
        refnodeid="btnCollBGo"></floating-button>

    <script>
        this.mixin("feature-child")

        this.options = {
            c_cattr: this.data.c_cattr,
            c_cfromw: this.corpus.righttoleft ? -this.data.c_ctow : this.data.c_cfromw,
            c_ctow: this.corpus.righttoleft ? -this.data.c_cfromw : this.data.c_ctow
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
        }

        changeData(options){
            Object.assign(this.options, options)
            this.update()
        }
    </script>
</collocations-tab-basic>
