<collfreq-selected-lines-box  class="collfreq-selected-lines-box">
    <div class="z-depth-3 background-color-blue-100">
        <span class="closeBtnWrapper">
            <i class="material-icons material-clickable" onclick={opts.onCloseClick}>close</i>
        </span>
        <label>
            {_("showConcordanceFor")}
            &nbsp;
        </label>
        <div>
            <a href={pLink} class="btn">
                {_("selected")} ({opts.getDataLength()})
            </a>
            <a href={pLink} target="_blank">
                <i class="material-icons">open_in_new</i>
            </a>
            &nbsp;
            <a href={nLink} class="btn" >
                {_("notSelected")}
            </a>
            <a href={nLink} target="_blank">
                <i class="material-icons">open_in_new</i>
            </a>
        </div>
    </div>

    <script>
        require("concordance/collfreq-selected-lines-box.scss")

        this.on("update", () => {
            if(this.opts.getDataLength() != 0){
                this.pLink = this.opts.getUrlToResultPage("p")
                this.nLink = this.opts.getUrlToResultPage("n")
            }
        })

        this.on("updated", () => {
            if(this.opts.getDataLength() == 0){
                $(this.root).slideUp(200)
            } else{
                $(this.root).slideDown(200)
            }
        })
    </script>
</collfreq-selected-lines-box>
