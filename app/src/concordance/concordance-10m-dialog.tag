<concordance-10m-dialog>
    <h4>
        {_(opts.random ? "cc.randomLines" : "cc.first10MLines")}
    </h4>
    <span>
        {_(opts.random ? "cc.usingRandomLines" : "cc.usingFirst10MLines")}
    </span>
    <br><br>
    <div class="center-align">
        <a class="btn" onclick={onBtnClicked}>{_(opts.random ? "cc.first10MLines" : "cc.randomLines")}</a>
    </div>

    <script>
        this.mixin("feature-child")

        onBtnClicked(evt){
            evt.stopPropagation()
            let options = {
                random: !this.opts.random
            }
            this.store.isConc && this.store.searchAndAddToHistory(options)
            this.store.isFreq && this.store.f_searchAndAddToHistory(options)
            this.store.isColl && this.store.c_searchAndAddToHistory(options)
            Dispatcher.trigger("closeDialog", "concordance10M")
        }
    </script>
</concordance-10m-dialog>
