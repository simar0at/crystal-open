<insert-characters class="insert-characters">
    <label>{_("insert")}</label>
    <span each={obj in list}
            class="btn btn-flat {charTooltip: obj.tooltip}"
            data-tooltip={obj.tooltip}
            onclick={onInsert}>{obj.character}</span>
    <script>
        require("./insert-characters.scss")

        this.tooltipClass = ".charTooltip"
        this.mixin("tooltip-mixin")

        this.list = this.opts.characters.map(item => {
            let isArray = Array.isArray(item)
            return {
                character: isArray ? item[0] : item,
                tooltip: isArray ? _(item[1]) : ""
            }
        })

        insert(character, cursorOffset){
            // standalone method so it can be called from outside
            let field = $(this.opts.field)[0]
            let cursorPos = getCaretPosition(field)
            let textBefore = field.value.substring(0,  cursorPos)
            let textAfter  = field.value.substring(cursorPos, field.value.length)
            let value = textBefore + character + textAfter
            field.value = value
            delay(function(){
                cursorOffset = isDef(cursorOffset) ? cursorOffset : character.length
                setCaretPosition(field, cursorPos + cursorOffset)
                isFun(this.opts.onInsert) && this.opts.onInsert(character, value)
            }.bind(this), 0)
        }

        onInsert(evt){
            this.insert(evt.item.obj.character, 1)
        }
    </script>
</insert-characters>
