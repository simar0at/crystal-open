<pattern-string class="pattern-string">
    <script>
        upd () {
            this.root.innerHTML = opts.content
        }
        this.upd()

        this.on('update', this.upd)
    </script>
</pattern-string>
