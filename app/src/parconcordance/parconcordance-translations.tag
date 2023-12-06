<parconcordance-translations class="parconcordance-translations">
    <span if={store.isConc && !store.data.isError && !store.data.isLoading}>
        <span if={store.translations.isLoading}>
            {_("locatingTranslations")}
            <span class='dotsAnimation'><span>...</span></span>
        </span>
        <span if={!store.translations.isLoading && store.translations.found} id="parconc_translation">{_("translationsLocated")}</span>
        <span if={!store.translations.isLoading && !store.translations.found} id="parconc_translation">{_("translationsNotFound")}</span>
    </span>

    <script>
        this.mixin("feature-child")
    </script>
</parconcordance-translations>
