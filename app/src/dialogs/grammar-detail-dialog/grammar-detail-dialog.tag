<grammar-detail-dialog class="grammar-detail-dialog">
    <div if={!isLoading}>
        <h5>{data.name}</h5>
        <div>{data.filename.split("/").pop()}</div>
        <div if={error}>
            <h5>{_("somethingWentWrong")}</h5>
            <h6>{error}</h6>
        </div>
        <pre ref="content" class="t_grammarContent"></pre>
    </div>
    <div if={isLoading} class="centerSpinner loading">
        <preloader-spinner></preloader-spinner>
    </div>

    <script>
        require("./grammar-detail-dialog.scss")
        const {Connection} = require('core/Connection.js')

        this.isLoading = true

        onLoad(payload){
            this.isLoading = false
            this.content = ""
            if(payload.error){
                this.error = payload.error
            } else {
                this.data = payload.data
                this._processContent()
            }
            this.update()
            this.refs.content.innerHTML = this.content
        }

        load(){
            this.data = null
            this.error = null
            let url = ""
            if(this.opts.id){
                url = window.config.URL_CA + "sketch_grammars/" + this.opts.id
            } else {
                url = window.config.URL_BONITO + "wsdef?corpname=" + this.opts.corpname + (this.opts.is_term ? "&termdef=1" : "")
            }
            Connection.get({
                url: url,
                done: this.onLoad,
                fail: function(payload) {
                    SkE.showToast(payload.error)
                }
            })
        }

        _processContent(){
            let lineclass = {
                '#': 'comment',
                '=': 'grname',
                '*': 'directive',
                'd': 'directive'
            }
            let lineType = ''
            this.content = this.data.content.split("\n").reduce((content, line) => {
                if(!line.trim()){
                    return content += "<br>"
                }

                lineType = line[0]
                let ret = '<div class="' + (lineclass[lineType] || 'query') + '">'
                ret += line.replace(new RegExp("&", 'g'), "&amp;").replace(new RegExp("<", 'g'), "&lt;")
                if (!'#=*'.includes(lineType)){
                    ret = ret.replace(new RegExp("[0-9]{1}\:", 'g'), '<span class="label">$&</span>')
                }
                ret += "</div>"

                return content + ret
            }, "")
        }


        this.on("mount", this.load)
    </script>
</grammar-detail-dialog>
