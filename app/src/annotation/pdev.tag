<pdev class="card pdev">
    <div class="row">
        <div class="col s6">
            <b>{opts.data.label}</b>
        </div>
        <div class="col s6 text-right">
            <a class="btn btn-flat" href="javascript:void(0);"
                    if={opts.data.label.indexOf('.') < 0}
                    title={_("an.addSubLabel")} onclick={add_sublabel}>
                <i class="material-icons">add</i>
            </a>
            <a class="btn {btn-flat: !edited, disabled: !edited, pulse: edited}"
                    onclick={save}>
                <i class="material-icons">save</i>
            </a>
            <a class="btn btn-flat" onclick={close}>
                <i class="material-icons">close</i>
            </a>
        </div>
    </div>
    <div class="row">
        <div class="col s12 input-field">
            <input name="implicature" value={label.implicature} oninput={oninput} />
            <label class="active">{_("an.primImpl")}</label>
        </div>
    </div>
    <div class="row">
        <div class="col s2 input-field">
            <input value={label.register} list="registers" name="register"
                    oninput={oninput} />
            <label class="active">{_("an.register")}</label>
        </div>
        <div class="col s2 input-field">
            <input value={label.domain} list="domains" name="domain"
                    oninput={oninput} />
            <label class="active">{_("an.domain")}</label>
        </div>
        <div class="col s2">
            <ui-checkbox name="idiom" label={_("an.idiom")}
                    on-change={oncheck} checked={label.idiom}>
            </ui-checkbox>
        </div>
        <div class="col s2">
            <ui-checkbox name="phrasal" label={_("an.phrasal")}
                    on-change={oncheck} checked={label.phrasal}>
            </ui-checkbox>
        </div>
        <div class="col s2 input-field">
            <label class="active">Semantic class</label>
            <input value={label.semantic_class} name="semantic_class"
                    list="semclasses" oninput={oninput} />
        </div>
        <div class="col s2 input-field">
            <label class="active">FrameNet</label>
            <input value={label.framenet} name="framenet" list="framenets"
                    oninput={oninput} />
        </div>
    </div>
    <table class="table">
        <tbody>
            <tr>
                <th style="width: 10rem;">{_("an.slot")}</th>
                <td each={slot, idx in label.slots} class="{palette[slot.type]}">
                    <select class="browser-default" name="slot"
                            oninput={onslotselect}>
                        <option each={t in slots} value={t.type}
                                selected={slot.type == t.type}>{t.str}</option>
                    </select>
                </td>
                <td if={label.slots.length < 10}>
                    <a href="javascript:void(0);" onclick={add_slot}>
                        <i class="material-icons">add</i>
                    </a>
                </td>
            </tr>
            <tr>
                <th>{_("an.qdm")}</th>
                <td each={slot, idx in label.slots} class="{palette[slot.type]}">
                    <div each={det_quant, idx2 in slot.det_quant}>
                        <input value={det_quant} name="det_quant"
                                style="width: 50%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.det_quant.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "det_quant")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);"
                                if={idx2 > 0 && idx2 == slot.det_quant.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "det_quant")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.prep_part")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div if={slot.type == "adverbial"} style="margin-bottom: .2rem;">
                        <input name="advl_head" oninput={oninput} value={slot.advl_head}
                                data-idx={idx}
                                style="width: 75%; margin-bottom: 0;" />
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.semtype")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div each={st, idx2 in slot.semtype} if={slot.type != "head"}>
                        <input value={slot.semtype[idx2]} name="semtype"
                                list="semtypes"
                                style="width: 55%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <ui-checkbox name="subopt_{idx}_{idx2}" label="O"
                                on-change={onsuboptcheck.bind(this, idx, idx2, "opt")}
                                checked={slot.opt[idx2]}>
                        </ui-checkbox>
                        <a href="javascript:void(0);"
                                if={idx2 == slot.semtype.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "semtype")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);"
                                if={idx2 > 0 && idx2 == slot.semtype.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "semtype")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                    <div if={slot.type == "head"}>
                        <label class="active">Verb form</label>
                        <input value={slot.head} data-idx={idx} name="head"
                                oninput={oninput} />
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.lexset")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div each={ls, idx2 in slot.lexset}>
                        <input value={slot.lexset[idx2]} name="lexset"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.lexset.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "lexset")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);"
                                if={idx2 > 0 && idx2 == slot.lexset.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "lexset")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.role")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div each={ro, idx2 in slot.role}>
                        <input value={slot.role[idx2]} name="role"
                                list="roles"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <a href="javascript:void(0);"
                                if={idx2 == slot.role.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "role")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.role.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "role")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.type")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div if={slot.type == "prep_compl" || slot.type == "adverbial"}>
                        <select name="type" class="browser-default"
                                oninput={ontypeselect.bind(this, idx)}>
                            <option value=""
                                    selected={adverbial_types.indexOf(slot.advl_func) < -1}>{_("an.type")}</option>
                            <option each={at in adverbial_types} value={at}
                                    selected={slot.advl_func == at}>{at}</option>
                        </select>
                    </div>
                    <div if={slot.type == "complement"}>
                        <select name="compl_type" class="browser-default"
                                oninput={onctypeselect.bind(this, idx)}>
                            <option value=""
                                    selected={slot.compl_type == ""}>Type</option>
                            <option value="object"
                                    selected={slot.compl_type == "object"}>object</option>
                            <option value="subject"
                                    selected={slot.compl_type == "subject"}>subject</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.attributes")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
                    <div>
                        <virtual each={ct in ["cl_to", "cl_quote", "cl_that", "cl_ing", "cl_wh"]}
                                if={slot.type == "object" || slot.type == "adverbial" || slot.type == "clausal"}>
                            <ui-checkbox name={ct} label={clmap[ct]}
                                    on-change={onatcheck.bind(this, idx, ct)}
                                    checked={slot[ct]}>
                            </ui-checkbox>
                        </virtual>
                        <ui-checkbox name="opt" label={_("an.opt")}
                                if={slot.type != "head"}
                                on-change={onoptcheck} checked={slot.optional}>
                        </ui-checkbox>
                        <ui-checkbox name="or" label={_("an.or")}
                                if={idx < label.slots.length-1 || slot.or}
                                on-change={onorcheck} checked={slot.or}>
                        </ui-checkbox>
                        <ui-checkbox name="compl_as" label={_("an.as")}
                                if={slot.type == "complement"}
                                on-change={onascheck} checked={slot.come}>
                        </ui-checkbox>
                    </div>
                </td>
            </tr>
            <tr>
                <th></th>
                <td each={slot, idx in label.slots} class={palette[slot.type]}>
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
                            onclick={move_right} if={idx < label.slots.length-1}>
                        <i class="material-icons">arrow_forward</i>
                    </a>
                </td>
            </tr>
        </tbody>
    </table>
    <div class="row">
        <div class="col s12" each={secimpl, idx in label.secondary_implicatures}>
            <label class="active" for="secimpl_{idx}">Secondary implicature {idx+1}</label>
            <input type="text" name="secondary_implicature" id="secimpl_{idx}"
                    data-idx={idx} value={secimpl} oninput={onsiinput} onkeydown={addsi} />
        </div>
    </div>
    <div class="row">
        <div class="col s12">
            <label for="comment" class="active">{_("an.comment")}</label>
            <input id="comment" name="comment"
                    value={data.attr && data.attr.comment}
                    oninput={oncomment} />
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

    <datalist id="roles">
        <option each={r in roles} value={r} />
    </datalist>
    <datalist id="semtypes">
        <option each={st in semtypes} value={st} />
    </datalist>
    <datalist id="registers">
        <option each={reg in registers} value={reg} />
    </datalist>
    <datalist id="domains">
        <option each={dom in domains} value={dom} />
    </datalist>
    <datalist id="framenets">
        <option each={fr in framenets} value={fr} />
    </datalist>
    <datalist id="semclasses">
        <option each={sc in semclasses} value={sc} />
    </datalist>

    <style scoped>
        table.table {
            table-layout: fixed;
            margin-bottom: 1rem;
        }
        tbody tr th,
        tbody tr td {
            vertical-align: top;
            border-radius: 0;
        }
        input {
            height: 2.2rem !important;
        }
        /* TODO: remove ? */
        [type="checkbox"] + label {
            padding-left: 1.5em !important;
        }
    </style>

    <script>
        const {AnnotationStore} = require('annotation/annotstore.js')

        this.adverbial_types = this.opts.settings.model.adverbial_types
        this.registers = this.opts.settings.model.registers
        this.domains = this.opts.settings.model.domains
        this.roles = this.opts.settings.model.roles
        this.semtypes = this.opts.settings.model.semtypes
        this.semclasses = this.opts.settings.model.semclasses
        this.framenets = this.opts.settings.model.framenets
        this.clmap = {
            "cl_to": "to+INF",
            "cl_that": "THAT",
            "cl_ing": "ING",
            "cl_quote": "QUOTE",
            "cl_wh": "WH+"
        }
        this.edited = false
        this.annot_tag = this.root.parentNode._tag
        this.data = this.opts.data
        this.label = this.opts.data.data
        this.query = this.opts.query
        this.slots = [
            {type: "subject", clr: "red lighten-4", str: "Subject"},
            {type: "indirect_object", clr: "blue lighten-4", str: "Indirect object"},
            {type: "head", clr: "orange lighten-2", str: "Verb"},
            {type: "object", clr: "green lighten-4", str: "Object"},
            {type: "adverbial", clr: "grey lighten-4", str: "Adverbial"},
            {type: "clausal", clr: "deep-purple lighten-4", str: "Clausal"},
            {type: "clausal_obj", clr: "deep-green lighten-2", str: "Clausal object"},
            {type: "complement", clr: "teal lighten-4", str: "Complement"}
        ]
        this.palette = {}
        for (let i=0; i<this.slots.length; i++) {
            this.palette[this.slots[i].type] = this.slots[i].clr
        }
        this.template = {
            "domain": "",
            "register": "",
            "semantic_class": "",
            "framenet": "",
            "idiom": false,
            "phrasal": false,
            "implicature": "",
            "secondary_implicatures": [""],
            "slots": [
                {
                    'type': "subject",
                    'semtype': ["Human", "Institution"],
                    'optional': false,
                    'role': [""],
                    'lexset': [""],
                    'opt': [false],
                    'advl_head': "",
                    'advl_func': "",
                    'det_quant': [""],
                    'compl_as': false,
                    'cl_to': false,
                    'cl_ing': false,
                    'cl_that': false,
                    'cl_wh': false,
                    'cl_quote': false,
                    'compl_type': "",
                    'head': ""
                },
                {
                    'type': "head",
                    'semtype': [""],
                    'optional': false,
                    'role': [""],
                    'lexset': [""],
                    'opt': [false],
                    'advl_head': "",
                    'advl_func': "",
                    'det_quant': [""],
                    'compl_as': false,
                    'cl_to': false,
                    'cl_ing': false,
                    'cl_that': false,
                    'cl_wh': false,
                    'cl_quote': false,
                    'compl_type': "",
                    'head': "VERB FORM"
                }
            ]
        }

        save() {
            AnnotationStore.saveLabel(this.data)
        }

        if (!this.label.hasOwnProperty('slots')) {
            let sub = false
            for (let i=0; i<AnnotationStore.labels.length; i++) {
                if (this.data.label.split('.')[0] == AnnotationStore.labels[i].label && this.data.label.indexOf('.') >= 0) {
                    sub = true
                    this.data.data = JSON.parse(JSON.stringify(labels[i].data))
                    this.label = this.data.data
                    break
                }
            }
            if (!sub) {
                this.data.data = JSON.parse(JSON.stringify(this.template))
                this.label = this.data.data
            }
            this.save()
        }

        oncomment(e) {
            this.data.attr.comment = e.target.value
            this.edited = true
            this.update()
        }

        addsi(e) {
            if (e.keyCode == 13) {
                this.label.secondary_implicatures.push("")
            }
        }

        onsiinput(e) {
            let idx = e.target.dataset.idx
            let v = e.target.value
            if (v.length == 0) {
                this.label.secondary_implicatures.splice(idx, 1)
            }
            else {
                this.label.secondary_implicatures[idx] = v
            }
            this.edited = true
        }

        onatcheck(idx, cl, value, name, e) {
            this.edited = true
            this.label.slots[idx][cl] = value
            this.update()
        }

        oncheck(value, name, e) {
            this.label[name] = value
            this.edited = true
            this.update()
        }

        oninput(e) {
            this.edited = true
            let idx = e.target.dataset.idx ? e.target.dataset.idx : null
            let idx2 = e.item ? e.item.idx2 : null
            let name = e.target.name
            if (name == "implicature" && e.target.value == " ") {
                let lbs = this.root.parentNode._tag.tags.labels.labels
                let lbi = this.root.parentNode._tag.tags.labels.opened_label
                this.label.implicature = lbs[lbi].pattern_string_flat
            }
            else if (name == "det_quant" || name == "semtype" || name == "lexset"
                    || name == "feature" || name == "role") {
                this.label.slots[idx][name][idx2] = e.target.value
            }
            else if (idx === null) {
                this.label[name] = e.target.value
            }
            else if (name.indexOf('cl_') == 0) {
                this.label.slots[idx][name] = e.target.checked
            }
            else {
                this.label.slots[idx][name] = e.target.value
            }
        }

        onctypeselect(idx, e) {
            this.label.slots[idx].compl_type = e.target.value
            this.edited = true
        }

        ontypeselect(idx, e) {
            this.label.slots[idx].advl_func = e.target.value
            this.edited = true
        }

        onslotselect(e) {
            this.label.slots[e.item.idx].type = e.target.value
            this.edited = true
        }

        onascheck(value, name, e) {
            this.label.slots[e.item.idx].compl_as = e.target.checked
            this.edited = true
            this.update()
        }

        onorcheck(value, name, e) {
            this.label.slots[e.item.idx].or = e.target.checked
            this.edited = true
            this.update()
        }

        onsuboptcheck(idx, idx2, param, value, name, e) {
            this.label.slots[idx][param][idx2] = e.target.checked
            this.edited = true
            this.update()
        }

        onoptcheck(value, name, e) {
            this.label.slots[e.item.idx].optional = e.target.checked
            this.edited = true
            this.update()
        }

        add_sublabel() {
            let suffixes = [".a", ".f", ".s"]
            // TODO
            alert("Not yet implemented")
        }

        close() {
            this.annot_tag.close_label()
        }

        unused_slot() {
            let used_slot_types = new Array()
            for (let i=0; i<this.label.slots.length; i++) {
                used_slot_types.push(this.label.slots[i].type)
            }
            for (let i=0; i<this.slots.length; i++) {
                if (used_slot_types.indexOf(this.slots[i].type) < 0) {
                    return this.slots[i].type
                }
            }
            return ""
        }

        move_right(e) {
            let idx = e.item.idx
            var x = this.label.slots[idx]
            this.label.slots[idx] = this.label.slots[idx+1]
            this.label.slots[idx+1] = x
            this.edited = true
            this.update()
        }

        move_subslot(slot, i, l, e) {
            if (e.altKey) {
                if (e.keyCode == 38) { // up
                    if (i > 0) {
                        let b = slot[i-1]
                        slot[i-1] = slot[i]
                        slot[i] = b
                        this.edited = true
                        this.update()
                    }
                }
                else if (e.keyCode == 40) { // down
                    if (i < l-1) {
                        let b = slot[i+1]
                        slot[i+1] = slot[i]
                        this.edited = true
                        slot[i] = b
                        this.update()
                    }
                }
            }
        }

        move_left(e) {
            let idx = e.item.idx
            var x = this.label.slots[idx]
            this.label.slots[idx] = this.label.slots[idx-1]
            this.label.slots[idx-1] = x
            this.edited = true
            this.update()
        }

        del_slot(e) {
            this.label.slots.splice(e.item.idx, 1)
            this.edited = true
        }

        add_slot(e) {
            let new_slot = JSON.parse(JSON.stringify(this.template.slots[0]))
            new_slot.type = this.unused_slot()
            this.label.slots.push(new_slot)
            this.edited = true
        }

        add_subslot(idx, idx2, name, e) {
            window.focus_after = [idx, name, e.target]
            this.label.slots[idx][name].push("")
            if (name == "semtype") {
                this.label.slots[idx].opt.push(false)
            }
            this.edited = true
        }

        del_subslot(idx, idx2, name, e) {
            if (name == "semtype" && this.label.slots[idx].opt.length == this.label.slots[idx].semtype.length) {
                this.label.slots[idx].opt.splice(idx2, 1)
            }
            this.label.slots[idx][name].splice(idx2, 1)
            this.edited = true
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
    </script>
</pdev>
