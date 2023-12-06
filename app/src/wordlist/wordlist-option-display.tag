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
            <sortable-list tag-name="wordlist-option-display-item"
                name="attributes"
                items={items}
                on-sort={onChangeOrder}
                sortable-params={sortableParams}>
            </sortable-list>
        </div>
    </div>


    <script>
        require("./wordlist-option-display.scss")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.options = this.parent.options
        this.items = []
        this.attributesList = this.corpus.attributes || []
        this.sortableParams = {
            axis: "y"
        }

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

        onItemChange(item){
            for(let i = 0; i < this.items.length; i++){
                if(this.items[i].name == item.name){
                    this.items[i] = item
                    this.updateOptions()
                    return
                }
            }
        }

        onRemove(name){
            this.items = this.items.filter((attr) => {
                return attr.name != name
            })
            this.updateOptions()
        }

        onCheckboxChange(name, checked){
            this.items = this.items.map((item) => {
                if(item.name == name){
                    item.lowercase = checked
                }
                return item
            })
            this.updateOptions()
        }

        onWlstructSelect(value, name){
            this.addItem(value, false)
            this.updateOptions()
        }

        onChangeOrder(items){
            this.items = items
            this.updateOptions()
        }

        addItem(name, lowercase){
            this.items.push({
                name: name,
                lowercase: lowercase,
                showCheckbox: !AppStore.get("corpus.unicameral"),
                disabled: !AppStore.getAttributeByName(name).ignoreCaseAllowed,
                onRemove: this.onRemove,
                onCheckboxChange: this.onCheckboxChange
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

        this.on("before-mount", this.setItemsFromStore)

        this.on("update", () => {
            if(this.isMounted){
                const viewportWidth = $(window).width()
                this.isLposSelected = !!AppStore.getLposByValue(this.options.find) // from find list is selected lpos and not attribute
                this.setItemsFromStore()
            }
        })

    </script>
</wordlist-option-display>
