<result-list class="result-list">
    <div if={list.length}>
        <a class="link clear hide-on-small-only"
                if={opts.section != "annotations"}
                onclick={onClearListClick}>{_("deleteAll")}</a>
        <ui-filtering-list
            name="resultList"
            size=20
            disable-tooltips=true
            options={options}></ui-filtering-list>
    </div>
    <span if={!list.length}>
        <span if={opts.section == "annotations"}>
            {_("nothingHere")}
        </span>
        <span if={!opts.section == "annotations"}>
            {_("nothingHere")}
        </span>
    </span>

    <script>
        require("./result-list.scss")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")

        getTime(page){
            return window.Formatter.dateTime(new Date(page.timestamp * 1))
        }

        getFeatureOptions(page){
            let ret = ""
            let opt
            for(let key in page.userOptions){
                let opt = page.userOptions[key]
                let label = opt.label || ""
                if(!label){
                    // TODO: just for some time - removing "xx." prefix after changing keys in resources
                    if(opt.labelId){
                        let labelId = (opt.labelId.indexOf(".") == "-1") ? opt.labelId : opt.labelId.split(".")[1]
                        label = _(labelId, {_: ""}) || _(opt.labelId)
                    }
                }
                ret += "<span>" + label.toLocaleLowerCase()
                if (isDef(opt.value) && opt.value !== "") {
                  ret +=  " &quot;<b>" + htmlEscape(riotEscape(opt.value)) + "</b>&quot;"
                }
                ret += "</span>"
            }
            return ret
        }

        itemGeneratorAnnot(option) {
            return `<a href="${this.getResultUrl(option.page)}">${option.value}</a>`
        }

        itemGenerator(option){
            return `<a href="${this.getResultUrl(option.page)}">
                        <span class='corpus'>${option.page.corpus}</span>
                        <span class='date hide-on-med-and-down'>${this.getTime(option.page)}</span>
                        <span class='featureIco'><i class='ske-icons ${getFeatureIcon(option.page.feature)} small'></i></span>
                        <span class='feature hide-on-small-only'>${getFeatureLabel(option.page.feature)}</span>
                        <span class='opts'>${this.getFeatureOptions(option.page)}</span>` + // wierd parsing bug workaround...
                    "</a> \
                    <a class='delete btn-flat btn-floating hide-on-small-only'>\
                        <i class='material-icons'>delete</i>\
                    </a>"
        }

        refreshAttributes(){
            if (this.opts.section == "annotations") {
                this.list = ConcordanceStore.get('storedconcs')
                this.options = []
                this.list.forEach((conc, idx) => {
                    this.options.push({
                        value: conc,
                        page: {
                            feature: "concordance",
                            corpname: ConcordanceStore.corpus.corpname,
                            data: {annotconc: conc}
                        },
                        label: conc,
                        generator: this.itemGeneratorAnnot
                    })
                })
            }
            else {
                this.list = UserDataStore.get(`pages.${this.opts.section}`)
                this.options = []
                this.list.forEach((page, idx) => {
                    this.options.unshift({ // oldest to bottom
                        value: idx,
                        page: page,
                        label: this.getTime(page) + " " + page.corpus + " " + page.feature + this.getFeatureOptions(page),
                        generator: this.itemGenerator
                    })
                })
            }
        }
        this.refreshAttributes()

        onClearListClick(evt){
            UserDataStore.clearUserData(`pages_${opts.section}`)
        }

        getResultUrl(page){
            return window.stores[page.feature].getUrlToResultPage(Object.assign({
                corpname: page.corpname
            }, page.data))
        }

        bindDeleteClick(){
            $("li .delete", this.root).click(function(evt){
                evt.stopPropagation()
                let idx = $(evt.target).closest("li").data("value")
                let page = this.list[idx]
                if(this.opts.section == "history"){
                    UserDataStore.removePageFromHistory(page)
                } else{
                    UserDataStore.togglePageFavourites(false, page)
                }
            }.bind(this))
        }

        this.on("update", this.refreshAttributes)

        this.on("updated", () => {
            this.bindDeleteClick()
        })

        this.on("mount", () => {
            this.bindDeleteClick()
            UserDataStore.on("pagesChange", this.update)
            ConcordanceStore.on("ANNOTATIONS_UPDATED", this.update)
            ConcordanceStore.on("ANNOTATION_REMOVED", this.update)
            ConcordanceStore.on("ANNOTATION_CREATED", this.update)
        })

        this.on("unmount", () => {
            UserDataStore.off("pagesChange", this.update)
            ConcordanceStore.off("ANNOTATIONS_UPDATED", this.update)
            ConcordanceStore.off("ANNOTATION_REMOVED", this.update)
            ConcordanceStore.off("ANNOTATION_CREATED", this.update)
        })
    </script>
</result-list>
