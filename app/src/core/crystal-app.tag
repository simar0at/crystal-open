<crystal-app class="crystal-app">
    <screen-overlay event-name={"LOADING_CHANGED"} multiple={true} show-academic-warning={true}></screen-overlay>
    <notification-bar></notification-bar>
    <modal-dialog></modal-dialog>

    <header-navbar></header-navbar>
    <side-nav></side-nav>
    <page-router></page-router>
    <div if={config.CUSTOM_FOOTER} class="footer">
        <raw-html content={config.CUSTOM_FOOTER}></raw-html>
    </div>

    <script>
        require('./crystal-app.scss')
        require('core/modal-dialog.tag')
        require('core/side-nav/side-nav.tag')
        require('core/header/header-navbar.tag')
        require('core/page-router/page-router.tag')

        this.on("mount", () => {
            App.init()
            Dispatcher.on("SESSION_LOADED", this.update)
            Dispatcher.on("LOCALIZATION_CHANGE", this.update);
            Dispatcher.one("APP_READY_CHANGED", () => {
                delay(() => {jQuery("#htmlLoading").fadeOut(600)}, 100)
            });
        })
    </script>
</crystal-app>
