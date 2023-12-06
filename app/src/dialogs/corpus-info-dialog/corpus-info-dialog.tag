<corpus-info-dialog class="corpus-info-dialog" style="position: relative;">
    <div if={!data}>
        <preloader-spinner overlay=1></preloader-spinner>
    </div>
    <div if={data}>
        <div class="titleWithButton">
            <span class="title">
                <h4>{data.name}</h4>
                <span class="corpname grey-text hide-on-med-and-down">
                    {data.corpname}
                    <span if={corpusListData && corpusListData.created}>
                        ● {_("created")}
                        {window.Formatter.dateTime(new Date(corpusListData.created))}
                    </span>
                </span>
            </span>
            <a if={window.permissions.ca} href="#ca" class="btn white-text" onclick={closeDialog}>
                {_("manageCorpus")}
            </a>
        </div>
        <div if={data.info} class="grey-text">
            {data.info}
        </div>

        <div class="colsContainer {hasRightCol: activeRequest || (structs && structs.length)}">
            <div class="leftCol">
                <div class="corpInfoSections">
                    <div>
                        <div class="card-panel">
                            <h5>{_("ci.generalInfo")}</h5>
                            <table class="table">
                                <tr>
                                    <td>{_("language")}</td>
                                    <td>{data.language_name}</td>
                                </tr>
                                <tr if={data.infohref}>
                                    <td>{_("ci.corpusDescription")}</td>
                                    <td><a href={data.infohref} class="btn" target="_blank">{_("description")}</a></td>
                                </tr>
                                <tr if={data.tagsetdoc}>
                                    <td>{_("tagset")}</td>
                                    <td><a href={data.tagsetdoc} class="btn" target="_blank">{_("description")}</a></td>
                                </tr>
                                <tr if={data.errsetdoc}>
                                    <td>{_("ci.errset")}</td>
                                    <td><a href={data.errsetdoc} class="btn" target="_blank">{_("description")}</a></td>
                                </tr>
                                <tr if={data.wsdef}>
                                    <td>{_("ci.wordSketchGrammar")}</td>
                                    <td><button class="btn" onclick={showGrammarDialog.bind(this, false)}>{_("show")}</button></td>
                                </tr>
                                <tr if={data.termdef}>
                                    <td>{_("termGrammar")}</td>
                                    <td><button class="btn" onclick={showGrammarDialog.bind(this, true)}>{_("show")}</button></td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div>
                        <div if={data.sizes}  class="card-panel">
                            <h5>{_("ci.counts")}&nbsp;<i class="material-icons tooltipped" data-tooltip="t_id:ci_counts">info</i></h5>
                            <table class="table">
                                <tr each={obj, idx in sizesList} if={data.sizes[obj[0]] > 0}>
                                    <td>{_(obj[1])}</td>
                                    <td class="right-align">{window.Formatter.num(parent.data.sizes[obj[0]])}</td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div>
                        <div if={activeRequest || (attributes && attributes.length)} class="lexiconSizes card-panel">
                            <h5>{_("ci.lexiconSizes")}&nbsp;<i class="material-icons tooltipped" data-tooltip="t_id:ci_lexicon_sizes">info</i></h5>
                            <preloader-spinner small=1 if={activeRequest}></preloader-spinner>
                            <table if={!activeRequest} class="table">
                                <tr each={attr in attributes}>
                                    <td>
                                        {attr.name}
                                        <i if={attr.label} class="material-icons tooltipped" data-tooltip={attr.label}>info_outline</i>
                                    </td>
                                    <td class="right-align">{isNaN(attr.id_range) ? "" : window.Formatter.num(attr.id_range)}</td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div>
                        <div if={data.wposlist && data.wposlist.length} class="card-panel">
                            <h5>{_("commonTags")}</h5>
                            <table class="table">
                                <tr each={pos in data.wposlist}>
                                    <td>{pos.label}</td>
                                    <td class="right-align">{pos.value}</td>
                                </tr>
                            </table>
                            <a if={data.tagsetdoc}
                                    href="{data.tagsetdoc}"
                                    target="_blank"
                                    style="margin-top: 5px; display: inline-block;">
                                <i class="material-icons small-help" style="vertical-align: middle;">help_outline</i>
                                {_("moreInfo")}
                            </a>
                        </div>
                    </div>

                    <div>
                        <div if={data.lposlist && data.lposlist.length} class="card-panel">
                            <h5>{_("ci.lemposSuffixes")}&nbsp;<i class="material-icons tooltipped" data-tooltip="t_id:ci_lempos_suffixes">info</i></h5>
                            <table class="table">
                                <tr each={pos in data.lposlist}>
                                    <td>{pos.label}</td>
                                    <td class="right-align">{pos.value}</td>
                                </tr>
                            </table>
                        </div>
                    </div>


                    <div>
                        <div if={activeRequest || (subcorpora && subcorpora.length)} class="subcorpora card-panel">
                            <h5>{_("ci.subcorporaStatistics")}</h5>
                            <preloader-spinner small=1 if={activeRequest}></preloader-spinner>
                            <table if={!activeRequest} class="table">
                                <thead>
                                    <tr>
                                        <th>{_("subcorpus")}</th>
                                        <th>{_("tokens")}</th>
                                        <th>%</th>
                                    </tr>
                                </thead>
                                <tr each={sc in subcorpora}>
                                    <td>{sc.n}</td>
                                    <td class="right-align">{window.Formatter.num(sc.tokens)}</td>
                                    <td class="right-align">{window.Formatter.num(sc.relsize,  {minimumFractionDigits: 2})}</td>
                                </tr>
                            </table>
                            <br>
                            <div class="center-align">
                                <a href="#ca-subcorpora" class="btn">
                                    {_("ca.subcorporaDesc")}
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div if={activeRequest || (structs && structs.length)} class="rightCol">
                <div class="card-panel noPaddingCard">
                    <h5>{_("textTypes")}&nbsp;<i class="material-icons tooltipped" data-tooltip="t_id:ci_text_types">info</i></h5>
                    <preloader-spinner small=1 if={activeRequest}></preloader-spinner>
                    <ul if={!activeRequest} class="collapsible" data-collapsible="expandable">
                        <li each={struct, idx in structs} class={active: idx == 0}>
                            <div class="collapsible-header">{struct[0]} <span class="scnt">({struct[2].length})</span>
                                <span class="right">{window.Formatter.num(struct[1])}</span>
                            </div>
                            <div class="collapsible-body">
                                <div each={itm in struct[2]}>
                                    {itm[1]}, &nbsp;
                                    <span class="attr">{itm[0]}</span>
                                    <span class="right">{window.Formatter.num(itm[2])}</span>
                                    <a href={getWordlistUrl(itm[0])}
                                            class="tooltipped"
                                            data-tooltip={_("statsWholeCorp")}
                                            onclick={closeDialog}>
                                        <i class="material-icons rotate90CW">insert_chart</i>
                                    </a>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div if={error}>
        <div class="error">{_("error")}: {error}</div>
    </div>

    <script>
        require('./corpus-info-dialog.scss')
        const {Connection} = require("core/Connection.js")
        const {Router} = require('core/Router.js')
        const {AppStore} = require('core/AppStore.js')
        const {Auth} = require('core/Auth.js')
        const Dialogs = require('dialogs/dialogs.js')

        this.mixin("tooltip-mixin")

        this.activeRequest = null
        this.isFullAccount = Auth.isFullAccount()
        this.corpusListData = AppStore.getCorpusByCorpname(this.opts.corpname)

        if (this.opts.corpname == AppStore.getActualCorpname()) {
            this.data = AppStore.getActualCorpus()
        } else {
            this.data = {}
            AppStore.loadAnyCorpus(this.opts.corpname)
        }

        this.sizesList = [
            ["tokencount", "tokens"],
            ["wordcount", "wordP"],
            ["sentcount", "sentences"],
            ["parcount", "paragraphs"],
            ["doccount", "documents"]
        ]

        getWordlistUrl(wlattr){
            return window.stores.wordlist.getUrlToResultPage({
                tab: "attribute",
                wlattr: wlattr,
                wlminfreq: 1,
                include_nonwords: 1,
                onecolumn: 1
            })
        }

        load(){
            this.error = null
            if(this.activeRequest){
                Connection.abortRequest(activeRequest)
            }
            this.activeRequest = Connection.get({
                url: window.config.URL_BONITO + "corp_info",
                query: {
                    corpname: opts.corpname,
                    struct_attr_stats: 1,
                    subcorpora: 1
                },
                done: this.onLoad,
                fail: this.onFail
            })

            this.update()
        }

        onLoad(payload){
            if(this.isMounted){ // user could close dialog before loaded
                this.attributes = payload.attributes
                this.structs = payload.structs.sort((a, b) => {return b[2].length - a[2].length})
                this.structs.forEach(s => {
                    s[2].sort((a,b) => {return a[1].localeCompare(b[1])})
                })
                this.subcorpora = payload.subcorpora
                this.activeRequest = null
                this.update()
            }
        }

        onFail(error){
            this.error = error
            this.activeRequest = null
            this.update()
        }

        closeDialog(){
            Dispatcher.trigger("closeDialog", "corpusInfo")
        }

        showGrammarDialog(is_term){
            Dialogs.showGrammarDetailDialog({corpname: this.data.corpname, is_term: is_term})
        }

        Dispatcher.on('ANY_CORPUS_LOADED', (data) => {
            this.data = data
            this.update()
        })

        this.on("mount", () => {
            this.load()
        })

        this.on("updated", () => {
            $('.collapsible', this.root).collapsible()
            $('.tooltipped', this.root).tooltip({
                enterDelay: 500
            })
        })

    </script>
</corpus-info-dialog>

