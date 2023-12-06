require("./new-corpus-notification/new-corpus-notification.tag")

window.getLabel = (obj) => {
    if(!obj){
        return ""
    }
    if(typeof obj.label != "undefined"){
        return obj.label;
    }
    if(obj.labelId){
        return _(obj.labelId);
    }
    return ""
}

window.externalLink = (linkId) => {
    // returns url to external site from list: external-links.json
    let link = window.config.links[linkId]
    if(!isDef(link)){
        console.warn("Links: request for unknown link: " + linkId)
        return ""
    }
    return link
}

window.getFeatureIcon = (feature) => {
    return {
        "parconcordance": "skeico_parallel_concordance",
        "keywords": "skeico_keywords",
        "sketchdiff": "skeico_word_sketch_difference",
        "ngrams": "skeico_n_grams",
        "trends": "skeico_trends",
        "wordsketch": "skeico_word_sketch",
        "wordlist": "skeico_word_list",
        "thesaurus": "skeico_thesaurus",
        "concordance": "skeico_concordance",
        "biwordsketch": "skeico_bilingual_word_sketch",
        "ocd": "skeico_ocd"
    }[feature] || ""
}

window.getLangFontClass = (language_id) => {
    if(["ja", "ko", "zh-CN", "zh-HK", "zh-TW" ,"zh-Hant", "zh-Hans", "bo"].includes(language_id)){
        // dense font
        return "f-cjk"
    }
    if(["vi", "ur", "th", "te", "ta", "si", "pa", "ne", "my", "mr", "ml", "lo", "kn", "km", "hi", "gu", "fa", "bn", "ar"].includes(language_id)){
        // tall font
        return "f-tall"
    }
    // english like
    return "f-eng"
}

window.getFeatureLabel = (feature) => {
    return feature == "wordsketch" ? "Word Sketch" : _(feature)
}

window.isDef = (obj) => {
    return typeof obj != "undefined";
}

window.isFun = (fun) => {
    return typeof fun == "function";
}

window.truncate = (str, length) => {
    let string = str + "";
    if(string.length > length)
        return string.substring(0, length) + '...';
    else
        return string;
}

window.capitalize = (str) => {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

window.objectEquals = (x, y) => {
    if(x === y) return true// if both x and y are null or undefined and exactly the same
    if(!(x instanceof Object) || !(y instanceof Object)) return false // if they are not strictly equal, they both need to be Objects
    if(x.constructor !== y.constructor) return false // they must have the exact same prototype chain, the closest we can do is test there constructor.
    for(var p in x) {
        if(!x.hasOwnProperty(p)) continue// other properties were tested using x.constructor === y.constructor
        if(!y.hasOwnProperty(p)) return false // allows to compare x[p] and y[p] when set to undefined
        if(x[p] === y[p]) continue // if they have the same strict value or identity then they are equal
        if(typeof(x[p]) !== "object") return false// Numbers, Strings, Functions, Booleans must be strictly equal
        if(!objectEquals(x[p], y[p])) return false // Objects and Arrays must be tested recursively
    }
    for(p in y) {
        if(y.hasOwnProperty(p) && ! x.hasOwnProperty(p)) return false// allows x[p] to be set to undefined
    }
    return true
}

window.debounce = (fn, delay) => {
    // if multiple functions fn are called with less delay between two of them
    // the only last will run
    let t
    return function () {
        clearTimeout(t)
        t = setTimeout(fn, delay)
    }
}

window.delay = (fun, time) => {
    // call function with delay
    let t = setTimeout(()=>{
        clearTimeout(t)
        fun()
    }, time)
    return t
}

window.isElementVisible = (element, whole) => {
    // return true, if given element (jquery selector, or node) is visible on screen
    if(element){
        let topOfElement = $(element).offset().top;
        let bottomOfElement = topOfElement + $(element).outerHeight();
        let topOfScreen = $(window).scrollTop();
        let bottomOfScreen = topOfScreen + $(window).height();
        if((!whole && (bottomOfScreen > topOfElement) && (topOfScreen < bottomOfElement))
            || whole && ((bottomOfScreen > bottomOfElement) && (topOfScreen < topOfElement))){
            return true
        }
    }
    return false
}

window.htmlEscape = (str) => {
    let entityMap = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
        '`': '&#x60;'
    }
    return String(str).replace(/[&<>"'`]/g, function (s) {
        return entityMap[s]
    })
}

