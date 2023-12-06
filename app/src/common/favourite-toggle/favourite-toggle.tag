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
        this.LABEL_SIZE = UserDataStore.PAGES_LABEL_SIZE

        this.store = this.opts.store

        updateAttributes(){
            this.isFavourite = UserDataStore.isPageInFavourite(this.store.getResultPageObject())
        }
        this.updateAttributes()

        onFavouriteToggleClick(evt){
            let page = this.store.getResultPageObject()
            if (this.isFavourite){
                this.isFavourite = !this.isFavourite
                UserDataStore.togglePageFavourites(false, page)
            } else{
              Dispatcher.trigger("openDialog", {
                title: _("addToFavourite"),
                tag: "ui-input",
                small: true,
                showCloseButton: true,
                buttons: [{
                    label: _("save"),
                    class: "btn-primary",
                    onClick: function(dialog, modal){
                        let value = dialog.contentTag.getValue().trim()
                        if (value && value.length > this.LABEL_SIZE){
                            value = value.substring(0, this.LABEL_SIZE)
                        }
                        page.label = value
                        UserDataStore.togglePageFavourites(true, page)
                        modal.close()
                    }.bind(this)
                }],
                opts: {
                    type: "text",
                    name: "t_favouriteDesc",
                    maxlength: this.LABEL_SIZE,
                    placeholder: _("addFavouriteLabel")
                }
              })
            }
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            UserDataStore.on("pages_favouritesChange", this.update)
        })

        this.on("unmount", () => {
            UserDataStore.off("pages_favouritesChange", this.update)
        })
    </script>
</favourite-toggle>
