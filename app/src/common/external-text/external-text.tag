<external-text class="external-text">
    <div ref="text" class="underlineLinks"></div>

    <script>
        require("./external-text.scss")

        this.on("mount", () => {
            window.TextLoader.load(this.opts.text, (payload) => {
                if(this.refs.text){ // was not removed during loading
                    this.refs.text.innerHTML = payload.text
                    $('.external-text .collapsible').collapsible({accordion: true})
                }
            })
        })
    </script>
</external-text>
