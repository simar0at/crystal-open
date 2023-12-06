<wordlist-option-display class="wordlist-option-display">
    <div class="row">
        <div class="col xl12 l5 m12">
            <ui-list
                name="wlstruct"
                options={wlstructList}
                disabled={length == 3}
                on-change={onWlstructSelect}
                style="max-width: 250px;"></ui-list>
                <div class="required" if={isLposSelected && items.length == 0}>
                    {_("ui.valueMissing")}
                </div>
                <div class="hint" if={items.length > 0}>
                    {_("wl.atributeListHelp")}
                </div>
        </div>
        <div class="col xl12 l7 m12">
            <div class="wlSortable">
                <wordlist-option-display-item each={item, idx in items}
                        id="{item.id}"
                        name={item.name}
                        disabled={item.disabled}
                        lowercase={item.lowercase}
                        show-checkbox={parent.caseSwitchAllowed}
                        on-remove={parent.onRemove}
                        on-checkbox-change={parent.onCheckboxChange}></wordlist-option-display-item>
            </div>
        </div>
    </div>


    <script>
        require("./wordlist-option-display.scss")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.options = this.parent.options
        this.items = []
        this.attributesList = this.corpus.attributes || []
        this.caseSwitchAllowed = !AppStore.get("corpus.unicameral")


        setItemsFromStore(){
            this.items = []
            let attribute

            for(let i = 0; i < 3; i++){
                attribute = this.options["wlstruct_attr" + (i + 1)]
                if(!attribute){
                    break
                }
                const attr = AppStore.getAttributeByName(attribute)
                if(attr){
                    this.addItem((attr.fromattr && attr.isLc) ? attr.fromattr : attr.name, attr.isLc)
                }
            }
            this.refreshWstructList()
        }

        refreshWstructList(){
            // add not selected attributes to list
            this.wlstructList = []
            this.attributesList.forEach((attr) => {
                if(!attr.isLc && !this.items.find((item) => {
                    return item.name == attr.name
                })){
                    this.wlstructList.push({
                        label: attr.label,
                        value: attr.name
                    })
                }
            })
        }

        onRemove(evt){
            this.items = this.items.filter((attr) => {
                return attr.name != evt.item.item.name
            })
            this.updateOptions()
        }

        onCheckboxChange(checked, name){
            this.items.find(item => item.name == name).lowercase = checked
            this.updateOptions()
        }

        onWlstructSelect(value, name){
            this.addItem(value, false)
            this.updateOptions()
        }

        onChangeOrder(items){
            let order = []
            $(".wordlist-option-display-item").each(function(idx, elem){
                order.push(elem._tag.opts.id)
            }.bind(this))
            this.items.sort((a, b) => order.indexOf(a.id) - order.indexOf(b.id))
            this.updateOptions()
        }

        addItem(name, lowercase){
            this.items.push({
                name: name,
                id: "itm_" + name,
                disabled: AppStore.data.unicameral,
                lowercase: lowercase
            })
        }

        updateOptions(){
            let options = {}
            let attribute
            let attrValue
            for(let i = 0; i < 3; i++){
                attribute = this.items[i]
                if(!attribute){
                    attrValue = ""
                } else{
                    attrValue = attribute.name
                    if(attribute.lowercase){
                        const attr = AppStore.getAttributeByName(attribute.name)
                        if(attr.lc){
                            attrValue = attr.lc
                        }
                    }
                }
                options["wlstruct_attr" + (i + 1)] = attrValue
            }
            Object.assign(this.options, options)
            this.update()
            this.parent.refreshSearchButtonDisable()
        }

        initSortable(){
            var el = $(".wlSortable")[0]
            el && Sortable.create(el, {
                animation: 150,
                onSort: this.onChangeOrder.bind(this)
            })
        }

        this.on("before-mount", this.setItemsFromStore)
        this.on("mount", this.initSortable)
        this.on("update", () => {
            if(this.isMounted){
                this.isLposSelected = !!AppStore.getLposByValue(this.options.find) // from find list is selected lpos and not attribute
                this.setItemsFromStore()
            }
        })
        this.on("updated", this.initSortable)

    </script>
</wordlist-option-display>
