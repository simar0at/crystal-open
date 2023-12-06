<concordance-quick-filters class="concordance-quick-filters right">
    <label for="">{_("cc.quickFilters")}: </label>
    <a href="" id="btnSubHits"  class="link btn tooltipped" onclick={onSubHitsClick} data-tooltip="t_id:conc_r_filter_subhits">{_("cc.filterSubHits")}</a>
    <a href="" id="btnFirstHit" class="link btn tooltipped" onclick={onFirstHitClick} data-tooltip="t_id:conc_r_filter_firsthit">{_("filterFirstHit")}</a>

    <script>
        require("./concordance-quick-filters.scss")
        this.mixin("feature-child")

        onFirstHitClick(evt){
            evt.preventDefault()
            this.store.firstHit()
        }

        onSubHitsClick(evt){
            evt.preventDefault()
            this.store.subHits()
        }
    </script>
</concordance-quick-filters>
