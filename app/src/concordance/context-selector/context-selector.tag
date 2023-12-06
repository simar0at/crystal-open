<context-selector class="context-selector">
    <div class="wideCtx">
        <div>
            <label if={!opts.nolabels} class="left {tooltipped: opts.tooltip}"
                    data-tooltip={opts.tooltip}>
                {_("cc.leftContext")}
                <sup if={opts.tooltip}>?</sup>
            </label>
            <label if={!opts.nolabels} class="right {tooltipped: opts.tooltip}"
                    data-tooltip={opts.tooltip}>
                {_("cc.rightContext")}
                <sup if={opts.tooltip}>?</sup>
            </label>
            <div class="clearfix"></div>
        </div>
        <div class="posWrapper center-align">
            <div class="left">
                <a each={item in leftList} class={getClasses(item)} onclick={onPositionClick.bind(this, item.value)}>{item.label}</a>
            </div>
            <a class={getClasses(kwic)} onclick={onPositionClick.bind(this, kwic.value)}>{kwic.label}</a>
            <div class="right">
                <a each={item in rightList} class={getClasses(item)} onclick={onPositionClick.bind(this, item.value)} >{item.label}</a>
            </div>
        </div>
    </div>

    <div class="narrowCtx">
        <ui-select options={selectList}
            name="contextSelector"
            value={opts.riotValue === "" ? "select" : opts.riotValue}
            label-id={opts.labelId || "cc.filterContext"}
            on-change={onPositionChange}></ui-select>
    </div>

    <script>
        require("./context-selector.scss")
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.leftList = []
            this.kwic = {value: 0, label: this.opts.kwicLabel || "KWIC"}
            this.rightList = []

            for(let i = 1; i <= this.opts.range; i++){
                this.rightList.push({
                    value: i,
                    label: i
                })
                this.leftList.unshift({
                    value: -i,
                    label: i
                })
            }

            let list = [{value: "select", labelId: "selectValue"}]
                    .concat(this.leftList, this.kwic, this.rightList)
            this.selectList = list.map(o => {
                let option = Object.assign({}, o) // copy object
                if(option.value < 0){
                    option.label = _("left") + " " + Math.abs(option.value)
                }
                if(option.value > 0){
                    option.label = _("right") + " " + option.value
                }
                return  option
            })
        }
        this.updateAttributes()

        onPositionClick(value){
            this.value = value
            this.opts.onChange(this.value, this.opts.name)
        }

        onPositionChange(position){
            this.opts.onChange(position, "contextSelector")
        }

        getClasses(item){
            let active = item.value == this.opts.riotValue
            return {
                "selected": active,
                "btn": 1,
                "btn-selector": 1,
                "pos": 1,
                "disabled": this.opts.disabled,
                "squareBtn": item.value != 0,
                "kwicBtn": item.value == 0
            }
        }

        this.on("update",  this.updateAttributes)
    </script>
</context-selector>
