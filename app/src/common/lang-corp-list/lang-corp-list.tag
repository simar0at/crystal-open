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

        optionGenerator(item){
            let html = '<span class=\"cLabel\">' + (item.autonym ? item.autonym : item.label)
            if(item.autonym){
                html += ' (' + item.label + ')'
            }
            html += '</span>'
            return html
        }

        refreshLangCorpList(){
            this.options = AppStore.get("availableLanguageList")
                    .filter(l => !!l.reference_corpus)
                    .map(l => {
                        return {
                            value: l.reference_corpus,
                            label: l.name,
                            autonym: l.autonym,
                            search: [l.autonym], // for ui-filtering list to search in autonym too
                            generator: this.optionGenerator
                        }
                        return l
                    }, this)
                    .sort((a, b) => {
                        return a.label.localeCompare(b.label)
                    })
        }
        this.refreshLangCorpList()

        onCorpusListLoad(corpusList){
            this.loading = false
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
