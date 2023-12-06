<favourite-toggle class="favourite-toggle">
    <a onclick={onFavouriteToggleClick}
        data-tooltip={_(isFavourite ? "removeFromFavourite" : "addToFavourite")}
        class="tooltipped btn btn-floating btn-flat {disabled: opts.disabled, favourite: isFavourite}">
        <i class="material-icons">{isFavourite ? "star" : "star_border"}</i>
    </a>

    <script>
        this.mixin("tooltip-mixin")
        require("./favourite-toggle.scss")
        const {UserDataStore} = require("core/UserDataStore.js")

        this.store = this.opts.store

        updateAttributes(){
            this.isFavourite = UserDataStore.isPageInFavourite(this.store.getResultPageObject())
        }
        this.updateAttributes()

        onFavouriteToggleClick(evt){
            this.isFavourite = !this.isFavourite
            UserDataStore.togglePageFavourites(this.isFavourite, this.store.getResultPageObject())
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            UserDataStore.on("pagesChange", this.update)
        })

        this.on("unmount", () => {
            UserDataStore.off("pagesChange", this.update)
        })
    </script>
</favourite-toggle>
