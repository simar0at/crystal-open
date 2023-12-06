<sortable-list class="sortable-list">
    <div ref="sortable">
        <span each={item, idx in opts.items || []} sort-id={idx} id="itm_{item.name}"></span>
    </div>

    <script>
        require("./sortable-list.scss")
        /*
            opts:
                items - array of opts for sortable items
                tagName - riot tag name sortable item
                onchange(optional) - function
                sortableParams - parameters for jQuery.sortable
         */

        refreshChildren(){
            // regenerates items containers and reinitialize jquery sortable
            opts.items.forEach((item, idx) => {
                riot.mount(this.refs.sortable.children[idx], this.opts.tagName, Object.assign({}, item, {"sortId": idx}))
            })
            this.initSortable()
        }

        onUpdate(){
            // called after order is changed
            let newOrder = []
            for (let i = 0; i < this.refs.sortable.children.length; i++) {
                newOrder.push(opts.items[this.refs.sortable.children[i].getAttribute("sort-id")])
            };

            if(typeof opts.onSort == "function"){
                opts.onSort(newOrder)
            }
        }

        initSortable(){
            if(this.isMounted){
                $(this.refs.sortable).sortable(Object.assign({
                    update: this.onUpdate
                }, opts.sortableParams || {}))
            }
        }

        this.on("mount", () => {
            this.refreshChildren()
        })

        this.on("updated", () => {
            this.refreshChildren()
        })

    </script>

</sortable-list>
