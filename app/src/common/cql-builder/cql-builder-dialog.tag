<cql-builder-history class="cql-builder-history">
    <div class="cb-history-wrapper">
        <div class="cb-history-content">
            <span class="right">
                <i class="material-icons material-clickable"
                        onclick={onCloseClick}
                        style="font-size: 30px;">
                    close
                </i>
            </span>
            <div class="cb-history-title">
                {_("cqlHistory")}
            </div>
            <div if={!data.length} class="emptyContent">
                <div class="title">{_("nothingHere")}</div>
            </div>
            <div if={data.length}>
                <table class="table">
                    <tr each={cqlObj, idx in data} onclick={onRowClick}>
                        <td class="num">{idx + 1}.</td>
                        <td class="cql">
                            {cqlObj.cql}
                        </td>
                        <td class="date">
                            {cqlObj.date}
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <script>
        const {UserDataStore} = require("core/UserDataStore.js")

        this.isLoading = true
        this.data = copy(UserDataStore.getCQLs()).reverse()

        onCloseClick(evt){
            evt.preventUpdate = true
            this.parent.toggleHistory()
        }

        onRowClick(evt){
            this.parent.builder.setStringData(evt.item.cqlObj.stringified)
        }

        this.on("update", () => {
            this.data = copy(UserDataStore.getCQLs()).reverse()

        })
    </script>
</cql-builder-history>


