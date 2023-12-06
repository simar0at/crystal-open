<interfeature-menu-macro-dialog class="interfeature-menu-macro-dialog">
    <div each={macro in macros}
            class="doubleLinks pt-1 pb-1">
        <a class="currentTabLink"
                href="{macro.link}">
            <i class="ske-icons skeico_concordance mr-4 vertical-middle" style="font-size: 24px;"></i>
            {truncate(macro.name, 80)}
        </a>
        <a target="_blank"
                href={macro.link}
                class="newTabLink menu-tooltip">
            <i class="material-icons">open_in_new</i>
        </a>
    </div>

    <script>
        require("./interfeature-menu-macro-dialog.scss")

        const {MacroStore} = require("common/manage-macros/macrostore.js")


        getLink(macro){
            let params = stores.concordance.getFeatureLinkParams(this.opts.params, macro.id)
            return window.stores.concordance.getUrlToResultPage(params)
        }

        this.macros = MacroStore.data.macros.map(macro => {
            return {
                name: macro.name,
                link: this.getLink(macro)
            }
        })
    </script>
</interfeature-menu-macro-dialog>