window.riotEscape = (str) => {
    return (str + "").replace(/{/g , "\\{").replace(/}/g , "\\}")
}

window.idEscape = (str) => {
    return "ID-" + encodeURIComponent(str).replace(/\W/g,'_') // valid HTML and jQuery ID
}

window.escapeCharacters = (str, characters) => {
    let re = "[" + window.escapeRE(characters) + "]"
    return String(str).replace(new RegExp(re, "g"), (c) => {
        return "\\" + c
    })
}

window.unescapeCharacters = (str, characters) => {
    characters.split("").forEach(ch => {
        str = str.replace(new RegExp("\\\\" + window.escapeRE(ch), "g"), () => {
            return ch
        })
    })
    return str
}

window.escapeRE = (str) => {
    return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}

window.factorial = (n) => {
    return n - 1 > 0 ? n * factorial(n - 1) : 1;
}

window._p = (obj) => {
    // just for debugging in riot templates
    return JSON.stringify(obj)
}

window._c = (obj) => {
    // just for debugging in riot templates
    // console.log(_p(obj))
}


window.debouncedUppdateTextFields = debounce(() => {
    M.updateTextFields && M.updateTextFields()
}, 1)

window.getPageParent = (tag) => {
    while (tag.parent != undefined) {
        if(tag.pageTag){
            return tag.pageTag
        }
        if (tag.parent.__.tagName.startsWith("page-"))
            return tag.parent
        tag = tag.parent
    }
}

window.initDropdown = (selector, context, options) => {
    $(selector, context).each((i, elem) => {
        if($.contains(document.documentElement, elem)){
            $(elem).dropdown(options || {})
        }
    })
}

window.destroyTooltips = (selector, context) => {
    $(selector, context).each((i, elem) => {
        elem.M_Tooltip && elem.M_Tooltip.destroy()
    })
}

window.decodeURIquery = (q) => {
    return decodeURIComponent(q.replace(/\+/g,' '));
}

window.secondsToString = (sec_num) => {
    sec_num = Math.floor(sec_num)
    let hours   = Math.floor(sec_num / 3600)
    let minutes = Math.floor((sec_num % 3600) / 60)
    let seconds = Math.floor(sec_num % 60)

    if (hours   < 10) {hours   = "0" + hours}
    if (minutes < 10) {minutes = "0" + minutes}
    if (seconds < 10) {seconds = "0" + seconds}
    return (hours != "00" ? (hours + ":") : "") + minutes + ':' + seconds

}

window.openPopup = (url, title, params, width, height, onClose) => {
    let dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX
    let dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY

    let screenWidth = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width
    let screenHeight = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height

    let left = ((screenWidth / 2) - (width / 2)) + dualScreenLeft
    let top = ((screenHeight / 2) - (height / 2)) + dualScreenTop

    let newWindow = window.open(url, title, params + ',' + 'width=' + width + ',height=' + height + ',top=' + top + ', left=' + left)

    if (window.focus) {
        newWindow.focus()
    }
    if(isFun(onClose)){
        let pollTimer = window.setInterval(function() {
            if (newWindow.closed !== false) { // !== is required for compatibility with Opera
                window.clearInterval(pollTimer)
                onClose()
            }
        }, 200)
    }
}



window.setCaretPosition = (elem, pos) => {
    if (elem.setSelectionRange) {
        elem.focus();
        elem.setSelectionRange(pos, pos);
    } else if (elem.createTextRange) {
        let range = elem.createTextRange();
        range.collapse(true);
        range.moveEnd('character', pos);
        range.moveStart('character', pos);
        range.select();
    }
}

window.getCaretPosition = (elem) => {
    let pos = 0;
    if('selectionStart' in elem) {
        pos = elem.selectionStart;
    } else if('selection' in document) {
        elem.focus();
        let Sel = document.selection.createRange();
        let SelLength = document.selection.createRange().text.length;
        Sel.moveStart('character', -elem.value.length);
        pos = Sel.text.length - SelLength;
    }
    return pos;
}


