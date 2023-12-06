<concordance-lemma-menu>
    <a class="btn btn-floating btn-flat" onclick={onOpenMenuClick}>
        <i class="material-icons menuIcon">more_horiz</i>
    </a>
    <interfeature-menu ref="interfeatureMenu"
            links={interFeatureMenuLinks}
            get-feature-link-params={getFeatureLinkParams}></interfeature-menu>

    <script>
        this.mixin("feature-child")

        this.interFeatureMenuLinks = [{
            name: "wordsketch",
            feature: "wordsketch",
            label: this.opts.data.keyword
        }, {
            name: "thesaurus",
            feature: "thesaurus",
            label: this.opts.data.keyword
        }]

        onOpenMenuClick(evt){
            this.refs.interfeatureMenu.onOpenMenuButtonClick(evt)
        }

        getFeatureLinkParams(feature){
            // not using data.lpos - because in parconcordance there are data under data.formValue key
            let lpos = this.opts.data.lpos
            let lemma = this.opts.data.keyword
            if(this.opts.data.queryselector == "lempos"){
                let idx = lemma.lastIndexOf("-")
                if(idx != -1){
                    lpos = lemma.substr(idx)
                    lemma = lemma.substr(0, idx)
                }
            }
            // annotation of a conc. of a verb (lempos/lemma)
            if (feature == "wordsketch" && this.data.annotconc) {
                lemma = this.data.annotconc
                if (lemma.slice(-2) == "-v") {
                    lemma = lemma.slice(0, -2)
                }
                lpos = "-v"
                return {
                    lemma: lemma,
                    lpos: lpos,
                    tab: 'advanced',
                    annotconc: this.data.annotconc
                }
            }

            if(feature == "wordsketch"){
                return {
                    tab: 'advanced',
                    lemma: lemma,
                    usesubcorp: this.data.usesubcorp,
                    tts: this.data.tts,
                    lpos: lpos
                }
            } else if(feature == "thesaurus"){
                return {
                    tab: 'advanced',
                    lemma: lemma,
                    lpos: lpos
                }
            }
        }
    </script>
</concordance-lemma-menu>
