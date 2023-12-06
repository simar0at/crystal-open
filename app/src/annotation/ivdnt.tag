<ivdnt class="card ivdnt">
    <div class="row">
        <div class="col s6">
            <b>{opts.data.label}</b>
        </div>
        <div class="col s6 text-right">
            <a class="btn btn-flat" title={_("an.goToWordSketch")}
                    href={annot_tag && annot_tag.query2wsurl(opts.query)}>
                <i class="ske-icons skeico_word_sketch"></i>
            </a>
            <a class="btn btn-flat" title={_("an.annotateLabel")}
                    href={annot_tag && annot_tag.label_annot_url()}>
                <i class="ske-icons skeico_concordance"></i>
            </a>
            <a class="btn btn-flat" onclick={close}>
                <i class="material-icons">close</i>
            </a>
        </div>
    </div>
    <div class="row no-bottom-margin">
        <div class="col s2 relative">
            <label class="active ab" for="type">{_("an.labelType")}</label>
            <select class="browser-default" name="type" onchange={onptypeselect}>
                <option each={t in label_types}
                        selected={t == label.type}>{t}</option>
            </select>
        </div>
        <div class="col s2 input-field">
            <input type="text" name"attitude" id="attitude" oninput={oninput}
                    onblur={autosave} value={label.attitude} list="attitudes" />
            <label for="attitude" class="active">{_("an.attitude")}</label>
        </div>
        <div class="col s2 input-field">
            <input type="text" name="style" id="style" oninput={oninput}
                    onblur={autosave} value={label.style} list="styles" />
            <label for="style" class="active">{_("an.style")}</label>
        </div>
        <div class="col s2 input-field">
            <input type="text" name="domain" id="domain" oninput={oninput}
                    onblur={autosave} value={label.domain} list="domains" />
            <label for="domain" class="active">{_("an.domain")}</label>
        </div>
        <div class="col s2 relative">
            <label class="active ab" for="variant">{_("an.variant")}</label>
            <select class="browser-default" name="variant"
                    onchange={onvtypeselect} id="variant">
                <option value="" selected={!label.variant}></option>
                <option each={v in variants} value={v.value}
                        selected={v.value == label.variant}>{v.text}</option>
            </select>
        </div>
        <div class="col s2 relative">
            <label class="active ab" for="auxiliary">{_("an.auxiliary")}</label>
            <select class="browser-default" name="auxiliary"
                    onchange={onatypeselect} id="auxiliary">
                <option value="" selected={!label.auxiliary}></option>
                <option each={a in auxiliaries} value={a}
                        selected={a == label.auxiliary}>{a}</option>
            </select>
        </div>
    </div>
    <table class="table">
        <tbody>
            <tr>
                <th></th>
                <td class="pointer slotid {idx == active_slot ? "active" : ""}"
                        onclick={selectSlot}
                        each={slot, idx in label.slots}>{idx+1}</td>
            </tr>
            <tr>
                <th style="width: 10rem;">{_("an.function")}</th>
                <td class="{palette[slot.type]}" each={slot, idx in label.slots}
                        onclick={selectSlot}>
                    <select class="browser-default"
                            name="type" onchange={ontypeselect}>
                        <option each={t in types} value={t.type}
                                selected={slot.type == t.type}>{t.str}</option>
                    </select>
                </td>
                <td if={label.slots.length < 21}>
                    <a href="javascript:void(0);" onclick={add_slot}>
                        <i class="material-icons">add</i>
                    </a>
                </td>
            </tr>
            <tr>
                <th>{_("an.semtype")}</th>
                <td each={slot, idx in label.slots} class="{palette[slot.type]}"
                        onclick={selectSlot}>
                    <div each={st, idx2 in slot.semtype}
                            if={slot.type != "aux" && slot.type != "head" && slot.type != "se" && slot.type != "svp"}>
                        <input type="text" value={slot.semtype[idx2]}
                                name="semtype"
                                onkeyup={move_subslot.bind(this, slot.semtype, idx2, slot.semtype.length)}
                                list="semtypes"
                                style="width: 75%; margin-bottom: 0;"
                                onblur={autosave}
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.semtype.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "semtype")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.semtype.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "semtype")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.fixedElement")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}
                        onclick={selectSlot}>
                    <div if={slot.type != "head"}>
                        <input type="text" style="width: 50%;" data-idx={idx}
                                value={slot.fixed} name="fixed"
                                onblur={autosave}
                                oninput={oninput} />
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.dummy")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}
                        onclick={selectSlot}>
                    <div each={du, idx2 in slot.dummies}>
                        <input type="text" value={du} name="dummies"
                                onkeyup={move_subslot.bind(this, slot.dummies, idx2, slot.dummies.length)}
                                list="vc_dummies"
                                style="width: 75%; margin-bottom: 0;"
                                onblur={autosave}
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.dummies.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "dummies")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);"
                                if={idx2 > 0 && idx2 == slot.dummies.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "dummies")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.lexset")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}
                        onclick={selectSlot}>
                    <div each={ls, idx2 in slot.lexset}
                            style="margin-bottom: .2rem;">
                        <input type="text" value={slot.lexset[idx2]}
                                name="lexset"
                                onkeyup={move_subslot.bind(this, slot.lexset, idx2, slot.lexset.length)}
                                style="width: 75%; margin-bottom: 0;"
                                onblur={autosave}
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.lexset.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "lexset")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.lexset.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "lexset")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("attributes")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}
                        onclick={selectSlot}>
                    <div if={slot.type != "head"}>
                        <ui-checkbox name="opt_{idx}" label={_("an.opt")}
                                on-change={onoptcheck} checked={slot.opt}>
                        </ui-checkbox>
                        <ui-checkbox name="or_{idx}" label={_("an.or")}
                                if={idx < label.slots.length-1 || slot.or}
                                on-change={onorcheck} checked={slot.or}>
                        </ui-checkbox>
                    </div>
                </td>
            </tr>
            <tr>
                <th></th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}
                        onclick={selectSlot}>
                    <a href="javascript:void(0);" class="btn-flat"
                            onclick={move_left} if={idx}>
                        <i class="material-icons">arrow_back</i>
                    </a>
                    <a href="javascript:void(0);" class="btn-flat"
                            onclick={del_slot}>
                        <i class="material-icons">delete</i>
                    </a>
                    <a href="javascript:void(0);" class="btn-flat"
                            style="float: right;"
                            onclick={move_right} if={idx<label.slots.length-1}>
                        <i class="material-icons">arrow_forward</i>
                    </a>
                </td>
            </tr>
        </tbody>
    </table>
    <div class="row">
        <div class="col s12 m6">
            <label class="active" for="implicature">{_("an.implicature")}</label>
            <input type="text" name="implicature" id="implicature"
                    oninput={oninput}
                    onblur={autosave} value={label.implicature} />
        </div>
        <div class="col s12 m6">
            <label class="active" for="meaning">{_("an.meaning")}</label>
            <input type="text" name="meaning" id="meaning" oninput={oninput}
                    onblur={autosave} value={label.meaning} />
        </div>
        <div class="col s12 m6">
            <label class="active" for="synonym">{_("an.synonym")}</label>
            <input type="text" name="synonym" id="synonym" oninput={oninput}
                    onblur={autosave} value={label.synonym} />
        </div>
    </div>
    <div class="row" each={ex, idx in (label.examples && label.examples.length) ? label.examples : [1]}>
        <div class="col s4">
            <label class="active" for="example_text_{idx}">{_("an.example")} {idx+1}
                <span class={blue-text: ex.toknum > -1}
                        title={opts.settings.corpname + ":" + ex.toknum}
                        if={ex.toknum && ex.toknum > -1}>{_("an.linked")}</span></label>
                <span class="exattrs red-text" if={ex.domain || ex.style || ex.attitude}>
                    {((ex.domain || "") + " " + (ex.style || "") + " " + (ex.attitude || "")).trim(" ")}
                </span>
            <input type="text" name="example.text" oninput={oninput}
                    onblur={autosave}
                    id="example_text_{idx}" value={ex.text} data-idx={idx} />
        </div>
        <div class="col s2">
            <label class="active"
                    for="example_lexitem_{idx}">{_("an.lexitem")} {idx+1}</label>
            <input type="text" name="example.lexitem" oninput={oninput}
                    onblur={autosave}
                    id="example_lexitem_{idx}" value={ex.lexitem}
                    data-idx={idx} />
        </div>
        <div class="col s2">
            <label class="active">{_("an.slot")}</label>
            <select class="browser-default" onchange={onetypeselect}>
                <option selected={ex.slotid < 0}></option>
                <option each={slot, idx2 in label.slots}
                        value={idx2}
                        selected={ex.slotid == idx2}>{slot.type} ({idx2+1})</option>
            </select>
        </div>
        <div class="col s4">
            <a href="javascript:void(0);" onclick={add_example}
                    class="btn btn-flat" style="position: relative; top: 1.2rem;">
                <i class="material-icons">add</i>
            </a>
            <a href="javascript:void(0);" if={label.examples && label.examples.length}
                    onclick={del_example.bind(this, idx)} class="btn btn-flat"
                    style="position: relative; top: 1.2rem;">
                <i class="material-icons">delete</i>
            </a>
            <a href="javascript:void(0);" onclick={show_pragma_menu}
                    class="btn btn-flat"
                    style="position: relative; top: 1.2em;">{_("an.pragmatics")}</a>
        </div>
        <div class="col s12 relative py-4 pr-3 pl-16" if={show_pragma == idx}>
            <div class="col s2 input-field">
                <input name="example.attitude" id="example.attitude" oninput={oninput}
                        data-idx={idx}
                        onblur={autosave} value={ex.attitude} list="attitudes" />
                <label for="example.attitude" class="active">{_("an.attitude")}</label>
            </div>
            <div class="col s2 input-field">
                <input name="example.style" id="example.style" oninput={oninput}
                        data-idx={idx}
                        onblur={autosave} value={ex.style} list="styles" />
                <label for="example.style" class="active">{_("an.style")}</label>
            </div>
            <div class="col s2 input-field">
                <input type="text" name="example.domain" id="example.domain"
                        oninput={oninput} data-idx={idx}
                        onblur={autosave} value={ex.domain} list="domains" />
                <label for="example.domain" class="active">{_("an.domain")}</label>
            </div>
            <div class="col s2">
                <label class="active ab" for="example.variant">{_("an.variant")}</label>
                <select class="browser-default" name="example.variant"
                        data-idx={idx}
                        onchange={onevtypeselect} id="example.variant">
                    <option value="" selected={!ex.variant}></option>
                    <option each={v in variants} value={v.value}
                            selected={v.value == ex.variant}>{v.text}</option>
                </select>
            </div>
        </div>
        <input type="hidden" name="example.toknum" value={ex.toknum}
                data-idx={idx} />
    </div>
    <div class="row">
        <div class="col s12">
            <label class="active" for="comment">{_("an.comment")}</label>
            <input type="text" name="comment" id="comment" oninput={oninput}
                    onblur={autosave} value={label.comment} />
        </div>
    </div>
    <div class="row no-bottom-margin fs85">
        <div class="col s12">
            <p>{_("created")}:<em>{opts.data.created}</em>
            ({opts.data.creator}),
            {_("an.lastEdited")} <em>{opts.data.edited}</em>
            ({opts.data.editor})</em></p>
        </div>
    </div>

    <datalist id="semtypes">
        <option each={st in semtypes} value={st} />
    </datalist>
    <datalist id="attitudes">
        <option each={att in attitudes} value={att} />
    </datalist>
    <datalist id="styles">
        <option each={sty in styles} value={sty} />
    </datalist>
    <datalist id="domains">
        <option each={dom in domains} value={dom} />
    </datalist>
    <datalist id="vc_dummies">
        <option each={vcd in vc_dummies} value={vcd} />
    <datalist>

    <script>
        const {AnnotationStore} = require('annotation/annotstore.js')

        this.edited = false
        this.annot_tag = this.root.parentNode._tag
        this.styles = this.opts.settings.model.styles
        this.attitudes = this.opts.settings.model.attitudes
        this.auxiliaries = ["hebben", "zijn"]
        this.domains = this.opts.settings.model.domains
        this.medium = this.opts.settings.model.medium
        this.semtypes = this.opts.settings.model.semtypes
        this.data = this.opts.data
        this.label = this.opts.data.data
        this.query = this.opts.query
        this.label_types = ["normal", "idiom", "proverb", "formula"]
        this.types = [
            {type: "subject",      clr: "red lighten-4",         str: "Subject"},
            {type: "aux",          clr: "indigo lighten-3",      str: "Auxiliary"},
            {type: "head",         clr: "deep-purple lighten-4", str: "Head"},
            {type: "object",       clr: "light-blue lighten-4",  str: "Object"},
            {type: "indir_obj",    clr: "green lighten-4",       str: "Indirect object"},
            {type: "pc",           clr: "yellow lighten-4",      str: "Prepositional object"},
            {type: "ppc",          clr: "purple lighten-4",      str: "Preliminary prepositional object"},
            {type: "se",           clr: "blue lighten-4",        str: "Reflexive zich"},
            {type: "predc",        clr: "teal lighten-4",        str: "Predicative complement"},
            {type: "me",           clr: "lime lighten-4",        str: "Measure complement"},
            {type: "ld",           clr: "orange lighten-4",      str: "Location_direction complement"},
            {type: "svp",          clr: "deep-orange lighten-4", str: "Separated verbal part"},
            {type: "vc_dat_of",    clr: "amber lighten-4",       str: "VC dat of"},
            {type: "vc",           clr: "grey lighten-2",        str: "Verbal complement"},
            {type: "svp_part mwe", clr: "brown lighten-4",       str: "Separated part mwe"},
            {type: "predm",        clr: "grey lighten-4",        str: "Predicative modifier"},
            {type: "mod",          clr: "grey lighten-3",        str: "Adverbial"},
            {type: "psubject",     clr: "",                      str: "Preliminary subject"},
            {type: "poctbject",    clr: "",                      str: "Preliminary object"},
            {type: "nn",           clr: "",                      str: "Not specified"}
        ]
        this.vc_dummies = ["vc_inf", "vc_ti", "vc_oti", "vc_om te inf",
                "vc_ahi", "vc_dat", "vc_of", "vc_qw", "vc_als-zin",
                "vc_alsof-zin", "vc_rhd", "quote"
        ]
        this.active_slot = -1
        AnnotationStore.slotid = -1
        this.palette = {}
        for (var i=0; i<this.types.length; i++) {
            this.palette[this.types[i].type] = this.types[i].clr
        }
        this.variants = [
            {"text": "(vooral) in Nederland", "value": "N"},
            {"text": "(vooral) in België", "value": "B"}
        ]
        this.template = {
            "variant": "",
            "auxiliary": "",
            "type": "",
            "head": "",
            "attitude": "",
            "style": "",
            "domain": "",
            "slots": [
                {
                    "type": "subject",
                    "opt": false,
                    "dummies": ["iemand"],
                    "semtype": ["Human", "Institution"],
                    "lexset": [""],
                    "or": false,
                    "fixed": ""
                },
                {
                    "type": "head",
                    "opt": false,
                    "dummies": [""],
                    "semtype": [""],
                    "lexset": [""],
                    "or": false,
                    "fixed": ""
                }
            ],
            "comment": "",
            "meaning": "",
            "implicature": "",
            "examples": [
                {
                    "text": "",
                    "toknum": -1,
                    "lexitem": "",
                    "slotid": -1,
                    "type": "",
                    "variant": "",
                    "style": "",
                    "domain": "",
                    "attitude": ""
                }
            ],
            "synonym": ""
        }

        autosave() {
            this.edited && this.save()
        }

        save() {
            AnnotationStore.saveLabel(this.data)
        }

        // initialize label structure with template
        if (!this.label.hasOwnProperty('slots')) {
            this.data.data = Object.assign(JSON.parse(JSON.stringify(this.template)), this.data.data)
            this.label = this.data.data
            this.save()
        }

        onatypeselect(e) {
            this.label.auxiliary = e.target.value
            this.save()
        }

        onevtypeselect(e) {
            this.label.examples[e.item.idx].variant = e.target.value
            this.save()
        }

        onvtypeselect(e) {
            this.label.variant = e.target.value
            this.save()
        }

        onptypeselect(e) {
            this.label.type = e.target.value
            this.save()
        }

        ontypeselect(e) {
            var fun = e.target.value
            var slot = this.label.slots[e.item.idx]
            if (["head", "aux"].includes(fun)) {
                slot.lexset = [""]
            }
            if(["aux", "head", "se", "svp"].includes(fun)){
                slot.dummies = [""]
            }
            slot.type = fun
            this.save()
        }

        onetypeselect(e) {
            if (e.target.value !== "") {
                this.label.examples[e.item.idx].type = this.label.slots[parseInt(e.target.value)].type
                this.label.examples[e.item.idx].slotid = parseInt(e.target.value)
            }
            else {
                this.label.examples[e.item.idx].type = ""
                this.label.examples[e.item.idx].slotid = -1
            }
            AnnotationStore.sortExamples(this.label.examples)
            this.save()
        }

        onorcheck(value, name, e) {
            this.label.slots[e.item.idx].or = value
            this.save()
        }

        onoptcheck(value, name, e) {
            this.label.slots[e.item.idx].opt = value
            this.save()
        }

        selectSlot(e) {
            this.active_slot = this.active_slot == e.item.idx ? -1 : e.item.idx
            AnnotationStore.slotid = this.active_slot
        }

        show_pragma_menu(e) {
            if (!this.show_pragma || this.show_pragma == -1) {
                this.show_pragma = e.item.idx
            }
            else {
                this.show_pragma = -1
            }
        }

        oninput(e) {
            this.edited = true
            let idx = e.target.dataset.idx ? e.target.dataset.idx : null
            let idx2 = e.item ? e.item.idx2 : null
            let name = e.target.name
            if (name == "implicature" && e.target.value == " ") {
                this.label.implicature = this.opts.data.pattern_string_flat
            }
            else if (name.indexOf("example") == 0) {
                if (!this.label.examples || !this.label.examples.length) {
                    this.label.examples = [{}]
                }
                let exitem = e.target.name.split('.')[1]
                this.label.examples[idx][exitem] = e.target.value
            }
            else {
                if (name == "semtype" || name == "lexset" || name == "dummies") {
                    this.label.slots[idx][name][idx2] = e.target.value
                }
                else if (idx === null) {
                    this.label[name] = e.target.value
                }
                else {
                    this.label.slots[idx][name] = e.target.value
                }
            }
        }

        close() {
            this.annot_tag.close_label()
        }

        unused_slot() {
            let used_slot_types = new Array()
            for (let i=0; i<this.label.slots.length; i++) {
                used_slot_types.push(this.label.slots[i].type)
            }
            for (let i=0; i<this.types.length; i++) {
                if (used_slot_types.indexOf(this.types[i].type) < 0) {
                    return this.types[i].type
                }
            }
            return ""
        }

        move_right(e) {
            let idx = e.item.idx
            var x = this.label.slots[idx]
            this.label.slots[idx] = this.label.slots[idx+1]
            this.label.slots[idx+1] = x
            for (let i=0; i<this.label.examples.length; i++) {
                if (this.label.examples[i].slotid) {
                    if (this.label.examples[i].slotid == idx) {
                        this.label.examples[i].slotid = idx+1
                    }
                    else if (this.label.examples[i].slotid == idx+1) {
                        this.label.examples[i].slotid = idx
                    }
                }
            }
            if (idx+1 == this.label.slots.length-1) {
                this.label.slots[idx+1].or = false
            }
            AnnotationStore.sortExamples(this.label.examples)
            this.save()
        }

        move_subslot(slot, i, l, e) {
            if (e.altKey) {
                if (e.keyCode == 38) { // up
                    if (i > 0) {
                        let b = slot[i-1]
                        slot[i-1] = slot[i]
                        slot[i] = b
                        this.save()
                    }
                }
                else if (e.keyCode == 40) { // down
                    if (i < l-1) {
                        let b = slot[i+1]
                        slot[i+1] = slot[i]
                        slot[i] = b
                        this.save()
                    }
                }
            }
        }

        move_left(e) {
            let idx = e.item.idx
            var x = this.label.slots[idx]
            this.label.slots[idx] = this.label.slots[idx-1]
            this.label.slots[idx-1] = x
            for (let i=0; i<this.label.examples.length; i++) {
                if (this.label.examples[i].slotid) {
                    if (this.label.examples[i].slotid == idx) {
                        this.label.examples[i].slotid = idx-1
                    }
                    else if (this.label.examples[i].slotid == idx-1) {
                        this.label.examples[i].slotid = idx
                    }
                }
            }
            AnnotationStore.sortExamples(this.label.examples)
            this.save()
        }

        del_slot(e) {
            for (let i=0; i<this.label.examples.length; i++) {
                if (this.label.examples[i].slotid && this.label.examples[i].slotid == e.item.idx) {
                    this.label.examples[i].slotid = -1
                    this.label.examples[i].type = ""
                }
            }
            this.label.slots.splice(e.item.idx, 1)
            this.save()
        }

        del_example(idx, e) {
            this.label.examples.splice(idx, 1)
            this.save()
        }

        add_example(e) {
            if (!this.label.examples) this.label.examples = []
            let new_ex = JSON.parse(JSON.stringify(this.template.examples[0]))
            this.label.examples.push(new_ex)
            AnnotationStore.sortExamples(this.label.examples)
        }

        add_slot(e) {
            let new_slot = JSON.parse(JSON.stringify(this.template.slots[0]))
            new_slot.type = this.unused_slot()
            if (new_slot.type != "subject") {
                new_slot.dummies = [""]
                new_slot.semtype = [""]
            }
            this.label.slots.push(new_slot)
        }

        add_subslot(idx, idx2, name, e) {
            window.focus_after = [idx, name, e.target]
            this.label.slots[idx][name].push("")
        }

        del_subslot(idx, idx2, name, e) {
            this.label.slots[idx][name].splice(idx2, 1)
            this.save()
        }

        labelSaved(labeldata) {
            this.annot_tag.updatePatStr(labeldata)
            this.edited = false
            this.update()
        }

        labelSaveFailed() {
            this.edited = false
            // notification
            this.update()
        }

        this.on("mount", function() {
            AnnotationStore.on("ANNOTATION_LABEL_SAVED", this.labelSaved)
            AnnotationStore.on("ANNOTATION_LABEL_SAVE_FAILED", this.labelSaveFailed)
        })

        this.on("unmount", function () {
            AnnotationStore.off("ANNOTATION_LABEL_SAVED", this.labelSaved)
            AnnotationStore.off("ANNOTATION_LABEL_SAVE_FAILED", this.labelSaveFailed)
        })

        this.on('updated', function () {
            // focus the newly added input box
            if (window.focus_after) {
                let tri = 0
                if (window.focus_after[1] == "semtype") tri = 2
                if (window.focus_after[1] == "dummies") tri = 4
                if (window.focus_after[1] == "lexset")  tri = 5
                let tdi = window.focus_after[0] + 2
                let el = $(`table.table tr:nth-child(${tri}) td:nth-child(${tdi}) div`)
                el.last().find('input').focus()
                window.focus_after = null
            }
        })
    </script>
</ivdnt>
