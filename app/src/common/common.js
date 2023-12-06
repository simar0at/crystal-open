require('./table-label/table-label.tag')
require('./column-table/column-table.tag')
require('./raw-html/raw-html.tag')
require('./dynamic-container/dynamic-container.tag')
require('./screen-overlay/screen-overlay.tag')
require('./notification-bar/notification-bar.tag')
require('./preloader-spinner/preloader-spinner.tag')
require('./floating-button/floating-button.tag')
require('./lang-corp-list/lang-corp-list.tag')
require('dialogs/icon-dialog/icon-dialog.tag')
require("./favourite-toggle/favourite-toggle.tag")
require("./feature-toolbar/feature-toolbar.tag")
require('./vis-icon/vis-icon.tag')
require("./result-error/result-error.tag")
require("./alt-lposlist/alt-lposlist.tag")
require("./subcorpus-select/subcorpus-select.tag")
require("./interfeature-menu/interfeature-menu.tag")
require("./user-list/user-list.tag")
require("./user-from-email/user-from-email.tag")
require('./bgjob-card/bgjob-card.tag')
require('./insert-characters/insert-characters.tag')
require('./feedback-form/feedback-form.tag')
require('./workindicator.js')
require('./textloader.js')
require('./lazy-dialog/lazy-dialog.tag')
require('./subcorpus-chip/subcorpus-chip.tag')
require('./text-types-chip/text-types-chip.tag')
require('./external-text/external-text.tag')
require('./text-types/text-types.tag')
require('./cql-builder/cql-builder.tag')
require('./swap-corpora/swap-corpora.tag')
require('./simple-math-slider/simple-math-slider.tag')
require('./error-dialog/error-dialog.tag')
require('./cql-textarea/cql-textarea.tag')
require('./filter-input/filter-input.tag')
require('./user-limit/user-limit.tag')
require('./vis-download/vis-download.tag')
require('../dashboard/oct-langs.tag')
require('./result-filter/result-filter.tag')
require('./result-filter-chip/result-filter-chip.tag')
require('./frequency-distribution/frequency-distribution.tag')
require('./result-preloader-spinner/result-preloader-spinner.tag')
require('./expandable-textarea/expandable-textarea.tag')
require('./manage-macros/manage-macros-icon.tag')
require('./manage-macros/macro-select.tag')

window.SkE = {
    showError: (message, detail, dialogParams) => {
        //displays standard dialog with error
        Dispatcher.trigger('openDialog', Object.assign({
            type: "warning",
            tag: "error-dialog",
            opts: {
                message: window.riotEscape(message),
                detail: window.riotEscape(detail)
            },
            title: _("somethingWentWrong")
        }, dialogParams));
    },

    showToast: (html, options) => {
        let duration = 5000
        if(typeof options == "number"){
            duration = options
            options = {}
        }
        M.toast(Object.assign({
            html: html,
            displayLength: duration}, options))
    },

    showNotification: (notification) => {
        // show message in notification bar
        if(typeof notification == "string"){
            notification = {
                message: notification
            }
        }
        Dispatcher.trigger("SHOW_NOTIFICATION", notification)
    },

    hideNotification: (notification) => {
        // notification object or notification id string
        Dispatcher.trigger("HIDE_NOTIFICATION", notification)
    },

    showCorpusInfo: (corpname) => {
        Dispatcher.trigger("openDialog", {
            id: "corpusInfo",
            tag: "corpus-info-dialog",
            fullScreen: true,
            opts: {
                corpname: corpname
            }
        })
    }
}

// https://github.com/douglascrockford/JSON-js/blob/master/cycle.js
if (typeof JSON.decycle !== "function") {
    JSON.decycle = function decycle(object, replacer) {
        "use strict";
        var objects = new WeakMap();
        return (function derez(value, path) {
            var old_path;
            var nu;
            if (replacer !== undefined) {
                value = replacer(value);
            }
            if (
                typeof value === "object" && value !== null &&
                !(value instanceof Boolean) &&
                !(value instanceof Date) &&
                !(value instanceof Number) &&
                !(value instanceof RegExp) &&
                !(value instanceof String)
            ) {
                old_path = objects.get(value);
                if (old_path !== undefined) {
                    return {$ref: old_path};
                }
                objects.set(value, path);
                if (Array.isArray(value)) {
                    nu = [];
                    value.forEach(function (element, i) {
                        nu[i] = derez(element, path + "[" + i + "]");
                    });
                } else {
                    nu = {};
                    Object.keys(value).forEach(function (name) {
                        nu[name] = derez(
                            value[name],
                            path + "[" + JSON.stringify(name) + "]"
                        );
                    });
                }
                return nu;
            }
            return value;
        }(object, "$"));
    };
}
