// keep tooltip open if cursor is on tooltip content
// if options.html starts with "t_id:" then rest of html value is used as
// text identifier to load external text and use it as tooltip content
let tooltipExtension = {
    old_animateIn: M.Tooltip.prototype._animateIn,
    old_animateOut: M.Tooltip.prototype._animateOut,
    old_setupEventHandlers: M.Tooltip.prototype._setupEventHandlers,
    old_open: M.Tooltip.prototype.open,

    open: function(params){
        this.old_open(params)
        if(this.options.html && this.options.html.startsWith('t_id:')){
            this._loadTextAndDisplay()
        }
    },

    _loadTextAndDisplay(){
        let tooltipBody = $(this.tooltipEl).children(0)
        if(this.loadedContent){
            tooltipBody.html(this.loadedContent)
        } else{
            $(this.tooltipEl).addClass("htmlTooltip tooltipLoading")
            let textId = this.options.html.substring(5)
            let spinnerNode = $("<div class='centerSpinner'>")
            tooltipBody.empty().append(spinnerNode)
            riot.mount($("<div>").appendTo(spinnerNode), "preloader-spinner", {small: 1})
            window.TextLoader.load(textId, function(payload){
                this.loadedContent = payload.text
                if(payload.status == "OK"){
                    tooltipBody && tooltipBody.html(this.loadedContent)// could be destroyed meanwhile
                }
                $(this.tooltipEl).removeClass("tooltipLoading")
            }.bind(this))
        }
    },

    _setupEventHandlers: function(){
        this.old_setupEventHandlers()
        this._handleElMouseEnterBound = this._handleElMouseEnter.bind(this)
        this._handleElMouseLeaveBound = this._handleElMouseLeave.bind(this)
    },

    _animateIn: function(){
        this.old_animateIn()
        this.tooltipEl.addEventListener("mouseenter", this._handleElMouseEnterBound)
        this.tooltipEl.addEventListener("mouseleave", this._handleElMouseLeaveBound)
        this.tooltipEl.style.pointerEvents = "initial"
    },

    _animateOut: function(){
        this.tooltipEl.removeEventListener("mouseenter", this._handleElMouseEnterBound)
        this.tooltipEl.removeEventListener("mouseleave", this._handleElMouseLeaveBound)
        this.old_animateOut()
        this.tooltipEl.style.pointerEvents = "none"
        isFun(this.onClose) && this.onClose()
    },

    _handleElMouseEnter: function(){
        this.isOpen = true
        this.isHovered = true
        this.isFocused = true
    },

    _handleElMouseLeave(){
        this._handleMouseLeave()
    }
}
$.extend(M.Tooltip.prototype, tooltipExtension)
