<ske-li-dialog class="ske-li-dialog">
    <div if={isShortening} class="center-align" style="min-height: 150px;">
        <br><br>
        <h5 class="grey-text">{_("shortening")}</h5>
    </div>
    <div class="center-align {hidden: isShortening || newLink}">
        <div class="row">
            <div class="col s12 m3">
                <ui-input ref="name"
                        label={_("nameOpts")}
                        validate=1
                        min-length=8
                        pattern="[A-Za-z0-9_]\{8,\}"
                        pattern-mismatch-message={_("invalidLinknNme")}
                        on-input={onNameInput}></ui-input>
            </div>
            <div class="col s12 m9">
                <ui-textarea class="desc"
                    label={_("descriptionOpts")}
                    ref="desc"
                    riot-value={desc}
                    rows=2></ui-textarea>
            </div>
        </div>

        <div class="primaryButtons">
            <a href="javascript:void(0);"
                    ref="createLinkBtn"
                    class="btn btn-primary"
                    onclick={onCreateLinkClick}>
                {_("createLink")}
            </a>
        </div>
    </div>
    <div if={newLink} class="center-align" style="min-height: 150px;">
        <br><br>
        <a href="https://ske.li/{newLink.name || newLink.hash}" target="_blank">
            <h3 class="inline-block">ske.li/{newLink.name || newLink.hash}</h3>
        </a>
        <br>
        <span onclick={onCopyClick} class="btn copyLink">{_("copyAndClose")}</span>
    </div>

    <br>
    <div class="center-align">
        <a class="btn btn-flat noCapitalization"
                onclick={onShowLInksToggle}>
            {_("olderLinks")}
            <i class="material-icons right">{showLinks ? "arrow_drop_up" : "arrow_drop_down"}</i>
        </a>
    </div>

    <div class="{hidden: !showLinks}">
        <h4>{_("olderLinks")}</h4>
        <table if={storedLinks.length} class="linkTable">
            <tbody each={link in storedLinks}>
                <tr>
                    <td>
                        <small class="grey-text">{getLocaleDate(link.created)}</small>
                    </td>
                    <td>
                        <a href="{link.skelink_url}" target="_blank">{link.skelink_name}</a>
                        <div if={link.desc}>
                            {link.desc}
                        </div>
                        <div if={link.url} class="grey-text linkUrl">
                            {link.url}
                        </div>
                    </td>
                </tr>

            </tbody>
        </table>
        <div if={!storedLinks.length} class="noStoredLinks">
            <h5 class="center-align grey-text">{_("nothingFound")}</h5>
        </div>
    </div>

    <script>
        require("./ske-li-dialog.scss")
        const {Auth} = require("core/Auth.js")
        const {Url} = require("core/url.js")
        const {Router} = require("core/Router.js")
        const {AppStore} = require("core/AppStore.js")
        this.isShortening = false
        this.storedLinks = []
        this.showLinks = false
        this.newLink = null

        let actualPageId = Router.getActualPage()
        let actualFeature = Router.getActualFeature()
        let optionsStr = ""
        this.desc = _(actualPageId)
        if(actualFeature){
            let store = window.stores[actualFeature]
            let options = store.getUserOptions()
            for(let key in options){
                optionsStr += optionsStr ? ", " : ""
                optionsStr += _(options[key].labelId) + "='" + options[key].value + "'"
            }
        } else {
            let corpname = Url.getQuery().corpname
            if(corpname){
                optionsStr = "corpus='" + AppStore.get("corpus.name") + "'"
            }
        }
        if(optionsStr){
            this.desc += ": " + optionsStr
        }

        loadStoredLinks(){
            $.ajax({
                url: window.config.URL_SKE_LI + "links",
                data: {
                    username: Auth.getUsername()
                },
                headers: {
                    "X-SKELI-CRYSTAL": "crystal-api"
                }
            })
            .done((payload) => {
                this.storedLinks = payload.data.reverse().map(link => {
                    let path = (link.name || link.hash)
                    link.skelink_url = "https://ske.li/" + path
                    link.skelink_name = "ske.li/" + path
                    return link
                })

                this.update()
            })
            .fail(()=>{

            })
        }
        this.loadStoredLinks()

        onNameInput(value, name, evt){
            let tag = evt.currentTarget.parentNode.parentNode._tag
            tag.validate()
            let disabled = !tag.isValid
            $(this.refs.createLinkBtn).toggleClass("disabled", disabled)
        }

        onCreateLinkClick(){
            $.ajax({
                url: window.config.URL_SKE_LI + "store",
                method: "POST",
                data: {
                    username: Auth.getUsername(),
                    url: encodeURI(window.location.href),
                    name: this.refs.name.getValue(),
                    desc: this.refs.desc.getValue()
                },
                headers: {
                    "X-SKELI-CRYSTAL": "crystal-api"
                }
            })
            .done((payload) => {
                this.newLink = payload.data
                this.update()
            })
            .fail(xhr => {
                SkE.showToast(xhr.responseJSON.error)
            })
            .always(() => {
                this.isShortening = false
                this.showLinks && this.loadStoredLinks()
                this.update()
            })

            this.isShortening = true
        }

        onShowLInksToggle(){
            this.showLinks = !this.showLinks
            $(".shortLinkDialog").toggleClass("skeLiExpanded", this.showLinks)
        }

        onCopyClick(evt){
            evt.stopPropagation()
            Dispatcher.trigger("closeDialog")
            copyToClipboard("https://ske.li/" + (this.newLink.name || this.newLink.hash))
        }

    </script>
</ske-li-dialog>
