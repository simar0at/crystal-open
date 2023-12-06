<cql-builder-token-warning>
    <span if={opts.obj.warning}
            class="cb-warning tooltipped"
            data-tooltip={opts.obj.warning}
            data-position="top">
        <i class="material-icons red-text">error</i>
    </span>

    <script>
        this.tooltipMargin = 30
        this.tooltipExitDelay = 0
        this.mixin("tooltip-mixin")
    </script>
</cql-builder-token-warning>


<cql-builder-token-label>
    <span if={parent.token.label}
            class="cb-modifiers">
        {parent.token.label}:
    </span>
</cql-builder-token-label>


<cql-builder-attr-value-selector class="cql-builder-attr-value-selector">
        <ui-select riot-value={opts.attr}
                inline=1
                label={_("attribute")}
                name="attr"
                tooltip="t_id:cb_attr"
                dynamic-width=1
                options={attributeOptions}
                on-change={onAttrChange}></ui-select>
        <ui-select inline=1
                dynamic-width=1
                name="equals"
                riot-value={opts.equals}
                options={equalsOptions}
                on-change={onChange}></ui-select>
        &quot;<ui-input ref="value"
                inline=1
                dynamic-width=1
                min-width=10
                name="value"
                label-id="value"
                riot-value={opts.riotValue}
                on-change={onChange}></ui-input>&quot;
                <button hide={opts.attr != "tag"}
                        ref="btn"
                        class="cb-btn-add-tag btn btn-floating tooltipped"
                        data-tooltip={_("insertTag")}
                        data-target="cb-tag-menu-{menuId}">
                    <i class="material-icons">playlist_add</i>
                </button>

    <ul id="cb-tag-menu-{menuId}" class="cb-attr-dropdown dropdown-content">
        <li each={tag in builder.corpus.wposlist}>
            <a data-value={tag.value} onclick={onInsertTagClick}>
                {tag.value + " (" + tag.label + ")"}
            </a>
        </li>
        <li class="divider" tabindex="-1"></li>
        <li if={corpus.tagsetdoc}>
            <a href={corpus.tagsetdoc} target="_blank">
                {_("showAllTags")}
                <i class="material-icons" style="margin: 0 0 0 15px;">open_in_new</i>
            </a>
        </li>
    </ul>

    <script>
        this.token = this.parent.token
        this.builder = this.parent.builder
        this.corpus = this.builder.corpus

        this.mixin("tooltip-mixin")

        this.attributeOptions = this.corpus.attributes.map(a => {a.label = a.label_en; return a})
        this.equalsOptions = [{
                value: "=",
                label: "="
            }, {
                value: "!=",
                label: "!="
            }
        ]
        this.tagOptions = this.builder.corpus.wposlist.map(w => {
            return {
                label: w.value + " (" + w.label + ")",
                value: w.value
            }
        })
        this.menuId = Math.round(Math.random() * 1000000)

        onAttrChange(value, name){
            if(value == "tag"){
                this.opts.riotValue = this.tagOptions[0].value
            }
            this.onChange(value, name)
            this.update()
        }

        onChange(value, name){
            this.opts.onChange(value, name)
        }

        onInsertTagClick(evt){
            this.opts.onChange($(evt.target).data("value"), "value")
        }

        this.on("mount", () => {
            $(this.refs.btn).dropdown({constrainWidth: false})
        })
    </script>
</cql-builder-attr-value-selector>


<cql-builder-modifiers>
    <span if={token.optional}
            class="cb-modifiers">?</span>
    <cql-builder-repeat if={token.repeat}
            token={token}
            builder={builder}></cql-builder-repeat>
    <script>
        this.token = this.parent.token
        this.builder = this.parent.builder
    </script>
</cql-builder-modifiers>


