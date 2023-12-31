<page-open class="page-open">
    <div class="pt-2">
        <div class="form card mt-0">
            <div class="openCorpora">
                <h5>{_("cp.freeCorpora")}</h5>
                <div if={isLoading} class="center-align" style="padding: 80px 0 100px">
                    <preloader-spinner></preloader-spinner>
                </div>
                <table if={!isLoading} class="corpusTable material-table z-depth-1">
                    <tbody>
                        <tr each={corpus in corpusList}>
                            <td>{corpus.language}</td>
                            <td>{corpus.name}</td>
                            <td class="num grey-text">{window.Formatter.num(corpus.sizes.wordcount)}&nbsp;{_("wordP")}</td>
                            <td class="buttons">
                                <a href="javascript:void(0);"
                                        class="btn white-text"
                                        onclick={onCorpusClick}>
                                    {_("open")}
                                </a>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <br><br>

                <div if={!window.config.NO_CA}>
                    <h5>{_("cp.openCorporaTitle")}</h5>
                    {_("cp.openCorporaNote")}
                    <br><br>
                    <div class="center-align">
                        <a href={window.config.URL_RASPI + "#register"} class="btn btn-primary">
                            {_("getAccess")}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./page-open.scss")
        const {AppStore} = require("core/AppStore.js")

        updateAttributes(){
            this.isLoading = !AppStore.data.corpusListLoaded || !AppStore.data.languageListLoaded
            this.corpusList = []
            if(AppStore.data.languageListLoaded){
                this.corpusList = AppStore.get("corpusList").filter(c => c.user_can_read)
                this.corpusList.forEach(c => {
                    c.language = AppStore.getLanguage(c.language_id).name
                })
                this.corpusList.sort((a, b) => {
                    if(a.language == b.language){
                        return a.name.localeCompare(b.name)
                    }
                    return a.language.localeCompare(b.language)
                })
            }
        }
        this.updateAttributes()

        onCorpusClick(evt){
            let corpname =evt.item.corpus.corpname
            AppStore.checkAndChangeCorpus(corpname)
            Dispatcher.trigger("ROUTER_GO_TO", "dashboard", {corpname: corpname})
        }

        updateOpenCorporaList(){
            this.updateAttributes()
            this.update()
        }

        this.on("mount", () => {
            AppStore.on("corpusListChanged", this.updateOpenCorporaList)
            AppStore.on("languageListLoaded", this.updateOpenCorporaList)
        })

        this.on("unmount", () => {
            AppStore.off("corpusListChanged", this.updateOpenCorporaList)
            AppStore.off("languageListLoaded", this.updateOpenCorporaList)
        })
    </script>
</page-open>
