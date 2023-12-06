const Meta = {
    operators:{
        AND: 1,
        OR: 2
    },
    filterList: {
        "basic": ["all", "startingWith", "endingWith", "containing"],
        "advanced": ["all", "startingWith", "endingWith", "containing", "regex", "fromList"]
    },
    filters: {
        "all": {
            value: "all",
            labelId: "all",
            regex: ".*"
        },
        "startingWith": {
            value: "startingWith",
            labelId: "startingWith",
            regex: "{key}.*",
            keyword: true
        },
        "endingWith": {
            value: "endingWith",
            labelId: "endingWith",
            regex: ".*{key}",
            keyword: true
        },
        "containing": {
            value: "containing",
            labelId: "containing",
            regex: ".*{key}.*",
            keyword: true
        },
        "regex": {
            value: "regex",
            labelId: "matchingRegex",
            regex: "{key}",
            keyword: true
        },
        "fromList": {
            value: "fromList",
            labelId: "fromList",
            regex: "{key}"
        }
    },

    wlnumsList: [{
        labelId: "frequency",
        value: "frq",
        tooltip: "t_id:wl_r_view_frequency"
    }, {
        labelId: "wl.docf",
        value: "docf",
        tooltip: "t_id:wl_r_view_docf"
    }, {
        label: "ARF",
        value: "arf",
        tooltip: "t_id:wl_r_view_arf"
    }],

    viewAsOptions: [{
        value: 1,
        labelId: "wl.simpleList",
        tooltip: "t_id:wl_a_simple_list"
    }, {
        value: 2,
        labelId: "wl.displayAs",
        tooltip: "t_id:wl_a_display_as"
    }]
}

module.exports = Meta




