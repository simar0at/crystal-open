<ca-compiler class="ca-compiler">
    <preloader-spinner if={!canBeCompiledLoaded} center=1></preloader-spinner>
    <virtual if={space.has_space && canBeCompiledLoaded}>
        <div class="status card-panel">
            <virtual if={corpus.can_be_compiled || corpus.isCompiling || corpus.isTagging}>
                <span class="statusText">
                    {_("ca." + corpus.status.toLowerCase())}
                    <a if={corpus.isCompiling}
                            id="btnCancelCompilation"
                            class="btn btn-floating btn-flat"
                            onclick={onCancelCompilation}>
                        <i class="material-icons grey-text">close</i>
                    </a>
                </span>
                <div ref="progressBar" class="progress {visibilityHidden: !corpus.isCompiling && !corpus.isTagging}">
                    <div class="indeterminate"></div>
                </div>
                <div class="statusDesc">
                    {_("ca." + corpus.status.toLowerCase() + "Desc")}
                    <div if={corpus.isCompiling}>
                        <br>
                        {_("ca.compilingTime1")} <br> {_("ca.compilingTime2")}
                    </div>
                </div>
            </virtual>
            <virtual if={canBeCompiledLoaded && !corpus.can_be_compiled && !corpus.isCompiling && !corpus.isTagging}>
                <h4>{_("compilationNotAvailable")}</h4>
                <div if={corpus.compilationNotAllowedReason}>{_("reason." + corpus.compilationNotAllowedReason.toLowerCase())}</div>
            </virtual>

            <br>
            <div class="buttons primaryButtons">
                <a href="#ca-create-content"
                        if={opts.showAddMoreFilesBtn}
                        id="btnMoreFiles"
                        class="btn {btn-flat: corpus.hasDocuments, disabled: corpus.isCompiling}">
                    {_("ca.addTexts")}
                </a>
                <a id="btnCompile"
                        ref="btnCompile"
                        onclick={onCompileCorpus}
                        class="btn {btn-primary: !corpus.isCompiled}
                                {btn-flat: corpus.isCompiled}
                                {disabled: !corpus.can_be_compiled || !corpus.hasDocuments || corpus.isCompiling || corpus.isCancelling || (showSettings  && (invalidDocStructure || invalidFileStructure))}">
                    {_(corpus.isCompiled ? "ca.recompile" : "ca.compile")}
                </a>
                <a href="#dashboard"
                        if={corpus.isCompiled}
                        id="btnDashboard"
                        class="btn {btn-primary: corpus.isCompiled}">
                    {_("ca.corpusDashboard")}
                </a>
            </div>
        </div>

        <div if={corpus.can_be_compiled || corpus.isCompiling}
                class="center-align">
            <a class="btn btn-flat noCapitalization {disabled: !corpus.hasDocuments || corpus.isCompiling}  t_btnExpertSettings"
                    onclick={onSettingsToggle}>
                {_("expertSettings")}
                <i class="material-icons right">{showSettings ? "arrow_drop_up" : "arrow_drop_down"}</i>
            </a>
            <a class="btn btn-flat noCapitalization {disabled: !corpus.hasDocuments} t_btnLog"
                    onclick={onShowLogClick}>
                {_("log")}
                <i class="material-icons right">{showLog ? "arrow_drop_up" : "arrow_drop_down"}</i>
            </a>
            <br><br>
        </div>
    </virtual>

    <div if={!space.has_space} class="spaceLimitReached">
        <br>
        <h5>{_("compilationDisabled")}</h5>
        <ca-space-dialog message={_("compilationDisabledMsg")}></ca-space-dialog>
        <br>
        <div class="center-align grey-text" style="font-size: 14px;">
            {_("ca.spaceUsage")}
            {space.used_str}
            {_("of")}
            {space.total_str}
            {_("wordP")}
            (<span class={red-text: space.percent >= 100 }>{space.percent}%</span>)
        </div>
        <div class="progress" style="opacity: 0.7; margin-bottom: 0;">
            <div class="determinate" style="width: {space.percent}%"></div>
        </div>
        <br>
    </div>

    <div if={showSettings} class="compilerSettings">
        <div class="cardtitle">{_("expertSettings")}</div>
        <div class="card-panel columnForm">
            <div if={isCompilerSettingsLoading} class="centerSpinner">
                <preloader-spinner></preloader-spinner>
            </div>
            <div if={expertMode}
                    class="center-align background-color-blue-100 p-2">
                {_("compilerExpertModeInfo")}
                <div class="pb-2 pt-5">
                    <a href="#ca-config" class="btn">{_("configPage")}</a>
                    <a href="javascript:void(0);"
                            class="btn"
                            onclick={onTurnExpertModeOffClick}>{_("expertModeOff")}</a>
                </div>
            </div>
            <virtual if={!isCompilerSettingsLoading}>
                <div class="row {hidden: expertMode}">
                    <label for="onion_structure" class="col m5 s12">
                        {_("ca.duplicatedContent")}
                        <i class="help tooltipped material-icons" data-tooltip={_("ca.onion_structureHelp")}>help_outline</i>
                    </label>
                    <span class="col m7 s12">
                        <ui-checkbox
                            label-id="ca.removeDuplicatedContent"
                            checked={options.deduplicate}
                            on-change={onDeduplicateChange}
                            name="deduplicate"></ui-checkbox>
                        <ui-select if={options.deduplicate}
                            label-id="ca.onion_structure"
                            name="onion_structure"
                            value={options.onion_structure}
                            on-change={onOnionStructureChange}
                            options={onion_structureList}></ui-select>
                    </span>
                </div>
                <div class="row {hidden: expertMode}">
                    <label class="col m5 s12">
                        {_("ca.struct_attrs")}&nbsp;<i class="help tooltipped material-icons" data-tooltip={_("ca.struct_attrsHelp")}>help_outline</i>
                    </label>
                    <span id="structAttrs" class="col m7 s12 input-field">
                        <a onclick={onAttrAllChangeChecked.bind(this, true)} class="link">{_("all")}</a>
                        |
                        <a onclick={onAttrAllChangeChecked.bind(this, false)} class="link">{_("none")}</a>
                        <div class="t_structs">
                            <div each={struct, sIdx in available_structures} class="ui-checkbox">
                                <label for={"attr" + sIdx} class="strAttrLabel">
                                    <input type="checkbox"
                                        class="struct"
                                        id={"attr" + sIdx}
                                        name={struct.name}
                                        onchange={onStructureChange}
                                        disabled={options.structures[struct.name].disabled}
                                        checked={options.structures[struct.name].checked}/>
                                    <span>
                                        {(struct.label || struct.name) + " (" + window.Formatter.num(struct.freq) + ")"}
                                    </span>
                                </label>
                                <a if={options.structures[struct.name].attributes.length} class="btn btn-floating btn-flat btn-small" onclick={onToggleAttributes}>
                                    <i class="material-icons grey-text">add</i>
                                </a>
                                <div if={options.structures[struct.name].attributes.length} class="attributes {hidden: !options.structures[struct.name].showAttributes}">
                                    <div each={attr in options.structures[struct.name].attributes} class="attr">
                                        <label for={attr.id} class="strAttrLabel">
                                            <input type="checkbox"
                                                name={attr.id}
                                                id="{attr.id}"
                                                onchange={parent.parent.onAttributeChange}
                                                checked={attr.checked} />
                                            <span>
                                                {attr.label || attr.name}
                                            </span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </span>
                </div>
                <div class="row t_sketchGrammars">
                    <label for="sketch_grammars" class="col m5 s12">
                        {_("ca.sketch_grammars")}
                        <i class="help tooltipped material-icons" data-tooltip={_("ca.sketch_grammarsHelp")}>help_outline</i>
                    </label>
                    <span class="col m7 s12">
                        <div class="ca-radio ui-radio">
                            <div if={data.isSketchGrammarLoading}>
                                <preloader-spinner center=1></preloader-spinner>
                            </div>
                            <div each={option, idx in sketch_grammarsOptions}>
                                <label for={"sgo_" + idx}
                                        class="rb_{(option.value + "").replace(/\W/g,'_')}">
                                    <input type="radio"
                                        id={"sgo_" + idx}
                                        name="sketch_grammar_id"
                                        value={option.value}
                                        checked={option.value == parent.options.sketch_grammar_id}
                                        onchange={parent.onChangeOption}>
                                        <span>
                                            {getLabel(option)}
                                            <span if={option.value == parent.data.tagset.default_sketchgrammar_id}
                                                    class="grey-text">({_("recommended")})</span>
                                        </span>
                                </label>
                                <a if={option.value} class="btn btn-floating btn-flat btn-small" onclick={onShowGrammDetail.bind(this, option.value)}>
                                    <i class="material-icons grey-text">info_outline</i>
                                </a>
                            </div>
                        </div>
                        <a class="addGrammarBtn btn btn-floating" onclick={onAddGrammarClick.bind(this, false)}>
                            <i class="material-icons">add</i>
                        </a>
                    </span>
                </div>
                <div class="row t_termGrammars">
                    <label for="terms" class="col m5 s12">
                        {_("ca.terms")}
                        <i class="help tooltipped material-icons" data-tooltip={_("ca.termsHelp")}>help_outline</i>
                    </label>
                    <span class="col m7 s12">
                        <div class="ca-radio ui-radio">
                            <div each={option, idx in termsOptions}>
                                <label for={"tg_" + idx}
                                        class="rb_{(option.value + "").replace(/\W/g,'_')}">
                                    <input type="radio"
                                        id={"tg_" + idx}
                                        name="term_grammar_id"
                                        value={option.value}
                                        checked={option.value == parent.options.term_grammar_id}
                                        onchange={parent.onChangeOption}>
                                    <span>
                                        {getLabel(option)}
                                        <span if={option.value == parent.data.tagset.default_sketchgrammar_id}
                                                class="grey-text">({_("recommended")})</span>
                                    </span>
                                </label>
                                <a if={option.value} class="btn btn-floating btn-flat btn-small" onclick={onShowGrammDetail.bind(this, option.value)}>
                                    <i class="material-icons grey-text">info_outline</i>
                                </a>
                           </div>
                        </div>
                        <a class="addGrammarBtn btn btn-floating" onclick={onAddGrammarClick.bind(this, true)}>
                            <i class="material-icons">add</i>
                        </a>
                    </span>
                </div>
                <div class="row {hidden: expertMode}">
                    <label for="file_structure" class="col m5 s12">
                        {_("ca.file_structure")}
                        <i class="help tooltipped material-icons" data-tooltip={_("ca.file_structureHelp")}>help_outline</i>
                    </label>
                    <span class="col m7 s12 input-field">
                        <ui-input ref="file_structure"
                            name="file_structure"
                            size=20
                            on-change={onChangeFileStructure}
                            on-input={validateFileStructure}
                            riot-value={options.file_structure}
                            inline=1></ui-input>
                        <span if={invalidFileStructure} id="file_structure_err" class="red-text">
                            <i class="material-icons orange-text tooltipped" data-tooltip={_("ca.invalidFileStructure")}>warning</i>
                        </span>
                    </span>
                </div>
                <div class="row {hidden: expertMode}">
                    <label for="docstructure" class="col m5 s12">
                        {_("ca.docstructure")}
                        <i class="help tooltipped material-icons" data-tooltip={_("ca.docstructureHelp")}>help_outline</i>
                    </label>
                    <span class="col m7 s12">
                        <ui-select
                            classes="docstructure"
                            style="width: 20em"
                            name="docstructure"
                            riot-value={options.docstructure}
                            on-change={onDocStructureChange}
                            options={docstructureList}></ui-select>
                    </span>
                </div>

                <br><br>

                <div class="center-align dividerTop">
                    <br>
                    <a id="btnCompilerOptionsCancel" onclick={onSettingsCancelClick} class="btn btn-flat">{_("cancel")}</a>
                    <a id="btnCompilerOptionsSave" onclick={onSettingsSaveClick} class="btn btn-primary {disabled: invalidDocStructure || invalidFileStructure}">{_("ca.saveAndCompile")}</a>
                </div>
            </virtual>
        </div>
    </div>

    <ca-compiler-log if={showLog}></ca-compiler-log>

    <br>
    <div class="quickInfo card-panel" if={canBeCompiledLoaded && corpus.isCompiled && space.has_space}>
        <h5>{_("ca.getToKnowYourCorpus")}</h5>
        <div class="center-align">
            <a href="#keywords" class="btn tooltipped" data-tooltip={_("ca.keywordsAndTermsDesc")}>
                {_("ca.keywordsAndTerms")}
                <i class="ske-icons skeico_keywords left"></i>
            </a>
            <a class="btn tooltipped" data-tooltip={_("ca.corpusDetailsDesc")} onclick={onShowCorpusInfoClick}>
                {_("ca.corpusDetails")}
                <i class="material-icons left">info</i>
            </a>
        </div>
    </div>


    <script>
        require("./ca-compiler.scss")
        require("./ca-browser.tag")
        require("./ca-compiler-log.tag")
        require("my/my-grammar-dialog/my-grammar-dialog.tag")
        const {AppStore} = require("core/AppStore.js")
        const {Auth} = require("core/Auth.js")
        const {CAStore} = require("./castore.js")
        const {Url} = require("core/url.js")
        const Dialogs = require("dialogs/dialogs.js")

        this.compileWhenFinished = CAStore.data.compileWhenFinished

        this.mixin("tooltip-mixin")

        this.corpus = CAStore.corpus || {}
        this.showSettings = !this.corpus.use_all_structures
        this.invalidFileStructure = false
        this.invalidDocStructure = false
        this.log = "empty"
        this.space = Auth.getSpace()
        this.options = {
            deduplicate: this.corpus.onion_structure !== null,
            onion_structure: this.corpus.onion_structure,
            file_structure: this.corpus.file_structure,
            sketch_grammar_id: this.corpus.sketch_grammar_id || null,
            term_grammar_id: this.corpus.term_grammar_id || null,
            docstructure: this.corpus.docstructure == this.corpus.file_structure ? "$filestructure$" : this.corpus.docstructure,
            structures: {}
        }

        refreshStructuresCheckedAndDisabled(){
            // set structures disabled and checked attribute for compulsory attributes
            for(let structName in this.options.structures){
                let struct = this.options.structures[structName]
                let isStructInPipeline = this.data.tagset && this.data.tagset.structures.includes(struct.name)
                let compulsory = isStructInPipeline || struct.name == this.options.onion_structure
                if(compulsory){
                    struct.checked = true
                }
                struct.disabled = compulsory
            }
        }

        refreshStructuresList(){
            this.docstructureList = []
            if(this.options.file_structure){
                this.docstructureList.push({
                    value: "$filestructure$",
                    labelId: "ca.useFileStructure"
                })
            } else{
                this.docstructureList.unshift({
                    value: "-select-",
                    labelId: "selectValue"
                })
            }
            for(let structName in this.options.structures){
                let struct = this.options.structures[structName]
                if(struct.checked){
                    this.docstructureList.push({
                        value: structName,
                        label: struct.label || struct.name
                    })
                }
            }
        }

        refreshOnionStructureList(){
            this.onion_structureList = [{
                labelId: "ca.file_structure",
                value: "@file@"
            }]
            this.corpus.available_structures.forEach(s => {
                if(s.name != "g"){
                    this.onion_structureList.push({
                        label: s.name,
                        value: s.name
                    })
                }
            })
        }

        refreshStructures(){
            this.options.structures = {}
            if(!this.corpus.user_can_manage){
                return
            }
            this.available_structures = this.corpus.available_structures.sort( (a, b) =>{
                return a.freq < b.freq
            })
            this.available_structures.forEach(s => {
                let struct = this.corpus.structures.find(s1 => {
                    return s1.name == s.name
                })
                this.options.structures[s.name] = s
                this.options.structures[s.name].checked = !!struct
                s.attributes.forEach((attr) => {
                    let id = s.name + "." + attr.name
                    attr.structure = s.name
                    attr.id = id
                    attr.checked = !!(struct && struct.attributes && struct.attributes.find(a1 => {
                        return a1.name == attr.name
                    }))
                })
            })

            // if there is at least one attribute selected, structure should be expanded
            for(let structName in this.options.structures){
                let struct = this.options.structures[structName]
                struct.showAttributes = struct.attributes.some(a => {
                    return a.checked
                })
            }
            this.refreshStructuresList()
            this.refreshStructuresCheckedAndDisabled()
            this.refreshOnionStructureList()
        }

        updateAttributes(){
            this.data = CAStore.data
            this.sketchGrammars = this.data.sketchGrammars
            this.canBeCompiledLoaded = AppStore.get("canBeCompiledLoaded")
            this.isCompilerSettingsLoading = this.data.tagset === null || this.sketchGrammars === null || this.data.terms === null
            this.expertMode = this.corpus.expert_mode

            if(this.isCompilerSettingsLoading){
                this.sketch_grammarsOptions = []
                this.termsOptions = []
                this.onion_structureList = []
                return
            }

            this.sketch_grammarsOptions = this.data.sketchGrammars.map(s => {
                return {
                    value: s.id,
                    label: s.name
                }
            }).concat({
                value: null,
                labelId: "ca.noWordSketch"
            })
            this.termsOptions = this.data.terms.map(s => {
                return {
                    value: s.id,
                    label: s.name
                }
            }).concat({
                value: null,
                labelId: "ca.noTerms"
            })

            this.refreshStructuresList()
            this.refreshStructuresCheckedAndDisabled()
        }
        this.updateAttributes()
        this.refreshStructures()
        CAStore.checkCorpusStatus(this.corpus.id)
        CAStore.loadSketchGrammars(this.corpus.id)
        CAStore.loadTerms(this.corpus.id)
        CAStore.loadActualTagSet()
        AppStore.loadCanBeCompiled()

        onCompileCorpus(evt){
            this.showSettings = false
            this.refs.btnCompile && this.refs.btnCompile.classList.add("disabled")
            CAStore.compileCorpus(this.corpus.id, {structures: "all"})
            if(this.showLog){
                CAStore.startLogChecking(this.corpus.id)
            }
            this.update()
            this.refs.progressBar && this.refs.progressBar.classList.remove("visibilityHidden")
        }

        onCancelCompilation(evt){
            $(evt.currentTarget).addClass("disabled")
            CAStore.cancelCompilation(this.corpus.id)
            this.corpus.isCompiling = false
            this.corpus.isCompilationFailed = true
            this.corpus.isCancelling = true
            this.corpus.status = "CANCELLING"
            this.update()
        }

        onSettingsToggle(){
            this.showSettings = !this.showSettings
            this.showLog = false
        }

        onChangeOption(evt){
            this.options[evt.target.name] = evt.item.option.value
        }

        onOnionStructureChange(onion_structure){
            this.options.onion_structure = onion_structure
            this.refreshStructuresCheckedAndDisabled()
            this.update()
        }

        onStructureChange(evt){
            let checked = evt.target.checked
            let structName = evt.item.struct.name
            this.options.structures[structName].checked = checked
            if(!checked){
                this.options.structures[structName].attributes.forEach(attr => {
                    attr.checked = false
                })
                if(structName == this.options.docstructure){
                    this.options.docstructure = "$filestructure$"
                }
            }
        }

        onAttributeChange(evt){
            let checked = evt.target.checked
            let tmp = evt.target.name.split(".")
            let structName = tmp[0]
            let attrName = tmp[1]
            let structure = this.options.structures[structName]
            structure.attributes.find(attr => {
                return attr.name == attrName
            }).checked = checked
            if(!structure.checked){
                if(structure.attributes.find(attr => {
                    return attr.checked
                })) {
                    structure.checked = true
                }
            }
            this.update()
        }

        onChangeFileStructure(value){
            if(value !== "" && this.options.docstructure == "-select-"){
                this.options.docstructure = "$filestructure$"
            } else if(value === "" && this.options.docstructure === "$filestructure$"){
                this.options.docstructure = "-select-"
                this.invalidDocStructure = true
            }
            this.options.file_structure = value
            this.update()
        }

        onDocStructureChange(value){
            this.options.docstructure = value
            this.invalidDocStructure = value == "-select-"
            this.update()
        }

        onSettingsCancelClick(){
            this.showSettings = false
        }

        onSettingsSaveClick(evt){
            evt.preventUpdate = true
            $(evt.currentTarget).addClass("disabled")
            this.saveSettings()
        }

        onAddGrammarClick(is_term, evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                title: _("addGrammar"),
                tag: "my-grammar-dialog",
                opts: {
                    grammar: {
                        content: "",
                        name: "",
                        is_term: is_term
                    },
                    hideIsTerm: true
                },
                fixedFooter: true,
                buttons: [{
                    id: "grammarDialogBtn",
                    label: _("create"),
                    class: "btn-primary disabled",
                    onClick: function(dialog, modal){
                        CAStore.createGrammar(dialog.contentTag.getGrammar())
                        modal.close()
                    }.bind(this)
                }]
            })
        }

        onTurnExpertModeOffClick(evt){
            evt.preventUpdate = true
            CAStore.turnOffExpertMode()
        }

        saveSettings(){
            let structures = []
            for(let structName in this.options.structures){
                let struct = this.options.structures[structName]
                if(this.options.structures[structName].checked){
                    let structure = {
                        name: structName,
                        attributes: []
                    }
                    struct.attributes.forEach(attr => {
                        if(attr.checked){
                            structure.attributes.push({
                                name: attr.name
                            })
                        }
                    })
                    structures.push(structure)
                }
            }
            let settings = {
                sketch_grammar_id: this.options.sketch_grammar_id,
                term_grammar_id: this.options.term_grammar_id
            }
            if(!this.expertMode){
                settings = Object.assign(settings, {
                    file_structure: this.options.file_structure,
                    onion_structure: this.options.onion_structure == "@file@" ? this.options.file_structure : this.options.onion_structure,
                    structures: structures,
                    docstructure: this.options.docstructure == "$filestructure$" ? this.options.file_structure : this.options.docstructure
                })
            }

            CAStore.updateCompilerSettings(this.corpus.id, settings, (payload) => {
                SkE.showToast(_("saved"))
                CAStore.compileCorpus(this.corpus.id)
                this.showSettings = false
                this.update()
            })
        }

        onAttrAllChangeChecked(checked, evt){
            $("#structAttrs input").each((idx, elem) => {
                $(elem).prop("checked", checked || $(elem).prop("disabled"))
            })
            for(let structName in this.options.structures){
                if(!this.options.structures[structName].disabled){
                    this.options.structures[structName].checked = checked
                    for(let attrName in this.options.structures[structName].attributes){
                        this.options.structures[structName].attributes[attrName].checked = checked
                    }
                }
            }
            evt.preventUpdate = true
        }

        onToggleAttributes(evt){
            evt.preventUpdate = true
            let node = $(evt.target).parent().parent()
            let attrs =  node.find(".attributes")
            attrs.toggleClass("hidden")
            let hidden = attrs.hasClass("hidden")
            node.find("i").text(hidden ? "add" : "remove")
            node.find(".strAttrLabel").first().css("font-weight", hidden ? "normal" : "bold")
        }

        onDeduplicateChange(checked){
            this.options.deduplicate = checked
            this.options.onion_structure = checked ? "@file@" : null
            this.update()
        }

        onShowLogClick(evt){
            this.showLog = !this.showLog
            this.showSettings = false
            if(this.showLog){
                CAStore.startLogChecking(this.corpus.id)
            } else{
                CAStore.stopLogChecking()
            }
        }

        onShowGrammDetail(grammar_id){
            Dialogs.showGrammarDetailDialog({id: grammar_id})
        }

        onShowCorpusInfoClick(){
            SkE.showCorpusInfo(this.corpus.corpname)
        }

        validateFileStructure(){
            if(this.refs.file_structure){
                let file_structure = this.refs.file_structure.refs.input.value
                let wasInvalid = this.invalidFileStructure
                this.invalidFileStructure = false
                if(file_structure){
                    this.invalidDocStructure = false
                    let re = new RegExp(/^[a-zA-Z]*$/)
                    if(re.test(file_structure)){
                        for(let key in this.options.structures){
                            if(key == file_structure || key.split(".")[1] == file_structure){
                                this.invalidFileStructure = true
                                break
                            }
                        }
                    } else {
                        this.invalidFileStructure = true
                    }
                }
                (wasInvalid != this.invalidFileStructure) && this.update()
            }
        }

        refreshStructuresAndUpdate(){
            this.refreshStructures()
            this.update()
        }

        onCorpusChange(){
            AppStore.loadCanBeCompiled()
            this.corpus = AppStore.getActualCorpus()
            this.refreshStructuresAndUpdate()
        }

        onStatusChange(){
            if(this.canBeCompiledLoaded
                && this.corpus.can_be_compiled
                && (this.corpus.isReady || this.corpus.isToBeCompiled || this.corpus.isCompiled || this.corpus.isCompilationFailed)
                && Url.getQuery().run){
                let fn = () => {
                    this.onCompileCorpus()
                    Url.setQuery({})
                }
                this.isMounted ? fn() : this.one("mounted", fn)
            }
            this.update()
        }

        this.on("update", this.updateAttributes)

        this.on("updated", () => {
            this.validateFileStructure()
            $('ui-select.docstructure input').each(function () {
                    $(this).val($(this).next('ul').find('li.selected').text())
                })
        })

        this.on("mount", () => {
            AppStore.on("statusChange", this.onStatusChange)
            CAStore.on("change", this.refreshStructuresAndUpdate)
            CAStore.on("actualTagsetLoaded", this.refreshStructuresAndUpdate)
            AppStore.on("corpusChanged", this.onCorpusChange)
            CAStore.on("expertModeOff", this.update)
        })

        this.on("unmount", () => {
            AppStore.off("statusChange", this.onStatusChange)
            CAStore.off("change", this.refreshStructuresAndUpdate)
            CAStore.off("actualTagsetLoaded", this.refreshStructuresAndUpdate)
            AppStore.off("corpusChanged", this.onCorpusChange)
            CAStore.off("expertModeOff", this.update)
        })
    </script>
</ca-compiler>