<cql-builder-repeat class="cql-builder-repeat">
    <virtual if={token.edit}>
        <span class="cb-modifiers">&#123;</span>
        <ui-select inline=1
                dynamic-width=1
                name="type"
                riot-value={type}
                options={distanceOptions}
                on-change={onTypeChange}></ui-select>
        &nbsp;
        <ui-input if={type == "exactly"}
                inline=1
                dynamic-width=1
                type="number"
                min=0
                max=100
                riot-value={repeat.min}
                name="exactly"
                on-change={onRepeatChange}
                ></ui-input>
        <ui-input if={type == "min" || type == "fromTo"}
                inline=1
                dynamic-width=1
                type="number"
                min=0
                max=100
                riot-value={repeat.min}
                name="min"
                on-change={onRepeatChange}></ui-input>
        <span if={type == "fromTo"}>→&nbsp;</span>
        <ui-input if={type == "max" || type == "fromTo"}
                inline=1
                min=0
                max=100
                type="number"
                dynamic-width=1
                riot-value={repeat.max}
                name="max"
                on-change={onRepeatChange}></ui-input>
        <span class="cb-modifiers">&#125;</span>
    </virtual>
    <virtual if={!token.edit}>
        <span class="cb-modifiers">{builder.getRepeatString(token)}</span>
    </virtual>

    <script>
        this.builder = this.parent.builder
        this.token = this.parent.token
        this.repeat = this.token.repeat

        this.type = "exactly"
        if(!isDef(this.repeat.min)){
            this.type = "max"
        } else if(!isDef(this.repeat.max)){
            this.type = "min"
        } else if(this.repeat.min != this.repeat.max){
            this.type = "fromTo"
        }
        this.distanceOptions = ["fromTo", "exactly", "min", "max"].map(d => {
            return {
                label: _(d),
                value: d
            }
        })

        onTypeChange(type){
            this.type = type
            delete this.repeat.max
            delete this.repeat.min
            if(this.type == "min" || this.type == "fromTo"){
                this.repeat.min = 1
            }
            if(this.type == "max" || this.type == "fromTo"){
                this.repeat.max = 1
            }
            this.update()
        }

        onRepeatChange(value, name){
            value = Math.min(value, 100)
            value = Math.max(value, 0)
            if(name == "exactly"){
                this.repeat.min = value
                this.repeat.max = value
            } else{
                this.repeat[name] = value
            }
            this.builder.validate()
            this.parent.update()
        }
    </script>
</cql-builder-repeat>

<cql-builder-toolbar>
    <div class="cb-token-toolbar">
        <virtual if={token.edit}>
            <span if={!opts.hideRepeat}
                    class="cb-token-optional-btn {active: token.optional} tooltipped"
                    data-tooltip={_("optionalTokenTip")}>
                <span class="cb-toolbar-icon {disabled: token.repeat}"
                        style="font-size: 18px; font-weight: bold;"
                        onclick={onOptionalClick}>?</span>
            </span>
            <span if={!opts.hideOptional}
                    class="cb-token-repeat-btn  {active: token.repeat} tooltipped"
                    data-tooltip={_("repeatTokenTip")}>
                <i class="cb-toolbar-icon material-icons {disabled: token.optional || token.label}"
                        onclick={onRepeatClick}>autorenew</i>
            </span>
            <span class="cb-token-label-btn  {active: token.label || showLabelInput} tooltipped"
                    data-tooltip={_("labelTokenTip")}>
                <i class="cb-toolbar-icon material-icons {disabled: token.repeat}"
                        ref="label"
                        onclick={onLabelClick}>label</i>
            </span>
            <ui-select if={showLabelSelect}
                    ref="labelInput"
                    inline=1
                    name="label"
                    dynamic-width=1
                    riot-value={token.label}
                    options={labelOptions}
                    on-change={onLabelChange}></ui-select>
            <span if={token.helpUrl}>
                <a href="{token.helpUrl}" target="_blank">
                    <i class="cb-toolbar-icon material-icons">info_outline</i>
                </a>
            </span>
        </virtual>
        <i if={token.edit && token.label}
                class="material-icons material-clickable cb-remove-label-btn"
                onclick={onRemoveLabelClick}>close</i>
    </div>

    <script>
        this.builder = this.parent.builder
        this.token = this.parent.token
        this.dialog = this.parent.parent

        this.mixin("tooltip-mixin")

        this.labelOptions = []
        for(let i = 1 ; i < 11; i++){
            this.labelOptions.push({value: i, label: i})
        }

        onOptionalClick(){
            if(this.token.repeat){
                return
            }
            this.token.optional = !this.token.optional
            this.onChange()
        }

        onRepeatClick(){
            if(this.token.optional || this.token.label){
                return
            }
            if(this.token.repeat){
                this.token.repeat = null
            } else {
                this.token.repeat = {
                    min: 1,
                    max: 1
                }
            }
            this.onChange()
        }

        onLabelClick(){
            if(this.token.repeat){
                return
            }
            this.showLabelSelect = !this.showLabelSelect
            this.token.label = this.showLabelSelect ? 1 : ""
            this.onChange()
        }

        onLabelChange(value){
            this.token.label = value
            this.onChange()
        }

        onRemoveLabelClick(evt){
            this.showLabelSelect = false
            this.token.label = ""
            this.onChange()
        }

        onChange(){
            this.parent.update()
            this.dialog.onChange()
        }
    </script>
