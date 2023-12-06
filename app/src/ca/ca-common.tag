<ca-breadcrumbs class="ca-breadcrumbs hide-on-small-only">
    <nav>
        <div class="nav-wrapper">
            <div class="col s12">
                <virtual each={link, idx in links} >
                    <a if={idx < parent.activeIndex } id="step_{idx}" href="#{link.href}" class="breadcrumb">
                        {idx + 1}.&nbsp;{_(link.labelId)}
                    </a>
                    <span if={idx >= parent.activeIndex} class="breadcrumb {active: idx == parent.activeIndex}">
                        {idx + 1}.&nbsp;{_(link.labelId)}
                    </span>
                </virtual>
            </div>
        </div>
    </nav>

    <script>
        const {CAMeta} = require('ca/ca.meta.js')

        updateLinks(){
            this.links = CAMeta.links[opts.section]
            this.activeIndex = this.links.findIndex((link) => {
                return link.href == this.opts.active
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
