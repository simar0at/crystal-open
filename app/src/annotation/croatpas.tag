<croatpas class="card croatpas">
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
            <input name="aspect" value={label.aspect} oninput={oninput}
                    list="aspects" />
            <label class="active">{_("an.aspect")}</label>
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
                    <div each={qdm, idx2 in slot.qdm} if={slot.slot != "verb"}>
                        <input value={slot.qdm[idx2]} name="qdm"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
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
                    <div each={st, idx2 in slot.semtype} if={slot.slot != "verb"}>
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
                        <a href="javascript:void(0);" if={idx2 > 0 && idx2 == slot.semtype.length-1}
                                onclick={del_subslot.bind(this, idx, idx2, "semtype")}>
                            <i class="material-icons tiny">delete</i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.lexset")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={ls, idx2 in slot.lexset} if={slot.slot != "verb"}>
                        <input value={slot.lexset[idx2]} name="lexset"
                                style="width: 75%; margin-bottom: 0;"
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
                <th>{_("an.role")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={ro, idx2 in slot.role} if={slot.slot != "verb"}>
                        <input value={slot.role[idx2]} name="role"
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
                <th>{_("an.feature")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div each={fe, idx2 in slot.feature} if={slot.slot != "verb"}
                            style="margin-bottom: .2rem;" >
                        <input value={slot.feature[idx2]} name="feature"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
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
                <th>{_("an.case")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div style="margin-bottom: .2rem;" if={slot.slot != "verb"}
                            if={slot.slot == "object" || slot.slot == "ind_compl" || slot.slot == "subject" || slot.slot == "adverbial" || slot.slot == "predic_compl"}>
                        <input value={slot.case} name="case"
                                list="cases"
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} oninput={oninput} />
                    </div>
                </td>
            </tr>
            <tr>
                <th>{_("an.type")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "prep_compl" || slot.slot == "adverbial"}
                            each={item, idx2 in slot.type} if={slot.slot != "verb"}>
                        <select name="type" class="browser-default"
                                oninput={ontypeselect.bind(this, idx, idx2, slot.slot)}>
                            <option value=""
                                    selected={adverbial_types.indexOf(item) < -1}>{_("an.type")}</option>
                            <option each={at in adverbial_types} value={pt}
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
                    <div if={slot.slot == "prep_compl" || slot.slot == "adverbial" || slot.slot == "ind_compl"}
                            each={p, idx2 in slot.prep} if={slot.slot != "verb"}
                            style="margin-bottom: .2rem;">
                        <input name="prep" oninput={oninput} value={slot.prep[idx2]}
                                list={preps}
                                style="width: 75%; margin-bottom: 0;"
                                data-idx={idx} />
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
                <th>{_("an.kaoza")}</th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot == "predic_compl"}>
                        <input name="kaoza" value={slot.kaoza} oninput={oninput}
                                data-idx={idx} list="kaozas" />
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
                                list="fins" />
                    </div>
                </td>
            </tr>
            <tr>
                <th></th>
                <td each={slot, idx in label.slots} class={palette[slot.slot]}>
                    <div if={slot.slot != "verb"}>
                        <ui-checkbox name="opt" label={_("an.opt")}
                                on-change={onoptcheck} checked={slot.optional}>
                        </ui-checkbox>
                        <ui-checkbox name="or" label={_("an.or")}
                                on-change={onorcheck} checked={slot.or}>
                        </ui-checkbox>
                        <ui-checkbox if={slot.slot == "clausals"}
                                name="inf" label={_("an.inf")}
                                on-change={oninfcheck} checked={slot.inf}
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
    <datalist id="aspects">
        <option each={a in aspects} value={a} />
    </datalist>
    <datalist id="cases">
        <option each={c in cases} value={c} />
    </datalist>
    <datalist id="preps">
        <option value="" />
        <option value="do" />
        <option value="iz" />
        <option value="između" />
        <option value="kroz" />
        <option value="na" />
        <option value="o" />
        <option value="od" />
        <option value="oko" />
        <option value="osim" />
        <option value="po" />
        <option value="preko" />
        <option value="prema" />
        <option value="protiv" />
        <option value="s" />
        <option value="sa" />
        <option value="tijekom" />
        <option value="u" />
        <option value="za" />
        <option value="zero" />
    </datalist>
    <datalist id="fins">
        <option value="" />
        <option value="da" />
        <option value="što" />
        <option value="kako" />
        <option value="kako bi" />
        <option value="gdje" />
        <option value="li" />
        <option value="neka" />
        <option value="kao" />
        <option value="kao da" />
        <option value="nego" />
        <option value="nego da" />
        <option value="koliko" />
        <option value="tko" />
        <option value="jer" />
        <option value="koji" />
        <option value="zašto" />
        <option value="kad" />
        <option value="dok" />
        <option value="čim" />
        <option value="prije" />
        <option value="ako" />
        <option value="kada" />
        <option value="da li" />
        <option value="čiji" />
        <option value="zero" />
    </datalist>
    <datalist id="kaozas">
        <option value="" />
        <option value="kao" />
        <option value="za" />
    </datalist>

    <style>
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
        this.aspects = ["perfective", "imperfective", "biaspectual"]
        this.cases = ["nominative", "genitive", "dative", "accusative", "vocative", "locative", "instrumental"]

        this.edited = false
        this.annot_tag = this.root.parentNode._tag
        this.data = this.opts.data
        this.label = this.opts.data.data
        this.query = this.opts.query
        this.slots = [
            {slot: "subject", clr: "red lighten-4", str: "Subject"},
            {slot: "verb", clr: "grey lighten-2", str: "Verb"},
            {slot: "ind_compl", clr: "blue lighten-4", str: "Indirect complement"},
            {slot: "object", clr: "green lighten-4", str: "Object"},
            {slot: "predic_compl", clr: "teal lighten-4", str: "Predicative complement"},
            {slot: "adverbial", clr: "grey lighten-4", str: "Adverbial"},
            {slot: "clausals", clr: "deep-purple lighten-4", str: "Clausals"}
        ]
        this.palette = {}
        for (let i=0; i<this.slots.length; i++) {
            this.palette[this.slots[i].slot] = this.slots[i].clr
        }
        this.template = {
            "aspect": "",
            "domain": "",
            "register": "",
            "semantic_class": "",
            "framenet": "",
            "subord_conj": "",
            "verb": "",
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
                    slot: "subject",
                    or: false,
                    fin: "",
                    inf: false,
                    case: "",
                    kaoza: "",
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
                    slot: "object",
                    or: false,
                    fin: "",
                    inf: false,
                    case: "",
                    kaoza: "",
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

        oncomment(e) {
            this.data.attr.comment = e.target.value
            this.edited = true
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
            if (name == "sense" && e.target.value == " ") {
                this.label.sense = this.opts.data.pattern_string[1]
            }
            else if (name == "qdm" || name == "semtype" || name == "lexset"
                    || name == "feature" || name == "role" || name =="prep"
                    || name =="prep_part") {
                this.label.slots[idx][name][idx2] = e.target.value
            }
            else if (idx === null) {
                /* TODO: never checkbox? */
                if (e.target.type == "checkbox") {
                    this.label[name] = e.target.checked
                }
                else {
                    this.label[name] = e.target.value
                }
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

        onsuboptcheck(idx, idx2, param, value, name, e) {
            this.label.slots[idx][param][idx2] = e.target.checked
            this.edited = true
            this.update()
        }

        oninfcheck(value, name, e) {
            this.label.slots[e.item.idx].inf = e.target.checked
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
            $(e.currentTarget).next('label').addClass('active')
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
            $(e.currentTarget).next('label').addClass('active')
            let idx = e.item.idx
            var x = this.label.slots[idx]
            this.label.slots[idx] = this.label.slots[idx-1]
            this.label.slots[idx-1] = x
            this.edited = true
            this.update()
        }

        del_slot(e) {
            $(e.currentTarget).next('label').addClass('active')
            this.label.slots.splice(e.item.idx, 1)
            this.edited = true
            this.update()
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
            this.update()
        }

        del_subslot(idx, idx2, name, e) {
            this.label.slots[idx][name].splice(idx2, 1)
            if (name == "semtype" && this.label.slots[idx].slot == "prep_compl"
                    && idx2 < this.label.slots[idx].type.length) {
                this.label.slots[idx].type.splice(idx2, 1)
            }
            this.edited = true
            this.update()
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
</croatpas>
