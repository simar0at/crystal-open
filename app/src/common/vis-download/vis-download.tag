<vis-download>
    <p>{_("chooseFileFormat")}</p>
    <div>
        <a class="btn mr-4"
                onclick={exportSVG}>
            <vis-icon class="download"></vis-icon> SVG
        </a>
        <a class="btn mr-4"
                onclick={exportPNG}>
            <vis-icon class="download"></vis-icon> PNG
        </a>
        <a class="btn mr-4" onclick={pdf_print}>
            <i class="ske-icons skeico_pdf"></i> PDF
        </a>
    </div>

    <script>
        pdf_print() {
            window.print()
        }

        exportPNG(e) {
            e.preventUpdate = true
            import ('libs/ske-viz/src/index.js').then(skeViz => {
                skeViz.exportPNG()
            })
        }

        exportSVG(e) {
            e.preventUpdate = true
            import ('libs/ske-viz/src/index.js').then(skeViz => {
                skeViz.exportSVG()
            })
        }
    </script>
</vis-download>
