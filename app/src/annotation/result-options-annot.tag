<result-options-annot class="result-options-annot">
    <div>
        {_("annotDesc")}
    </div>
    <ui-input size="20" id="annotconc" label-id="an.annotconcLabel"
            riot-value={annotconc}
            if={!data.annotconc} on-change={onAnnotConcChange}>
    </ui-input>
    <p id="amt" if={data.annotconc}>{_("an.annotationModeText")}</p>
    <div class="row" if={data.annotconc}>
        <div class="col s12 l9">
            <table class="annotDetails">
                <thead>
                    <tr>
                        <th>{_("an.annotLabel")}</th>
                        <th colspan="2" if={opts.source == "conc"}>{_("an.annotFilter")}</th>
                        <th>{_("an.annotFrequency")}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <tr each={label in labels} if={label.id}>
                        <td class="annotLabelCell">
                            <span class="annot {sub: label.label.indexOf('.') > 0}">{label.label}</span>
                        </td>
                        <td if={opts.source == "conc"}>
                            <button disabled={(label.freq <= 0) || disabledFilter}
                                      data-tooltip={_("an.posFilter")}
                                      class="tooltipped btn btn-small btn-floating filterButton"
                                      onclick={onPFilter}>
                                  <i class="material-icons">visibility</i>
                            </button>
                        </td>
                        <td if={opts.source == "conc"}>
                            <button disabled={(label.freq == data.total) || disabledFilter}
                                      data-tooltip={_("an.negFilter")}
                                      class="tooltipped btn btn-small btn-floating filterButton"
                                      onclick={onNFilter}>
                                  <i class="material-icons">visibility_off</i>
                            </button>
                        </td>
                        <td class="right-align">{label.freq}</td>
                        <td class="labelBar">
                            <div if={label.name != "_"} class="background-color-blue-800" style="width:{label.ratio}%"></div>
                        </td>
                    </tr>
                    <tr if={opts.source == "conc" && disabledFilter}>
                        <td></td>
                        <td colspan="2">
                              <a href="javascript:void(0);" class="link clearFilter" onclick={onClearFilterClick}>{_("clearFilter")}</a>
                        </td>
                        <td colspan="2"></td>
                    </tr>
                </tbody>
            </table>
            <div class="center-align">
                <button class="btn btn-floating tooltipped"
                        onclick={addLabel}
                        data-tooltip={_("an.addLabel")}>
                    <i class="material-icons">add</i>
                </button>
            </div>
        </div>
        <div class="col s12 l3 btn-col">
            <a href="#annotation?corpname={window.stores.app.data.corpus.corpname}&annotconc={this.data.annotconc}"
                    class="btn clearfix">{_("an.manageAnnotations")}</a><br>
            <button class="btn clearfix"
                    onclick={onSortLabels}
                    if={opts.source == "conc"}>
                {_("an.annotSortLabels")}
            </button><br>
            <button class="btn btn-primary clearfix" onclick={onFinishAnnot}>{_("an.endAnnotate")}</button>
        </div>
    </div>

    <div if={!data.annotconc} class="row center-align">
        <a href="javascript:void(0);" class="btn"
                onclick={onInitAnnot}>{_("an.startAnnotate")}</a>
    </div>

    <script>
        this.mixin("tooltip-mixin")
        const {ConcordanceStore} = require("concordance/ConcordanceStore.js")
        const {AnnotationStore} = require('annotation/annotstore.js')

        require("./result-options-annot.scss")
        require('annotation/annotation.scss')

        this.data = {}
        this.corpname = ""
        this.annotconc = ""
        this.labels = []
        this.disabledFilter = false

        initData() {
            if (this.opts.source == "conc"){
                this.data = ConcordanceStore.data
                this.corpname = ConcordanceStore.corpus.corpname
                this.annotconc = this.data.keyword + this.data.lpos
                if (this.data.operations_annotconc.find(op => op.filter == true)){
                    this.disabledFilter = true
                }
            }
            this.labels = AnnotationStore.labels
        }

        addLabel(evt) {
            AnnotationStore.addLabelModal()
        }

        onClearFilterClick() {
            this.data.operations_annotconc = []
            ConcordanceStore.searchAndAddToHistory()
        }

        onSortLabels(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: "an.annotSortLabels",
                query: {q: "g" + this.data.annotconc}
            })
        }

        onPFilter(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: _("an.posFilter"),
                arg: evt.item.label.label,
                query: {q: "L" + this.data.annotconc + " -" + evt.item.label.id},
                filter: true
            })
        }

        onNFilter(evt) {
            ConcordanceStore.addOperationAndSearch({
                name: _("an.negFilter"),
                arg: evt.item.label.label,
                query: {q: "L" + this.data.annotconc + " " + evt.item.label.id},
                filter: true
            })
        }

        renameLabel(evt) {
            AnnotationStore.renameLabel(this.data.annotconc, evt.item.item.n)
        }

        onAnnotConcChange(annotconc) {
            this.annotconc = annotconc
        }

        onInitAnnot() {
            ConcordanceStore.initAnnotation(this.annotconc)
        }

        onFinishAnnot() {
            this.opts.source == "conc" && ConcordanceStore.closeAnnotation()
        }

        updateLabels() {
            this.labels = AnnotationStore.labels
            this.update()
        }

        updateLabelFreq() {
            AnnotationStore.getAnnotLabels()
            this.update()
        }

        this.on('mount', function () {
            this.initData()
            this.update()
            AnnotationStore.on("ANNOTATION_LABELS_UPDATED", this.updateLabels)
            AnnotationStore.on("ANNOTATION_SUCCESSFUL", this.updateLabelFreq)
        })

        this.on('unmount', function () {
            AnnotationStore.off("ANNOTATION_LABELS_UPDATED", this.updateLabels)
            AnnotationStore.off("ANNOTATION_SUCCESSFUL", this.updateLabelFreq)
            let inp = document.getElementById('annotconc')
            inp && inp.focus()
        })
    </script>
</result-options-annot>
