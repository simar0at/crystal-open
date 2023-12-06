<concordance-frequency-tab-basic class="frequency-tab-basic">
    <div class="card-content">
        <div class="center-table">
            <div class="columns">
                <span class="inline-block leftColumn">
                    <frequency-links-column column={_getColumnDef("frq.left1", -1)}></frequency-links-column>
                    <frequency-links-column column={_getColumnDef("kwic", 0)}></frequency-links-column>
                    <frequency-links-column column={_getColumnDef("frq.right1", 1)}></frequency-links-column>
                </span>

                <div class="frequency-quick-list">
                    <frequency-links-column column={textTypeColumn}></frequency-links-column>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./frequency-tab-basic.scss")
        require("./frequency-links-column.tag")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("feature-child")

        this.hasLemma = !!AppStore.getAttributeByName("lemma")
        this.hasTags = !!AppStore.getAttributeByName("tag")
        this.hasPos = !!AppStore.getAttributeByName("pos")

        _getColumnDef(colLabelId, ctx){
            let colSuffix = {"-1": "left", "0": "kwic", "1": "right"}[ctx]
            return {
                labelId: colLabelId,
                links: [{
                    id: "words_" + colSuffix,
                    labelId: "wordForms",
                    tooltip: "t_id:conc_r_freq_words_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "word", "basic")
                }, {
                    id: "pos_" + colSuffix,
                    labelId: "pos",
                    tooltip: "t_id:conc_r_freq_pos_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "pos", "basic"),
                    disabled: !this.hasPos
                }, {
                    id: "tags_" + colSuffix,
                    labelId: "frq.tags",
                    tooltip: "t_id:conc_r_freq_tags_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "tag", "basic"),
                    disabled: !this.hasTags
                }, {
                    id: "lemmas_" + colSuffix,
                    labelId: "lemmaP",
                    tooltip: "t_id:conc_r_freq_lemmas_" + colSuffix,
                    href: this.store.f_getContextLink(ctx, "kwic", "lemma", "basic"),
                    disabled: !this.hasLemma
                }]
            }
        }
        let textTypes = this.store.getAllTextTypes()
        let links = textTypes.length ? [{
                id: "textTypes",
                labelId: "textTypes",
                tooltip: "t_id:conc_r_freq_text_types",
                href: this.store.f_getLink({f_texttypes: textTypes}, "texttypes", "basic")
            }] : []

        let lineDetails = this.store.f_getLineDetailsTextTypes()
        links.push({
            id: "lineDetails",
            labelId: "lineDetails",
            tooltip: "t_id:conc_r_freq_line_details",
            disabled: !lineDetails.length,
            href: this.store.f_getLink({f_texttypes: lineDetails}, "texttypes", "basic")
        })

        this.textTypeColumn = {
            labelId: "frq.morePresets",
            links: links
        }
    </script>
</concordance-frequency-tab-basic>
