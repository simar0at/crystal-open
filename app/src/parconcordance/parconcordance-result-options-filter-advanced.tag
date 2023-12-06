<parconcordance-result-options-filter-advanced class="parconcordance-result-options-filter-advanced pt-4">
    <div if={no_kwic} class="disabledcontextselector">{_("pc.alsegment")}</div>
    <span if={!no_kwic} class="inline-block">
        <ui-range if={!no_kwic} id="contextselector"
                label={_("range")}
                riot-value={{
                            from: options.filterFrom,
                            to: options.filterTo
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
                checked={!options.inclkwic}
                disabled={excludeKwicDisabled}
                on-change={onExclKwickChange}></ui-checkbox>
        </div>
    </span>

    <div class="row">
        <ui-select name="pnfilter"
                value={options.pnfilter}
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
                on-submit={onSubmit}
                on-reset={onFormReset}
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
        this.options = {
            filterFrom: this.data.filterFrom,
            filterTo: this.data.filterTo,
            inclkwic: this.data.inclkwic,
            pnfilter: this.data.pnfilter
        }

        onRangeChange(value){
            this.options.filterFrom = value.from
            this.options.filterTo = value.to
            let justKwic = value.from == "kwic" && value.to == "kwic"
            let kwicInRange = (value.from == "kwic" || value.from <= -1) && (value.to == "kwic" || value.to >= 1)
            if(justKwic){
                this.options.inclkwic = true
                this.excludeKwicDisabled = true
            } else {
                this.excludeKwicDisabled = !kwicInRange
            }
            this.update()
        }

        onExclKwickChange(checked){
            this.options.inclkwic = !checked
            this.update()
        }

        this.formValue = {}
        this.no_kwic = this.parent.parent.opts.has_no_kwic

        onOptionChange(value, name) {
            this.options[name] = value
        }

        onFormReset(){
            this.store.resetGivenOptions(this.options)
            this.update()
        }

        onFormChange(value) {
            this.formValue = value
            if (!this.formValue.default_attr) {
                this.formValue.default_attr = this.store.default_attr
            }
        }

        onSubmit() {
            let corpname = this.parent.parent.opts.corpname
            let qs = this.formValue.queryselector
            let query = this.formValue[qs == "cql" ? "cql" : "keyword"]
            let filter = {
                pnfilter: this.options.pnfilter,
                inclkwic: this.options.filterInclKwic,
                filfpos: this.options.filterFrom,
                filtpos: this.options.filterTo,
                queryselector: qs + "row",
                lpos: this.formValue.lpos,
                wpos: this.formValue.wpos
            }
            filter[qs] = query
            if (this.no_kwic) {
                filter.within = 1
                filter.maincorp = corpname
            }

            for(let key in this.formValue.tts){
                filter["sca_" + key] = this.formValue.tts[key]
            }

            this.store.addOperationAndSearch({
                name: "filter",
                corpname: corpname,
                arg: "(" + this.store.getAlignedLangName(corpname) + ") " + query,
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
