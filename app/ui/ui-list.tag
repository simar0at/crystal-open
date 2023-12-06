<ui-list class="ui ui-list {opts.classes}">
    <div class="{disabled:opts.disabled} input-field">
        <div if={opts.label || opts.labelId}
                ref="label"
                class="label {tooltipped: opts.tooltip}"
                data-tooltip={ui_getDataTooltip()}>
            {getLabel(opts)}
            <sup if={opts.tooltip}>?</sup>
            <lazy-dialog if={opts.helpDialog} file={opts.helpDialog}></lazy-dialog>
        </div>
        <ul class="ui-list-list"
            tabindex="0"
            ref="list"
            onkeydown={onKeyDown}
            onkeyup={onKeyUp}
            onscroll={onScrollDebounced}
            onmouseover={onMouseOver}
            onmouseleave={onMouseLeave}
            style={!opts.fullHeight ? ("max-height: " + maxHeight + "px;") : ""}>
            <li each={option, idx in opts.options}
                ref="{idx}_o"
                if={opts.showAll || idx < showLimit}
                data-value={option.value}
                class="{checkbox: parent.opts.multiple} {option.class}"
                onclick={this.parent.onOptionClick}
                disabled={option.disabled}>
                <raw-html if={typeof option.generator == "function"} content={option.generator(option)}></raw-html>
                {getOptionContent(option)}
            </li>
            <li class="ui-list-empty serviceNode" if={specialNodeTextId}>
                {_(specialNodeTextId)} <span if={opts.loading} class='dotsAnimation'><span>...</span></span>
            </li>
        </ul>
        <div if={opts.footerContent} class="footerContent">
            {opts.footerContent}
        </div>
        <span ref="errorLabel" data-error="{opts.error}" class="errorLabel"></span>
    </div>

    <script>
        this.mixin('ui-mixin')

        this.lastClickedOptionIndex = null // for multiselect, to select ranges of options between two clicks
        this.size = (parseInt(this.opts.size, 10) || 6 )
        this.cursorPosition = null
        this.showLimit = 20

        sort(){
            this.opts.options.sort((a, b) => {
                return getLabel(a) > getLabel(b)
            })
        }
        if(this.opts.sort){
            this.sort()
        }

        onOptionClick(evt){
            this.cursorPosition = evt.item.idx
            this.processItemSelect(evt)
        }

        onKeyDown(evt){
            evt.preventUpdate = true
            // prevent screen scroll
            if([38, 40, 33, 34].includes(evt.keyCode)){ // up, down, PgUp, PgDown
                evt.preventDefault()
            }
        }

        onKeyUp(evt){
            evt.preventUpdate = true
            if(evt.keyCode == 38){
                this.moveCursorUp(1)
            } else if(evt.keyCode == 40){
                this.moveCursorDown(1)
            } else if(evt.keyCode == 33){
                this.moveCursorUp(this.size) //pgUp
            } else if(evt.keyCode == 34){
                this.moveCursorDown(this.size) // pgDown
            } else if(evt.keyCode == 27){ //esc

            } else if(evt.keyCode == 13){ // enter
                if(this.cursorPosition !== null){
                    this.processItemSelect(evt)
                }
            }
        }

        onScrollDebounced(evt){
            evt.preventUpdate = true
            this.removeTooltips()
            debounce(this.onListScroll.bind(this), 50)()
        }

        onMouseOver(evt){
            // event is attached to list for better performance. In huge list it would
            // be expensive to bind two events on every LI
            evt.preventUpdate = true
            if(this.opts.disableTooltips){
                return
            }
            clearTimeout(this.tooltipTimeout)
            let target = evt.path && evt.path.find((elem) => {
                return ["LI", "UL"].includes(elem.tagName.toUpperCase()) // find first UL / LI
            })
            if(target.tagName == "LI" && target && this.refs.list){
                // create node, insert text into and measure width. Invisible element
                // has width "auto" so jquery width() measure max width. LIs in UL-list
                // have max width of UL -> we cannot measure their width.
                let tempNode = $("<li>", {html: target.innerHTML})
                    .css("display", "none")
                    .prependTo($(this.refs.list))
                if(tempNode.width() > target.clientWidth - 20){ // -20 for scrollbar
                    this.hoverNode = target
                    this.showTooltipDelayed(target)
                }
                tempNode.remove()
            }
        }

        onMouseLeave(evt){
            evt.preventUpdate = true
            this.hoverNode = null
            clearTimeout(this.tooltipTimeout)
        }

        selectOptionsInRange(optionIdx){
            // user clicked on row with shift -> make range selection
            const index1 = optionIdx
            const index2 = this.lastClickedOptionIndex
            if(index1 != -1 && index2 != -1){
                for(let i = Math.min(index1, index2); i <= Math.max(index1, index2); i++){
                    this.selectItem(this.opts.options[i])
                }
            }
        }

        moveCursorDown(step){
            if(this.cursorPosition !== null){
                this.cursorPosition += (step || 1)
                if(this.cursorPosition >= this.opts.options.length){
                    this.cursorPosition = this.opts.options.length - 1
                    isFun(this.opts.onScrollToBottom) && this.opts.onScrollToBottom(this.opts.name)
                }
            } else{
                if(this.opts.options.length){
                    this.cursorPosition = 0
                }
            }
            this.updateCursor()
        }

        moveCursorUp(step){
            if(this.cursorPosition !== null){
                this.cursorPosition -= (step || 1)
                if(this.cursorPosition < 0){
                    this.cursorPosition = 0
                }
            } else{
                if(this.opts.options.length){
                    this.cursorPosition = this.opts.options.length - 1
                }
            }
            this.updateCursor()
        }

        updateCursor(){
            // if cursorPosition is defined, make selected option focused
            if(this.isMounted){
                $("li.focused", this.root).removeClass("focused")
                const node = this.refs[this.cursorPosition + "_o"]
                if(node){
                    $(node).addClass("focused")
                    this.scrollSelectedIntoView()
                }
            }
        }

        callOnChange(evt){
            if(isFun(this.opts.onChange)){
                let label = this.getLabelByValue(this.value)
                this.opts.onChange(this.value, this.opts.name, label, this.opts.options[this.cursorPosition])
            }
        }

        processItemSelect(evt){
            // on item click or selected by keyboard
            evt.preventUpdate = true
            let option = this.opts.options[this.cursorPosition]
            if(this.opts.disabled || option.disabled){
                return
            }
            if((!isDef(this.opts.deselectOnClick) || this.opts.deselectOnClick) && (!this.opts.multiple || !evt.shiftKey) && this.isValueSelected(option.value)){
                this.deselectItem(option)
            } else{
                this.selectItem(option)
                if(this.opts.multiple){
                    if(evt.shiftKey){
                        this.selectOptionsInRange(evt.item.idx)
                    } else{
                        this.lastClickedOptionIndex = evt.item.idx
                    }
                }
            }
            this.markSelected()
            this.callOnChange(evt)
        }

        selectItem(option){
            if(this.opts.multiple){
                if(!this.isValueSelected(option.value)){
                    this.value.push(option.value + "")
                }
            } else{
                this.value = option.value + ""
            }
        }

        deselectItem(option){
            if(this.opts.multiple){
                let idx = this.value.indexOf(option.value + "")
                if(idx != -1){
                    this.value.splice(idx, 1);
                }
            } else{
                this.value = ""
                this.cursorPosition = null
            }
        }

        markSelected(){
            // mark selected rows with grey background
            $("li:not(.serviceNode)", this.root).each((idx, row) => {
                $(row).toggleClass("selected", this.isValueSelected($(row).attr('data-value') !== undefined ? row.getAttribute("data-value") : ''))
            })
        }

        getLabelByValue(value){
            return this.getLabel(this.opts.options.find(o => {return o.value + "" === value + ""}))
        }

        getOptionContent(option){
            // return content of list row (<li> element), if its not generated
            return isFun(option.generator) ? null : this.getLabel(option)
        }

        scrollSelectedIntoView(){
            // if item is out of view or too close (size of one row) to border => scroll list viewport
            if(!this.refs.list){
                return
            }
            let selectedItem = this.refs[this.cursorPosition + "_o"]
            if(selectedItem){
                let list = this.refs.list
                let offsetTop = selectedItem.offsetTop
                let rowHeight = selectedItem.clientHeight
                let min = list.scrollTop
                let max = list.scrollTop + list.clientHeight - rowHeight
                if(offsetTop < min){
                    list.scrollTop = offsetTop
                } else if(offsetTop > max){
                    list.scrollTop = offsetTop - list.clientHeight + rowHeight
                }
            }
        }

        onListScroll(evt){
            if(this.refs.list.scrollHeight - this.refs.list.scrollTop <= this.refs.list.clientHeight + 150){
                if(isFun(this.opts.onScrollToBottom)){
                    this.opts.onScrollToBottom(this.opts.name)
                } else {
                    if(this.showLimit < this.opts.options.length){
                        this.showLimit += 40
                        this.update()
                    }
                }
            }
        }

        isValueSelected(value){
            return this.opts.multiple ? this.value.includes(value + "") : this.value + "" === value + ""
        }

        isAnyItemSelected(){
            return this.cursorPosition !== null
        }

        showTooltipDelayed(node){
            // wait one second, if user did not moved from LI, show tooltip
            this.tooltipTimeout = setTimeout(function(){
                if(this.hoverNode == node){
                    window.showTooltip(node, node.innerHTML)
                }
            }.bind(this), 1000)
        }

        getNodeContent(node){
            // return content of option node. Text or HTML, if option is created
            // by function "generator"
            let id = node.id.split("_")[2]
            let option = this.opts.options[id]
            return isFun(option.generator) ? option.generator(option) : this.getLabel(option)
        }

        removeTooltips(){
            destroyTooltips(".hasTooltip")
        }

        updateAttributes(){
            this.opts.options = this.opts.options
            if(this.opts.riotValue){
                this.value = this.opts.riotValue
            } else{
                this.value = this.opts.multiple ? [] : ""
            }
            this.maxHeight = this.size * 44 + 10 //top and bottom padding

            this.specialNodeTextId = ""
            if(this.opts.loading){
                this.specialNodeTextId = "ui.loading"
            } else if(!this.opts.options.length && !this.opts.specialNodeTextId){
                this.specialNodeTextId = "empty"
            } else if(this.opts.specialNodeTextId){
                this.specialNodeTextId = this.opts.specialNodeTextId
            }
        }
        this.updateAttributes()

        this.on("mount", () => {
            if(isDef(this.opts.riotValue)){
                let idx = this.opts.options.findIndex(o => { return o.value === this.opts.riotValue}, this)
                this.cursorPosition = idx == -1 ? null : idx
            }
            this.markSelected()
            setTimeout(this.scrollSelectedIntoView.bind(this), 0)
        })

        this.on("update", () => {
            this.removeTooltips()
            this.updateAttributes()
        })

        this.on("updated", () => {
            this.cursorPosition = null
            this.markSelected()
        })
        this.on("before-unmount", this.removeTooltips)
    </script>
</ui-list>
