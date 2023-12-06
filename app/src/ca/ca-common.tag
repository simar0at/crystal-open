<ca-breadcrumbs class="ca-breadcrumbs hide-on-small-only">
    <nav>
        <div class="nav-wrapper">
            <span each={link, idx in links} class="breadcrumb {active: idx == parent.activeIndex}">
                {_(link.labelId)}
            </span>
        </div>
    </nav>

    <script>
        const {CAMeta} = require('ca/ca.meta.js')

        updateLinks(){
            this.links = CAMeta.links[opts.section]
            this.activeIndex = this.links.findIndex((link) => {
                return link.href.split("?")[0] == this.opts.active
            })
        }
        this.updateLinks()

        this.on("update", this.updateLinks)
    </script>
</ca-breadcrumbs>



<ca-title class="ca-title dividerBottom">
    <virtual if={opts.corpus && opts.corpus.name}>
        <span class="name">{_("corpus")}:</span>
        <span class="corpname">{opts.corpus.name}</span>
        <span class="language">({opts.corpus.language_name})</span>
    </virtual>
</ca-title>
