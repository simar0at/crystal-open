<node class="node">
    <div each={s in opts.data._sub} if={s._st[0] != "_"}>
        <span class="semtype">
            <virtual if={s._sub && s._sub.length}>
                <a onclick={open} if={!s._opened && s._sub && s._sub.length}
                        href="javascript:void(0);">&plus; {s._st}</a>
                <a onclick={close} if={s._opened}
                        href="javascript:void(0);">
                    &minus;
                    <span if={!s._match}>{s._st}</span>
                    <b if={s._match} class="red-text" style="font-size: 18px;">{s._st}</b>
                </a>
            </virtual>
            <virtual if={!s._sub || !s._sub.length}>
                {s._st}
            </virtual>
        </span>
        <div class="meta">
            <div class="def" if={s._def}>{s._def}</div>
            <div class="ex"
                    if={s._ex && s._ex.length}>{s._ex.join(", ")}</div>
        </div>
        <node data={s} if={s._opened}></node>
    </div>

    <script>
        open(ev) {
            ev.item.s._opened = true
        }

        close(ev) {
            ev.item.s._opened = false
        }
    </script>
</node>
