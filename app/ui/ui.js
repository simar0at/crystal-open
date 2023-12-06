require("./ui.scss")
require("./ui-input.tag")
require("./ui-tabs.tag")
require("./ui-select.tag")
require("./ui-list.tag")
require("./ui-filtering-list.tag")
require("./ui-checkbox.tag")
require("./ui-radio.tag")
require("./ui-pagination.tag")
require("./ui-textarea.tag")
require("./ui-collapsible.tag")
require('./ui-slider.tag')
require('./ui-uploader.tag')
require('./ui-chips.tag')
require('./ui-range.tag')
require('./ui-input-file.tag')

class IdGeneratorClass {
    constructor(){
        this.cnt = 0
    }
    get(){
        return "r_" + this.cnt++
    }
}
const generator = new IdGeneratorClass()

riot.mixin('ui-mixin', {
    getLabel: window.getLabel,

    init: function(){
        this.id = generator.get()

        this.opts.tooltip && this.on("updated", this.ui_initTooltip)

        this.on("mount", () => {
            this.opts.tooltip && this.ui_initTooltip()
            this.root.id = this.id
            debouncedUppdateTextFields()
        })

        this.on("unmount", () => {
            if(this.opts.tooltip){
                destroyTooltips(".tooltipped", this.root)
            }
        })
        if(this.opts.validate){
            this.on("updated", this.ui_validate)
        }

        if(this.opts.dynamicWidth){
            this.on("updated", this.ui_refreshWidth)
            this.on("mount", () => {
                this.ui_refreshWidth()
            })
        }
    },

    ui_refreshWidth(){
        // works correctly only for monospace inputs
        if(this.opts.dynamicWidth){ //if used in componet directly
            let inputNode = $("input", this.root)
            if(inputNode){
                let val = inputNode.val()
                let minWidth = this.opts.minWidth ? this.opts.minWidth * 1 : 8
                let width = val ? val.length + (this.root.tagName == "UI-SELECT" ? 3 : 2) : minWidth
                width = Math.max(width, this.opts.minWidth ? this.opts.minWidth * 1 : 5)
                if(this.opts.suffixIcon){
                    width += 3
                }
                inputNode.css("width", width + "ch")
            }
        }
    },

    ui_getDataTooltip(){
        return window.getTooltip(this.opts.tooltip)
    },

    ui_initTooltip(){
        $('.tooltipped', this.root).tooltip({
            enterDelay: 1000
        });
    },

    ui_validate(){
        // validity - HTML object ValidityState  - {customError: true, valueMissing: false...}
        // node of label where should be error message displayed in :after element
        let inputNode = this.refs.input || this.refs.textarea
        let validity = inputNode.validity
        if(!this.opts.validate || !validity){ //
            return
        }
        let errorMsgId = "";
        if(!validity.valid){
            ["customError", "patternMismatch", "rangeOverflow", "rangeUnderflow",
            "stepMismatch", "tooLong", "typeMismatch", "valueMissing"].some((err) => {
                if(validity[err] === true){
                    errorMsgId = err
                    return true
                }
                return false
            })
        } else{
            inputNode.classList.add("valid")
        }

        if(this.refs.errorLabel){
            this.refs.errorLabel.setAttribute("data-error", this.ui_getErrorMessage(errorMsgId))
        }
        if(errorMsgId){
            // something is wrong -> field is invalid
            inputNode.classList.add("invalid")
            inputNode.classList.remove("valid")
            this.isValid = false
        } else{
            inputNode.classList.remove("invalid")
            this.isValid = true
        }
    },

    ui_getErrorMessage(errorMsgId){
        // returns error message for errorMsgId - from opts[errorMessageId] if is
        // defined, or from resources ui.errorMsgId
        //
        /*  valid           - Returns whether the input field value has no validity errors.

            customError     - Returns whether the input field has raised a custom error.
            patternMismatch - Returns whether the input field value does not match the rules defined by the pattern attribute.
            rangeOverflow   - Returns whether a value is greater than the max attribute on an input control.
            rangeUnderflow  - A value is less than the min attribute on an input control.
            stepMismatch    - Returns whether the input field value does not fit the rules given by the step attribute.
            tooLong         - Returns whether an input field's value is longer than is allowed by the maxlength attribute.
            typeMismatch    - Returns whether the input field value is not the correct syntax.
            valueMissing    - Returns whether a value has not been entered in an input field that is required.
            */
        if(!errorMsgId){
            return ""
        }
        let optsMessage = this.opts[errorMsgId + "Message"]
        return optsMessage ? optsMessage : _("ui." + errorMsgId)
    }
})
