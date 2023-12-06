<text-types-modal>
    <text-types ref="textTypes"
            selection={opts.selection}
            disable-structure-mixing={isDef(opts.disableStructureMixing) ? opts.disableStructureMixing : true}
            on-detail-toggle={onDetailToggle}></text-types>
    <div ref="submitButton"
            class="fixed-action-btn">
        <a href="javascript:void(0);"
                class="btn btn-primary btn-floating btn-large pulse"
                onclick={onSubmit}>
            GO
        </a>
    </div>

    <script>
        onSubmit(){
            this.modalParent.close()
            this.opts.onSubmit(this.refs.textTypes.selection)
        }

        onDetailToggle(textType){
            this.refs.submitButton.classList.toggle("hidden", !!textType)
        }
    </script>
</text-types-modal>



<text-types-chip class="text-types-chip">
    <span if={numOfTextTypes}
            onclick={onClick}
            class="link chip clickable tooltipped"
            data-tooltip="t_id:tt_chip">
        {_("textTypes")}
        <span>
            <b>
                {numOfTextTypes}
            </b>
            ({numOfValues})
        </span>
        <i class="material-icons">more_horiz</i>
    </span>

    <script>
        require("./text-types-chip.scss")
        this.mixin("feature-child")
        this.mixin("tooltip-mixin")

        updateAttributes(){
            this.numOfTextTypes = 0
            this.numOfValues = 0
            for(tt in this.data.tts){
                this.numOfTextTypes++
                this.numOfValues += this.data.tts[tt].length
            }
        }
        this.updateAttributes()

        onClick(evt){
            Dispatcher.trigger("openDialog", {
                tag: "text-types-modal",
                title: _("textTypes"),
                fullScreen: true,
                opts: {
                    disableStructureMixing: this.opts.disableStructureMixing,
                    selection: copy(this.data.tts),
                    onSubmit: this.onSubmit
                }
            })
        }

        onSubmit(tts){
            if(!window.objectEquals(this.data.tts, tts)){
                if(isFun(this.opts.onChange)){
                    this.opts.onChange(tts)
                } else {
                    this.store.searchAndAddToHistory({
                        tts: tts
                    })
                }
            }
        }

        this.on("update", this.updateAttributes)
    </script>
</text-types-chip>
