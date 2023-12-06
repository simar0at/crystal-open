<ca-seeds-url-dialog class="ca-seeds-url-dialog">
    <div class="grey-text">
        {_("selectUrlsHelp")}
        <a href="javascript:void(0)"
                class="link"
                onclick={onShowSettingsClick}>{_("checkSettingsNow")}</a>
        {_("selectionWillBeLost")}
    </div>
    <preloader-spinner if={isLoading}
            overlay=1
            center=1
            message={_("urlsLoading")}></preloader-spinner>
    <div if={!isLoading} class="card-panel controlBar">
        <ui-input placeholder={_("ui.typeToSearch")}
                label={_("filter")}
                size=10
                riot-value={filter}
                inline=1
                on-input={onFilterChange}
                suffix-icon={filter !== "" ? "close" : ""}
                on-suffix-icon-click={onCancelFilterClick}></ui-input>
        &nbsp;&nbsp;
        <span style="white-space: nowrap;">
            <button class="btn" onclick={visibleSelectToggle.bind(this, true)}>
                {_("selectVisible")}
            </button>
            <button class="btn" onclick={visibleSelectToggle.bind(this, false)}>
                {_("deselectVisible")}
            </button>
            &nbsp;&nbsp;
        </span>
        <span style="white-space: nowrap;">
            <button class="btn" onclick={onExpandAllToggleClick.bind(this, true)}>
                {_("cc.expandAll")}
            </button>
            <button class="btn" onclick={onExpandAllToggleClick.bind(this, false)}>
                {_("cc.collapseAll")}
            </button>
        </span>
    </div>

    <div if={filter !== "" && !somethingFound} class="grey-text">
        <h2 class="emptyResults">{_("nothingFound")}</h2>
    </div>

    <div if={tuple.show} each={tuple, tupleIdx in data} class="tuple">
        <div class="header" onclick={onTupleExpandToggleClick.bind(this, tuple)}>
            <ui-checkbox checked={tuple.checked}
                    indeterminate={tuple.selectedCnt != tuple.urls.length && tuple.selectedCnt != 0}
                    inline=1
                    on-change={onTupleCheckboxChange.bind(this, tuple)}></ui-checkbox>
            <span>{tuple.seeds.join(" ● ")}</span>
            <span class="count">({tuple.selectedCnt}/{tuple.urls.length} {_("selected")})</span>
            <button class="btn btn-flat btn-floating">
                <i class="material-icons">
                    {tuple.expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"}
                </i>
            </button>
        </div>
        <div if={tuple.expanded && url.show}
                each={url, urlIdx in tuple.urls}
                class="url ui-checkbox">
            <label for="url_{tupleIdx}_{urlIdx}">
                <input type="checkbox"
                        id="url_{tupleIdx}_{urlIdx}"
                        checked={url.checked}
                        onchange={onUrlCheckboxChange.bind(this, tuple, url)}/>
                <span></span>
                <b>{url.domain}</b>{url.path}
            </label>
            <a href={url.url} target="_blank" class="urlLink">
                <i class="material-icons">open_in_new</i>
            </a>
        </div>
    </div>
    <span ref="goBtnWrapper" id="goBtnWrapper" class="fixed-action-btn">
        <a href="javascript:void(0)"
                id="btnCaSeedsUrlGo"
                ref="btnGo"
                class="btn btn-primary btn-floating btn-large disabled"
                onclick={onGoClick}>
            {_("go")}
        </a>
    </span>

    <script>
        require("./ca-seeds-url-dialog.scss")

        const {CAStore} = require("./castore.js")

        this.data = []
        this.isLoading = true
        this.filter = ""

        CAStore.loadUrlsFromSeeds(this.opts.corpus_id, Object.assign({
            input_type: "seed_words",
            seed_words: this.opts.seed_words,
            tuple_size: this.opts.tuple_size,
            max_urls_per_query: this.opts.max_urls_per_query,
            sites_list: this.opts.sites_list,
            name: this.opts.name
        }, this.opts.settings))

        onDataLoaded(payload){
            if(payload.error){
                Dispatcher.trigger("closeDialog")
                SkE.showError(payload.error)
            } else {
                this._processData(payload)
                this.isLoading = false
                this.update()
            }
        }

        onFilterChange(filter){
            this.filter = filter
            this.somethingFound = false
            this.data.forEach(t => {
                t.show = false
                t.urls.forEach(u => {
                    u.show = filter === "" || u.url.indexOf(filter) != -1
                    t.show |= u.show
                })
                t.expanded = filter === "" ? true : t.show
                this.somethingFound |= t.show
            }, this)
            this.update()
        }

        onCancelFilterClick(){
            this.onFilterChange("")
        }

        visibleSelectToggle(checked, evt){
            evt.preventUpdate = true
            this.data.forEach(t => {
                if(t.show){
                    t.urls.forEach(u => {
                        if(u.show){
                            u.checked = checked
                        }
                    })
                    this._updateTupleAttributes(t)
                }
            }, this)
            this.onFilterChange("")
        }

        onExpandAllToggleClick(expanded){
            this.data.forEach(t => {
                t.expanded = expanded
                t.urls.forEach(u => {
                    u.expanded = expanded
                })
            })
        }

        onTupleCheckboxChange(tuple){
            tuple.checked = !tuple.checked
            tuple.urls.forEach(u => {
                u.checked = tuple.checked
            })
            tuple.selectedCnt = tuple.checked ? tuple.urls.length : 0
            this.update()
        }

        onUrlCheckboxChange(tuple, url){
            url.checked = !url.checked
            this._updateTupleAttributes(tuple)
            this.update()
        }

        onTupleExpandToggleClick(tuple, evt){
            tuple.expanded = !tuple.expanded
        }

        onGoClick(evt){
            let urls = []
            this.data.forEach(t => {
                t.urls.forEach(u => {
                    u.checked && urls.push(u.url)
                })
            })
            CAStore.startWebBootCaT(this.opts.corpus_id, Object.assign(this.opts.settings, {
                urls: [...new Set(urls)], // demove duplicities
                seed_words: this.opts.seed_words,
                input_type: "urls",
                name: this.opts.name
            }))
        }

        onWebBootCaTStarted(){
            this.modalParent.close()
        }

        onShowSettingsClick(evt){
            evt.preventUpdate = true
            this.modalParent.close()
            delay(() => {
                Dispatcher.trigger("toggleSettings", "showWebSearchSettings")
            }, 500)
        }

        _updateTupleAttributes(tuple){
            tuple.selectedCnt = tuple.urls.reduce((cnt, u) => {
                return u.checked ? cnt + 1 : cnt
            }, 0)
            tuple.checked = tuple.selectedCnt == tuple.urls.length
        }

        _updateBtnGoDisabled(){
            let disabled = this.isLoading || this.data.every(t => {
                return t.urls.every(u =>{
                    return !u.checked
                })
            })
            this.refs.btnGo.classList.toggle("disabled", disabled)
        }

        _processData(payload){
            this.data = []
            let domain, urls
            payload.result.sort((a, b) => {
                return a[0].localeCompare(b[0])
            }).forEach(r => {
                urls = []
                r[1].forEach(url => {
                    domain = this._getDomain(url)
                    urls.push({
                        domain: domain,
                        path: url.substr(url.indexOf(domain) + domain.length),
                        show: true,
                        checked: true,
                        url: url
                    })
                }, this)

                this.data.push({
                    title: r[0],
                    seeds: r[0].match(/"(?:\\"|[^"])+"|([^\s\\])+/g).map(word => {
                        return word.trim().replace(/\"/g, "")
                    }),
                    show: true,
                    checked: true,
                    selectedCnt: urls.length,
                    expanded: payload.result.length < 20,
                    urls: Object.values(urls).sort((a, b) => {
                        return a.url.localeCompare(b.url)
                    })
                })
            }, this)
        }

        _getDomain(url) {
            let domain
            if (url.indexOf("//") > -1) {
                domain = url.split('/')[2]
            } else {
                domain = url.split('/')[0]
            }
            domain = domain.split(':')[0]
            domain = domain.split('?')[0]
            if(domain.substr(0, 4) == "www."){
                domain = domain.substr(4)
            }
            return domain
        }

        this.on("updated", this._updateBtnGoDisabled)

        this.on("mount", () => {
            document.body.appendChild(this.refs.goBtnWrapper)
            CAStore.on("urlsFromSeedsLoaded", this.onDataLoaded)
            CAStore.on("webBotCaTStarted", this.onWebBootCaTStarted)
        })

        this.on("unmount", () => {
            document.getElementById("goBtnWrapper").remove()
            CAStore.off("urlsFromSeedsLoaded", this.onDataLoaded)
            CAStore.off("webBotCaTStarted", this.onWebBootCaTStarted)
        })
    </script>
</ca-seeds-url-dialog>
