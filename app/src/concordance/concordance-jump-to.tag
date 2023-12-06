<concordance-jump-to-dialog class="concordance-jump-to-dialog monospace">
    <span each={letter in data} onclick={onLetterClick}>{letter.label}</span>

    <script>
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")

        this.data = ConcordanceStore.get("raw.Sort_idx").sort( (a,b) =>{
            return a.label.localeCompare(b.label)
        })

        onLetterClick(evt){
            Dispatcher.trigger("closeDialog", "concordanceJumpTo")
            // TODO: just temporary, until Bonito is updated, then remove "page" option
            ConcordanceStore.searchAndAddToHistory({
                page: isDef(evt.item.letter.page) ? evt.item.letter.page : evt.item.letter.pos / ConcordanceStore.get("itemsPerPage") + 1
            })
        }
    </script>
</concordance-jump-to-dialog>


<concordance-jump-to class="concordance-jump-to">
    <a class="btn" onclick={onJumpToClick}>
        {_("cc.jumpTo")}
        <i class="material-icons right">redo</i>
    </a>

    <script>
        require("./concordance-jump-to.scss")

        onJumpToClick(){
            Dispatcher.trigger("openDialog", {
                id: "concordanceJumpTo",
                title: _("cc.jumpToTitle"),
                tag: "concordance-jump-to-dialog"
            })
        }

        this.on("mount", () => {
            Dispatcher.on("concordanceOpenJumpTo", this.onJumpToClick)
        })

        this.on("unmount", () => {
            Dispatcher.off("concordanceOpenJumpTo", this.onJumpToClick)
        })

    </script>
</concordance-jump-to>
