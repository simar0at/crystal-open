<concordance-result-options-annot>
    <ui-input size="20" id="annotconc" label-id="annotconcLabel"
            riot-value={annotconc}
            if={!data.annotconc} on-change={onAnnotConcChange}>
    </ui-input>
    <table if={data.annotconc} class="annotDetails">
        <tbody>
            <tr each={label in data.annotLabels}>
                <td><span class="annot">{label.name}</span></td>
                <td><a href="javascript:void(0);" onclick={onPFilter}>P</a></td>
                <td><a href="javascript:void(0);" onclick={onNFilter}>N</a></td>
                <td style="text-align: right;">{label.freq}x</td>
                <td class="labelBar">
                    <div if={label.name != "_"} style="width:{label.ratio}%"></div>
                </td>
            </tr>
        </tbody>
    </table>
    <div if={data.annotconc} class="row">
        <input ref="newlabel" id="annotconc" style="width: 5em;" />
        <a href="javascript:void(0);" class="btn"
                onclick={addLabel}>{_("cc.addLabel")}</a>
    </div>
    <div if={data.annotconc} class="row">
        <a href="javascript:void(0);" class="btn"
                onclick={onSortLabels}>{_("annotSortLabels")}</a>
    </div>

    <div class="center-align">
        <a href="javascript:void(0);" class="btn" if={!data.annotconc}
                onclick={onInitAnnot}>{_("startAnnotate")}</a>
        <a href="javascript:void(0);" class="btn" if={data.annotconc}
                onclick={onFinishAnnot}>{_("endAnnotate")}</a>
        <a href={window.config.URL_SKEMA + "?corpname=" + corpname}
                target="_blank" class="btn" if={agroup}>{_("skema")}</a>
    </div>

    <style scoped>
        td > span.annot {
            white-space: nowrap;
        }
        .annot {
            padding: 2px 3px;
            font-size: 75%;
            font-weight: bold;
            background-color: limegreen;
        }
        .annotDetails {
            width: 100%;
            margin-bottom: 2em;
            background-color: rgba(255,255,255,0.8);
        }
        .annotDetails td.labelBar {
            width: 100%;
        }
        .annotDetails td.labelBar div {
            height: .5em;
            background-color: #004B69;
        }
        .annotDetails td {
            padding: 4px 8px;
        }
    </style>

    <script>
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")
        const {Auth} = require("core/Auth.js")

        this.data = ConcordanceStore.data
        this.agroup = Auth.getAnnotationGroup()
        this.corpname = ConcordanceStore.corpus.corpname
        this.annotconc = this.data.keyword + this.data.lpos

        addLabel(evt) {
            ConcordanceStore.addLabel(this.refs.newlabel.value)
            this.refs.newlabel.value = ""
        }

        onSortLabels(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: "annotSortLabels",
                query: {q: "g" + this.data.annotconc}
            })
        }

        onPFilter(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: "Positive filter: " + evt.item.label.name,
                query: {q: "L" + this.data.annotconc + " -" + evt.item.label.id}
            })

        }

        onNFilter(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: "Negative filter: " + evt.item.label.name,
                query: {q: "L" + this.data.annotconc + " " + evt.item.label.id}
            })
        }

        renameLabel(evt) {
            ConcordanceStore.renameLabel(this.data.annotconc, evt.item.item.n)
        }

        onAnnotConcChange(annotconc) {
            this.annotconc = annotconc
        }

        onInitAnnot() {
            ConcordanceStore.initAnnotation(this.annotconc)
        }
        
        onFinishAnnot() {
            ConcordanceStore.closeAnnotation(this.data.annotconc)
        }

        this.on('mount', function () {
            Dispatcher.on("ANNOTATION_LABELS_UPDATED", this.update)
        })

        this.on('unmount', function () {
            Dispatcher.off("ANNOTATION_LABELS_UPDATED", this.update)
            let inp = document.getElementById('annotconc')
            inp && inp.focus()
        })
    </script>
</concordance-result-options-annot>
