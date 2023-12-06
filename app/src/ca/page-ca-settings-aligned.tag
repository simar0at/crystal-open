<page-ca-settings-aligned class="page-ca-settings-aligned ca">
    <ca-breadcrumbs active="ca-settings-aligned" section="createMultiAligned"></ca-breadcrumbs>
    <div if={!isQuery}>
        <div class="primaryButtons">
            <br><br>
            <h5>{_("somethingWentWrong")}</h5>
            <br><br>
            <a href="#dashboard" class="btn btn-primary">{_("goToDashboard")}</a>
        </div>
    </div>
    <virtual if={isQuery}>
        <div if={isLoading} class="centerSpinner">
            <preloader-spinner></preloader-spinner>
        </div>
        <div class="columnWrapper" style="max-width: 600px; margin: auto;" if={!isLoading}>
            <div if={isError}>
                <h5 style="padding: 0px 0;">{_("notFound")}</h5>
                <div>{_("alignedDataErrorMessage")} <a href="mailto:{externalLink('support@sketchengine.eu')}">support@sketchengine.eu</a></div>
                <br><br>
                <div class="primaryButtons">
                    <a href="#dashboard" id="btnBack" class="btn btn-flat btn-primary">{_("goToDashboard")}</a>
                </div>
            </div>
            <virtual if={!isError}>
                <div if={!data.corpora}>
                    <h5 style="padding: 0px 0;">{_("noCorpusFound")}</h5>
                    <div>{_("alignedDataEmptyNote")}</div>
                    <br><br>
                    <div class="primaryButtons">
                        <a href="#ca-create-upload-aligned" id="btnBack" class="btn btn-flat btn-primary color-blue-800">{_("back")}</a>
                    </div>
                </div>
                <virtual if={data.corpora}>
                    <div class="grey-text">{_("ca.alignedDataSettingsNote")}</div>
                    <div class="card-panel">
                        <div class="columnForm">
                            <div class="row t_lang_{htmlEscape(corpus.language_id)}" each={corpus, userLangName in data.corpora} >
                                <label class="col m5 s12">{_("ca.corpusName", [userLangName])}</label>
                                <span class="col m7 s12">
                                    <ui-input class="corpName"
                                            name="corpname"
                                            required=1
                                            validate=1
                                            riot-value={corpus.name}
                                            on-input={onCorpusnameInput}
                                            on-change={onCorpnameChange.bind(this, userLangName)}
                                            inline=1></ui-input>
                                </span>
                                <label class="col m5 s12">{_("ca.corpusLanguage", [userLangName])}</label>
                                <span class="col m7 s12">
                                    <ui-select riot-value={corpus.language_id}
                                            name="language"
                                            on-change={onLanguageChange.bind(this, userLangName)}
                                            options={languageList}></ui-select>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="buttons primaryButtons">
                        <a href="#ca-create-upload-aligned" id="btnBack" class="btn btn-flat color-blue-800 color-blue-800">{_("back")}</a>
                        <a class="btn btn-primary btnNext disabled"
                                id="btnNext"
                                onclick={onNextClick}>{_("next")}</a>

                        <floating-button classes="btnNext"
                            on-click={onNextClick}
                            label=""
                            refnodeid="btnNext"
                            icon="arrow_forward"
                            disabled=1></floating-button>
                    </div>
                </virtual>
            </virtual>
        </div>
    </virtual>



    <script>
        const {AppStore} = require("core/AppStore.js")
        const {CAStore} = require("./castore.js")
        const {Url} = require("core/url.js")

        this.isLoading = true
        this.isEmpty = true
        this.isQuery = true
        this.isValid = false
        this.data = {}

        let query = Url.getQuery()
        if(query.somefile_id && query.corpusname){
            this.somefile_id = query.somefile_id
            this.corpusname = decodeURIComponent(query.corpusname)
            CAStore.loadSomefile(this.somefile_id).xhr
                .done(function(payload){
                    if(payload.data.guessed_languages){
                        this.data = {
                            corpora: {}
                        }
                        for(let userLangName in payload.data.guessed_languages){
                            let langId = payload.data.guessed_languages[userLangName]
                            this.data.corpora[userLangName] = {
                                language_id: langId || "select",
                                name: this.getCorpusName(langId, userLangName)
                            }
                        }
                    }
                }.bind(this))
                .fail(function(payload){
                    this.isError = true
                }.bind(this))
                .always(function(){
                    this.isLoading = false
                    this.update()
                    this.refreshNextDisabled()
                }.bind(this))
        } else {
            this.isQuery = false
        }


        refreshLanguageList(){
            this.languageList = AppStore.data.languageList.map(l => {
                return {
                    value: l.id,
                    label: l.name
                }
            })
            this.languageList.unshift({
                value: "select",
                label: _("selectValue")
            })
        }
        this.refreshLanguageList()

        AppStore.on('languageListLoaded', () => {
            this.refreshLanguageList()
            this.update()
        })

        getCorpusName(languageId, userLangName){
            return this.corpusname + ", "
                    + (languageId ? AppStore.getLanguage(languageId).name : userLangName)
        }

        onCorpusnameInput(){
            this.refreshNextDisabled()
        }

        onCorpnameChange(userLangName, value, name, evt){
            this.data.corpora[userLangName].name = value
        }

        onLanguageChange(userLangName, value){
            this.data.corpora[userLangName].language_id = value
            this.refreshNextDisabled()
        }

        refreshIsValid(){
            this.isValid = $(".corpName input", this.root).filter((idx, input) => {
                return input.value === ""
            }).length == 0
            if(this.isValid){
                for(let userLangName in this.data.corpora){
                    this.isValid = this.isValid && this.data.corpora[userLangName].language_id != "select"
                }
            }
        }

        refreshNextDisabled(){
            this.refreshIsValid()
            $(".btnNext", this.root).toggleClass("disabled", !this.isValid)
        }

        onNextClick(){
            $("#btnNext").addClass("disabled")
            CAStore.changeAlignedDataSettings(this.somefile_id, this.data)
                .done(function(payload){
                    AppStore.loadCorpusList()
                    Dispatcher.trigger("ROUTER_GO_TO", "ca-compile-aligned", {
                        corpora: JSON.stringify(payload.data.map(corpus => {
                            return corpus.id
                        })) // list of corpora IDs
                    })
                }.bind(this))
        }

        CAStore.updateUrl()
    </script>
</page-ca-settings-aligned>
