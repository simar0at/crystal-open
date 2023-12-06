<parconcordance-translations class="parconcordance-translations">
    <span if={store.isConc && !store.data.isError && !store.data.isLoading}>
        <span if={store.translations.isLoading}>
            {_("locatingTranslations")}
            <span class='dotsAnimation'><span>...</span></span>
        </span>
        <span if={!store.translations.isLoading && store.translations.loaded}
                id="parconc_translation">
            {_(store.translations.found ? "translationsLocated" : "translationsNotFound")}
        </span>
    </span>

    <script>
        this.mixin("feature-child")

        this.on("mount", () => {
            this.store.on("translations_loaded", this.update)
        })

        this.on("unmount", () => {
            this.store.off("translations_loaded", this.update)
        })
    </script>
</parconcordance-translations>
