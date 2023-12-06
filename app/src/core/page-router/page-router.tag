<page-router class="page-router">
    <div class="appContainer">
        <div if={actualPage} data-is="page-{actualPage}"></div>
    </div>

    <script>
        require('./page-router.scss')
        require('pages/page-404.tag')
        require('pages/page-not-allowed.tag')
        require('concordance/page-concordance.tag')
        require('parconcordance/page-parconcordance.tag')
        require('wordlist/page-wordlist.tag')
        require('keywords/page-keywords.tag')
        require('corpus/page-corpus.tag')
        require('open/page-open.tag')
        require('ca/page-ca.tag')
        require('ca/page-ca-subcorpora.tag')
        require('dashboard/page-dashboard.tag')
        require('bgjobs/page-bgjobs.tag')

        const {Router} = require('core/Router.js')

        this.actualPage = Router.getActualPage()

        Dispatcher.on("ROUTER_CHANGE", (id) => {
           this.isMounted && this.update({
              actualPage: id
           })
           window.scrollTo(0, 0)
        })
    </script>
</page-router>
