<tpas class="card tpas">
    <div class="row">
        <div class="col s6">
            <b>{opts.data.label}</b>
        </div>
        <div class="col s6 text-right">
            <a class="btn btn-flat" href="javascript:void(0);"
                    if={opts.data.label.indexOf('.') < 0}
                    title={_("an.addSubLabel")} onclick={add_metonym}>
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
            <input name="sense" value={label.sense} oninput={oninput} />
            <label class="active">{_("an.senseDesc")}</label>
        </div>
    </div>
    <div class="row">
        <div class="col s2 input-field">
            <input value={label.verb_form} name="verb_form" oninput={oninput} />
            <label class="verb active">{_("an.verbform")}</label>
        </div>
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
        <div class="col s3">
            <ui-checkbox name="idiom" label={_("an.idiom")}
                    on-change={oncheck} checked={label.idiom}>
            </ui-checkbox>
        </div>
        <div class="col s3">
            <ui-checkbox name="phrasal" label={_("an.phrasal")}
                    on-change={oncheck} checked={label.phrasal}>
            </ui-checkbox>
        </div>
    </div>
    <table class="table">
        <tbody>
            <tr>
                <th style="width: 10rem;">{_("an.slot")}</th>
                <td each={slot, idx in label.slots} class="{palette[slot.slot]}">
                    <select class="browser-default" name="slot"
                            oninput={onslotselect}>
                        <option each={t in slots} value={t.slot}
                                selected={slot.slot == t.slot}>{t.str}</option>
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
                <td each={slot, idx in label.slots} class="{palette[slot.slot]}">
                    <div each={qdm, idx2 in slot.qdm}>
                        <input value={slot.qdm[idx2]} name="qdm"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <span class="snum">{idx2+1}</span>
                        <a href="javascript:void(0);"
                                if={idx2 == slot.qdm.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "qdm")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);"
                                if={idx2 > 0 && idx2 == slot.qdm.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "qdm")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.semtype")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={st, idx2 in slot.semtype}>
                        <input value={slot.semtype[idx2]} name="semtype"
                                list="semtypes"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <span class="snum">{idx2+1}</span>
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
                </td>
            </tr>
            <tr>
                <th>{_("an.lexset")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={ls, idx2 in slot.lexset}>
                        <input value={slot.lexset[idx2]} name="lexset"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <span class="snum">{idx2+1}</span>
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
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={ro, idx2 in slot.role}>
                        <input value={slot.role[idx2]} name="role"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <span class="snum">{idx2+1}</span>
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
                <th>{_("an.feature")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={fe, idx2 in slot.feature}
                            style="margin-bottom: .2rem;" >
                        <input value={slot.feature[idx2]} name="feature"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                        <span class="snum">{idx2+1}</span>
                        <a href="javascript:void(0);"
                                if={idx2 == slot.feature.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "feature")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.feature.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "feature")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.type")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "prep_compl" || slot.slot == "adverbial"}
                            each={item, idx2 in slot.type}>
                        <select name="type" class="browser-default"
                                oninput={ontypeselect.bind(this, idx, idx2, slot.slot)}>
                            <option value=""
                                    selected={adverbial_types.indexOf(item) < -1}>{_("an.type")}</option>
                            <option each={at in adverbial_types} value={at}
                                    selected={item == at}>{at}</option>
                        </select>
                    </div>
                    <div if={slot.slot == "predic_compl"}
                            each={item, idx2 in slot.type}>
                        <select name="type" class="browser-default"
                                oninput={ontypeselect.bind(this, idx, idx2, slot.slot)}>
                            <option value=""
                                    selected={predic_compl_types.indexOf(item) < -1}>{_("an.type")}</option>
                            <option each={pt in predic_compl_types} value={pt}
                                    selected={item == pt}>{pt}</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.preposition")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "prep_compl"}
                            each={p, idx2 in slot.prep}
                            style="margin-bottom: .2rem;">
                        <input name="prep" oninput={oninput} value={slot.prep[idx2]}
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} />
                        <span class="snum">{idx2+1}</span>
                        <a href="javascript:void(0);"
                                if={idx2 == slot.prep.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "prep")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.prep.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "prep")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.prep_part")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "adverbial"}
                            each={p, idx2 in slot.prep_part}
                            style="margin-bottom: .2rem;">
                        <input name="prep_part" oninput={oninput} value={slot.prep_part[idx2]}
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} />
                        <span class="snum">{idx2+1}</span>
                        <a href="javascript:void(0);"
                                if={idx2 == slot.prep_part.length-1}
                                onclick={add_subslot.bind(this, idx, idx2, "prep_part")}>
                            <i class="material-icons tiny">add</i>
                        </a>
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.prep_part.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "prep_part")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.inf")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "clausals"}>
                        <input name="inf" value={slot.inf} oninput={oninput}
                                data-idx={idx}
                                style="margin-bottom: -.5em; height: 1.6rem !important;"
                                list="clausals_infs" />
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.fin")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "clausals"}>
                        <input name="fin" value={slot.fin} oninput={oninput}
                                data-idx={idx}
                                style="margin-bottom: -.5em; height: 1.6rem !important;"
                                list="clausals_fins" />
                    </div>
                </td>
            </tr>
            <tr>
                <th></th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div>
                        <ui-checkbox name="opt" label={_("an.opt")}
                                on-change={onoptcheck} checked={slot.optional}>
                        </ui-checkbox>
                        <ui-checkbox name="or" label={_("an.or")}
                                on-change={onorcheck} checked={slot.or}>
                        </ui-checkbox>
                        <ui-checkbox name="come" label={_("an.come")}
                                if={slot.slot == "predic_compl"}
                                on-change={oncomecheck}
                                checked={Array.isArray(slot.come) ? slot.come.indexOf(true) >= 0 : slot.come}>
                        </ui-checkbox>
                        <ui-checkbox name="quote" label={_("an.quote")}
                                if={slot.slot == "clausals"}
                                on-change={onquotecheck}
                                checked={slot.quote === true}>
                        </ui-checkbox>
                    </div>
                </td>
            </tr>
            <tr>
                <th></th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
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
    <datalist id="clausals_infs">
        <option value="di" />
        <option value="da" />
        <option value="a" />
        <option value="zero" />
    </datalist>
    <datalist id="clausals_fins">
        <option value="che" />
        <option value="come" />
        <option value="perche'" />
        <option value="se" />
    </datalist>

    <style scoped>
        .snum {
            position: relative;
            left: -1em;
            bottom: -.8em;
            font-size: 65%;
            font-weight: bold;
            color: #BBB;
        }
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
        /* TODO: REMOVE? */
        [type="checkbox"] + label {
            padding-left: 1.5em !important;
        }
    </style>

    <script>
        const {AnnotationStore} = require('annotation/annotstore.js')

        this.adverbial_types = this.opts.settings.model.adverbial_types
        this.predic_compl_types = this.opts.settings.model.predic_compl_types
        this.registers = this.opts.settings.model.registers
        this.domains = this.opts.settings.model.domains
        this.roles = this.opts.settings.model.roles
        this.semtypes = this.opts.settings.model.semtypes
        this.edited = false
        this.annot_tag = this.root.parentNode._tag
        this.data = this.opts.data
        this.label = this.opts.data.data
        this.query = this.opts.query
        this.slots = [
            {slot: "subject", clr: "red lighten-4", str: "Subject"},
            /* {slot: "ind_obj", clr: "blue lighten-4", str: "Indirect object"}, */
            {slot: "object", clr: "green lighten-4", str: "Object"},
            {slot: "adverbial", clr: "grey lighten-4", str: "Adverbial"},
            {slot: "prep_compl", clr: "orange lighten-4", str: "Prepositional complement"},
            {slot: "clausals", clr: "deep-purple lighten-4", str: "Clausals"},
            {slot: "predic_compl", clr: "teal lighten-4", str: "Predicative complement"}
        ]
        this.palette = {}
        for (let i=0; i<this.slots.length; i++) {
            this.palette[this.slots[i].slot] = this.slots[i].clr
        }
        this.template = {
            "domain": "",
            "register": "",
            "semantic_class": "",
            "framenet": "",
            "subord_conj": "",
            "verb": "",
            "no_adverb": false,
            "idiom": false,
            "phrasal": false,
            "sense": "",
            "sec_sense": "",
            "slots": [
                {
                    qdm: [""],
                    opt: [false],
                    semtype: ["Human"],
                    lexset: [""],
                    feature: [""],
                    role: [""],
                    prep: [""],
                    type: [""],
                    prep_part: [""],
                    // global
                    come: false,
                    quote: false,
                    slot: "subject",
                    or: false,
                    fin: "",
                    inf: "",
                    optional: false
                },
                {
                    qdm: [""],
                    opt: [false],
                    semtype: ["Human | Institution"],
                    lexset: [""],
                    feature: [""],
                    role: [""],
                    prep: [""],
                    type: [""],
                    prep_part: [""],
                    //global
                    come: false,
                    quote: false,
                    slot: "object",
                    or: false,
                    fin: "",
                    inf: "",
                    optional: false
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
                    this.data.data = JSON.parse(JSON.stringify(AnnotationStore.labels[i].data))
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
            if (name == "sense" && e.target.value == " ") {
                this.label.sense = this.opts.data.pattern_string[1]
            }
            else if (name == "qdm" || name == "semtype" || name == "lexset"
                    || name == "feature" || name == "role" || name =="prep"
                    || name =="prep_part") {
                this.label.slots[idx][name][idx2] = e.target.value
            }
            else if (idx === null) {
                this.label[name] = e.target.value
            }
            else {
                this.label.slots[idx][name] = e.target.value
            }
        }

        ontypeselect(idx, idx2, slot, e) {
            this.label.slots[idx].type[idx2] = e.target.value
            this.edited = true
        }

        onslotselect(e) {
            this.label.slots[e.item.idx].slot = e.target.value
            this.edited = true
        }

        onorcheck(value, name, e) {
            this.label.slots[e.item.idx].or = e.target.checked
            this.edited = true
            this.update()
        }


        onquotecheck(value, name, e) {
            this.label.slots[e.item.idx].quote = e.target.checked
            this.edited = true
            this.update()
        }

        oncomecheck(value, name, e) {
            this.label.slots[e.item.idx].come = e.target.checked
            this.edited = true
            this.update()
        }

        onoptcheck(value, name, e) {
            this.label.slots[e.item.idx].optional = e.target.checked
            this.edited = true
            this.update()
        }

        add_metonym() {
            this.annot_tag.show_all_labels = true
            AnnotationStore.addLabel(this.data.label + ".m")
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
            new_slot.slot = this.unused_slot()
            this.label.slots.push(new_slot)
            this.edited = true
            this.update()
        }

        add_subslot(idx, idx2, name, e) {
            window.focus_after = [idx, name, e.target]
            this.label.slots[idx][name].push("")
            if (name == "semtype" && this.label.slots[idx].slot == "prep_compl"
                    && this.label.slots[idx].type.length < this.label.slots[idx].semtype.length) {
                this.label.slots[idx].type.push("")
            }
            this.edited = true
        }

        del_subslot(idx, idx2, name, e) {
            this.label.slots[idx][name].splice(idx2, 1)
            if (name == "semtype" && this.label.slots[idx].slot == "prep_compl"
                    && idx2 < this.label.slots[idx].type.length) {
                this.label.slots[idx].type.splice(idx2, 1)
            }
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
</tpas>
