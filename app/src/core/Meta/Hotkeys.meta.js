let HotkeysMeta = {
    global: {
        label: "Global",
        bindings: [{
            key: "s c",
            help: "hp.selectCorpus",
            event: "SELECT_CORPUS_FOCUS"
        }, {
            key: "s a",
            help: "hp.selectCorpusAdvanced",
            event: "ROUTER_GO_TO",
            args: ["corpus", {tab:"advanced"}]
        }, {
            key: "g h",
            help: "hp.goToDashboard",
            event: "ROUTER_GO_TO",
            args: ["dashboard"]
        }, {
            key: "g b",
            help: "hp.goToBGJobs",
            event: "ROUTER_GO_TO",
            args: ["bgjobs"]
        }, {
            key: "g m",
            help: "hp.goToCA",
            event: "ROUTER_GO_TO",
            args: ["ca"]
        }, {
            key: "g w",
            help: "hp.goToWordlist",
            event: "SHOW_FEATURE_SEARCH_FORM",
            args: "wordlist"
        },
        {
            key: "g c",
            help: "hp.goToConcordance",
            event: "SHOW_FEATURE_SEARCH_FORM",
            args: "concordance"
        }, {
            key: "g p",
            help: "openParconcordance",
            event: "SHOW_FEATURE_SEARCH_FORM",
            args: "parconcordance"
        },
        {
            key: "g k",
            help: "hp.goToKeywords",
            event: "SHOW_FEATURE_SEARCH_FORM",
            args: "keywords"
        },
        {
            key: "d 1",
            help: "hp.densityLow",
            event: "CHANGE_SETTINGS",
            args: {density: "low", noToast: true}
        }, {
            key: "d 2",
            help: "hp.densityMedium",
            event: "CHANGE_SETTINGS",
            args: {density: "medium", noToast: true}
        }, {
            key: "d 3",
            help: "hp.densityHigh",
            event: "CHANGE_SETTINGS",
            args: {density: "high", noToast: true}
        },{
            key: "left",
            help: "hp.prevPage",
            event: "RESULT_PREV_PAGE",
            args: {arrow: 'left'}
        }, {
            key: "right",
            help: "hp.nextPage",
            event: "RESULT_NEXT_PAGE",
            args: {arrow: 'right'}
        }, {
            key: "esc",
            help: "hp.escape",
            event: "ESCAPE_TAG",
            args: {keycode: 27}
        }, {
            key: "c c",
            help: "hp.changeCriteria",
            event: "CHANGE_CRITERIA"
        }]
    },
    concordance: {
        label: _("concordance"),
        bindings: [{
            key: "f w",
            help: "hp.showWordFrequency",
            event: "FEATURE_HOTKEY",
            args: {method: 'openFrequencyResults', params: ['word']}
        }, {
            key: "f l",
            help: "hp.showLemmaFrequency",
            event: "FEATURE_HOTKEY",
            args: {method: 'openFrequencyResults', params: ['lemma']}
        }, {
            key: "f t",
            help: "hp.showPosFrequency",
            event: "FEATURE_HOTKEY",
            args: {method: 'openFrequencyResults', params: ['tag']}
        }, {
            key: "f d",
            help: "hp.showLineDetailsFrequency",
            event: "FEATURE_HOTKEY",
            args: {method: 'openFrequencyResults', params: ['lineDetails']}
        }, {
            key: "f x",
            help: "hp.showTextTypesFrequency",
            event: "FEATURE_HOTKEY",
            args: {method: 'openFrequencyResults', params: ['textTypes']}
        }, {
            key: "v k",
            help: "hp.viewmodeKwic",
            event: "FEATURE_HOTKEY",
            args: {method: 'searchAndAddToHistory', params: [{'viewmode': 'kwic'}]}
        }, {
            key: "v s",
            help: "hp.viewmodeSen",
            event: "FEATURE_HOTKEY",
            args: {method: 'searchAndAddToHistory', params: [{'viewmode': 'sen'}]}
        }]
    }
}


export {HotkeysMeta}
