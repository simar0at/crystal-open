<parconcordance-result-options-filter-basic class="parconcordance-result-options-filter-basic">
    <div class="center-align">
        <span class="inlineBlock">
            <ui-input placeholder={_("abc")}
                    value=""
                    name="keyword"
                    on-change={onChange}
                    on-submit={onSubmit}
                    on-key-up={onKeyUp}
                    style="max-width: 200px;">
            </ui-input>
        </span>
        <div class="center-align" id="ctb_searchButton">
            <a class="waves-effect waves-light btn" disabled={isSearchDisabled}
                onclick={onSubmit}>{_("go")}</a>
        </div>
        <floating-button disabled={isSearchDisabled} onclick={onSubmit}
                refnodeid="ctb_searchButton" periodic="1">
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
            let corpname = this.parent.parent.opts.opts.corpname
            if (this.parent.parent.opts.opts.has_no_kwic) {
                query.within = 1
                query.maincorp = corpname
            }
            this.store.addOperationAndSearch({
                name: "filter",
                corpname: corpname,
                arg: this.keyword,
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
