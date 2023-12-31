const {Connection} = require("core/Connection.js")
const {Auth} = require("core/Auth.js")
const {AppStore} = require("core/AppStore.js")
require("./create-subcorpus-dialog/create-subcorpus-dialog.tag")
require("./change-password-dialog/change-password-dialog.tag")
require("./request-space-dialog/request-space-dialog.tag")
require("./grammar-detail-dialog/grammar-detail-dialog.tag")
require("./reset-fup-dialog/reset-fup-dialog.tag")
require("./tags-dialog/tags-dialog.tag")
require("./corpus-edit-dialog/corpus-edit-dialog.tag")

const showCreateSubcorpus = (showManageBtn) => {
    Dispatcher.trigger("openDialog", {
        id: "createSubcorpus",
        tag: "add-subcorpus-dialog",
        opts: {showManageBtn: showManageBtn},
        fullScreen: true
    })
}

const showChangePasswordDialog = () => {
    Dispatcher.trigger("openDialog", {
        id: "changePassword",
        tag: "change-password-dialog",
        title: _("newPassword"),
        small: true,
        buttons: [{
            id: "cpd_changeBtn",
            label: _("changePassword"),
            class: "disabled btn-primary",
            onClick: Dispatcher.trigger.bind(this, "changePassword")
        }]
    })
}


const showRequestMoreSpaceDialog = () => {
    Dispatcher.trigger("openDialog", {
        tag: "request-space-dialog",
        small: true,
        buttons: [{
            label: _("send"),
            class: "btn-primary",
            onClick: (dialog) => {
                let extra_space = dialog.contentTag.refs.space.getValue()
                Connection.get({
                    url: window.config.URL_CA + "users/me/request_more_space",
                    loadingId: "sendQutoaRequest",
                    xhrParams: {
                        method: "POST",
                        data: JSON.stringify({
                            extra_space: extra_space * 1000000
                        }),
                        contentType: "application/json"
                    },
                    done: () => {
                        Dispatcher.trigger("closeDialog")
                        Dispatcher.trigger("openDialog", {
                            title: _("quotaRequestSentTitle"),
                            content: _("quotaRequestSentMsg"),
                            small: true
                        })
                    },
                    fail: xhr => {
                        SkE.showToast("quotaRequestSendFail", xhr.error)
                    }
                })
            }
        }]
    })
}


const showGrammarDetailDialog = (opts) => {
    Dispatcher.trigger("openDialog", {
        tag: "grammar-detail-dialog",
        opts: opts,
        fixedFooter: true
    })
}


const showCorpusConfigDialog = (corpus_id) => {
    Dispatcher.trigger("openDialog", {
        title: _("ca.corpusSettings"),
        tag: "corpus-edit-dialog",
        small: true,
        id: "editCorpus",
        buttons: [{
            label: _("expertSettings"),
            class: "mr-2",
            onClick: () => {
                Dispatcher.trigger("closeDialog", "editCorpus")
                Dispatcher.trigger("ROUTER_GO_TO", "ca-config")
            }
        }, {
            label: _("save"),
            class: "btn-primary",
            id: "corpusEditSaveBtn",
            onClick: () => {
                AppStore.updateCorpus(corpus_id, {
                    name: $(".ca-edit-name input").val(),
                    info: $(".ca-edit-info textarea").val()
                })
                Dispatcher.trigger("closeDialog", "editCorpus")
            }
        }]
    })
}


Dispatcher.on("FUPLimitReached", () => {
    if(Auth.isFullAccount()){
        Dispatcher.trigger("openDialog", {
            id: "fupReset",
            onTop: true,
            title: _("fupTitle"),
            tag: "reset-fup-dialog",
            small: true
        })
    } else{
        SkE.showError(_("err.tooManyRequests"), _("err.tooManyRequestsTitle"))
    }
})


module.exports = {
    showCreateSubcorpus,
    showChangePasswordDialog,
    showRequestMoreSpaceDialog,
    showGrammarDetailDialog,
    showCorpusConfigDialog
}
