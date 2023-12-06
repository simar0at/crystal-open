<collocations-form class="collocations-form inlineBlock">
    <div class="columns">
        <span class="inlineBlock">
            <ui-filtering-list
                label={_("count")}
                riot-value={parent.options.c_cattr}
                name="c_cattr"
                options={store.attrList}
                floating-dropdown=1
                value-in-search=1
                open-on-focus=1
                tooltip="t_id:conc_r_coll_count"
                on-change={onCattrChange}
                deselect-on-click={false}></ui-filtering-list>
        </span>
        <span class="inlineBlock">
            <range-select
                if={opts.hideCustomrange || !parent.options.c_customrange}
                name="c_range"
                on-change={onRangeChange}
                riot-value={{
                    from: this.parent.options.c_cfromw,
                    to: this.parent.options.c_ctow
                }}
                tooltip="t_id:conc_r_coll_range"></range-select>
            <virtual if={!opts.hideCustomRange}>
                <span if={parent.options.c_customrange}>
                    <label>{_("from")}</label>
                    <ui-input inline=1
                            size=3
                            name="c_cfromw"
                            label={_("range")}
                            riot-value={parent.options.c_cfromw}
                            on-change={onRangePartChange}></ui-input>
                    <label>{_("to")}</label>
                    <ui-input inline=1
                            size=3
                            name="c_ctow"
                            riot-value={parent.options.c_ctow}
                            on-change={onRangePartChange}></ui-input>
                </span>
                <br>
                <ui-checkbox label={_("customRange")}
                        class="customRange"
                        checked={parent.options.c_customrange}
                        on-change={onCustomRangeChange}></ui-checkbox>
            </virtual>
        </span>
    </div>

    <script>
        require("concordance/range-select/range-select.tag")

        this.mixin("feature-child")

        onCattrChange(c_cattr){
            this.parent.changeValue(c_cattr, "c_cattr")
        }

        onRangeChange(range){
            this.parent.changeData({
                c_cfromw: range.from,
                c_ctow: range.to
            })
        }

        onRangePartChange(value, name){
            this.parent.changeData({[name]: value})
        }

        onCustomRangeChange(c_customrange){
            this.parent.changeData({
                c_customrange: c_customrange,
                c_cfromw: c_customrange ? this.parent.options.c_cfromw : Math.max(-5, this.parent.options.c_cfromw),
                c_ctow: c_customrange ? this.parent.options.c_ctow : Math.min(5, this.parent.options.c_ctow)
            })
        }
    </script>
</collocations-form>
