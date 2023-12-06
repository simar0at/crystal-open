<parconcordance-result-options-view class="parconcordance-result-options-view">
    <div class="columns">
        <div class="inlineBlock">
            <ui-filtering-list label-id="showAttributes"
                    ref="attrs"
                    inline={true}
                    value={options.attrs}
                    name="attrs"
                    multiple={true}
                    options={store.attrList}
                    tooltip="t_id:conc_r_view_attributes"
                    on-change={onAttrsChange}>
            </ui-filtering-list>
            <div>
                <ui-radio
                        name="attr_allpos"
                        label-id="cc.displayAttrs"
                        value={options.attr_allpos}
                        on-change={onDataChange}
                        options={attrsDisplayOptions}>
                </ui-radio>
            </div>
        </div>
        <div class="inlineBlock">
            <ui-filtering-list
                    label-id="cc.showStructures"
                    inline=1
                    name="structs"
                    riot-value={options.structs}
                    on-change={onDataChange}
                    multiple={true}
                    tooltip="t_id:conc_r_view_structs_list"
                    options={structList}>
            </ui-filtering-list>
        </div>
        <div class="inlineBlock">
            <ui-checkbox
                    checked={data.linenumbers}
                    label-id="showLineNumbers"
                    name="linenumbers"
                    tooltip="t_id:conc_r_view_line_numbers"
                    on-change={onChangeValue}>
            </ui-checkbox>
            <ui-checkbox
                    checked={glue}
                    label-id="cc.glue"
                    name="glue"
                    tooltip="t_id:conc_r_view_glue"
                    on-change={onDataChange}>
            </ui-checkbox>
            <br>
            <button class="btn" onclick={onLineDetailsClick}>
                <i class="material-icons right">settings</i>
                {_("lineDetails")}
            </button>
        </div>
    </div>
    <div class="center-align">
        <a class="btn contrast" id="btnViewSave" onclick={onSaveClick}>{_("save")}</a>
    </div>
    <floating-button onclick={onSaveClick} periodic=1 refnodeid="btnViewSave">
    </floating-button>

    <script>
        require("concordance/concordance-line-detail-dialog.tag")

        this.mixin('feature-child')

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

        updateAttributes(){
            this.options = {
                refs: jQuery.isArray(this.data.refs) ? this.data.refs : this.data.refs.split(","),
                refs_up: this.data.refs_up,
                glue: this.data.glue,
                attrs: this.data.attrs.split(","),
                structs: this.data.structs.split(",").filter((e) => {
                    return e != 'g' && e.length > 0
                }),
                attr_allpos: this.data.attr_allpos
            }
        }
        this.updateAttributes()

        onSaveClick(){
            let attrs = this.options.attrs.join(",")
            this.store.searchAndAddToHistory({
                attrs: attrs,
                glue: this.options.glue,
                attr_allpos: this.options.attr_allpos,
                ctxattrs: this.options.attr_allpos == "all" ? attrs : "word",
                structs: this.options.structs.join(","),
                refs: this.options.refs,
                refs_up: this.options.refs_up
            })
        }

        onAttrsChange(value){
            this.options.attrs = value.length ? value : ["word"]
            this.update()
        }

        onDataChange(value, name){
            this.options[name] = value
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

        this.on("updated", this.updateAttrsSelected)
    </script>
</parconcordance-result-options-view>
