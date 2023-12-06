//http://browser-update.org/customize.html

const browserUpdate = require("browser-update")

const BROWSER_UPDATE_SETTINGS = {
    required: {
        i: 11,
        e: -3,
        f: -3,
        o: -3,
        s: -1,
        c: -3
    },
    // Specifies required browser versions
    // Browsers older than this will be notified.
    // f:22 ---> Firefox < 22 gets notified
    // Negative numbers specify how much versions behind current version.
    // c:-5 ---> Chrome < 35  gets notified if latest Chrome version is 40.

    reminder: 24,
    // after how many hours should the message reappear
    // 0 = zobrazit vždy

    reminderClosed: 168,
    // if the user explicitly closes message it reappears after x hours

    onshow: function(infos){
        $(".buorg_tt").tooltip()
    },
    onclick: function(infos){
        destroyTooltips(".buorg_tt")
    },
    onclose: function(infos){
        destroyTooltips(".buorg_tt")
    },
    // callback functions after notification has appeared / was clicked / closed

    //test: true, // true = vždy zobrazit lištu (pro testování)

    text: "<b>" + _("browserTooOld") + "</b>&nbsp;"
            + _("browserTooOldDesc") + "&nbsp;"
            + '<div class="hide-on-med-and-up"></div>'
            + '<a id="buorgul" href="' + config.links.updateBrowser + '" target="_blank" class="btn contrast buorg_tt" data-tooltip="'
                    + _("updateBrowserTip") + '">' + _("updateBrowser") + '</a> '
            + _("or")
            + " <a{ignore_but}>" + _("ignore") + "</a>",

    url: "" // the url to go to after clicking the notification
}

Dispatcher.on("APP_READY_CHANGED", (ready) => {
    ready && browserUpdate(BROWSER_UPDATE_SETTINGS)
})
