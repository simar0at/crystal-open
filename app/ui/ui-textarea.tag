<ui-textarea class="ui ui-textarea {opts.class}">
    <div class="input-field">
        <textarea
            class="materialize-textarea {monospace: opts.monospace} {invalid: opts.error}"
            ref="textarea"
            name={opts.name || ""}
            required={opts.required}
            disabled={opts.disabled}
            rows={rows}
            placeholder={opts.placeholder || ""}
            onkeyup={onKeyUp}
            oninput={onInput}
            onchange={onChange}
            onblur={onBlur}
            style={"min-height:" + rows + "rem;"}>{opts.riotValue || ""}</textarea>
        <span ref="errorLabel" data-error="{opts.error}" class="errorLabel"></span>
        <label ref="label"
            class="{tooltipped: opts.tooltip}"
            data-tooltip={ui_getDataTooltip()}>
            {getLabel(opts)}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
        </label>
    </div>

    <script>
        this.mixin('ui-mixin')

        this.rows = this.opts.rows || 3

        getValue(){
            return this.refs.textarea ? this.refs.textarea.value : ""
        }

        onKeyUp(evt){
            evt.preventUpdate = true
            if(evt.keyCode == "27"){
                $(this.refs.textarea).blur()
            } else if (evt.keyCode == 13 && isFun(this.opts.onSubmit)){
                evt.preventDefault()
                this.opts.onSubmit()
            } else{
                this.validate()
            }
        }

        onChange(evt){
            evt.preventUpdate = true
            this.callOnChange(evt)
        }

        onBlur(evt){
            evt.preventUpdate = true
            this.validate()
            this.callOnChange()
        }

        onInput(evt){
            evt.preventUpdate = true
            evt && evt.stopPropagation()
            this.isMounted && isFun(this.opts.onInput) && this.opts.onInput(this.refs.textarea.value, this.opts.name, evt)
        }

        callOnChange(evt){
            if(this.isMounted){
                if(typeof this.opts.onChange == "function"){
                    this.opts.onChange(this.refs.textarea.value, this.opts.name)
                }
            }
            evt && evt.stopPropagation()
        }

        validate(){
            this.ui_validate(this.refs.textarea)
        }

        autoresize(){
            if(this.isMounted){
                M.textareaAutoResize ($(this.refs.textarea))
            }
        }

        this.on("updated", this.autoresize)

        this.on("mount", () => {
            // materialize css fix
            let node = $("textarea", this.root)
            node.data("original-height", node.height())
                .data("previous-length", node.val().length)
            this.autoresize()
        })
    </script>
</ui-textarea>
