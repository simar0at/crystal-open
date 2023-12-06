require('./whats-new.tag')
const {UserDataStore} = require('core/UserDataStore.js')

class WhatsNewClass {

    constructor(){
        this.newsList = [/*
            template:
            {
                date: "m.d.yyyy",
                id: x
            }
            // x: incremental number, each news has unique ID which has to be
            //    higher than previous IDs
            //    ID is used to load message - from /texts/news_x.html
        */]
        Dispatcher.on("APP_READY_CHANGED", this.onAppReadyChange.bind(this))
    }

    getAllNewsList(){
        return this.newsList
    }

    openDialog(onlyNew){
        if(!this.newsList.length){
            return
        }
        let newsList = []
        let lastNewsId = null
        if(onlyNew){
            let lastSeenNews = UserDataStore.getOtherData("lastSeenNews") || 0
            lastNewsId = this.newsList[this.newsList.length - 1].id
            if(lastSeenNews < lastNewsId){
                newsList = this.newsList.filter(m => m.id > lastSeenNews)
            }
        } else {
            newsList = this.newsList
        }

        newsList.length &&  Dispatcher.trigger("openDialog", {
            tag: "whats-new",
            tall: true,
            fixedFooter: true,
            onClose: function(lastNewsId, onlyNew){
                if(onlyNew){
                    UserDataStore.saveOtherData({lastSeenNews: lastNewsId})
                    let btnNode = $("#btnhelp:visible")
                    btnNode.length && delay(() => {
                        let tooltipNode = btnNode.find("i")
                        btnNode.addClass("btn btn-floating pulse")

                        tooltipNode.tooltip({
                            enterDelay: 0,
                            exitDelay: 500,
                            html: _("moreNewsHere")
                        })
                        let tooltip = M.Tooltip.getInstance(tooltipNode)
                        tooltip.open()

                        delay(()=>{
                            tooltip.close()
                            btnNode.removeClass("btn btn-floating pulse")
                        }, 7000)
                    }, 500)
                }
            }.bind(this, lastNewsId, onlyNew),
            opts: {
                newsList: copy(newsList)
            }
        })
    }

    onAppReadyChange(ready){
        if(ready){
            delay(function(){
                this.openDialog(true)
            }.bind(this), 500)
        }
    }
}

export let WhatsNew = new WhatsNewClass()
