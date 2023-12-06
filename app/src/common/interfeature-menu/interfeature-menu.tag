<interfeature-menu>
    <ul id="{id}"
            class="dropdown-content interfeature-menu">
        <li each={link in links}
                class="doubleLinks"
                data-feature="{link.feature}"
                data-link={link.name}>
            <a class="currentTabLink">
                <i class="ske-icons {getFeatureIcon(link.feature)}"></i>
                {getLinkLabel(link)}
            </a>
            <a if={link.name != "concordanceMacro"}
                    target="_blank"
                    class="newTabLink menu-tooltip">
                <i class="material-icons">open_in_new</i>
            </a>
        </li>
    </ul>

    <script>
        require("./interfeature-menu-macro-dialog.tag")

        const {Auth} = require("core/Auth.js")
        const {AppStore} = require("core/AppStore.js")
        const {MacroStore} = require("common/manage-macros/macrostore.js")

        updateAttributes(){
            this.links = {}
            if(Array.isArray(this.opts.features)){
                this.links = this.opts.features.map( f => {
                    let link = {
                        feature: f,
                        name: f
                    }
                    if(f == "concordanceMacro"){
                        link.feature = "concordance"
                        link.label = _("concordanceMacro")
                    }
                    return link
                })
            } else{
                this.links = this.opts.links
            }
            if(!Auth.isFullAccount()){
                this.links = this.links.filter(l => {
                    return l.name != "concordanceMacro"
                })
            }
        }
        this.updateAttributes()

        this.id = this.opts.id || ('interfeatureMenu' + Math.floor((Math.random() * 100000)))

        getLinkLabel(link){
            return getLabel(link) || getFeatureLabel(link.feature)
        }

        onOpenMenuButtonClick(evt, rowData){
            evt.preventUpdate = true
            evt.stopPropagation()
            if(!$(evt.target).hasClass("menuIcon")){
                return // click on inner dropdown menu link, event bubbled to dropdown menu icon
            }
            let menuNode = $(evt.target.parentNode)
            if(evt.target.parentNode.tagName.toLowerCase() != "a"){
                return // prevent bug (duplicated menu) after fast click on icon before previous menu is completly closed
            }
            if(!menuNode.attr("data-target")){ // menu is not created yet
                let id = "ts_" + Date.now() + Math.floor((Math.random() * 10000))
                evt.stopPropagation()
                // creating copy of list. Without copy, UL is moved as child of target node and after riot update is destroyed
                $("#" + this.id).clone()
                    .attr({id: id})
                    .appendTo($("body"))
                    .find("li").each(function(idx, elem){
                        let li = $(elem)
                        let aNodes = li.find("a")
                        let feature = li.data("feature")
                        let link = li.data("link")
                        let linkObj = this.links.find(l => { return l.name == link})
                        let isConcMacro = linkObj.name == "concordanceMacro"
                        let disabled = !window.permissions[feature]
                                || (isFun(this.opts.isFeatureLinkActive) && !this.opts.isFeatureLinkActive(feature, rowData, evt, linkObj))
                        let urlParams = this.opts.getFeatureLinkParams(feature, rowData, evt, linkObj)
                        if(!disabled && urlParams.corpname){
                            let corpus = AppStore.getCorpusByCorpname(urlParams.corpname)
                            if(corpus && !corpus.user_can_read){
                                disabled = true
                            }
                        }
                        if(isConcMacro && !MacroStore.hasAnyMacro()){
                            disabled = true
                        }
                        if(disabled){
                            aNodes.attr("disabled", disabled)
                            li.addClass("menu-tooltip disabled")
                            if(isConcMacro){
                                li.attr("data-tooltip", _("concordanceHasNoMacros"))
                            } else {
                                li.attr("data-tooltip", _("wl." + feature + "LinkDisabled"))
                            }
                        } else{
                            if(isConcMacro){
                                aNodes.click(() => {
                                    menuNode.dropdown("close")
                                    this.openConcordanceMacroDialog(urlParams)
                                })
                            } else {
                                let url = window.stores[feature].getUrlToResultPage(urlParams)
                                aNodes.attr("href", url)
                                li.find(".newTabLink").attr("data-tooltip", _("openInNewTab"))
                                         .attr("data-position", "right")
                            }
                        }
                    }.bind(this))
                menuNode.attr("data-target", id)
                    .dropdown({
                        constrainWidth: false,
                        closeOnClick: false,
                        onOpenEnd: () => {$(".menu-tooltip").tooltip({enterDelay: 1000})},
                        onCloseStart: () => {destroyTooltips(".menu-tooltip")}
                    })
                    .dropdown("open")
            }
        }

        openConcordanceMacroDialog(params){
            Dispatcher.trigger("openDialog", {
                title: _("macros"),
                tag: "interfeature-menu-macro-dialog",
                fixedFooter: true,
                opts: {
                    params: params
                }
            })
        }

        this.on("update", this.updateAttributes)
    </script>
</interfeature-menu>
