<annotation-box class="annotation-box {hiddenClass}" id="annotation-box">
    <div class="z-depth-3 annotationBoxWrapper">
        <div>
            <label class="annotationBoxLabel">{_("an.annotationActive")}</label>
            <button class="btn" onclick={onShowLabelsClick}>{_("an.annotationActions")}</button>
            <a href="#annotation?corpname={window.stores.app.data.corpus.corpname}&annotconc={this.data.annotconc}"
                    class="btn btn-flat">{_("an.manageAnnotations")}</a>
        </div>
    </div>

    <script>
        require("./annotation-box.scss")

        this.mixin("feature-child")

        onShowLabelsClick() {
            this.opts.active ? this.header.classList.add(this.hiddenClass) : document.getElementById("btnannotate").click()
            document.body.scrollTop = 0 // For Safari
            document.documentElement.scrollTop = 0 // For Chrome, Firefox, IE and Opera
        }

        stickyBox(){
            this.headerHeight = (this.header.offsetTop > 0 ? this.header.offsetTop : this.headerHeight)
            let offset = this.headerHeight + 60
            if (window.pageYOffset > offset) {
              this.header.classList.add("sticky")
              this.hiddenClass && this.header.classList.remove(this.hiddenClass)
            } else {
              this.header.classList.remove("sticky")
              this.hiddenClass && this.header.classList.add(this.hiddenClass)
            }
        }

        this.on('mount', () => {
            this.header = document.getElementById("annotation-box")
            this.headerHeight = this.header.offsetTop
            window.addEventListener('scroll', this.stickyBox)
        })

        this.on('update', () => this.hiddenClass = this.opts.active ? "boxHidden" : null)

        this.on('unmount', () => {
            window.removeEventListener('scroll', this.stickyBox)
        })
    </script>
</annotation-box>
