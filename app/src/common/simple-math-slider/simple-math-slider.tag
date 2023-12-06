<simple-math-slider>
    <ui-slider name="simple_n"
            hfill={true}
            label-id="focusOn"
            left-label={_("rare")}
            right-label={_("common")}
            on-change={opts.onChange}
            slider-to-input={sliderToInput}
            input-to-slider={inputToSlider}
            type="number"
            step=1
            slider-min=0
            slider-max={sliderValues.length - 1}
            input-min=0.00001
            input-max=1000000000
            tooltip="t_id:kw_a_simple_n"
            riot-value={opts.riotValue}>
    </ui-slider>

    <script>
        this.sliderValues = [0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000]

        sliderToInput(value){
            return this.sliderValues[value]
        }

        inputToSlider(value){
            let ret = 0
            let max = this.sliderValues[this.sliderValues.length - 1]
            if(value >= max){
                return this.sliderValues.length - 1
            }
            while(ret < this.sliderValues.length && ((this.sliderValues[ret] + this.sliderValues[ret + 1]) / 2) < value){
                ret ++
            }
            return ret
        }
    </script>
</simple-math-slider>
