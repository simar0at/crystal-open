<concordance-result-options-view class="concordance-result-options-view">
    <div class="columns">
        <span class="inline-block">
            <ui-filtering-list label-id="showAttributes"
                ref="attrs"
                inline={true}
                riot-value={options.attrs}
                name="attrs"
                multiple={true}
                options={attrList}
                tooltip="t_id:conc_r_view_attributes"
                on-change={onAttrsChange}></ui-filtering-list>
                <div if={options.attrs[0] != "word"} class="attrWarn red-text">
                    <b>{_("cc.attrWarn")}</b>
                    <i class="material-icons ccResViewTip" data-tooltip={_("cc.attrWarnTip")}>help</i>
                </div>
            <div>
                <ui-radio
                    name="attr_allpos"
                    label-id="cc.displayAttrs"
                    riot-value={options.attr_allpos}
                    on-change={onDataChange}
                    options={attrsDisplayOptions}></ui-radio>
            </div>
            <div>
                <ui-checkbox
                    checked={data.show_as_tooltips}
                    label-id="showAsTooltips"
                    name="show_as_tooltips"
                    on-change={onChangeValue}></ui-checkbox>
            </div>
        </span>
        <span class="inline-block">
            <ui-filtering-list
                label-id="cc.showStructures"
                inline=1
                riot-value={options.structs_list}
                name="structs_list"
                on-change={onDataChange}
                multiple={true}
                tooltip="t_id:conc_r_view_structs_list"
                options={structList}></ui-filtering-list>
        </span>
        <span class="inline-block" style="vertical-align: top;">
            <ui-switch
                riot-value={data.fullcontext}
                label-id="fullcontext"
                name="fullcontext"
                tooltip="t_id:conc_r_view_full_context"
                on-change={onChangeValue}
                class="lever-right"></ui-switch>
            <ui-switch
                riot-value={data.checkboxes}
                label-id="cc.checkboxes"
                name="checkboxes"
                on-change={onChangeValue}
                class="lever-right"></ui-switch>
            <ui-switch
                riot-value={data.showcopy}
                label-id="showcopy"
                name="showcopy"
                on-change={onChangeValue}
                class="lever-right"></ui-switch>
            <ui-switch
                riot-value={data.linenumbers}
                label-id="showLineNumbers"
                name="linenumbers"
                tooltip="t_id:conc_r_view_line_numbers"
                on-change={onChangeValue}
                class="lever-right"></ui-switch>
            <ui-switch
                riot-value={data.glue}
                label-id="cc.glue"
                name="glue"
                tooltip="t_id:conc_r_view_glue"
                on-change={onDataChange}
                class="lever-right"></ui-switch>
            <ui-switch
                if={hasTBL}
                riot-value={data.showTBL}
                label-id="showTBL"
                name="showTBL"
                tooltip="t_id:conc_r_view_tbl"
                on-change={onShowTBLChange}
                class="lever-right"></ui-switch>
            <div if={hasTBL && options.showTBL} class="TBLList">
                <ui-select options={TBLList}
                        label-id="TBLTemplate"
                        riot-value={options.tbl_template}
                        name="tbl_template"
                        on-change={onTbl_templateChange}></ui-select>
            </div>
            <br>
            <button class="btn detailsBtn" onclick={onLineDetailsClick}>
                <i class="material-icons right">settings</i>
                {_("lineDetails")}
            </button>
        </span>
    </div>
    <div class="primaryButtons">
        <a class="btn btn-primary" id="btnViewSave" onclick={onSaveClick}>{_("save")}</a>
    </div>

    <floating-button on-click={onSaveClick}
        periodic=1
        refnodeid="btnViewSave"></floating-button>


    <script>
        const {Auth} = require("core/Auth.js")
        require("./concordance-result-options-view.scss")
        require("concordance/concordance-line-detail-dialog.tag")

        this.mixin("feature-child")
        this.tooltipClass = ".ccResViewTip"
        this.mixin("tooltip-mixin")

        if(Auth.isFullAccount()){
            let tbl_templates = Auth.getUser().tbl_templates
            this.hasTBL = tbl_templates.length
            if(this.hasTBL){
                this.TBLList = tbl_templates.map(t => {
                    return {
                        label: t,
                        value: t
                    }
                })
            }
        }

        this.structList = this.store.structList.filter(a => {
            return a.value != "g"
        })

        this.attrsDisplayOptions = [{
            value: "all",
            label: "For each token"
        },{
            value: "kw",
            label: "For KWIC only"
        }]
        this.attrList = this.corpus.attributes.map(a => {
            return {
                value: a.name,
                label: a.labelP
            }
        })

        updateAttributes(){
            this.options = {
                glue: this.data.glue,
                attrs: this.data.attrs.split(","),
                structs_list: this.data.structs.split(",").filter(
                        (e) => { return e != 'g' && e.length > 0}
                ),
                attr_allpos: this.data.attr_allpos,
                showTBL: this.data.showTBL,
                tbl_template: this.data.tbl_template
            }
        }
        this.updateAttributes()

        onSaveClick(){
            let attrs = this.options.attrs.join(",")
            let options = {
                attrs: attrs,
                glue: this.options.glue,
                attr_allpos: this.options.attr_allpos,
                structs: this.options.structs_list.join(","),
                showTBL: this.options.showTBL,
                tbl_template: this.options.tbl_template
            }
            this.data.closeFeatureToolbar = true
            this.store.searchAndAddToHistory(options)
        }

        onAttrsChange(value){
            this.options.attrs = value.length ? value : ["word"]
            this.update()
        }

        onDataChange(value, name){
            this.options[name] = value
        }

        onShowTBLChange(checked){
            this.options.showTBL = checked
            if(!checked){
                this.options.tbl_template = ""
            } else {
                this.options.tbl_template = this.TBLList[0].value
            }
            this.update()
        }

        onTbl_templateChange(tbl_template){
            this.options.tbl_template = tbl_template
            this.data.tbl_template = tbl_template
            this.store.saveUserOptions(["tbl_template"])
            this.store.updateUrl()
        }

        onChangeValue(value, name){
            this.store.changeValue(value, name)
            this.store.saveUserOptions([name])
        }

        onLineDetailsClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                tag: "concordance-line-detail-dialog",
                class: "modal-line-detail",
                opts: {
                    store: this.store,
                    toknum: this.data.items[0].toknum
                },
                buttons: [{
                    label: _("save"),
                    class: "btn-primary",
                    onClick: (dialog) => {
                        dialog.contentTag.save()
                    }
                }],
                fixedFooter: 1,
                big: 1,
                tall: 1
            })
        }

        updateAttrsSelected(){
            let attrs = this.refs.attrs.refs.list.value
            $("ui-filtering-list[name='attrs'] .order", this.root).remove()
            $("ui-filtering-list[name='attrs'] .selected", this.root).each((idx, item) => {
                item.innerHTML = item.innerHTML + "<span class=\"order\">(" + (attrs.indexOf($(item).attr("data-value")) + 1) +")</span>"
            })
        }

        this.on("mount", () => {
            this.refs.attrs.on("updated", this.updateAttrsSelected)
            this.refs.attrs.on("mount", this.updateAttrsSelected)
        })
    </script>
</concordance-result-options-view>
