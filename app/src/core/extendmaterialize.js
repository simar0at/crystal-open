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

let dropdownExtension = {
    // removed touchend event listener which caused problems with selecting items on mobil devices
    _setupTemporaryEventHandlers: function() {
        document.body.addEventListener('click', this._handleDocumentClickBound, true)
        document.body.addEventListener('touchmove', this._handleDocumentTouchmoveBound)
        this.dropdownEl.addEventListener('keydown', this._handleDropdownKeydownBound)
    },

    _removeTemporaryEventHandlers: function() {
        document.body.removeEventListener('click', this._handleDocumentClickBound, true)
        document.body.removeEventListener('touchmove', this._handleDocumentTouchmoveBound)
        this.dropdownEl.removeEventListener('keydown', this._handleDropdownKeydownBound)
    }
}

// fixed tooltip position bug:
// https://github.com/Dogfalo/materialize/commit/1498e0c5bcc7b73a31c2361459adfce0a13c6afd
let old = M.checkWithinContainer
M.checkWithinContainer = function(container, bounding, offset){
    let edges = old(container, bounding, offset)
    let containerRect = container.getBoundingClientRect();
    let containerRight = container === document.body
            ? Math.max(containerRect.right, window.innerWidth)
            : containerRect.right;
    let scrollLeft = container.scrollLeft;
    let scrolledX = bounding.left - scrollLeft;
    edges.right = scrolledX + bounding.width > containerRight - offset ||
                    scrolledX + bounding.width > window.innerWidth - offset
    return edges
}

// add two more pixels to compensate for border (to avoid displaying scrollbars when no needed)
M.textareaAutoResize = function($textarea){
    // Wrap if native element
    if ($textarea instanceof Element) {
      $textarea = $($textarea);
    }

    if (!$textarea.length) {
      console.error('No textarea element found');
      return;
    }

    // Textarea Auto Resize
    var hiddenDiv = $('.hiddendiv').first();
    if (!hiddenDiv.length) {
      hiddenDiv = $('<div class="hiddendiv common"></div>');
      $('body').append(hiddenDiv);
    }

    // Set font properties of hiddenDiv
    var fontFamily = $textarea.css('font-family');
    var fontSize = $textarea.css('font-size');
    var lineHeight = $textarea.css('line-height');

    // Firefox can't handle padding shorthand.
    var paddingTop = $textarea.css('padding-top');
    var paddingRight = $textarea.css('padding-right');
    var paddingBottom = $textarea.css('padding-bottom');
    var paddingLeft = $textarea.css('padding-left');

    if (fontSize) {
      hiddenDiv.css('font-size', fontSize);
    }
    if (fontFamily) {
      hiddenDiv.css('font-family', fontFamily);
    }
    if (lineHeight) {
      hiddenDiv.css('line-height', lineHeight);
    }
    if (paddingTop) {
      hiddenDiv.css('padding-top', paddingTop);
    }
    if (paddingRight) {
      hiddenDiv.css('padding-right', paddingRight);
    }
    if (paddingBottom) {
      hiddenDiv.css('padding-bottom', paddingBottom);
    }
    if (paddingLeft) {
      hiddenDiv.css('padding-left', paddingLeft);
    }

    // Set original-height, if none
    if (!$textarea.data('original-height')) {
      $textarea.data('original-height', $textarea.height());
    }

    if ($textarea.attr('wrap') === 'off') {
      hiddenDiv.css('overflow-wrap', 'normal').css('white-space', 'pre');
    }

    hiddenDiv.text($textarea[0].value + '\n');
    var content = hiddenDiv.html().replace(/\n/g, '<br>');
    hiddenDiv.html(content);

    // When textarea is hidden, width goes crazy.
    // Approximate with half of window size

    if ($textarea[0].offsetWidth > 0 && $textarea[0].offsetHeight > 0) {
      hiddenDiv.css('width', $textarea.width() + 'px');
    } else {
      hiddenDiv.css('width', window.innerWidth / 2 + 'px');
    }

    /**
     * Resize if the new height is greater than the
     * original height of the textarea
     */
    if ($textarea.data('original-height') <= hiddenDiv.innerHeight()) {
      $textarea.css('height', hiddenDiv.innerHeight() + 2 + 'px');
    } else if ($textarea[0].value.length < $textarea.data('previous-length')) {
      /**
       * In case the new height is less than original height, it
       * means the textarea has less text than before
       * So we set the height to the original one
       */
      $textarea.css('height', $textarea.data('original-height') + 'px');
    }
    $textarea.data('previous-length', $textarea[0].value.length);
  }

$.extend(M.Tooltip.prototype, tooltipExtension)
$.extend(M.Dropdown.prototype, dropdownExtension)
