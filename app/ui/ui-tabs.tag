<ui-tabs class="ui ui-tabs {opts.class}">
    <div>
        <ul ref="tabs"
                class="tabs">
            <li class="tab" each={tab, idx in tabs}>
                <a href="javascript:void(0);"
                class={active: tab.tabId == parent.tab}
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
        <div each={t, idx in tabs}
            ref={"content-" + t.tabId}
            id="tab-{t.tabId}"
            data-is={t.tag}></div>
    </div>

    <script>
        this.mixin('ui-mixin')

        updateAttributes(){
            this.tabs = opts.tabs
            this.tab = isDef(this.opts.active) ? this.opts.active : this.opts.tabs[0].tabId
        }
        this.updateAttributes()

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

        onResizeDebounced(){
            this.timer && clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                clearTimeout(this.timer)
                this.fixScrollBar()
            }, 200)
        }

        fixScrollBar(){
            if(this.refs.tabs){
                if(this.refs.tabs.scrollWidth > this.refs.tabs.clientWidth){
                    this.refs.tabs.classList.add("hasScrollbar")
                } else {
                    this.refs.tabs.classList.remove("hasScrollbar")
                }
            }
        }

        this.on("update", this.updateAttributes)
        this.on("updated", this.refreshDisplay)
        this.on("mount", () => {
            this.refreshDisplay()
            window.addEventListener('resize', this.onResizeDebounced)
            delay(this.fixScrollBar, 500) // if tab is in modal we need to wait for animation
        })

        this.on("unmount", () => {
            window.removeEventListener('resize', this.onResizeDebounced)
        })
    </script>
</ui-tabs>
