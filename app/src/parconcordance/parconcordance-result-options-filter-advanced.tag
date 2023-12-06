<parconcordance-result-options-filter-advanced class="parconcordance-result-options-filter-advanced">
    <div if={no_kwic} class="disabledcontextselector">{_("pc.alsegment")}</div>
    <span if={!no_kwic} class="inlineBlock">
        <ui-range if={!no_kwic} id="contextselector"
                label={_("range")}
                riot-value={{
                            from: data.filterFrom,
                            to: data.filterTo
                        }}
                range={rangeOptions}
                on-change={onRangeChange}></ui-range>
                &nbsp;
        <div class="center-align">
            <br>
            <ui-checkbox
                inline=1
                name="inclkwic"
                label-id="cc.exclKwic"
                checked={!data.inclkwic}
                disabled={excludeKwicDisabled}
                on-change={onExclKwickChange}></ui-checkbox>
        </div>
    </span>

    <div class="row">
        <ui-select name="pnfilter"
                value={data.pnfilter}
                inline=1
                on-change={onOptionChange}
                options={[ {label: _("pc.contains"), value: "p"},
                {label: _("pc.notcontains"), value: "n"} ]}>
        </ui-select>
    </div>
    <div class="row">
        <concordance-filter-form
                riot-value={formValue}
                btn-label={_("filter")}
                on-change={onFormChange}
                onsubmit={onSubmit}
                is-displayed={true}
                show-context={false}>
        </concordance-filter-form>
    </div>

    <script>
        require("./parconcordance-result-options-filter-advanced.scss")
        require("concordance/range-select/range-select.tag")
        require("concordance/concordance-filter-form.tag")

        this.mixin("feature-child")

        let list = [-5, -4, -3, -2, -1, "kwic", 1, 2, 3, 4, 5]
        this.rangeOptions = list.map(o => {
            return {
                label: o,
                value: o
            }
        })
        this.excludeKwicDisabled = false

        onRangeChange(value){
            this.data.filterFrom = value.from
            this.data.filterTo = value.to
            let justKwic = value.from == "kwic" && value.to == "kwic"
            let kwicInRange = (value.from == "kwic" || value.from <= -1) && (value.to == "kwic" || value.to >= 1)
            if(justKwic){
                this.data.inclkwic = true
                this.excludeKwicDisabled = true
            } else {
                this.excludeKwicDisabled = !kwicInRange
            }
            this.update()
        }

        onExclKwickChange(checked){
            this.data.inclkwic = !checked
            this.update()
        }

        this.formValue = {}
        this.no_kwic = this.parent.parent.opts.opts.has_no_kwic

        onOptionChange(value, name) {
            this.data[name] = value
        }

        onFormChange(value) {
            this.formValue = value
            if (!this.formValue.default_attr) {
                this.formValue.default_attr = this.store.default_attr
            }
        }

        onSubmit() {
            let corpname = this.parent.parent.opts.opts.corpname
            let qs = this.formValue.queryselector
            let query = this.formValue[qs == "cql" ? "cql" : "keyword"]
            let filter = {
                pnfilter: this.data.pnfilter,
                inclkwic: this.data.filterInclKwic,
                filfpos: this.data.filterFrom,
                filtpos: this.data.filterTo,
                queryselector: qs + "row",
                lpos: this.formValue.lpos,
                wpos: this.formValue.wpos
            }
            filter[qs] = query
            if (this.no_kwic) {
                filter.within = 1
                filter.maincorp = corpname
            }

            this.store.addOperationAndSearch({
                name: "filter",
                corpname: corpname,
                arg: query,
                query: filter
            })
        }

        this.on("mount", () => {
            delay(function(){
                $("input[name=\"keyword\"]:visible, textarea:visible", this.root).first().focus()
            }.bind(this), 400)
        })
    </script>
</parconcordance-result-options-filter-advanced>
