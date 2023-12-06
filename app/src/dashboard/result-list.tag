<result-list class="result-list">
      <div>
        <div class="right hide-on-small-only">
          <ui-switch label-id="searchHistory"
              riot-value="{historyValue}"
              class="right"
              name="historyValue"
              on-change={toggleSwitch}>
          </ui-switch>
          <ui-switch label-id="db.favouritesResults"
              riot-value="{favouritesChecked}"
              class="right"
              name="favouritesChecked"
              on-change={toggleSwitch}>
          </ui-switch>
        </div>
        <ui-filtering-list if={list.length}
            name="resultList"
            ref="resultList"
            size=20
            disable-tooltips=true
            options={options}>
        </ui-filtering-list>
        <div class="right hide-on-small-only">
            <a if={list.length}
                class="link clear"
                onclick={onClearListClick}>{_("deleteAll")}
            </a>
        </div>
    </div>
    <span if={!list.length}>
        <span>{_("nothingHere")}</span>
    </span>

    <script>
        require("./result-list.scss")
        const {UserDataStore} = require("core/UserDataStore.js")
        this.LABEL_SIZE = UserDataStore.PAGES_LABEL_SIZE

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
            return `<div class='result-row'>
                      <a class='favourite btn btn-flat btn-floating tooltipped' data-tooltip="` +
                      (option.page.favourite ? _("removeFromFavourite") + '"> <i class=\'material-icons favourited\'>star</i>' : _("addToFavourite") + '"> <i class=\'material-icons\'>star_border</i>')
                      + `</a>
                      <a href="${this.getResultUrl(option.page)}" class='result-data'>
                          <span class='line'>
                              <span class='corpus'>${option.page.corpus}</span>
                              <span class='chip ${!option.page.label?'hidden':''}'><i class='material-icons tiny'>label</i> ${option.page.label}</span>
                          </span>
                          <span class='featureIco'><i class='ske-icons ${getFeatureIcon(option.page.feature)} small'></i></span>
                          <span class='feature hide-on-small-only'>${getFeatureLabel(option.page.feature)}</span>
                          <span class='opts'>${this.getFeatureOptions(option.page)}</span>
                      </a>
                      <div class='date hide-on-med-and-down'>
                        ${this.getTime(option.page)}
                      </div>
                      <button class='btn btn-flat btn-floating hide-on-small-only dropdown-trigger tooltipped' data-target=${option.value} data-tooltip="` +
                      _("labelActions") +`" data-position="top">
                          <i class="material-icons menuIcon">label${!option.page.label?'_outline': ''}</i>
                      </button>
                      <button class='delete btn btn-flat btn-floating hide-on-small-only tooltipped' data-tooltip="` +
                              (option.page.favourite ? _("removeFromFavourite") : _("removeFromHistory"))
                              + `">
                          <i class='material-icons'>delete</i>
                      </button>
                      <ul id='${option.value}' class='dropdown-content' data-value='${option.value}'>
                          <li class="serviceNode"><a class="labelAdd ${option.page.label?'disabled': ''}" href="javascript:void(0);"><i class="material-icons">add_circle</i>`
                          +_("addLabel")+`</a></li>
                          <li class="serviceNode"><a class="labelEdit ${!option.page.favourite||!option.page.label?'disabled': ''}" href="javascript:void(0);"><i class="material-icons">edit</i>`
                          +_("editLabel")+`</a></li>
                          <li class="serviceNode"><a class="labelDelete ${!option.page.favourite||!option.page.label?'disabled': ''}" href="javascript:void(0);"><i class="material-icons">delete</i>`
                          +_("removeLabel")+`</a></li>
                      </ul>
                    </div>`
        }

        initData(){
            this.favourites = []
            this.history = []
            this.list = []
            this.options = []

            this.favouritesChecked = false;
            this.historyValue = false;
        }

        refreshAttributes(){
            this.list = []
            this.options = []
            this.favourites = UserDataStore.get(`pages_favourites`).map(page => ({ ...page, favourite: 'true' }))
            this.history = UserDataStore.get(`pages_history`)

            if(!this.favouritesChecked && !this.historyValue){
              this.list = this.history.filter((page) => !UserDataStore.isPageInFavourite(page))
                          .concat(this.favourites)
                          .sort((a, b) => a.timestamp - b.timestamp)
            }
            else if(this.favouritesChecked){
              this.list = this.favourites;
            }
            else if(this.historyValue){
              this.list = this.history;
            }

            this.list.forEach((page, idx) => {
                this.options.unshift({ // oldest to bottom
                    value: idx,
                    page: page,
                    label: this.getTime(page) + " " + page.corpus + " " + page.feature + this.getFeatureOptions(page) + " " + page.label,
                    generator: this.itemGenerator,
                    class: "resultItem"
                })
            })
        }

        toggleSwitch(value, name){
          this[name] = value

          // Only one switch can be on
          if (value){
              (name == "favouritesChecked") ? this.historyValue = false : this.favouritesChecked = false
          }

          this.update()
        }

        this.initData()
        this.refreshAttributes()

        onClearListClick(evt){
          Dispatcher.trigger("openDialog", {
              small: true,
              showCloseButton: true,
              content: this.favouritesChecked ? _("removeAllFavouriteConfirmation") : _("removeAllHistoryConfirmation"),
              buttons: [{
                  label: _("an.remove"),
                  class: "btn-primary",
                  onClick: function(dialog, modal){
                      !this.favouritesChecked && UserDataStore.clearData('pages_history')
                      !this.historyValue && UserDataStore.clearData('pages_favourites')
                      modal.close()
                  }.bind(this)
              }]
          })
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
                if (page.favourite){
                  Dispatcher.trigger("openDialog", {
                      small: true,
                      showCloseButton: true,
                      content: _("removeFromFavouriteConfirmation"),
                      buttons: [{
                          label: _("an.remove"),
                          class: "btn-primary",
                          onClick: function(dialog, modal){
                              UserDataStore.togglePageFavourites(false, page)
                              modal.close()
                          }.bind(this)
                      }]
                  })
                }
                else{
                  Dispatcher.trigger("openDialog", {
                      small: true,
                      showCloseButton: true,
                      content: _("removeFromHistoryConfirmation"),
                      buttons: [{
                          label: _("an.remove"),
                          class: "btn-primary",
                          onClick: function(dialog, modal){
                              UserDataStore.removePageFromHistory(page)
                              modal.close()
                          }.bind(this)
                      }]
                  })
                }
            }.bind(this))
        }

        bindFavouriteToggle(){
            $(".favourite", this.root).click(function(evt){
                evt.stopPropagation()
                let idx = $(evt.target).closest("li").data("value")
                let page = this.list[idx]
                page && UserDataStore.togglePageFavourites(!page.favourite, page)
            }.bind(this))
        }

        initDropdown(){
            $('.dropdown-trigger').click(function(evt){
               evt.stopPropagation()
               let elem = $(evt.currentTarget).dropdown({
                  constrainWidth: false,
                  alignment: "right",
                  coverTrigger: false
               })
               M.Dropdown.getInstance(elem).open()
            })
        }

        bindLabelActions(){
            $(".dropdown-content .labelAdd", this.root).off().click(function(evt){
                evt.stopPropagation()
                let idx = $(evt.target).closest(".dropdown-content").data("value")
                let page = this.list[idx]
                Dispatcher.trigger("openDialog", {
                    title: _("addLabel"),
                    small: true,
                    showCloseButton: true,
                    tag: "ui-input",
                    buttons: [{
                        label: _("save"),
                        class: "btn-primary",
                        onClick: function(dialog, modal){
                            this.setLabel(dialog.contentTag.getValue().trim(), page)
                            modal.close()
                        }.bind(this)
                    }],
                    opts: {
                        type: "text",
                        maxlength: this.LABEL_SIZE,
                        placeholder: _("addFavouriteLabel")
                    }
                })
            }.bind(this))

            $(".dropdown-content .labelEdit", this.root).off().click(function(evt){
                evt.stopPropagation()
                let idx = $(evt.target).closest(".dropdown-content").data("value")
                let page = this.list[idx]
                Dispatcher.trigger("openDialog", {
                    title: _("editLabel"),
                    small: true,
                    showCloseButton: true,
                    tag: "ui-input",
                    buttons: [{
                        label: _("save"),
                        class: "btn-primary",
                        onClick: function(dialog, modal){
                            this.setLabel(dialog.contentTag.getValue().trim(), page)
                            modal.close()
                        }.bind(this)
                    }],
                    opts: {
                        type: "text",
                        maxlength: this.LABEL_SIZE,
                        riotValue: page.label
                    }
                })
            }.bind(this))

            $(".dropdown-content .labelDelete", this.root).off().click(function(evt){
                evt.stopPropagation()
                let idx = $(evt.target).closest(".dropdown-content").data("value")
                let page = this.list[idx]
                Dispatcher.trigger("openDialog", {
                    small: true,
                    showCloseButton: true,
                    content: _("removeLabelConfirmation"),
                    buttons: [{
                        label: _("an.remove"),
                        class: "btn-primary",
                        onClick: function(dialog, modal){
                            this.setLabel(null, page)
                            modal.close()
                        }.bind(this)
                    }]
                })
            }.bind(this))
        }

        setLabel(value, page){
            if (value && value.length > this.LABEL_SIZE){
                value = value.substring(0, this.LABEL_SIZE)
            }
            UserDataStore.saveLabel(page, value)
            this.update()
        }

        initBindings(){
            this.bindDeleteClick()
            this.bindFavouriteToggle()
            this.initDropdown()
            this.bindLabelActions()
        }

        this.on("update", this.refreshAttributes)

        this.on("updated", () => {
            this.initBindings()
        })

        this.on("mount", () => {
            this.initBindings()
            UserDataStore.on("pages_historyChange", this.update)
            UserDataStore.on("pages_favouritesChange", this.update)
            this.refs.resultList && this.refs.resultList.on("updated", this.initBindings)
        })

        this.on("before-unmount", () => {
            UserDataStore.off("pages_historyChange", this.update)
            UserDataStore.off("pages_favouritesChange", this.update)
            this.refs.resultList && this.refs.resultList.off("updated", this.initBindings)
        })
    </script>
</result-list>