</cql-builder-toolbar>



<cql-builder-token-standard class="cql-builder-token cql-builder-token-standard {edit: token.edit}">
    <div class="cb-name">{_("standardToken")}</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <span class="cb-bracket">[</span>
        <span if={token.edit}
                each={part, idx in token.parts}
                class="cb-part cb-part-{idx + 1} {canHighlight: token.parts.length > 1}">
            <ui-select if={idx > 0}
                    inline=1
                    dynamic-width=1
                    name="andOr"
                    riot-value={part.andOr}
                    options={andOrOptions}
                    on-change={onPartChange.bind(this, part)}></ui-select>
            <span class="cb-part-content">
                <cql-builder-attr-value-selector attr={part.attr}
                        equals={part.equals}
                        riot-value={part.value}
                        on-change={onPartChange.bind(this, part)}></cql-builder-attr-value-selector>
                <button if={token.parts.length > 1}
                            class="cb-part-remove-btn btn btn-floating btn-small"
                            onclick={onRemovePartClick}>
                    <i class="material-icons">close</i>
                </button>
            </span>
        </span>
        <span if={!token.edit}
                class="cb-part">
            {builder.getStandardTokenString(token)}
        </span>
        <button if={token.edit}
                class="cb-btn-add-part btn btn-flat btn-floating"
                onclick={onPartAddClick}>
            <i class="material-icons">add</i>
        </button>
        <span class="cb-bracket">]</span>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar token={token} builder={builder}></cql-builder-toolbar>


    <script>
        this.token = this.opts.token
        this.builder = this.opts.builder

        this.andOrOptions = [{
            value: "&",
            label: _("and")
        }, {
            value: "|",
            label: _("or")
        }]

        onPartAddClick(){
            this.token.parts.push({
                attr: this.builder.defaultAttribute,
                value: "",
                equals: "=",
                icase: false,
                andOr: "&"
            })
            this.parent.onChange()
        }

        onRemovePartClick(evt){
            this.token.parts.splice(evt.item.idx, 1)
            this.parent.onChange()
        }

        onPartChange(part, value, name){
            part[name] = value
            this.parent.onChange()
        }
    </script>
</cql-builder-token-standard>


<cql-builder-token-any class="cql-builder-token cql-builder-token-any {edit: token.edit}">
    <div class="cb-name">{_("anyToken")}</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <span class="cb-bracket">[]</span>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar></cql-builder-toolbar>

    <script>
        this.token = this.opts.token
        this.builder = this.opts.builder
    </script>
</cql-builder-token-any>


<cql-builder-token-distance class="cql-builder-token cql-builder-token-distance {edit: token.edit}">
    <div class="cb-name">{_("distance")}</div>
    <span class="card-panel">
        <span class="cb-bracket">[]</span>
        <cql-builder-repeat></cql-builder-repeat>
    </span>

    <script>
        this.builder = this.opts.builder
        this.token = this.opts.token
    </script>
</cql-builder-token-distance>


