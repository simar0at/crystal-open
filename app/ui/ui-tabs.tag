<ui-tabs class="ui ui-tabs">
    <div>
        <ul class="tabs">
            <li class="tab" each={tab, idx in tabs}>
                <a href="javascript:void(0);"
                    id="tab-link-{tab.tabId}"
                    ref={"link-" + tab.tabId}
                    onclick={onTabClick}>
                    {getLabel(tab)}
                    <i if={tab.icon} class="material-icons">{tab.icon}</i>
                </a>
            </li>
        </ul>
    </div>
    <div class="tabContent">
        <div each={tab, idx in tabs}
            ref={"content-" + tab.tabId}
            id="tab-{tab.tabId}"
            data-is={tab.tag}></div>
    </div>

    <script>
        this.mixin('ui-mixin')
        this.tabs = opts.tabs
        this.tab = this.opts.active ? this.opts.active : this.opts.tabs[0].tabId

        setTab(tab){
            this.tab = tab
            this.refreshDisplay()
        }

        onTabClick(evt){
            evt.preventUpdate = true
            this.tab = evt.item.tab.tabId
            this.refreshDisplay()
            isFun(this.opts.onTabChange) && this.opts.onTabChange(this.tab)
        }

        refreshDisplay(){
            this.tabs.forEach(function(tab){
                let isActive = tab.tabId == this.tab
                $(this.refs["link-" + tab.tabId]).toggleClass("active", isActive)
                $(this.refs["content-" + tab.tabId].root).toggle(isActive).toggleClass("active", isActive)
            }.bind(this))
        }

        this.on("update", () => {
            this.tab = isDef(this.opts.active) ? this.opts.active : this.opts.tabs[0].tabId
        })
        this.on("updated", () => {
            this.refreshDisplay()
        })
        this.on("mount", this.refreshDisplay)
    </script>
</ui-tabs>
