<cql-builder-condition-attribute>
    <ui-select ref="label1"
            label={_("label")}
            dynamic-width=1
            riot-value={condition.label1}
            name="label1"
            inline=1
            options={labelOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="attr1"
            label={_("attribute")}
            dynamic-width=1
            riot-value={condition.attr1}
            name="attr1"
            inline=1
            options={attributeOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="equals"
            dynamic-width=1
            riot-value={condition.equals}
            name="equals"
            inline=1
            options={equalsOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="label2"
            label={_("label") + " 2"}
            dynamic-width=1
            riot-value={condition.label2}
            name="label2"
            inline=1
            options={labelOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="attr2"
            label={_("attribute") + " 2"}
            dynamic-width=1
            riot-value={condition.attr1}
            name="attr2"
            inline=1
            options={attributeOptions}
            on-change={onOptionChange}></ui-select>

    <script>
        this.condition = this.opts.condition
        this.builder = this.parent.builder
        this.corpus = this.builder.corpus

        this.attributeOptions = this.corpus.attributes
        this.equalsOptions = [{
                value: "=",
                label: "="
            }, {
                value: "!=",
                label: "!="
            }
        ]
        this.labelOptions = []
        for(let i = 1 ; i < 11; i++){
            this.labelOptions.push({value: i, label: i})
        }

        onOptionChange(value, name){
            this.condition[name] = value
            this.parent.onChange()
        }
    </script>
</cql-builder-condition-attribute>


<cql-builder-condition-frequency>
    <ui-select ref="label"
            label={_("label")}
            dynamic-width=1
            riot-value={condition.label}
            name="label"
            inline=1
            options={labelOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="attr"
            label={_("attribute")}
            dynamic-width=1
            riot-value={condition.attr}
            name="attr"
            inline=1
            options={attributeOptions}
            on-change={onOptionChange}></ui-select>
    <ui-select ref="gtlt"
            dynamic-width=1
            riot-value={condition.gtlt}
            name="gtlt"
            inline=1
            options={gtltOptions}
            on-change={onOptionChange}></ui-select>
    <ui-input ref="frequency"
            label={_("frequency")}
            type="number"
            dynamic-width=1
            riot-value={condition.frequency}
            name="frequency"
            inline=1
            on-change={onOptionChange}></ui-input>
    <script>
        this.condition = this.opts.condition
        this.builder = this.parent.builder
        this.corpus = this.builder.corpus

        this.attributeOptions = this.corpus.attributes

        this.gtltOptions = [{
                value: ">",
                label: ">"
            }, {
                value: "<",
                label: "<"
            }
        ]
        this.labelOptions = []
        for(let i = 1 ; i < 11; i++){
            this.labelOptions.push({value: i, label: i})
        }

        onOptionChange(value, name){
            this.condition[name] = value
            this.parent.onChange()
        }
    </script>
</cql-builder-condition-frequency>


<cql-builder-condition class="cql-builder-condition cql-builder-token {edit: builder.condition.edit}">
    <div class="cb-name">{_("conditions")}</div>
    <cql-builder-token-warning obj={condition}></cql-builder-token-warning>
    <div class="card-panel">
        <div if={condition.edit}
                each={part, idx in condition.parts}>
            <span class="cb-modifier">
                &
            </span>
            <span class="cb-part canHighlight">
                <span class="cb-part-content">
                    <div data-is="cql-builder-condition-{part.type}" condition={part} builder={builder}></div>
                    <button class="cb-part-remove-btn btn btn-floating btn-small"
                            onclick={onRemoveConditionClick}>
                        <i class="material-icons">close</i>
                    </button>
                </span>
            </span>
        </div>
        <div if={!condition.edit}>
            {builder.getConditionStr()}
        </div>
    </div>


    <script>
        this.builder = this.opts.builder
        this.condition = this.builder.condition

        onConditionChange(){
            this.parent.onChange()
        }

        onRemoveConditionClick(evt){
            this.condition.parts.splice(evt.item.idx, 1)
            this.parent.onChange()
        }
    </script>
</cql-builder-condition>