<cql-builder-dialog class="cql-builder-dialog">
    <div class="cb-dialog-top">
        <div class="cb-cql-toolbar z-depth-1">
            <div class="cb-cql-header">
                <div class="imgWrapper">
                    <img src="images/logo_blue.png" alt="Sketch Engine" class="left" height="30px;" loading="lazy">
                </div>
                <span class="centered" style="font-size: 24px;">CQL builder</span>
                <span class="cb-cql-buttons">
                    <button class="btn btn-flat btn-floating tooltipped {disabled: !tokens.length}"
                            data-tooltip={_("copyCQLToClipboard")}
                            onclick={onCopyCQLClick}>
                        <i class="material-icons material-clickable">file_copy</i>
                    </button>
                    <button class="cb-btn-open-history btn btn-flat btn-floating tooltipped btnToggleHistory"
                            data-tooltip={_("cbHistoryTip")}
                            onclick={onToggleHistoryClick}>
                        <i class="material-icons material-clickable {active: isHistoryOpen}">history</i>
                    </button>
                    <button class="btn btn-flat btn-floating tooltipped"
                            data-tooltip={_("help")}
                            onclick={onHelpClick}>
                        <i class="material-icons material-clickable">help</i>
                    </button>
                </span>
            </div>
            <span class="fullScreenClose">
                <i class="material-icons material-clickable" onclick={onCloseClick}>close</i>
            </span>
            <div class="cb-final-cql-wrapper">
                <span class="cb-final-cql">
                    <span class="label {hidden: !tokens.length}">CQL: </span>
                    <span ref="cql"
                            class="monospace"></span>
                </span>
            </div>

            <div ref="history"
                    class="cb-history"
                    style="display: none;">
                <cql-builder-history></cql-builder-history>
            </div>
        </div>
    </div>
    <div class="cb-dialog-center valign-wrapper">
        <br>
        <div class="cb-tokens-wrapper">
            <div class="cb-cols">
                <span if={builder.addConditionBrackets()}
                        class="cb-col cb-group-bracket cb-group-bracket-left">(</span>
                <span if={builder.followsGroup(0)}
                        class="cb-col cb-group-bracket cb-group-bracket-left">(</span>
                <span class="cb-col">
                    <span class="relative"> <!-- for correct dropdown positioning -->
                        <button id="cb-add-token"
                                class="cb-add-token-btn-1 btn btn-floating {btn-flat: tokens.length} {pulse: !tokens.length} {btn-primary: !tokens.length}"
                                onclick={onAddTokenClick}>
                            <i class="material-icons">add</i>
                        </button>
                    </span>
                    <div if={!tokens.length} class="cb-start-here">
                        {_("startHere")}
                    </div>
                </span>
                <virtual each={token, idx in tokens}>
                    <span if={token.type == "or" && builder.precedesGroup(idx - 1)}
                            class="cb-col cb-group-bracket cb-group-bracket-right">)</span>
                    <span class="cb-col">
                        <span class="cb-token-wrapper cb-token-{idx + 1}">
                            <div data-is="cql-builder-token-{token.type}"
                                    token={token}
                                    builder={opts.builder}></div>
                            <button class="cb-token-remove-btn btn btn-floating btn-small"
                                    onclick={onRemoveTokenClick}>
                                <i class="material-icons">close</i>
                            </button>
                            <button if={token.edit}
                                    class="cb-token-save-btn btn btn-floating btn-small green"
                                    onclick={onSaveTokenClick}>
                                <i class="material-icons">check</i>
                            </button>
                        </span>
                    </span>
                    <span if={token.type == "or" && builder.followsGroup(idx + 1)}
                            class="cb-col cb-group-bracket cb-group-bracket-left">(</span>
                    <span class="cb-col">
                        <button class="cb-add-token-btn-{idx + 2} {cb-add-token-btn-last: idx == tokens.length - 1} addTokenBtn btn btn-floating btn-flat"
                                onclick={onAddTokenClick}>
                            <i class="material-icons">add</i>
                        </button>
                    </span>
                </virtual>
                <span if={builder.precedesGroup(tokens.length - 1)}
                        class="cb-col cb-group-bracket cb-group-bracket-right">)</span>
                <span if={builder.addConditionBrackets()}
                        class="cb-col cb-group-bracket cb-group-bracket-left">)</span>
                <virtual if={tokens.length}>
                    <span class="cb-col cb-condition-delimiter"></span>
                    <span if={builder.condition.parts.length} class="cb-col">
                        <span class="cb-token-wrapper">
                            <cql-builder-condition builder={builder}></cql-builder-condition>
                        </span>
                    </span>
                    <span class="cb-col cb-col-condition">
                        <button ref="addConditionBtn"
                                class="cb-btn-add-condition-btn btn btn-floating btn-flat tooltipped"
                                data-tooltip={_("globalConditions")
                                        + "<br><br>"
                                        + _("globalConditionsTip")
                                        + "&nbsp;"
                                        + "<a href=\""
                                        + window.config.links.cb_global_conditions
                                        + "\" target=\"_blank\">"
                                        + _("details")
                                        + "</a>"}
                                data-target="cb-addConditionMenu"
                                onclick={onAddConditionBtnClick}>
                            <i class="material-icons">add_to_photos</i>
                        </button>
                    </span>
                </virtual>
            </div>
        </div>
    </div>

    <div class="cb-dialog-bottom">
        <div if={showSentenceBoundaryWarning}
                class="cqlBuilderNote center-align">
            {_("sentenceBoundaryWarn")}
        </div>
        <div style="height: 20px;">
            <button if={tokens.length}
                    class="cb-btn-use-cql btn btn-primary right {disabled: !builder.isCQLValid} tooltipped"
                    data-tooltip={_("useCQLTip")}
                    onclick={onUseCQLClick}>
                {_("useCQL")}
                <i class="material-icons right">send</i>
            </button>
        </div>
        <cql-builder-examples ref="examples" builder={builder}></cql-builder-examples>
    </div>


    <ul id="cb-addTokenMenu"
            class="cb-dropdown-content dropdown-content">
        <li each={item in addMenuItems}>
            <a data-type={item.type} class={item.class}>
                {item.label}
                <i class="material-icons right tooltipped"
                        data-tooltip={item.tooltip + (item.url ? ("<br><a href=\"" + item.url + "\" target=\"_blank\">" + _("details") + "</a>") : "")}>
                    help_outline
                </i>
            </a>
        </li>
    </ul>

    <ul id="cb-addConditionMenu"
            class="cb-dropdown-content dropdown-content">
        <li onclick={onAddConditionClick.bind(this, "frequency")}>
            <a>
                {_("frequencyCondition")}
                <i class="material-icons right tooltipped"
                        data-tooltip={_("cbTooltipCondFrq")}>
                    help_outline
                </i>
            </a>
        </li>
        <li onclick={onAddConditionClick.bind(this, "attribute")}>
            <a>
                {_("attributeCondition")}
                <i class="material-icons right tooltipped"
                        data-tooltip={_("cbTooltipCondAttr")}>
                    help_outline
                </i>
            </a>
        </li>
    </ul>


    <script>
        require("./cql-builder-examples.tag")
        require("./cql-builder-tokens.tag")
        require("./cql-builder-condition.tag")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("tooltip-mixin")

        this.builder = this.opts.builder
        this.tokens = this.builder.tokens

        this.isHistoryOpen = false

        this.addMenuItems = [
            {type: "standard",      label: _("standardToken") + " [ = \" \" ]",     tooltip: _("cbTooltipStandard"), url: window.config.links.cb_basics},
            {type: "any",           label: _("anyToken") + " [ ]",                  tooltip: _("cbTooltipAny"), url: window.config.links.cb_basics},
            {type: "distance",      label: _("distanceToken") + " [ ] { , }",       tooltip: _("cbTooltipDistance"), url: window.config.links.cb_basics},
            {type: "structure",     label: _("structureToken") + " <s> <doc>…",     tooltip: _("cbTooltipStructure"), url: window.config.links.cb_structures},
            {type: "or",            label: _("orToken") + " |",                     tooltip: _("cbTooltipOr"), url: window.config.links.cb_basics},
            {type: "within",        label: "within",                                tooltip: _("cbTooltipWithin"), url: window.config.links.cb_within_containing, class: "monospace"},
            {type: "containing",    label: "containing",                            tooltip: _("cbTooltipContaining"), url: window.config.links.cb_within_containing, class: "monospace"},
            {type: "meet",          label: "meet",                                  tooltip: _("cbTooltipMeet"), url: window.config.links.cb_meet, class: "monospace"}
        ]


        onAddTokenClick(evt){
            evt.preventUpdate = true
            if(! $(evt.currentTarget).attr("data-target")){
                evt.stopPropagation()
                let id = "l_" + Date.now()
                $("#cb-addTokenMenu").clone()
                        .attr({id: id})
                        .appendTo($("body"))
                $(evt.currentTarget).attr("data-target", id)
                    .dropdown({
                        coverTrigger: true,
                        position: "right",
                        constrainWidth: false,
                        onOpenEnd: btnEl => {
                            this.initializeTooltips(this)
                            btnEl.M_Dropdown.$dropdownEl.addClass("dropdown-open")
                        },
                        onCloseStart: btnEl => {
                            btnEl.M_Dropdown.$dropdownEl.removeClass("dropdown-open")
                        }})
                    .dropdown('open')
            }
            let dropdown_id = $(evt.currentTarget).attr("data-target")
            // refresh click event every time, item.idx could change after
            // dropdown was created (precedent token might be deleted)
            $("#" + dropdown_id).find("a").each(function(idx, e){
                $(e).off("click")
                    .click(this.addToken.bind(this, {
                        position: evt.item ? evt.item.idx + 1 : 0,
                        type: $(e).data("type")
                    }))
                }.bind(this))
        }

        onAddConditionBtnClick(evt){
            evt.stopPropagation()
            $(evt.currentTarget).dropdown({
                constrainWidth: false,
                onOpenEnd: this.initializeTooltips.bind(this)
            }).dropdown('open')
        }

        addToken(params, evt){
            evt.stopPropagation() // to not fire document.onClick -> cancel token editing
            this.builder.addToken(params)
            this.refreshSentenceWarning()
            this.update()
        }

        onRemoveTokenClick(evt){
            this.builder.removeToken(evt.item.idx)
            this.refs.examples.reload()
        }

        onSaveTokenClick(evt){
            this.refs.examples.reload()
        }

        onAddConditionClick(type, evt){
            evt.stopPropagation() // to not fire document.onClick -> cancel token editing
            this.builder.addCondition(type)
        }

        onCopyCQLClick(evt){
            evt.preventUpdate = true
            this.builder.addCQLToHistory()
            window.copyToClipboard(this.builder.getCQLString(), SkE.showToast.bind(null, _("copied")))
        }

        onToggleHistoryClick(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            this.toggleHistory()
        }

        onHelpClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                title: "CQL builder",
                tag: "external-text",
                opts: {text: "cql_builder_help.html"}
            })
        }

        onUseCQLClick(evt){
            evt.preventUpdate = true
            this.modalParent.close()
            this.builder.onCQLSubmit()
        }

        handleClick(evt){
            let path = evt.path || evt.composedPath()
            let tokenElement = path.find(node => {
                return node.classList && node.classList.contains("cql-builder-token")
            })
            if(tokenElement){
                if(tokenElement._tag.token){
                    if(!tokenElement._tag.token.edit){
                        this.builder.condition.edit = false
                        this.builder.setTokenEdit(tokenElement._tag.token, true)
                    } else{
                        return // prevent cql builder unwanted update()
                    }
                } else {
                    if(!this.builder.condition.edit){
                        this.builder.condition.edit = true
                        this.builder.setTokenEdit(null, false)
                    } else{
                        return
                    }
                }
            } else{
                this.builder.condition.edit = false
                this.builder.setTokenEdit(null, false)
            }
            if(this.isHistoryOpen && !evt.target.classList.contains("btnToggleHistory") && !path.find(node => {
                return node.classList && node.classList.contains("cql-builder-history")
            })) {
                this.toggleHistory()
            }
            this.update()
        }

        onChange(){
            this.builder.validate()
            this.refs.cql.innerHTML = window.htmlEscape(this.builder.getCQLString())
            this.refs.examples.tokenChanged()
            this.refreshSentenceWarning()
        }

        onCloseClick(evt){
            evt.preventUpdate = true
            if(this.tokens.length && this.builder.dataOpenedWith != this.builder.stringify()){
                Dispatcher.trigger("openDialog", {
                    content: _("cbDialogClose"),
                    title: _("cqlWillBeLost"),
                    showCloseButton: false,
                    small: true,
                    buttons: [{
                        label: _("leave"),
                        class: "modal-close",  // for testing
                        onClick: function(dialog, modal){
                            this.builder.reset()
                            modal.close()
                            this.modalParent.close()
                        }.bind(this)
                    }, {
                        label: _("backToBuilder"),
                        onClick: (dialog, modal) => {
                            modal.close()
                        }
                    }]
                })
            } else {
                this.builder.reset()
                this.modalParent.close()
            }
        }

        toggleHistory(){
            this.isHistoryOpen = !this.isHistoryOpen
            $(this.refs.history).slideToggle(this.isHistoryOpen)
        }

        refreshSentenceWarning(){
            // if there is "[]" or "[]{x,y}" in CQL and also there is not "within <s>", show warning
            let anyIdx = this.builder.tokens.findIndex(t => t.type == "any" || t.type == "distance")
            let withinIdx = this.builder.tokens.findIndex((t, idx) => t.type == "within"
                    && this.builder.tokens[idx + 1]
                    && this.builder.tokens[idx + 1].type == "structure"
                    && this.builder.tokens[idx + 1].structure.name == "s")
            this.showSentenceBoundaryWarning = anyIdx > withinIdx
        }

        initializeTooltips(){
            $(".cb-dropdown-content i").tooltip({
                position: "right",
                enterDelay: 500
            })
        }

        document.addEventListener('click', this.handleClick)

        this.on("update", () => {
            this.tokens = this.builder.tokens
        })

        this.on("updated", this.onChange)

        this.on("mount", this.onChange)

        this.on("unmount", () => {
            document.removeEventListener('click', this.handleClick)
        })
    </script>
</cql-builder-dialog>
