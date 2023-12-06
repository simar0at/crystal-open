<manage-macros-dialog class="manage-macros-dialog">
    <div class="topBar text-left">
        <div class="grey-text mb-5">
            {_("macrosDesc")}
        </div>
        <div class="mb-4 center">
            <ui-input if={showNewMacroName}
                    ref="name"
                    name="name"
                    inline=1
                    riot-value={newMacroName}
                    on-input={onNameInput}
                    on-submit={onNameSubmit}
                    autocomplete={false}
                    maxlength=200
                    label-id="name">
            </ui-input>
            <button  if={!showNewMacroName && showMacroAdd}
                    class="btn btn-primary {disabled: isBtnAddDisabled} {tooltipped: macros.length}"
                    onclick={onCreateClick}
                    data-tooltip={_("newMacroNote")}>{_("createNewMacro")}</button>
            <button if={showNewMacroName}
                    class="btn btn-primary ml-2"
                    onclick={onNameSubmit}>
                <i class="material-icons white-text">check</i>
            </button>
            <button if={showNewMacroName}
                    class="btn ml-2"
                    onclick={onCreateClick}>
                <i class="material-icons white-text">close</i>
            </button>
        </div>
    </div>

    <label if={macros.length}>
        {_("savedMacros")}
    </label>
    <table if={macros.length} class="material-table">
        <tbody each={macro in macros}>
            <tr if={macro.id != editedMacroId}>
                <td class="mt-2 mb-2">
                    {macro.name}
                </td>
                <td class="nowrap"style ="width: 1px;">
                    <i class="material-icons material-clickable"
                            onclick={onDetailClick}>info</i>
                    <i class="material-icons material-clickable"
                            onclick={onEditClick}>edit</i>
                    <i class="material-icons material-clickable"
                            onclick={onRemoveClick}>delete</i>
                </td>
            </tr>
            <tr if={macro.id == editedMacroId}>
                <td>
                    <ui-input ref="edit"
                            riot-value={macro.name}
                            on-submit={onEditSubmit}>
                    </ui-input>
                </td>
                <td class="nowrap" >
                    <i class="material-icons material-clickable"
                            onclick={onDetailClick}>info</i>
                    <i class="material-icons material-clickable"
                            onclick={onEditCancel}>close</i>
                    <i class="material-icons material-clickable"
                            onclick={onEditSubmit}>check</i>
                </td>
            </tr>
        </tbody>
    </table>
    <div if={!macros.length}
            class="noMacros text-center grey-text mb-4">
        <i class="material-icons">
            space_bar
        </i>
        <br>
        <div>
            {_("noMacros")}
        </div>
    </div>

    <script>
        require("./manage-macros.scss")

        const {MacroStore} = require("./macrostore.js")
        const {UserDataStore} = require("core/UserDataStore.js")
        const {TextTypesStore} = require("common/text-types/TextTypesStore.js")

        this.mixin("tooltip-mixin")
        this.store = this.opts.store
        this.macroStore = MacroStore
        this.tooltipEnterDelay = 800
        this.showMacroAdd = true
        this.isBtnAddDisabled = this.store.data.operations.length <= 1
                && !this.store.isColl
                && !this.store.isFreq
                && !this.store.data.sort.length
                && !this.store.data.gdex_enabled
                && $.isEmptyObject(this.opts.store.data.tts)


        updateAttributes(){
            this.macros = this.macroStore.data.macros
        }
        this.updateAttributes()

        onCreateClick(evt){
            this.showNewMacroName = !this.showNewMacroName
            if(this.showNewMacroName){
                this.newMacroName = this.getMacroOptions().map(p => {
                    return `${p[0]}${p[1] ? ": " + p[1] : ""}`
                }).join(" ● ")
            }
            delay(() => {$(".ui-input input", this.root).focus()}, 1)
        }

        getMacroOptions(data){
            data = data || this.store.data
            parts = []
            if(data.results_screen == "frequency"){
                parts.push([_("frequency"), data.f_freqml.map(f => {
                    return `${f.attr}(${f.ctx})`
                }).join(", ")])

            }
            if(data.results_screen == "collocations"){
                parts.push([_("collocations"), `${data.c_cattr}(${data.c_cfromw}..${data.c_ctow})`])
            }
            if(data.showcontext != "none"){
                parts.push([_("context"), this.store.getContextStr(data)])
            }
            let operations = data.operations.filter(o => o.name != "context").forEach(operation => {
                parts.push([operation.name, truncate(operation.arg, 30)])
            }, "")
            for(let key in data.tts){
                parts.push([TextTypesStore.getTextType(key).label, data.tts[key].length])
            }
            if(data.sort.length){
                let sortStr = data.sort.reduce((str, sort) => {
                    let label = sort.label
                    if(!label){
                        label = sort.attr
                        if(sort.ctx == '0'){
                            label += " KWIC"
                        } else {
                            label += ` (${Math.abs(sort.ctx)} ${sort.ctx < 0 ? _("left") : _("right")})`
                        }
                    }
                    return str + (str ? ", " : "") + label
                }, "")
                parts.push([_("Sort"),sortStr])
            }
            if(data.gdex_enabled){
                parts.push(["GDEX", `${truncate(data.gdexconf, 30) || "default"} (${data.gdexcnt})`])
            }
            return parts
        }

        onNameSubmit(){
            let name = this.refs.name.getValue()
            if(!name){
                return
            }
            if(this.macroStore.isNameTaken(name)){
                SkE.showToast(_("macroNameTaken"))
            } else {
                this.macroStore.createMacro(name)
                this.showNewMacroName = false
                this.showMacroAdd = false
                this.update()
            }
        }

        onEditClick(evt){
            this.editedMacroId = evt.item.macro.id
            this.update()
            delay(() => {$(".ui-input input", this.root).focus()}, 1)
        }

        onEditSubmit(){
            let name = this.refs.edit.getValue()
            if(!name){
                return
            }
            if(this.macroStore.data.macros.find(m => m.id != this.editedMacroId && m.name === name)){
                SkE.showToast(_("macroNameTaken"))
            } else {
                this.macroStore.updateMacroName(this.editedMacroId, name)
                this.editedMacroId = null
            }
        }

        onEditCancel(){
            this.editedMacroId = null
        }

        onRemoveClick(evt){
            evt.stopPropagation()
            this.macroStore.deleteMacro(evt.item.macro.id)
        }

        onDetailClick(evt){
            let macro = this.macroStore.getMacro(evt.item.macro.id)
            let content = this.getMacroOptions(macro.options).map(p => {
                return `${p[0]}${p[1] ? ": <b>" + p[1] + "</b>" : ""}`
            }).join("<br>")

            Dispatcher.trigger("openDialog", {
                title: "Macro detail",
                small: true,
                tag: "raw-html",
                opts: {
                    content: "<table>"
                            + `<tr><td class=\"grey-text vertical-top\" style="width: 1px;">${capitalize(_("name"))}</td><td>${truncate(macro.name, 200)}</td></tr>`
                            + `<tr><td class=\"grey-text vertical-top\">${capitalize(_("created"))}</td><td>${Formatter.dateTime(new Date(macro.id))}</td></tr>`
                            + `<tr><td class=\"grey-text vertical-top\">${capitalize(_("actions"))}</td><td>${content}</td></tr>`
                            +"</table>"
                }
            })
        }

        this.on("update", this.updateAttributes)

        this.on("mount", () => {
            this.macroStore.on("listChange", this.update)
        })

        this.on("before-unmount", () => {
            this.macroStore.off("listChange", this.update)
        })
    </script>
</manage-macros-dialog>
