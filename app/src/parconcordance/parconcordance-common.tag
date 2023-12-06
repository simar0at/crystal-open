<parconcordance-result-options-shuffle class="parconcordance-result-options-shuffle">
    <external-text text="conc_r_shuffle"></external-text>
    <br>
    <div class="primaryButtons">
        <a id="btnGoShuffle" class="btn btn-primary" onclick={store.shuffle.bind(store)}>{_("shuffle")}</a>
    </div>
    <script>
        this.mixin('feature-child')
    </script>
</parconcordance-result-options-shuffle>

<parconcordance-result-options-sample class="parconcordance-result-options-sample">
    <external-text text="conc_r_sample"></external-text>
    <div class="center">
        <ui-input ref="sampleCount" name="sample" type="number" validate={true}
                inline=1 min=1 placeholder="250" riot-value=250 required={true}
                on-submit={onRandomSampleSubmit} size=4>
        </ui-input>
        &nbsp;
        <a id="btnGoSample" class="btn btn-primary" onclick={onRandomSampleSubmit}>{_("go")}</a>
    </div>

    <script>
        this.mixin('feature-child')

        onRandomSampleSubmit() {
            let count = this.refs.sampleCount.getValue()
            if (count) {
                this.store.randomSample(count)
            }
        }

        this.on("mount", () => {
            $("input", this.root).focus()
        })
    </script>
</parconcordance-result-options-sample>

<parconcordance-result-items>
        <span each={item, idxI in opts.data} no-reorder
        if={item.str || item.strc}
        class="itm {item.class} {coll: item.coll} {strc: item.strc} {hl: item.hl}"
        onclick={opts.onClick}
        data-tooltip={item.attr && opts.show_as_tooltips ? item.attr.substr(1) : ""}
        attr={item.attr && !opts.show_as_tooltips && item.attr.substr(1)}
        style="{item.color ? 'color: '  + item.color : ''}">{isDef(item.str) ? (item.str.match(/\S/) ? item.str : "&nbsp;") : null}{item.strc}</span>
</parconcordance-result-items>

<parconcordance-result-refs-row class="tr refsUpRow tn-{opts.item.toknum}">
    <div if={parent.lineNumbersUp} class="td num">
        {opts.num}
    </div>
    <div class="td">
        <span class="refsUp">
            <a class="btn btn-flat btn-floating lineDetail tooltipped t_lineDetail" data-tooltip={_("lineDetailsTip")}>
                <i class="material-icons color-blue-200">info_outline</i>
            </a>
            <span if={parent.data.refs !== ""}
                    class="refsUpValues"
                    onmouseover={showTooltip}>{opts.item.ref}</span>
        </span>
    </div>
    <virtual if={parent.data.viewmode == "kwic"}>
        <div class="td"></div>
        <div class="td"></div>
    </virtual>
    <div each={opts.item.Align} class="td"></div>

    <script>
        showTooltip(evt){
            evt.preventUpdate = true
            evt.stopPropagation()
            let node = evt.currentTarget
            if(node.clientWidth < node.scrollWidth){
                let tooltip = window.showTooltip(node, node.innerHTML, 600)
                $(".tooltip-content", tooltip.tooltipEl).css("max-width", "1000px")
            }
        }
    </script>
</parconcordance-result-refs-row>
