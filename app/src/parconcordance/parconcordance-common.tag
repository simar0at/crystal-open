<parconcordance-result-options-shuffle class="parconcordance-result-options-shuffle">
    <external-text text="conc_r_shuffle"></external-text>
    <br>
    <div class="center">
        <a class="btn contrast" onclick={store.shuffle.bind(store)}>{_("go")}</a>
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
        <a class="btn contrast" onclick={onRandomSampleSubmit}>{_("go")}</a>
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

<parconcordance-result-context>
    <div each={item, idxI in opts.data} class="itm">
        <span if={item.str || item.attr} class="str {item.class} {coll: item.coll}">
            {item.str.match(/\S/) ? item.str : "&nbsp;"}
        </span>
        <span if={item.attr} class="attr">
            {item.attr.substr(1)}
        </span>
        <span if={item.strc} class="strc">
            {item.strc}
        </span>
    </div>
</parconcordance-result-context>

<parconcordance-result-refs-row class="tr refsUpRow tn-{opts.item.toknum}">
    <div if={parent.lineNumbersUp} class="td num">
        {opts.num}
    </div>
    <div class="td">
        <span class="refsUp">
            <a class="btn btn-flat btn-floating lineDetail tooltipped" data-tooltip={_("lineDetailsTip")}>
                <i class="material-icons medium">info_outline</i>
            </a>
            <span class="refsUpValues" onmouseover={showTooltip}>{opts.item.ref}</span>
        </span>
    </div>
    <virtual if={parent.data.viewmode == "kwic"}>
        <div class="td"></div>
        <div class="td"></div>
    </virtual>

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
