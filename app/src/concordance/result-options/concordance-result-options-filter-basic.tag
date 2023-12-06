<concordance-result-options-filter-basic>
    <div class="center-align">
        <span class="inlineBlock">
            <ui-input placeholder={_("abc")}
                    value=""
                    name="keyword"
                    on-change={onChange}
                    on-submit={onSubmit}
                    on-key-up={onKeyUp}
                    label-id="basicFilter"
                    tooltip="t_id:conc_r_filter_b_search"
                    style="max-width: 200px;">
            </ui-input>
        </span>
        <div class="center-align">
            <a  id="btnBasicGoFilter"
                    class="waves-effect waves-light btn"
                    disabled={isSearchDisabled}
                    onclick={onSubmit}>{_("go")}</a>
        </div>
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
            let filter = {
                pnfilter: "p",
                inclkwic: true,
                iquery: this.keyword,
                filfpos: "-1:s",
                filtpos: "1:s",
                desc: this.keyword,
                queryselector: "iqueryrow"
            }
            this.store.filter(filter)
        }

        this.on("mount", () => {
            this.isSearchDisabled = !this.keyword
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        })
    </script>
</concordance-result-options-filter-basic>
