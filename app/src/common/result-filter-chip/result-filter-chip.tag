<result-filter-chip class="result-filter-chip">
    <span if={data.search_query !== ""}
            class="chip cursor-pointer"
            onclick={onChipClick}>
        <span class="truncate"
                onmouseover={showTooltip}>
            {_("filter")},&nbsp;{_(data.search_mode)}&nbsp;<span class="red-text">{data.search_query}</span>
        </span>
        <i class="close material-icons"
                onclick={onCloseClick}>close</i>
    </span>


    <script>
        require("./result-filter-chip.scss")

        this.mixin("feature-child")

        onChipClick(){
            Dispatcher.trigger("FEATURE_TOOLBAR_SHOW_OPTIONS", "filter")
        }

        onCloseClick(evt){
            evt.stopPropagation()
            this.store.cancelFilter()
        }

        showTooltip(evt){
            evt.preventUpdate = true
            let node = evt.currentTarget
            if(node.clientWidth < node.scrollWidth){
                window.showTooltip(node, node.innerHTML, 600)
                evt.stopPropagation()
            }
        }
    </script>
</result-filter-chip>