<cql-builder-token-structure class="cql-builder-token cql-builder-token-structure {edit: token.edit}">
    <div class="cb-name">{_("structure")}</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <span class="cb-bracket">&lt;</span>
        <virtual if={token.edit}>
            <ui-filtering-list inline=1
                    dynamic-width=1
                    min-width=6
                    name="name"
                    riot-value={structure.name}
                    floating-dropdown=1
                    value-in-search=1
                    open-on-focus=1
                    options={builder.structOptions}
                    on-change={onOptionChange}></ui-filtering-list>
            &nbsp;
            <ui-select if={token.structure}
                    inline=1
                    dynamic-width=1
                    riot-value={structure.range}
                    name="range"
                    options={structRangeOptions}
                    on-change={onOptionChange}></ui-select>
        </virtual>
        <virtual if={!token.edit}>
            {builder.getStructureString(token).slice(1,-1)}
        </virtual>
        <span class="cb-bracket">&gt;</span>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar token={token} builder={builder}></cql-builder-toolbar>

    <script>
        this.builder = this.opts.builder
        this.token = this.opts.token
        this.structure = this.token.structure
        this.structRangeOptions = ["whole", "startOf", "endOf"].map(s => {
            return {
                label: _(s),
                value: s
            }
        })

        onOptionChange(value, name){
            this.structure[name] = value
            this.parent.onChange()
            this.update()
        }
    </script>
</cql-builder-token-structure>


<cql-builder-token-or class="cql-builder-token cql-builder-token-or">
    <div class="cb-name">{_("or")}</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <span class="cb-bracket">|</span>
    </span>

    <script>
        this.token = this.opts.token
        this.builder = this.opts.builder
    </script>
</cql-builder-token-or>


<cql-builder-token-within class="cql-builder-token cql-builder-token-within">
    <div class="cb-name">within</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        within
    </span>

    <script>
        this.token = this.opts.token
        this.builder = this.opts.builder
    </script>
</cql-builder-token-within>


<cql-builder-token-containing class="cql-builder-token cql-builder-token-containing">
    <div class="cb-name">containing</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        containing
    </span>

    <script>
        this.token = this.opts.token
        this.builder = this.opts.builder
    </script>
</cql-builder-token-containing>


<cql-builder-token-meet class="cql-builder-token cql-builder-token-meet {edit: token.edit}">
    <div class="cb-name">meet</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <span class="cb-bracket">(</span>
        <virtual if={token.edit}>
            <span class="cb-block-wrapper">
                <label>{_("meetWhat")}</label>
                <cql-builder-attr-value-selector attr={meet.attr1}
                            equals={meet.equals1}
                            riot-value={meet.value1}
                            on-change={onMeetPartChange.bind(this, 1)}></cql-builder-attr-value-selector>
            </span>
            <span class="cb-block-wrapper cb-meet-middle-block">
                <label>{_("meetCondition")}</label>
                <cql-builder-attr-value-selector attr={meet.attr2}
                            equals={meet.equals2}
                            riot-value={meet.value2}
                            on-change={onMeetPartChange.bind(this, 2)}></cql-builder-attr-value-selector>
            </span>
            &nbsp;
            <ui-input inline=1
                    type="number"
                    label-id="left"
                    riot-value={meet.left}
                    min=0
                    max=100
                    name="left"
                    on-change={onNumberChange}></ui-input>
            <ui-input inline=1
                    type="number"
                    label-id="right"
                    riot-value={meet.right}
                    min=0
                    max=100
                    name="right"
                    on-change={onNumberChange}></ui-input>
        </virtual>
        <virtual if={!token.edit}>
            {builder.getMeetString(token).slice(1,-1)}
        </virtual>
        <span class="cb-bracket">)</span>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar token={token} builder={builder}></cql-builder-toolbar>

    <script>
        this.builder = this.opts.builder
        this.token = this.opts.token
        this.meet = this.token.meet

        onMeetPartChange(part, value, name){
            this.onChange(value, name + part)
        }

        onNumberChange(value, name){
            this.onChange(Math.abs(value), name)
        }

        onChange(value, name){
            this.meet[name] = value
            this.parent.onChange()
            this.update()
        }
    </script>
