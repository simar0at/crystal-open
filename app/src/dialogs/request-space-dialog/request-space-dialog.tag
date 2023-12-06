<request-space-dialog>
    <div>
        <h4>{_("requestMoreSpace")}</h4>
        {_("requestFor")}
        &nbsp;
        <ui-input ref="space"
                type="number"
                min=1
                size=3
                riot-value=1
                inline=1></ui-input>
        &nbsp;
        {_("millionWords")}
        <br><br>
        {_("spaceRequestNote")}
    </div>

    <script>
        this.on("mount", () => {
            delay(() => {
                $("input", this.root).focus()
            }, 1)
        })
    </script>
</request-space-dialog>
