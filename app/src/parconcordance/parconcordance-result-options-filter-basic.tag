<parconcordance-result-options-filter-basic class="parconcordance-result-options-filter-basic">
    <div class="center-align">
        <span class="inline-block">
            <ui-input placeholder={_("abc")}
                    value=""
                    name="keyword"
                    on-change={onChange}
                    on-submit={onSubmit}
                    on-key-up={onKeyUp}
                    style="max-width: 200px;">
            </ui-input>
        </span>
        <div class="primaryButtons" id="ctb_searchButton">
            <a class="btn btn-primary" disabled={isSearchDisabled}
                onclick={onSubmit}>{_("go")}</a>
        </div>
        <floating-button disabled={isSearchDisabled}
                on-click={onSubmit}
                refnodeid="ctb_searchButton"
                periodic="1">
        </floating-button>
    </div>

    <script>
        this.mixin("feature-child")

        onKeyUp(evt) {
            this.isSearchDisabled = !evt.target.value
            this.update()
        }

        onChange(value) {
            this.keyword = value
        }

        onSubmit() {
            let query = {
                pnfilter: "p",
                inclkwic: true,
                iquery: this.keyword,
                filfpos: "-1:s",
                filtpos: "1:s"
            }
            let corpname = this.parent.parent.opts.corpname
            if (this.parent.parent.opts.has_no_kwic) {
                query.within = 1
                query.maincorp = corpname
            }
            this.store.addOperationAndSearch({
                name: "filter",
                corpname: corpname,
                arg: "(" + this.store.getAlignedLangName(corpname) + ") " + this.keyword,
                query: query
            })
        }

        this.on("mount", () => {
            this.isSearchDisabled = !this.keyword
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        })
    </script>
</parconcordance-result-options-filter-basic>
