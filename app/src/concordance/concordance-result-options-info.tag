<concordance-result-options-info>
    <table class="material-table">
        <thead>
            <tr>
                <th>{_("operation")}</th>
                <th>{_("parameters")}</th>
                <th>{_("hits")}</th>
                <th>{_("perMillion")}</th>
            </tr>
        </thead>
        <tbody>
            <tr each={line in desc}>
                <td>{line.op}</td>
                <td>{line.arg}</td>
                <td>{window.Formatter.num(line.size)}</td>
                <td>{window.Formatter.num(line.rel)}</td>
            </tr>
        </tbody>
    </table>

    <script>
        this.mixin("feature-child")

        this.desc = this.store.data.raw.Desc
    </script>
</concordance-result-options-info>
