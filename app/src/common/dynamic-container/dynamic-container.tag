<dynamic-container>
    <div>
        <div each={item in opts.items}>
            <span onclick={removeItem}>remove</span>
            <div data-is={tagType} data={item}>
            </div>
        </div>

        <span onclick={addItem}>
            <i class="material-icons">add</i>
        </span>
    </div>

    <script>

        this.tagType = opts.tagType // cannot use opts.tagType directly in template

        removeItem(evt){
            let item = evt.item.id
            this.opts.onItemRemove(item)
        }

        addItem(item){
            this.opts.onItemAdd()
            this.update()
        }
    </script>
</dynamic-container>