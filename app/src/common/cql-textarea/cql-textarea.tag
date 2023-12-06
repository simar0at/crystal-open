<cql-textarea>
    <ui-textarea placeholder={_("cc.cqlPlaceholder")}
            class="cql-textarea-{ta_id} mainFormField"
            monospace=1
            inline=1
            ref="cql"
            label-id="cql"
            riot-value={value}
            name="cql"
            rows=1
            on-input={onInput}
            on-change={onChange}
            onkeydown={onCqlKeyDown}
            style="width: {isCbAllowed ? 'calc(100% - 60px);' : '100%;'}"></ui-textarea>
    <button if={isCbAllowed}
            class="inline-block btn ui cffTooltip"
            data-tooltip={_("editCQLBtnTip")}
            onclick={onEditCQLBuilderClick}
            style="position: relative; top: -9px;">
        <i class="material-icons">edit</i>
    </button>

    <insert-characters ref="characters"
            characters={charactersList}
            field=".cql-textarea-{ta_id} textarea"
            on-insert={onCharacterInsert}></insert-characters>
    <a if={wposOptions.length}
            href="javascript:void(0);"
            class="btn white-text vertical-top"
            onclick={onTagsHelpClick}>{_("tagP")}</a>
    <cql-builder ref="builder"
            on-submit={onCQLBuilderSubmit}
            style="vertical-align: top;"></cql-builder>

    <script>
        const {AppStore} = require("core/AppStore.js")

        this.tooltipClass = ".cffTooltip"
        this.mixin("tooltip-mixin")

        this.corpus = this.opts.corpus || AppStore.getActualCorpus()
        this.ta_id = Math.round(Math.random() * 1000000)
        this.charactersList = [
            ["[]", "cc.squareBracketTip"],
            ["{}", "cc.curlyBracketTip"],
            ["<>", "cc.angleBracketTip"],
            ["\"\"", "cc.quotesTip"],
            ["&", "cc.ampBracketTip"],
            "\\",
            ["|", "cc.pipeTip"],
            "~", "#"
        ]
        this.wposOptions = this.opts.wposOptions || this.corpus.wposlist
        this.isCbAllowed = !!this.opts.cbValue
        this.value = this.opts.riotValue

        getValue(){
            return this.value
        }

        onCqlKeyDown(evt){
            evt.preventUpdate = true
            if(isFun(this.opts.onSubmit)){
                if(evt.keyCode == 13){
                    evt.preventDefault()
                    if(this.refs.cql.getValue()){
                        this.opts.onSubmit(this.value, this.opts.name, evt, this)
                    }
                }
            }
        }

        onInput(value){
            this.value = value
            if(this.isCbAllowed){
                this.isCbAllowed = false
                this.update()
            }
            isFun(this.opts.onInput) && this.opts.onInput(value, this.opts.name)
        }

        onChange(value){
            this._callOnChange(value)
        }

        onCharacterInsert(character, value){
            this.value = value
            this.update()
            this._callOnChange(value)
        }

        onEditCQLBuilderClick(evt){
            evt.preventUpdate = true
            this.refs.builder.openDialogWithData(this.opts.cbValue)
        }

        onCQLBuilderSubmit(value, stringified){
            this.value = value
            this.opts.cbValue = stringified
            this.isCbAllowed = true
            this._callOnChange(value)
            isFun(this.opts.onCbChange) && this.opts.onCbChange(stringified)
        }

        onTagsHelpClick(evt){
            evt.preventUpdate = true
            Dispatcher.trigger("openDialog", {
                tag: "tags-dialog",
                opts:{
                    wposlist: this.wposOptions,
                    tagsetdoc: this.opts.tagsetdoc || this.corpus.tagsetdoc,
                    onTagClick: function(tag){
                        this.refs.characters.insert(tag)
                        Dispatcher.trigger("closeDialog")

                    }.bind(this)
                },
                small: true,
                fixedFooter: true
            })
        }

        _callOnChange(value){
            isFun(this.opts.onChange) && this.opts.onChange(value, this.opts.name)
        }
    </script>
</cql-textarea>
