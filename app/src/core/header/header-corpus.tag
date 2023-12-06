<header-corpus class="header-corpus">
    <ui-input inline=1
            on-focus={onFocus}
            on-key-up={onKeyUp}
            on-key-down={onKeyDown}
            autocomplete={false}
            white=1
            riot-value={query}
            suffix-icon={!showList || query === "" ? "search" : "close"}
            placeholder={_("ui.typeToSearch")}
            on-suffix-icon-click={onSuffixIconClick}
            on-input={onInput}></ui-input>
    <input type="hidden" id="actualCorpname" value="{actualCorpname}"> <!--for testing purposes-->
    <div if={showList} ref="wrapper" class="wrapper">
        <ul ref="list" onscroll={onScrollDebounced}>
            <li each={corpus, idx in visibleCorpora}
                    if={idx < showLimit}
                    ref="{idx}_r"
                    class={notAvailable: !corpus.user_can_read, actual: corpus.corpname == actualCorpname, old: corpus.new_version}
                    onclick={onRowClick}>
                <div>
                    <i class="material-icons left">
                        {corpus.icon}
                    </i>
                    <span class="cLang" ref="{idx}_l">{corpus.language_name}</span>
                    <span if={showCorpname} class="cCorpname" ref="{idx}_c">{corpus.corpname}&nbsp;●&nbsp;</span>
                    <span class="cLabel" ref="{idx}_n">{corpus.name}</span>
                    <span class="clSize">{corpus.sizes ? window.Formatter.num(corpus.sizes.wordcount) : ""}</span>
                </div>
                <div if={showInfo} class="cInfo" ref="{idx}_i">
                    {corpus.info}
                </div>
            </li>
        </ul>
        <div if={!corpusListLoaded} class="listLoading">
            <preloader-spinner center=1></preloader-spinner>
        </div>
        <div if={corpusListLoaded && !visibleCorpora.length} class="empty">
            <h4>{_("noCorpusFound")}</h4>
        </div>
        <div if={hasCorpus && maxScore < -10000 && query !== "" && query !== "#"} class="featureLinks center">
            <div class="msg">
                <raw-html content={_("notCorporaSearch", ["<b>" + query + "</b>"])}></raw-html>
            </div>
            <a if={window.permissions.wordsketch}
                href={getUrlToResultPage("wordsketch")} class="btn" onclick={closeList}>
                <i class="ske-icons skeico_word_sketch left"></i>
                Word Sketch
            </a>
            <a if={window.permissions.concordance}
                href={getUrlToResultPage("concordance")} class="btn" onclick={closeList}>
                <i class="ske-icons skeico_concordance left"></i>
                {_("concordance")}
            </a>
            <a if={window.permissions.thesaurus}
                href={getUrlToResultPage("thesaurus")} class="btn" if={query.indexOf(" ") == -1} onclick={closeList}>
                <i class="ske-icons skeico_thesaurus left"></i>
                {_("thesaurus")}
            </a>
        </div>
        <div if={corpusListLoaded} ref="buttons" class="buttons">
            <div class="foundCount hide-on-small-only">
                {_("corpCount", [window.Formatter.num(visibleCorpora.length)])}
            </div>
            <div class="buttonsControls">
                <span class="corpusDescCheckbox">
                    <ui-checkbox label={"Show description"}
                            checked={showInfo}
                            on-change={onShowInfoChange}></ui-checkbox>
                </span>
                <a href="#corpus?tab=advanced"
                        id="btnManageCorpora"
                        class="btn btn-flat teal-text"
                        style="margin-left: auto;"
                        onclick={closeList}>{_("advancedSearch")}</a>
                <a if={window.permissions["ca-create"]}
                        href="#ca-create"
                        id="btnCreateCorpus"
                        class="btn btn-flat teal-text"
                        onclick={closeList}>{_("createCorpus")}</a>

            </div>
        </div>
    </div>

    <a if={ready}
            id="btnShowCorpusInfo"
            class="btn btn-floating btn-flat color-blue-200 corpusInfoBtn"
            onclick={onShowCorpusInfoClick}>
        <i class="material-icons">info_outline</i>
    </a>
    <a href="#ca-compile" if={window.permissions["ca-compile"] && corpus.hasDocuments && corpus.needs_recompiling}>
        <i class="material-icons tooltipped orange-text hide-on-small-only corpusFlagIcon"}
                data-tooltip={_("msg.corpusNeedsCompile")}>warning</i>
    </a>
    <i if={loggedAs}
            class="material-icons tooltipped orange hide-on-small-only corpusFlagIcon loggedAsIcon link"
            data-tooltip={getLoggedAsTooltip()}
            onclick={onLoggedAsClick}>supervisor_account</i>

    <a if={window.permissions["ca-share"] && corpus && corpus.is_shared && userId == corpus.owner_id}
            href="#ca-share" class="btn btn-floating btn-flat">
        <i class="material-icons tooltipped grey-text hide-on-small-only corpusFlagIcon"
                data-tooltip={_("iShareCorpus")}>share</i>
    </a>
    <i if={corpus && corpus.is_shared && userId != corpus.owner_id}
            class="material-icons tooltipped grey-text hide-on-small-only corpusFlagIcon"
            data-tooltip={_("corpusIsSharedWithMe", [this.corpus.owner_name])}>share</i>

    <script>
        require('./header-corpus.scss')
        require('dialogs/corpus-info-dialog/corpus-info-dialog.tag')
        const {AppStore} = require("core/AppStore.js")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {Auth} = require("core/Auth.js")
        const {Router} = require("core/Router.js")
        const FuzzySort = require('libs/fuzzysort/fuzzysort.js')

        this.mixin("tooltip-mixin")
        this.query = ""
        this.showLimit = 20
        this.cursorPosition = null
        this.showCorpname = false
        this.corpusListLoaded = AppStore.get("corpusListLoaded")
        this.showInfo = UserDataStore.getOtherData("showInfoInCorpusSearch") || false

        compareCorporaFun(a, b){
            if(a.sort_to_end && !b.sort_to_end) return 1
            if(!a.sort_to_end && b.sort_to_end) return -1
            if (a.id && !b.id) return -1 // corpus with ID is user corpus
            if (b.id && !a.id) return 1
            if (a.is_featured && !b.is_featured) return -1
            if (b.is_featured && !a.is_featured) return 1
            return a.name.localeCompare(b.name)
        }

        initData(){
            this.userId = Auth.getUserId()
            this.isFullAccount = Auth.isFullAccount()
            this.corpus = AppStore.getActualCorpus()
            this.actualCorpname = this.corpus ? this.corpus.corpname : ""
            this.hasCorpus = !!this.corpus
            this.query = this.corpus ? this.corpus.name : ""
        }
        this.initData()

        initCorpora(){
            this.corpusListLoaded = AppStore.get("corpusListLoaded")
            this.allCorpora = copy(AppStore.get('corpusList')) || []
            this.allCorpora.sort(this.compareCorporaFun)
            this.visibleCorpora = this.allCorpora
        }
        this.initCorpora()

        updateAttributes(){
            this.ready = AppStore.get("ready")
            this.loggedAs = Auth.isLoggedAs()
        }
        this.updateAttributes()

        onSuffixIconClick(evt){
            evt.preventUpdate = true
            this.query = ""
            this.filterCorpora()
        }

        onFocus(){
            if(!this.showList){
                document.addEventListener('click', this.handleClickOutside)
                this.query = ""
                this.showList = true
                this.filterCorpora()
                this.updateCursor()
            }
        }

        onInput(query){
            query = query.trim()
            if(this.query !== query){
                this.query = query
                this.showLimit = 20
                this.filterCorpora()
                this.updateCursor()
                this.refs.list.scrollTop = 0
            }
        }
        onKeyDown(evt){
            if([38, 40, 33, 34/*, 35, 36*/].includes(evt.keyCode)){
                evt.preventDefault()
                evt.stopPropagation()
            }
            evt.preventUpdate = true
        }

        onKeyUp(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            evt.preventDefault()
            if(evt.keyCode == 38){
                this.moveCursorUp(1)
            } else if(evt.keyCode == 40){
                this.moveCursorDown(1)
            } else if(evt.keyCode == 33){
                // TODO do not use constant
                this.moveCursorUp(7) //pgUp
            } else if(evt.keyCode == 34){
                this.moveCursorDown(7) // pgDown
            } else if(evt.keyCode == 9 || evt.keyCode == 27){ //esc, tab
                this.closeList()
            }/* else if(evt.keyCode == 36){
                this.cursorPosition = 0
                this.updateCursor()
            } else if(evt.keyCode == 35){
                this.cursorPosition = this.visibleCorpora.length - 1
                this.increaseShowLimit(this.visibleCorpora.length)
                delay(this.updateCursor.bind(this), 1)
            }*/ else if(evt.keyCode == 13){ // enter
                if(this.cursorPosition !== null){
                    this.changeCorpus(this.visibleCorpora[this.cursorPosition].corpname)
                }
            }
        }

        onRowClick(evt){
            this.changeCorpus(evt.item.corpus.corpname)
        }

        onShowCorpusInfoClick(){
            SkE.showCorpusInfo(this.corpus.corpname)
        }


        onScrollDebounced(evt){
            evt.preventUpdate = true
            debounce(this.onListScroll.bind(this), 50)()
        }

        onListScroll(evt){
            let isScrolledToBottom = this.refs.list.scrollHeight - this.refs.list.scrollTop <= this.refs.list.clientHeight + 150
            if(isScrolledToBottom && this.showLimit < this.visibleCorpora.length){
                // prevent another on scrolltobottom event -> move one pixel above bottom
                this.refs.list.scrollTop = this.refs.list.scrollTop - 1
                this.increaseShowLimit()
            }
        }

        onLoggedAsClick(evt){
            evt.preventUpdate = true
            Auth.logoutAs()
        }

        onShowInfoChange(showInfo){
            this.showInfo = showInfo
            UserDataStore.saveOtherData({showInfoInCorpusSearch: showInfo})
            if(this.query){
                this.filterCorpora()
            } else {
                this.update()
            }
        }

        filterCorpora(query){
            this.cursorPosition = 0
            this.showCorpname = this.query[0] == "#"
            this.allCorpora.forEach(c => {
                delete c.h_cname
                delete c.h_lang
                delete c.h_name
                delete c.h_info
            })
            if(this.query !== "" && this.query !== "#"){
                this.visibleCorpora = []
                let fuzzySorted
                let query = this.query
                let keys
                if(this.showCorpname){
                    query = this.query.substr(1, this.query.length - 1)
                    keys = ["corpname"]
                } else {
                    keys = ["language_name", "name"]
                    if(this.showInfo){
                        keys.push("info")
                    }
                }
                fuzzySorted = FuzzySort.go(query, this.allCorpora, {
                        key: "corpname",
                        keys: keys,
                        fullMatchKeys: ["info"]
                    })
                this.maxScore = -Infinity
                this.visibleCorpora = fuzzySorted.map(fs => {
                    if(fs.score > -Infinity){
                        if(fs.score >  this.maxScore){
                            this.maxScore = fs.score
                        }
                        let c = fs.obj
                        c.score = fs.score
                        if(c.new_version){
                            c.score *= 3 // penalty for old corpora
                        } else if(c.sort_to_end){
                            c.score *= 2
                        } else if(c.id || c.is_featured){
                            c.score *= 0.5
                        }
                        if(this.showCorpname){
                            c.h_cname = FuzzySort.highlight(fs[0], '<b class="red-text">', "</b>") + "&nbsp;●&nbsp;"
                        } else{
                            c.h_lang = FuzzySort.highlight(fs[0], '<b class="red-text">', "</b>")
                            c.h_name = FuzzySort.highlight(fs[1], '<b class="red-text">', "</b>")
                            if(this.showInfo){
                                c.h_info = FuzzySort.highlight(fs[2], '<b class="red-text">', "</b>")
                            }
                        }
                        return c
                    }
                }).sort((a, b) => {
                    return a.score == b.score ? this.compareCorporaFun(a, b) : Math.sign(b.score - a.score)
                })
            } else{
                this.visibleCorpora = this.allCorpora
            }
            this.visibleCorpora.forEach(c => {
                if(c.user_can_read){
                    if(c.new_version){
                        c.icon = "update"
                    } else {
                        if(c.corpname == this.actualCorpname){
                            c.icon = "check"
                        } else {
                            c.icon ="storage"
                        }
                    }
                } else{
                    c.icon = "lock"
                }
            }, this)
            this.update()
            this.highlightOccurrences()
        }

        closeList(){
            this.showList = false
            this.query = this.corpus ? this.corpus.name : ""
            document.removeEventListener('click', this.handleClickOutside)
            $(".ui-input input", this.root).blur()
            this.update()
        }

        changeCorpus(corpname){
            if(corpname != this.actualCorpname){
                AppStore.checkAndChangeCorpus(corpname)
                this.closeList()
                AppStore.one("corpusChanged", () => {
                    let feature = Router.getActualFeature()
                    let page = AppStore.hasCorpusFeature(feature) ? feature : "dashboard"
                    if(page != Router.getActualPage()){
                        Dispatcher.trigger("ROUTER_GO_TO", page, {corpname: corpname});
                    }
                })
            }
        }

        increaseShowLimit(limit){
            this.showLimit = limit ? limit : this.showLimit + 40
            this.update()
            this.highlightOccurrences()
        }

        moveCursorDown(step){
            if(this.cursorPosition !== null){
                this.cursorPosition += (step || 1)
                if(this.cursorPosition >= this.visibleCorpora.length){
                    this.cursorPosition = this.visibleCorpora.length - 1
                }
                if(this.cursorPosition > this.showLimit){
                    this.increaseShowLimit()
                }
            } else{
                if(this.visibleCorpora.length){
                    this.cursorPosition = 0
                }
            }
            this.updateCursor()
        }

        moveCursorUp(step){
            if(this.cursorPosition !== null){
                this.cursorPosition -= (step || 1)
                if(this.cursorPosition < 0){
                    this.cursorPosition = 0
                }
            }
            this.updateCursor()
        }

        updateCursor(){
            // if cursorPosition is defined, make selected option focused
            if(this.isMounted){
                $("li.focused", this.root).removeClass("focused")
                let node = this.refs[this.cursorPosition + "_r"]
                if(node){
                    $(node).addClass("focused")
                    this.scrollSelectedIntoView()
                }
            }
        }

        handleClickOutside(evt){
            if (!this.root.contains(evt.target)){
                this.closeList(evt)
            }
        }

        highlightOccurrences(){
            let el, row
            if(!this.showCorpname || this.query != "#"){
                this.visibleCorpora.forEach(function(c, idx){
                    row = this.refs[idx + "_r"]
                    if(row){
                        if(this.showCorpname){
                            el = this.refs[idx + "_c"];
                            el.innerHTML = (c.h_cname + "&nbsp;●&nbsp;") ? c.h_cname : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')
                        } else{
                            el = this.refs[idx + "_l"];
                            el.innerHTML = c.h_lang ? c.h_lang : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')

                            el = this.refs[idx + "_n"];
                            el.innerHTML = c.h_name ? c.h_name : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')
                            if(this.showInfo){
                                el = this.refs[idx + "_i"];
                                el.innerHTML = c.h_info ? c.h_info : el.innerHTML.replace(/<b class="red-text">|<\/b>/g, '')
                            }
                        }
                    }
                }.bind(this))
            }
        }

        updateListPosition(){
            if(!this.showList){
                return
            }
            let node = $(this.refs.wrapper)
            node.removeClass("wrapLines").removeAttr("style")
            let listwidth = node.outerWidth()
            let screenWidth = $(window).width()

            if(listwidth >= screenWidth){
                node.offset({"left": 0})
                node.css({
                    "min-width": screenWidth,
                    right: "unset"
                })
                node.addClass("wrapLines")
            } else{
                let leftOffset = node.offset().left
                let rightOffset = screenWidth - leftOffset - listwidth
                let leftOverlap = leftOffset < 0 ? leftOffset * -1 : 0
                let rightOverlap = rightOffset < 0 ? rightOffset * -1 : 0
                node.css({
                    "min-width": listwidth,
                    "margin-left": -rightOverlap,
                    "margin-right": -leftOverlap
                })
            }
        }

        scrollSelectedIntoView(){
            // if item is out of view or too close (size of one row) to border => scroll list viewport
            if(!this.refs.list){
                return
            }
            let selectedItem = this.refs[this.cursorPosition + "_r"]
            if(selectedItem){
                let list = this.refs.list
                let offsetTop = selectedItem.offsetTop
                let rowHeight = selectedItem.clientHeight
                let min = list.scrollTop
                let max = list.scrollTop + list.clientHeight - rowHeight
                if(offsetTop < min){
                    list.scrollTop = offsetTop
                } else if(offsetTop > max){
                    list.scrollTop = offsetTop - list.clientHeight + rowHeight
                }
            }
        }

        refreshInputWidth(){
            delay(function(){
                // refresh input content - actual corpus and width
                let input = $(".ui-input input", this.root)
                let tempNode = $('<span>').hide().appendTo(document.body);
                tempNode.text(this.corpus ? this.corpus.name : input.attr('placeholder'))
                        .css('font', input.css('font'))
                        .css("font-size", "16px")
                        .css("padding-right", ".75em");
                let width = tempNode.outerWidth() + 40 // search icon
                let maxWidth = $("#headerRight").offset().left - input.offset().left - 50 // padding and "i" btn
                width = width <= maxWidth ? width : maxWidth
                input.css("width", width)
                tempNode.remove()
            }.bind(this), 1) // make it async so rest of page is rendered
        }

        focusInput(){
            $(".ui-input input", this.root).focus()
        }

        getUrlToResultPage(feature){
            let params = {
                tab: "basic"
            }
            if(feature == "wordsketch" || feature == "thesaurus"){
                params.lemma = this.query
            } else if(feature == "concordance"){
                params.keyword = this.query
            }
            return window.stores[feature].getUrlToResultPage(params)
        }

        getLoggedAsTooltip(){
            return _("loggedAs", [Auth.getUsername()])
        }

        onResizeDebounced(){
            this.timer && clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                clearTimeout(this.timer)
                this.refreshInputWidth()
                this.updateListPosition()
            }, 200)
        }

        onCorpusChange(){
            this.initData()
            this.update()
        }

        onCorpusListChanged(){
            this.initCorpora()
            this.showList && this.update()
        }

        onLogin(){
            this.initData()
            this.update()
        }

        this.on("update", this.updateAttributes)

        this.on("updated", () => {
            this.refreshInputWidth()
            this.updateListPosition()
        })

        onUserDataLoaded(){
            this.showInfo = UserDataStore.getOtherData("showInfoInCorpusSearch") || false
            this.showList && this.update()
        }

        this.on("mount", () => {
            this.handle = window.addEventListener('resize', this.onResizeDebounced)
            this.refreshInputWidth()
            AppStore.on("corpusChanged", this.onCorpusChange)
            AppStore.on("corpusListChanged", this.onCorpusListChanged)
            Dispatcher.on("AUTH_LOGIN", this.onLogin)
            Dispatcher.on("SELECT_CORPUS_FOCUS", this.focusInput)
            UserDataStore.on("otherChange", this.onUserDataLoaded)
        })

        this.on("unmount", () => {
            AppStore.off("corpusChanged", this.onCorpusChange)
            AppStore.off("corpusListChanged", this.onCorpusListChanged)
            Dispatcher.off("AUTH_LOGIN", this.onLogin)
            Dispatcher.off("SELECT_CORPUS_FOCUS", this.focusInput)
            UserDataStore.off("otherChange", this.onUserDataLoaded)
        })
    </script>
</header-corpus>
