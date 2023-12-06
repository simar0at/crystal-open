<corpus-history class="corpus-history">
    <div class="content z-depth-1">
        <table if={list.length} class="table material-table highlight">
            <tbody class="noBorder">
                <tr each={corpus in list} onclick={onCorpusChange}>
                    <td>{corpus.name}</td>
                    <td class="hide-on-small-only">{corpus.language}</td>
                    <td class="size hide-on-small-only">{getCorpSize(corpus)}</td>
                    <td class="size hide-on-small-only">
                        <a class='delete iconButton btn-flat btn-floating hide-on-small-only tooltipped'
                            data-tooltip={_("removeCorpusFromList")}
                            onclick={onCorpusDeleteClick}>
                            <i class='material-icons'>delete</i>
                        </a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <span if={!list.length}>
        {_("nothingHere")}
    </span>

    <script>
        require("./corpus-history.scss")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("tooltip-mixin")

        getCorpSize(corpus){
            return window.Formatter.num(corpus.size)
        }

        refreshAttributes(){
            let corpusHistory = UserDataStore.get("corpora")
            this.list = []
            if(AppStore.get("corpusListLoaded")){
                this.list = corpusHistory.filter(corpus => {
                    return !!AppStore.getCorpusByCorpname(corpus.corpname)
                }).map((corpus) => {
                    return {
                        corpname: corpus.corpname,
                        name: corpus.name,
                        language: corpus.language,
                        size: corpus.size,
                        favourite: corpus.favourite
                    }
                }).reverse()
            }
        }
        this.refreshAttributes()

        onCorpusChange(evt){
            AppStore.checkAndChangeCorpus(evt.item.corpus.corpname)
            window.scrollTo(0, 0)
        }

        onCorpusDeleteClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            UserDataStore.removeCorpusFromHistory(evt.item.corpus.corpname)
        }

        this.on("update", this.refreshAttributes)

        this.on("mount", () => {
            UserDataStore.on("corporaChange", this.update)
            AppStore.on("corpusListChanged", this.update)
        })

        this.on("unmount", () => {
            UserDataStore.off("corporaChange", this.update)
            AppStore.off("corpusListChanged", this.update)
        })
    </script>

    <style>

    </style>
</corpus-history>
