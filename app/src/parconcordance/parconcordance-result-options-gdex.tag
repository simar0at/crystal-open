<parconcordance-result-options-gdex class="parconcordance-result-options-gdex">
    <external-text text="conc_r_gdex"></external-text>
    <br><br>
    <div style="display:table; margin: 0 auto;">
        <ui-input
            ref="gdexcnt"
            type="number"
            name="gdexcnt"
            size={4}
            value={data.gdexcnt}
            label-id="cc.gdexcnt"
            on-submit={onSaveClick}
            tooltip="t_id:conc_r_gdex_gdexcnt"></ui-input>
        <ui-select
                label={_("cc.gdexConfigs")}
                name="gdexconf"
                ref="gdexconf"
                options={gdexconfs}
                riot-value={data.gdexconf}
                on-change={onSelectGDEXConf}>
        </ui-select>
        <ui-checkbox
            label={_("cc.showGdexScore")}
            name="show_gdex_scores"
            checked={data.show_gdex_scores}
            on-change={onShowScoresChange}
            tooltip="t_id:conc_r_gdex_gdex_score"></ui-checkbox>
        <div class="primaryButtons">
            <br>
            <a id="btnGoGdex" class="btn btn-primary" onclick={onSaveClick}>{_("go")}</a>
        </div>
    </div>


    <script>
        const {Auth} = require("core/Auth.js")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")
        this.show_gdex_scores = this.data.show_gdex_scores
        this.gdexconfs = []

        updateAttributes(){
            this.gdexconfs = AppStore.get("gdexConfsLoaded") ? AppStore.get("gdexConfs") : []
        }
        this.updateAttributes()


        onShowScoresChange(checked){
            this.show_gdex_scores = checked
        }

        onSelectGDEXConf(value, name, event) {
            this.data.gdexconf = value
            this.store.updateUrl()
            this.update()
        }

        if(Auth.isAnonymous()){
            this.gdexconfs = [{'label': _("cc.gdexDefault"), 'value': '__default__'}]
        } else{
            AppStore.loadGDEXConfs()
        }

        onSaveClick(){
            this.data.closeFeatureToolbar = true
            this.store.searchAndAddToHistory({
                gdexcnt: this.refs.gdexcnt.getValue(),
                page: 1,
                sort: [],
                gdex_enabled: true,
                gdexconf: this.refs.gdexconf.value,
                show_gdex_scores: this.show_gdex_scores,
                viewmode: "sen"
            })
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            AppStore.on("gdexConfsLoaded", this.update)
            delay(() => {$("input", this.refs.gdexcnt.root).focus()}, 400) // card show animation duration
        })

        this.on("unmount", () => {
            AppStore.off("gdexConfsLoaded", this.update)
        })
    </script>
</parconcordance-result-options-gdex>
