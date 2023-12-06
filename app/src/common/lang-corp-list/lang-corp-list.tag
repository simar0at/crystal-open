<lang-corp-list class="lang-corp-list">
    <ui-filtering-list options={options}
        riot-value={corpname}
        floating-dropdown={true}
        inline=true
        name={opts.name}
        loading={loading}
        white=true
        autocomplete={opts.autocomplete}
        open-on-focus=true
        value-in-search={opts.valueInSearch}
        deselect-on-click={false}
        on-change={onChange}></ui-filtering-list>

    <script>
        require ('./lang-corp-list.scss')
        const {AppStore} = require('core/AppStore.js')
        const {Router} = require('core/Router.js')

        this.loading = !AppStore.get("corpusListLoaded")

        onChange(corpname, name, label, option){
            AppStore.checkAndChangeCorpus(corpname)
            AppStore.one("corpusChanged", () => {
                let feature = Router.getActualFeature()
                let page = AppStore.hasCorpusFeature(feature) ? feature : "dashboard"
                if(page != Router.getActualPage()){
                    Dispatcher.trigger("ROUTER_GO_TO", page, {corpname: corpname});
                }
            })
            isFun(opts.onChange) && this.opts.onChange(corpname)
        }

        corpLangGenerator(item){
            let html = '<i class=\"material-icons\">'
                    + "language"
                    + '</i><span class=\"cLabel\">' + item.label + "</span>"
            return html
        }

        refreshLangCorpList(){
            this.options = []
            this.loading = false
            const languageList = AppStore.get("availableLanguageList").sort((a, b) => {
                return (a.name > b.name) ? 1 : -1
            })
            languageList.forEach((lang) => {
                if(lang.reference_corpus){
                    this.options.push({
                        value: lang.reference_corpus,
                        label: lang.name,
                        type: "lang",
                        generator: this.corpLangGenerator
                    })
                }
            })
        }
        this.refreshLangCorpList()

        onCorpusListLoad(corpusList){
            this.refreshLangCorpList()
            this.update()
        }

        this.on("mount", () => {
            AppStore.on("corpusChange", this.update)
            AppStore.on("corpusListChanged", this.onCorpusListLoad)
        })

        this.on("unmount", () => {
            AppStore.off("corpusChange", this.update)
            AppStore.off("corpusListChanged", this.onCorpusListLoad)
        })
    </script>
</lang-corp-list>
