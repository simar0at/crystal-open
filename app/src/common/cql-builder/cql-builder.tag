<cql-builder class="cql-builder">
    <button class="btn teal tooltipped"
            data-tooltip={_("cqlBuilderTip")}
            onclick={openDialog}>
        CQL Builder
        <i class="material-icons right">fullscreen</i>
    </button>

    <script>
        require("./cql-builder.scss")
        require("./cql-builder-dialog.tag")
        const {AppStore} = require("core/AppStore.js")
        const {UserDataStore} = require("core/UserDataStore.js")

        this.mixin("tooltip-mixin")

        this.tokens = []
        this.corpus = AppStore.getActualCorpus()
        this.isCQLValid = false
        this.condition = {
            parts: [],
            warning: "",
            edit: false
        }
        this.tokenTypeMap = {
            "standard":   "s",
            "any":        "a",
            "distance":   "d",
            "structure":  "r",
            "or":         "o",
            "within":     "i",
            "containing": "c",
            "meet":       "m",
            "thesaurus":  "t",
            "wordsketch": "w"
        }


        reset(){
            this.tokens = []
            this.condition = {
                parts: []
            }
        }

        onCQLSubmit(){
            this.addCQLToHistory()
            let CQLString = this.getCQLString()
            let stringified = this.stringify()
            this.reset()
            this.opts.onSubmit(CQLString, stringified)
        }

        openDialogWithData(stringified){
            this.dataOpenedWith = stringified
            this.setStringData(stringified)
            this.openDialog()
        }

        openDialog(){
            Dispatcher.trigger("openDialog", {
                id: "cql-builder-dialog",
                fullScreen: true,
                dismissible: false,
                tag: "cql-builder-dialog",
                opts: {
                    builder: this
                }
            })
        }

        setStringData(stringified){
            let obj = this.parse(stringified)
            this.tokens = obj.tokens
            this.condition = obj.condition
            this.validate()
        }

        setTokenEdit(token, edit){
            this.tokens.forEach(t => {
                t.edit = token == t ? edit : false
            })
            this.validate()
        }

        addToken(params, tokenOpts){
            let token = Object.assign(this._getDefaultToken(params.type), tokenOpts)
            token.edit = true
            this.tokens.splice(params.position, 0, token)
            this.setTokenEdit(this.tokens[params.position], true)
        }

        removeToken(position){
            this.tokens.splice(position, 1)
        }

        addCondition(type){
            let condition = {
                type: type
            }
            if(type == "attribute"){
                condition.attr1 = "lemma"
                condition.attr2 = "lemma"
                condition.label1 = "1"
                condition.label2 = "2"
                condition.equals = "="
            } else {
                condition.label = "1"
                condition.frequency = "1000"
                condition.gtlt = ">"
                condition.attr = "lemma"
            }
            this.condition.parts.push(condition)
            this.condition.edit = true
        }

        validate(){
            let labels = {}
            this.tokens.forEach(t => {
                if(t.label){
                    if(!labels[t.label]){
                        labels[t.label] = 0
                    }
                    labels[t.label] ++
                }
            })
            this.isCQLValid = true
            this.tokens.forEach((token, idx) => {
                let warnings = []
                if(["or", "containing", "within"].includes(token.type)){
                    !this._isPrevTokenNormal(idx) && warnings.push(_("errNoTokenLeft"))
                    !this._isNextTokenNormal(idx) && warnings.push(_("errNoTokenRight"))
                }
                token.type == "standard"
                        && token.parts.some(part => {
                            return part.value === ""
                        })
                        && warnings.push(_("errEmptyValue"))
                token.type == "wordsketch"
                        && this._isFieldMissing(token.wordsketch, ["headword", "relation", "collocation"])
                        && warnings.push(_("errEmptyValue"))
                token.type == "thesaurus"
                        && this._isFieldMissing(token.thesaurus, ["lemma"])
                        && warnings.push(_("errEmptyValue"))
                token.type == "meet"
                        && this._isFieldMissing(token.meet, ["attr1", "value1", "attr2", "value2", "left", "right"])
                        && warnings.push(_("errEmptyValue"))
                token.repeat
                        && this._isFieldMissing(token.repeat, ["min", "max"])
                        && warnings.push(_("errEmptyRange"))
                token.label
                        && labels[token.label] > 1
                        && warnings.push(_("errSameLabels"))

                token.warning = warnings.join("<br><br>")
                this.isCQLValid = this.isCQLValid && !warnings.length
            })

            warnings = []
            this.condition.parts.forEach(condition => {
                if(condition.type == "attribute"){
                    (!isDef(labels[condition.label1]) || !isDef(labels[condition.label2]))
                            && warnings.push(_("errUnassignedLabel"))
                    this._isFieldMissing(condition, ["frequency"])
                            && warnings.push(_("errMissingFrequency"))
                } else if(condition.type == "frequency"){
                    !isDef(labels[condition.label])
                            && warnings.push(_("errUnassignedLabel"))
                    this._isFieldMissing(condition, ["frequency"])
                            && warnings.push(_("errMissingFrequency"))
                }
            })
            this.isCQLValid = this.isCQLValid && !warnings.length
            this.condition.warning = warnings.join("<br><br>")
        }

        addCQLToHistory(){
            if(this.isCQLValid){
                UserDataStore.addCQL({
                    cql: this.getCQLString(),
                    stringified: this.stringify(),
                    date: window.Formatter.dateTime(new Date())
                })
            }
        }

        addConditionBrackets(){
            return this.condition.parts.length && !!this.tokens.find(t => {
                return t.type == "within" || t.type == "containing"
            })
        }

        precedesGroup(idx){
            if(!this._hasGroups()){
                return false
            }
            let i = idx
            let cnt = 0
            while(i >= 0 && cnt < 2 && this.tokens[i] && this.tokens[i].type != "or"){
                if(this._isTokenNormal(this.tokens[i])){
                    cnt++
                }
                i--
            }
            return cnt == 2
        }

        followsGroup(idx){
            if(!this._hasGroups()){
                return false
            }
            let i = idx
            let cnt = 0
            while(i < this.tokens.length && cnt < 2 && this.tokens[i] && this.tokens[i].type != "or"){
                if(this._isTokenNormal(this.tokens[i])){
                    cnt++
                }
                i++
            }
            return cnt == 2
        }

        getCQLString(){
            let str = ""
            if(this.addConditionBrackets()){
                str += "("
            }
            if(this.followsGroup(0)){
                str += "("
            }
            str += this.tokens.reduce((allTokensStr, token, idx) => {
                if(token.label){
                    allTokensStr += " " + token.label + ":"
                }
                if(token.type == "or"){
                    if(this.precedesGroup(idx - 1)){
                        allTokensStr += ")"
                    }
                    allTokensStr += " | "
                    if(this.followsGroup(idx + 1)){
                        allTokensStr += "("
                    }
                    return allTokensStr
                } else if (token.type == "within"){
                    return allTokensStr += " within "
                } else if (token.type == "containing"){
                    return allTokensStr += " containing "
                } else if(token.type == "meet"){
                    return allTokensStr += this.getMeetString(token) + " "
                } else if(token.type == "structure"){
                    return allTokensStr += this.getStructureString(token) + " "
                } else {
                    let tokenStr = ""
                    if(token.type != "thesaurus"){
                        tokenStr += "["
                    }
                    if(token.type == "standard"){
                        tokenStr += this.getStandardTokenString(token)
                    } else if(token.type == "wordsketch"){
                        tokenStr += this.getWordsketchString(token)
                    } else if(token.type == "thesaurus"){
                        tokenStr += this.getThesaurusString(token)
                    }
                    if(token.type != "thesaurus"){
                        tokenStr += "]"
                    }
                    tokenStr += this.getRepeatString(token)
                    if(token.optional){
                        tokenStr += "? "
                    }
                    tokenStr += " "
                    return allTokensStr += tokenStr
                }
            }, "", this)
            if(this.precedesGroup(this.tokens.length - 1)){
                str += ")"
            }
            if(this.addConditionBrackets()){
                str += ")"
            }
            str += this.getConditionStr()

            return str.trim()
        }

        stringify(){
            let str = ""
            let esc = window.escapeCharacters
            this.tokens.forEach(t => {
                let val, val2
                str += str ? "#" : ""
                str += this.tokenTypeMap[t.type]
                t.label && (str += t.label + ":")
                if(t.type == "standard"){
                    str += t.parts.reduce((partsStr, part, idx) => {
                        if(idx > 0){
                            partsStr += `${part.andOr}`
                        }
                        partsStr += `${part.attr}${part.equals}"${esc(part.value, "#|&")}"`
                        return partsStr
                    }, "")
                } else if(t.type == "structure"){
                    str += this.getStructureString(t).slice(1,-1)
                } else if(t.type == "meet"){
                    str += `[${t.meet.attr1}${t.meet.equals1}"${esc(t.meet.value1, "#[]")}"]`
                        + `[${t.meet.attr2}${t.meet.equals2}"${esc(t.meet.value2, "#[]")}"]`
                        + `${t.meet.left} ${t.meet.right}`
                } else if(t.type == "thesaurus"){
                    str += `~${t.thesaurus.corpusFlag}${t.thesaurus.count}"${esc(t.thesaurus.lemma, "#")}${t.thesaurus.lpos}"`
                } else if(t.type == "wordsketch"){
                    str += `"${esc(t.wordsketch.headword, "#")}",`
                        + `"${esc(t.wordsketch.relation, "#")}",`
                        + `"${esc(t.wordsketch.collocation, "#")}")`
                }

                t.optional && (str += "?")
                t.repeat && (str += `${t.repeat.min || ""},${t.repeat.max || ""}`)
            }, this)

            let condStr = this.getConditionStr().replace(/ |\(|\)/g, "")
            if(condStr){
                str += "#g" + condStr.substr(1) // remove first &
            }

            return str
        }

        parse(str){
            if(!str){
                return {
                    tokens: [],
                    condition: {
                        parts: []
                    }
                }
            }
            let unesc = window.unescapeCharacters
            let tokens = []
            let condition = {
                parts: []
            }
            let obj, tmp, tmp2 = null
            let idx = 0
            let parts = window.tokenize(str, "\\", "#")
            if(parts[parts.length - 1].substr(0, 1) == "g"){
                let condStr = parts.pop().substr(1) // remove g
                //f1.lemma>1000&1.tag=2.lempos
                condStr.split("&").forEach(partStr => {
                    let part = {}
                    if(partStr.charAt(0) == "f"){
                        part.type = "frequency"
                        part.gtlt = partStr.indexOf("<") != -1 ? "<" : ">"
                        tmp = partStr.split(".")
                        part.label = tmp[0]
                        tmp = tmp[1].split(/[\<\>]+/)
                        part.attr = tmp[0]
                        part.frequency = tmp[1]

                    } else {
                        part.type = "attribute"
                        part.equals = partStr.indexOf("!=") != -1 ? "!=" : "="
                        tmp = partStr.split(/[\!\=/|\=]+/)
                        tmp2 = tmp[0].split(".")
                        part.label1 = tmp2[0]
                        part.attr1 = tmp2[1]
                        tmp2 = tmp[1].split(".")
                        part.label2 = tmp2[0]
                        part.attr2 = tmp2[1]

                    }
                    condition.parts.push(part)
                }, this)
            }
            parts.forEach(part => {
                let type = _getTokenType(part.substr(0, 1))
                part = part.slice(1) // remove type
                let token = this._getDefaultToken(type)
                // parse optional
                if(part.slice(-1) == "?"){
                    token.optional = true
                    part = part.slice(0, -1) // remove optional
                }
                // parse label
                idx = part.indexOf(":")
                if(idx != -1 && idx <= 2){
                    token.label = part.substr(0, idx) * 1
                    part = part.substr(idx + 1) // remove label
                }
                // parse repeat
                let i = part.length - 1
                for(; i >= 1 && (part.charAt(i - 1) == "," || !isNaN(part.charAt(i - 1))); i--){}
                if(i < part.length - 1 && part.lastIndexOf(",") >= i){ // meet ends with number too
                    i = Math.max(0, i)
                    tmp = part.substr(i).split(",")
                    part = part.slice(0, i)
                    token.repeat = {}
                    if(tmp[0]){
                        token.repeat.min = tmp[0]
                    }
                    if(tmp[1]){
                        token.repeat.max = tmp[1]
                    }
                }
                if(type == "standard"){
                    token.parts = []
                    idx = 0
                    window.tokenize(part, "\\", ["|", "&"]).forEach(p => {
                        obj = this._parseAttrValue(p)
                        token.parts.push({
                            attr: obj.attr,
                            value: unesc(obj.value, "#|&"),
                            andOr: idx > 0 ? part.charAt(idx) : "&",
                            equals: obj.equals
                        })
                        idx += p.length + (idx > 0 ? 1 : 0)
                    }, this)

                } else if(type == "structure"){
                    if(part.charAt(0) == "/"){
                        token.structure.range = "endOf"
                        token.name = part.slice(1)
                    } else if(part.charAt(part.length - 1) == "/"){
                        token.structure.range = "whole"
                        token.structure.name = part.slice(0, -1)
                    } else{
                        token.structure.range = "startOf"
                        token.structure.name = part
                    }

                } else if(type == "meet"){
                    // [lemma!="apple"][tag="RB.?"]-1 1
                    token.meet = {}
                    idx = part.lastIndexOf(" ")
                    token.meet.right = part.slice(idx) * 1
                    part = part.slice(0, idx)
                    idx = part.lastIndexOf("]")
                    token.meet.left = part.slice(part.lastIndexOf("]") + 1) * 1

                    let meetParts = window.tokenize(part, "\\", "]")
                    obj = this._parseAttrValue(meetParts[0])
                    token.meet.attr1 = obj.attr
                    token.meet.equals1 = obj.equals
                    token.meet.value1 = unesc(obj.value, "#[]")
                    obj = this._parseAttrValue(meetParts[1])
                    token.meet.attr2= obj.attr
                    token.meet.equals2 = obj.equals
                    token.meet.value2 = unesc(obj.value, "#[]")
                } else if(type == "thesaurus" && !window.config.NO_SKE){
                    // t2:~~54\"some-n\"
                    if(part.charAt(1) == "~"){
                        token.thesaurus.corpusFlag = "~"
                        part = part.slice(2)
                    } else {
                        part = part.slice(1)
                    }
                    let count = part.split("\"")[0]
                    token.thesaurus.count = count === "" ? "" : count * 1
                    let lempos = part.slice(count.length).slice(1, -1) // remove count and quotes
                    token.thesaurus.lpos = lempos.slice(-2)
                    token.thesaurus.lemma = unesc(lempos.slice(0, -2), "#")

                } else if(type == "wordsketch" && !window.config.NO_SKE){
                    tmp = part.split(",")
                    token.wordsketch = {
                        headword: unesc(tmp[0].slice(1, -1), "#"), //remove quotes
                        relation: unesc(tmp[1].slice(1, -1), "#"),
                        collocation:unesc(tmp[2].slice(1, -1), "#")
                    }
                }
                tokens.push(token)
            })

            return {
                tokens: tokens,
                condition: condition
            }
        }

        getRepeatString(token){
            let str = ""
            let repeat = token.repeat
            if(repeat){
                if(repeat.min == repeat.max){
                    str = repeat.min
                } else{
                    if(isDef(repeat.min)){
                        str = repeat.min
                    }
                    str += ","
                    if(isDef(repeat.max)){
                        str += repeat.max
                    }
                }
                str = "{" + str + "}"
            }
            return str
        }

        getStandardTokenString(token){
            return token.parts.reduce((partsStr, part, idx) => {
                if(idx > 0){
                    partsStr += ` ${part.andOr} `
                }
                partsStr += `${part.attr}${part.equals}"${part.value}"`
                return partsStr
            }, "")
        }

        getStructureString(token){
            let s = token.structure
            return "<"
                + (s.range == "endOf" ? "/" : "")
                + s.name
                + (s.range == "whole" ? "/" : "")
                + ">"
        }

        getWordsketchString(token){
            let ws = token.wordsketch
            return `ws("${ws.headword}", `
                + `"${ws.relation}", `
                + `"${ws.collocation}")`
        }

        getThesaurusString(token){
            let thes = token.thesaurus
            return `~${thes.corpusFlag}${thes.count}"${thes.lemma}${thes.lpos}"`
        }

        getMeetString(token){
            let meet = token.meet
            return "(meet "
                + `[${meet.attr1}${meet.equals1}"${meet.value1}"] `
                + `[${meet.attr2}${meet.equals2}"${meet.value2}"] `
                + `${-meet.left} ${meet.right}`
                + ")"
        }

        getConditionStr(){
            return this.condition.parts.reduce((str, condition) => {
                str += " & "
                if(condition.type == "attribute"){
                    str += `${condition.label1}.${condition.attr1}${condition.equals}${condition.label2}.${condition.attr2}`
                } else if(condition.type == "frequency"){
                    str += `f(${condition.label}.${condition.attr})${condition.gtlt}${condition.frequency}`
                }
                return str
            }, "")
        }



        _isFieldMissing(obj, keys){
            return keys.some(key => {
                return obj[key] === ""
            })
        }

        _isPrevTokenNormal(idx){
            return this.tokens[idx - 1] && this._isTokenNormal(this.tokens[idx - 1])
        }

        _isNextTokenNormal(idx){
            return this.tokens[idx + 1] && this._isTokenNormal(this.tokens[idx + 1])
        }

        _isTokenNormal(token){
            return ["standard", "any", "distance", "structure", "meet", "thesaurus", "wordsketch"].includes(token.type)
        }

        _hasGroups(){
            return this.tokens.findIndex(t => {
                return t.type == "or"
            }) != -1
        }

        _getDefaultToken(type){
            let defaultToken = {
                type: type,
                edit: false,
                warning: ""
            }
            let links = window.config.links
            if(type == "standard"){
                defaultToken.parts = [{
                    attr: "lemma",
                    value: "",
                    andOr: "&",
                    equals: "=",
                    icase: false
                }]
                defaultToken.helpUrl = links.cb_basics
            } else if(type == "structure"){
                defaultToken.structure = {
                    name: null,
                    range: "whole",
                }
                defaultToken.helpUrl = links.cb_structures
            } else if(type == "wordsketch"){
                defaultToken.wordsketch = {
                    headword: "",
                    relation: "",
                    collocation: ""
                }
                defaultToken.helpUrl = links.cb_wordsketch
            } else if(type == "distance"){
                defaultToken.repeat = {
                    min: 1,
                    max: 2
                }
                defaultToken.helpUrl = links.cb_basics
            } else if(type == "meet"){
                defaultToken.meet = {
                    attr1: "lemma",
                    equals1: "=",
                    value1: "",
                    attr2: "lemma",
                    equals2: "=",
                    value2: "",
                    left: 5,
                    right: 5
                }
                defaultToken.helpUrl = links.cb_meet
            } else if(type == "thesaurus"){
                defaultToken.thesaurus = {
                    lemma: "",
                    lpos: "",
                    count: "",
                    corpusFlag: ""
                }
                defaultToken.helpUrl = links.cb_thesaurus
            } else if(type == "or" || type == "within" || type == "containing"){
                defaultToken.helpUrl = links.cb_within_containing
            } else if(type == "any"){
                defaultToken.helpUrl = links.cb_basics
            }
            return defaultToken
        }

        _getTokenType = (code) => {
            for(let t in this.tokenTypeMap){
                if(this.tokenTypeMap[t] == code){
                    return t
                }
            }
        }

        _parseAttrValue(str){
            // parse attr_name="value" or attr_name!="value"
            let ret = {}
            str = str.trim()
            if(str.charAt(0) == "["){
                str = str.slice(1)
            }
            if(str.charAt(str.length -1) == "]"){
                str = str.slice(0, -1)
            }
            let tmp = str.split(/!=|=/)
            return {
                attr: tmp[0],
                value: tmp[1].slice(1, -1),
                equals: str.indexOf("!=") != -1 ? "!=" : "="
            }
        }
    </script>
</cql-builder>
