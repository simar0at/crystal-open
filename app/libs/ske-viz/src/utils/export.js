function exportSVG() {
    let svg = document.getElementById('ske-viz-opposite-0') || document.getElementById('ske-viz-radial')
    let svgDocType = document.implementation.createDocumentType('svg', "-//W3C//DTD SVG 1.1//EN", "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
    let svgDoc = document.implementation.createDocument('http://www.w3.org/2000/svg', 'svg', svgDocType)
    svgDoc.replaceChild(svg.cloneNode(true), svgDoc.documentElement)
    let svgData = (new XMLSerializer()).serializeToString(svgDoc)
    //  Fire download
    let link = document.createElement('a')
    link.download = "SkE-visualization.svg"
    link.style.opacity = "0"
    link.href =  'data:image/svg+xml; charset=utf8, ' + encodeURIComponent(svgData.replace(/></g, '>\n\r<'))
    document.body.append(link)
    link.click()
    link.remove()
}

function exportPNG() {
    let svgElement = document.getElementById('ske-viz-opposite-0') || document.getElementById('ske-viz-radial')
    svgElement.style = 'background-color: white;'
    let rect = svgElement.getBoundingClientRect()
    let width = rect.width * 2;
    let height = rect.height * 2;
    let outerHTML = (new XMLSerializer()).serializeToString(svgElement)
    let blob = new Blob([outerHTML],{type:'image/svg+xml'})
    let wURL = window.URL || window.webkitURL || window
    let blobURL = wURL.createObjectURL(blob)
    let image = new Image()

    image.onload = () => {
        let canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height
        let context = canvas.getContext('2d')
        context.drawImage(image, 0, 0, width, height)
        //  Fire download
        let png = canvas.toDataURL()
        let link = document.createElement('a')
        link.download = "SkE-visualization.png"
        link.style.opacity = "0"
        document.body.append(link)
        link.href = png
        link.click()
        wURL.revokeObjectURL(blobURL)
        link.remove()
    }
    image.src = blobURL
 }

export {
  exportSVG,
  exportPNG
};
