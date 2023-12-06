<whats-new class="whats-new">
    <h4>{_("whatsNew")}</h4>


    <div class="newsList">
        <div each={news, idx in opts.newsList}
                if={idx < showLimit}
                class="news card-panel">
            <span class="date">
                {window.Formatter.date(new Date(news.date))}
            </span>
            <div ref="msg_{news.id}"
                     class="content">
                <preloader-spinner center=1></preloader-spinner>
            </div>
        </div>

        <div if={opts.newsList.length > showLimit}
                ref="showMoreBtn"
                class="hidden center ">
            <button class="btn"
                    onclick={onShowOlderClick}>show older</button>
        </div>
    </div>

    <script>
        require("./whats-new.scss")

        this.showLimit = 3

        onNewsLoad(newsIdx, payload){
            let news = this.opts.newsList[newsIdx]
            news.loaded = true
            this.refs["msg_" + news.id].innerHTML = payload.text
            this.refs.showMoreBtn && this.refs.showMoreBtn.classList.remove("hidden")
        }

        onShowOlderClick(){
            this.showLimit += 5
            this.loadNewsList()
        }

        loadNewsList(){
            this.opts.newsList.forEach((news, idx) => {
                if(idx >= this.showLimit){
                    return
                }
                if(!news.loaded){
                    window.TextLoader.load("news_" + news.id, this.onNewsLoad.bind(this, idx))
                }
            }, this)
        }
        this.on("mount",() => {
            delay(this.loadNewsList.bind(this), 400) // wait until dialog is fully open
        })
    </script>
</whats-new>
