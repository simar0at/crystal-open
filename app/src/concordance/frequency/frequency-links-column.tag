<frequency-links-column class="quickLinkColumn">
    <label>{_(opts.column.labelId)}</label>
    <div each={link in opts.column.links} class="btn doubleLinks quickLink {disabled: link.disabled}">
        <a href={link.href}
                id="btn_{link.id}"
                class="link currentTabLink tooltipped"
                data-tooltip={link.tooltip}>
            {_(link.labelId)}
        </a>
        <a href={link.href} target="_blank" class="newTabLink tooltipped" data-tooltip={_("openInNewTab")}>
            <i class="material-icons">open_in_new</i>
        </a>
    </div>

    <script>
        require("./frequency-links-column.scss")
        this.mixin("tooltip-mixin")
    </script>
</frequency-links-column>