</cql-builder-token-meet>


<cql-builder-token-thesaurus  class="cql-builder-token cql-builder-token-thesaurus {edit: token.edit}">
    <div class="cb-name">Thesaurus</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <virtual if={token.edit}>
            <ui-input dynamic-width=1
                    inline=1
                    label={_("lemma")}
                    name="lemma"
                    riot-value={thesaurus.lemma}
                    on-change={onChange}></ui-input>
            <ui-select dynamic-width=1
                    inline=1
                    label={capitalize(_("pos"))}
                    name="lpos"
                    riot-value={thesaurus.lpos}
                    options={lposOptions}
                    on-change={onChange}></ui-select>
            <ui-select dynamic-width=1
                    inline=1
                    label={_("corpus")}
                    name="corpusFlag"
                    riot-value={thesaurus.corpusFlag}
                    tooltip="thesCorpTip"
                    options={corpusFlagOptions}
                    on-change={onChange}></ui-select>
            <ui-input dynamic-width=1
                    inline=1
                    type="number"
                    min=1
                    label={_("count")}
                    tooltip="thesCntTip"
                    name="count"
                    riot-value={thesaurus.count}
                    on-change={onChange}></ui-input>
        </virtual>
        <virtual if={!token.edit}>
            {builder.getThesaurusString(token)}
        </virtual>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar token={token} builder={builder}></cql-builder-toolbar>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.builder = this.opts.builder
        this.token = this.opts.token
        this.thesaurus = this.token.thesaurus

        this.lposOptions = AppStore.getActualCorpus().lposlist

        this.corpusFlagOptions = [{
            label: _("refCorpusRec"),
            value: ""
        }, {
            label: _("currentCorpus"),
            value: "~"
        }]

        if(!this.thesaurus.lpos){
            this.thesaurus.lpos = this.lposOptions[0].value
        }

        onChange(value, name){
            this.thesaurus[name] = value
            this.parent.onChange()
            this.update()
        }
    </script>
</cql-builder-token-thesaurus>


<cql-builder-token-wordsketch class="cql-builder-token cql-builder-token-wordsketch {edit: token.edit}">
    <div class="cb-name">Wordsketch</div>
    <cql-builder-token-warning obj={token}></cql-builder-token-warning>
    <span class="card-panel">
        <cql-builder-token-label></cql-builder-token-label>
        <span class="cb-bracket">[</span>
        <virtual if={token.edit}>
             <ui-input inline=1
                    label={_("headword")}
                    dynamic-width=1
                    riot-value={wordsketch.headword}
                    name="headword"
                    on-change={onWordsketchChange}></ui-input>
            &nbsp;
            <ui-input inline=1
                    label={_("relation")}
                    dynamic-width=1
                    riot-value={wordsketch.relation}
                    name="relation"
                    on-change={onWordsketchChange}></ui-input>
            &nbsp;
            <ui-input inline=1
                    label={_("collocation")}
                    dynamic-width=1
                    riot-value={wordsketch.collocation}
                    name="collocation"
                    on-change={onWordsketchChange}></ui-input>
            &nbsp;
        </virtual>
        <virtual if={!token.edit}>
            {builder.getWordsketchString(token)}
        </virtual>
        <span class="cb-bracket">]</span>
        <cql-builder-modifiers></cql-builder-modifiers>
    </span>
    <cql-builder-toolbar token={token} builder={builder}></cql-builder-toolbar>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.builder = this.opts.builder
        this.token = this.opts.token
        this.wordsketch = this.token.wordsketch

        this.structOptions = AppStore.getActualCorpus().structures.filter(s => {
            return s.value != "g"
        }).map(s => {
            return {
                value: s.name,
                label: s.label || s.name
            }
        })
        if(!this.token.structure){
            this.token.structure = this.structOptions[0].value
        }

        onWordsketchChange(value, name){
            this.wordsketch[name] = value
            this.parent.onChange()
            this.update()
        }
    </script>
</cql-builder-token-wordsketch>
