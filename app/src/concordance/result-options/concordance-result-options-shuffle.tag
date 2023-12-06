<concordance-result-options-shuffle class="concordance-result-options-shuffle">
    <external-text text="conc_r_shuffle"></external-text>
    <br>
    <div class="center">
        <a id="btnGoShuffle" class="btn contrast" onclick={onShuffleClick}>
            {_("shuffle")}
        </a>
    </div>

    <script>
        this.mixin("feature-child")

        onShuffleClick(){
            this.store.shuffle()
        }
    </script>
</concordance-result-options-shuffle>
