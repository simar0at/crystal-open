<concordance-tags-help>
    <div if={opts.wposlist.length}>
        <h5>{_("commonTags")}</h5>
        <table class="table material-table highligh" >
            <tr each={pos in opts.wposlist} class="link" onclick={onTagClick}>
                <td>{getLabel(pos)}</td>
                <td class="right-align">
                    <a style="word-break: break-word"> {pos.value}</a>
                    &nbsp;
                    <span class="btn btn-flat btn-floating btn-small" onclick={onCopyClick}>
                        <i class="material-icons grey-text">file_copy</i>
                    </span>
                </td>
            </tr>
        </table>
        <br>
        <div>
            {_("cc.tagsHelpText")} &nbsp;
            <a href={opts.tagsetdoc} target="_blank" class="btn white-text">{_("cc.allTags")}</a>
        </div>
    </div>

    <script>
        onTagClick(evt){
            this.opts.onTagClick(evt.item.pos.value)
        }

        onCopyClick(evt){
            evt.stopPropagation()
            Dispatcher.trigger("closeDialog")
            copyToClipboard(evt.item.pos.value)
        }
    </script>
</concordance-tags-help>