window.copyToClipboard = (str, onDone, onFailed) => {
    // NOTE: does not work with open DevTools
    if(navigator.clipboard){
        navigator.clipboard.writeText(str).then(onDone, onFailed);
    } else{
        const el = document.createElement('textarea')
        el.value = str
        document.body.appendChild(el)
        el.select()
        document.execCommand('copy')
        document.body.removeChild(el)
    }
}

window.copy = (obj) => {
    try {
        return JSON.parse(JSON.stringify(obj))
    } catch (err) {
        return JSON.parse(JSON.stringify(JSON.decycle(obj)))
    }
}

window.isEmail = (str) => {
    return new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/).test(str)
}

window.getLocaleDate = (dateString) => {
    return (new Date(dateString)).toLocaleDateString()
}

window.showTooltip = (selector, message, delay=0) => {
    let node = $(selector)
    if(M.Tooltip.getInstance(node)) return

    node.tooltip({
        enterDelay: delay,
        exitDelay: 500,
        html: message
    })
    let tooltip = M.Tooltip.getInstance(node)
    setTimeout(function(node){
        if($(node).is(":hover")){
            let tooltip = M.Tooltip.getInstance(node)
            tooltip && tooltip.open()
        }
    }.bind(null, node), delay)
    node.one("mouseleave", function(){
        !this.isOpen && this.destroy()
    }.bind(tooltip))
    tooltip.onClose = () => {
        window.delay(tooltip.destroy.bind(tooltip), 300)
    }
    return tooltip
}

window.measureData = {}

window.measure = (fun, label) => {
    if(!measureData[label]){
        measureData[label] = {
            total: 0,
            count: 0
        }
    }
    let start = new Date().getTime()
    fun()
    let diff = new Date().getTime() - start
    measureData[label].total += diff
    measureData[label].count++
    console.log((label || "") + " " + diff + " avg: " + (measureData[label].total / measureData[label].count) + " of " + measureData[label].count)
}

window.addLinksToTheText = (text) => {
    // replaces all "%[linkId|linkLabel]%" occurences in text with links from linkMap
    // linkLabel might be omitted, "%[linkId]%", linkId will be also displayed
    let linkMap = {};

    ["lemma", "collocate", "subcorpus", "frequency", "wordForm", "regex", "token",
            "KWIC", "structure", "attribute", "lc", "tag", "lempos",
            "annotating", "relfreq"].forEach(key => {
        linkMap[key] = window.config.links["h_" + key]
    })

    for(let key in linkMap){
        linkMap[key] = '<a href="' + linkMap[key] + '" target="_blank">%link%</a>'
    }

    let reg = /%\[(.*?|.*?)\]%/g;
    let result
    let tmp, link, linkLabel, linkWithLabel
    while((result = reg.exec(text)) !== null) {
        tmp = result[1].split("|")
        link = linkMap[tmp[0]]
        linkLabel = tmp[1] || tmp[0]
        if(link){
            linkWithLabel = link.replace("%link%", linkLabel)
            text = text.replace(result[0], linkWithLabel)
        } else{
            console.log("addLinksToTheText:Link for " + tmp[0] + " not found.")
        }

    }
    return text
}

window.arrayToOptionList = (arr, valueKey, labelKey) => {
    return arr.map(item => {
        return {
            value: item[valueKey],
            label: item[labelKey]
        }
    })
}

window.tokenize = (str, escape, separators) => {
    separators = Array.isArray(separators) ? separators : [separators]
    for (var arr = [], part = '', i = 0, e = str.length; i < e; i++) {
        var char = str.charAt(i)
        if (char == escape){
            part += char + str.charAt(++i)
        } else if (!separators.includes(char)) {
            part += char
        } else {
            arr.push(part)
            part = ''
        }
    }
    arr.push(part)
    return arr
}

window.getTooltip = (tooltip) => {
    if(!tooltip){
        return null
    } else if(tooltip.startsWith("t_id:")){
        return tooltip
    } else{
        return _(tooltip)
    }
}

