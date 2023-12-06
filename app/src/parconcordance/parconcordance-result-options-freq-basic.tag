<parconcordance-result-options-freq-basic class="parconcordance-result-options-freq">
    <div class="card-content">
        <div class="row">
            <span class="inlineBlock leftColumn">
                <frequency-links-column column={_getColumnDef("frq.left1", -1)}></frequency-links-column>
                <frequency-links-column column={_getColumnDef("kwic", 0)}></frequency-links-column>
                <frequency-links-column column={_getColumnDef("frq.right1", 1)}></frequency-links-column>
            </span>
            <div class="frequency-quick-list" if={textTypeColumn}>
                <frequency-links-column column={textTypeColumn}></frequency-links-column>
            </div>
        </div>
    </div>

    <script>
        require("./parconcordance-result-options-freq.scss")
        require("concordance/frequency/frequency-links-column.tag")
        const {AppStore} = require('core/AppStore.js')

        this.mixin('feature-child')

        this.has_tags = !!AppStore.getAttributeByName("tag")
        this.has_lemmas = !!AppStore.getAttributeByName("lemma")

        _getColumnDef(colLabelId, ctx){
            let corpname = this.parent.parent.parent.parent.opts.corpname
            let colSuffix = {"-1": "left", "0": "kwic", "1": "right"}[ctx]
            return {
                labelId: colLabelId,
                links: [{
                    id: "words_" + colSuffix,
                    labelId: "wordForms",
                    tooltip: "t_id:conc_r_freq_words_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "word", corpname, "basic")
                }, {
                    id: "tags_" + colSuffix,
                    labelId: "frq.tags",
                    tooltip: "t_id:conc_r_freq_tags_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "tag",  corpname, "basic"),
                    disabled: !this.has_tags
                }, {
                    id: "lemmas_" + colSuffix,
                    labelId: "lemmaP",
                    tooltip: "t_id:conc_r_freq_lemmas_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "lemma",  corpname, "basic"),
                    disabled: !this.has_lemmas
                }]
            }
        }

        let alignedCorpname = this.parent.parent.parent.parent.opts.corpname
        let textTypes = this.store.getAllTextTypes()
        let links = textTypes.length ? [{
                id: "textTypes",
                labelId: "textTypes",
                tooltip: "t_id:conc_r_freq_text_types",
                href: this.store.f_getLink({
                    f_texttypes: textTypes,
                    alignedCorpname: alignedCorpname
                }, "texttypes", "basic")
            }] : []
        let lineDetails = this.store.f_getLineDetailsTextTypes()
        links.push({
            id: "lineDetails",
            labelId: "lineDetails",
            tooltip: "t_id:conc_r_freq_line_details",
            disabled: !lineDetails.length,
            href: this.store.f_getLink({
                f_texttypes: lineDetails,
                alignedCorpname: alignedCorpname
            }, "texttypes", "basic")
        })
        this.textTypeColumn = {
            labelId: "frq.morePresets",
            links: links
        }
    </script>
</parconcordance-result-options-freq-basic>
