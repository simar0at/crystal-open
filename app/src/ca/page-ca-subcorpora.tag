<subcorpus-def>
    <p>{_("subcorpus")}: <b>{opts.n}</b></p>
    <div if={opts.struct || opts.query}>
        <p>{_("tr.structattr")}: <tt>&lt;{opts.struct}&gt;</tt></p>
        <span each={q, idx in queries} if={!fromc}>
            <span class="chip">{q.tt.label || q.tt.name} = <span class="ttval">{q.val}</span></span>&nbsp;
        </span>
        <p if={fromc && dattr}>
            <span>{_("cc.defaultAttr")}: <b>{dattr}</b></span>
        </p>
        <p if={fromc}>
            {_("cql")}: <tt each={q in queries}>{q.q}<br /></tt>
        </p>
    </div>
    <div if={!opts.struct && !opts.query}>
        <p><em>Subcorpus definition not available.</em></p>
    </div>

    <style>
        .ttval:before,
        .ttval:after
        {
            content: "\""
        }
        tt
        {
            background-color: #EEE;
            padding: .2em;
        }
    </style>

    <script>
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        this.queries = []
        this.fromc = false
        this.dattr = ""
        if (this.opts.query[0] == "Q") {
            this.fromc = true
            let subs = this.opts.query.slice(2).split('\v')
            for (let i=0; i<subs.length; i++) {
                let defattr = ""
                if (i == 0) {
                    // remove default attribute
                    let m = subs[i].match(/^a[a-z]+,/)
                    if (m) {
                        this.dattr = m[0].slice(1, -1)
                        subs[i] = subs[i].replace(/^a[a-z]+,/, '')
                    }
                    else if (subs[i][0] == "q") {
                        subs[i] = subs[i].slice(1)
                    }
                }
                this.queries.push({
                    q: subs[i].replace(/\\/g, '')
                })
            }
        }
        else {
            let subs = this.opts.query.split(' & ')
            for (let i=0; i<subs.length; i++) {
                let subsubs = subs[i].split(' | ')
                for (let j=0; j<subsubs.length; j++) {
                    let m = subsubs[j].match(/([^(]+)="([^")]+)"/)
                    if (m) {
                        this.queries.push({
                            tt: TextTypesStore.getTextType(this.opts.struct + "." + m[1]) || m[1],
                            val: m[2].replace(/\\/g, ''),
                        })
                    }
                }
            }
        }
    </script>
</subcorpus-def>

<page-ca-subcorpora class="page-ca-subcorpora">
    <div>
        <ca-title corpus={corpus}></ca-title>
        <div class="card-panel greyCard">
            <span class="right rightCol">
                <a if={hasTextTypes}
                        class="btn contrast tooltipped"
                        data-tooltip={_("ca.createDesc")}
                        onclick={onCreateSubcorpusClick}>
                    {_("createSubcorpus")}
                </a>
                <br>
                <ui-checkbox label={_("showPreloadedSubcorpora")}
                        riot-value={showPreloaded}
                        on-change={onShowPreloadedChange}></ui-checkbox>
            </span>
            <div if={!subcorpora.length} class="center-align grey-text">
                <br>
                <h4>{_(isTextTypesLoaded ? "nothingHere" : "loading")}</h4>
                <br>
            </div>
            <div class="subcorpora center-align">
                <table if={subcorpora.length} class="material-table highlight">
                    <thead>
                        <tr>
                            <th>{_("name")}</th>
                            <th>{_("tokens")}</th>
                            <th>{_("wordP")}</th>
                            <th>%</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tr each={subcorpus in subcorpora}>
                        <td>
                            <span if={subcorpus.user == 2}
                                    class="tooltipped" data-tooltip="t_id:ca_subc_old">
                                {subcorpus.n}
                                <sup>?</sup>
                            </span>
                            <span if={subcorpus.user != 2}>{subcorpus.n}</span>
                        </td>
                        <td>{subcorpus.user == 2 ? "" : window.Formatter.num(subcorpus.tokens)}</td>
                        <td>{subcorpus.user == 2 ? "" : ("~" + window.Formatter.num(subcorpus.words))}</td>
                        <td>{subcorpus.user == 2 ? "" : window.Formatter.num(subcorpus.relsize, {maximumFractionDigits: 1})}</td>
                        <td>
                            <i class="material-icons material-clickable grey-text"
                                    if={subcorpus.user}
                                    onclick={onSubcorpusInfoClick}>
                                info
                            </i>
                            <i class="material-icons material-clickable grey-text"
                                    if={subcorpus.user}
                                    onclick={onSubcorpusRemoveClick}>
                                delete_forever
                            </i>
                        </td>
                    </tr>
                </table>
                <br>
                <div class="buttons">
                    <a href="#ca" id="btnBack" class="btn btn-flat">{_("back")}</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./page-ca-subcorpora.scss")
        const {CAStore} = require("./castore.js")
        const {AppStore} = require("core/AppStore.js")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")
        const Dialogs = require("dialogs/dialogs.js")

        this.mixin("tooltip-mixin")
        this.corpus = AppStore.getActualCorpus()
        this.showPreloaded = false
        TextTypesStore.loadTextTypes()

        updateAttributes(){
            this.isTextTypesLoaded = TextTypesStore.get("isTextTypesLoaded")
            this.hasTextTypes = TextTypesStore.get("hasTextTypes")
            this.subcorpora = AppStore.get("corpus.subcorpora").filter(s => {
                return s.value !== "" && (this.showPreloaded || s.user)
            }, this)
        }
        this.updateAttributes()

        onSubcorpusInfoClick(e) {
            Dispatcher.trigger("openDialog", {
                small: true,
                opts: e.item.subcorpus,
                title: _("ca.subcorpusDefinition"),
                tag: "subcorpus-def",
                buttons: []
            })
        }

        onSubcorpusRemoveClick(evt){
            let subcorpus = evt.item.subcorpus
            Dispatcher.trigger("openDialog", {
                title: _("deleteSubcorpusTitle"),
                content: _("reallyDeleteSubcorpus", [subcorpus.n]),
                small: true,
                buttons: [{
                    label: _("delete"),
                    onClick: function(subcorpus, currentDialog, modalContainer){
                        AppStore.deleteSubcorpus(subcorpus.n)
                        modalContainer.close()
                        this.update()
                    }.bind(this, subcorpus)
                }]
            })
        }

        onShowPreloadedChange(){
            this.showPreloaded = !this.showPreloaded
            this.update()
        }

        onCreateSubcorpusClick(){
            Dialogs.showCreateSubcorpus()
        }

        getRatio(relsize){
            return Math.round(relsize * 10) / 10
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            AppStore.on("subcorporaChanged", this.update)
            TextTypesStore.on("textTypesLoaded", this.update)
        })

        this.on("unmount", () => {
            AppStore.off("subcorporaChanged", this.update)
            TextTypesStore.off("textTypesLoaded", this.update)
        })

        CAStore.updateUrl()
    </script>
</page-ca-subcorpora>
