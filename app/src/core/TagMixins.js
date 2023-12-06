const {Localization} = require('core/Localization.js')
const {SettingsStore} = require("core/SettingsStore.js")
const {AppStore} = require("core/AppStore.js")

riot.mixin({
    init: function(){
        this.on("mount", function(){
            if(isDef(this.opts.width)){
                this.root.style.width = this.opts.width + "px";
            }
            if(isDef(this.opts.inline)){
                this.root.classList.add("inline-block")
            }
        })

        if(this.opts.dataIs || this.opts.copyOpts){
            // Copy opts form opts.opts to opts. Used for <div data-is="tagName" opts={objectWithOpts}>
            this._copyOpts()
            this.on("update", this._copyOpts)
        }

    },

    _copyOpts(){
        if(this.opts.opts){
            for(let key in this.opts.opts){
                this.opts[key] = this.opts.opts[key]
            }
        }
    }
})

riot.mixin('feature-child', {
    init: function(){
        this.corpus = AppStore.getActualCorpus()
        this.pageTag = this.opts.pageTag || getPageParent(this)
        this.store = this.pageTag.store
        this.data = this.store.data

        this.on("update", () => {
            this.corpus = this.store.corpus
            this.data = this.store.data
        })
    }
})


riot.mixin('tooltip-mixin', {

    initializeTooltips: function(){
        let selector = this.tooltipClass || '.tooltipped'
        $(selector, this.root).tooltip({
            enterDelay: isDef(this.tooltipEnterDelay) ? this.tooltipEnterDelay : 500,
            exitDelay: isDef(this.tooltipExitDelay) ? this.tooltipExitDelay : 500,
            html: this.tooltipHtml,
            margin: isDef(this.tooltipMargin) ? this.tooltipMargin : 5,
            position: this.tooltipPosition || "bottom"
        });
    },

    removeTooltips: function(){
        destroyTooltips(this.tooltipClass || '.tooltipped', this.root)
    },

    init: function(){
        this.on("mount", this.initializeTooltips)
        // we have to remove tooltips, because in riot modifies dom nodes content
        // and tooltip is attached to node. So after node content is modified
        // there could be still attached tooltip of previous content
        this.on("update", this.removeTooltips)
        this.on("updated", this.initializeTooltips)
        this.on("before-unmount", this.removeTooltips)
    }
})

riot.mixin('adjust-gramrel-sizes', {
    adjustSizes: function() {
        let gramrelbox = $(this.refs.gramrelbox)
        if (!Array.isArray(this.refs.gramrel)) {// if there are no or just a single gramrel, do not do anything, just show as is
            gramrelbox.fadeTo(250, 1)
            $(this.refs.main_spinner).hide()
            return;
        }

        // reset all values to have browser do the layout with new data

        this.refs.gramrel_tag.forEach(gt => {
            $(gt.refs.gramrelname).height("")
            gt.refs.table.style.width = (this.store.getTableWidth()*gt.getNumOfColls()) + "em"
        })
        this.refs.gramrel_container.forEach(gc => {
            gc.style.width = ""
        })

        // find rows of tables
        let card_rows = {}
        this.refs.gramrel.forEach((g, i) => {
            let t = $(g).offset().top
            if (t in card_rows)
                card_rows[t].push(i)
            else
                card_rows[t] = [i]
        });

        // adjust width of tables
        let gr_width = gramrelbox.outerWidth()
        let gr_right = gramrelbox[0].getBoundingClientRect().right
        let first_row = Object.keys(card_rows).sort(function(a, b){return a - b})[0]
        if (Object.keys(card_rows).length == 1) { // only one row of gramrels
            let most_right = 0;
            for (let i of card_rows[first_row])
                most_right = Math.max(most_right, $(this.refs.gramrel[i])[0].getBoundingClientRect().right)
            if (gr_right * 0.75 > most_right)
                gr_width -= (gr_right - most_right)
        }
        let l = card_rows[first_row].length
        gr_width = gr_width / l - 16 /*margin 8px eaach side*/
        this.refs.gramrel_container.forEach(gc => {
            gc.style.width = gr_width + "px";
        })
        let test_width = gr_width
        this.refs.gramrel_tag.forEach(gt => {
            gt.refs.table.style.width = "100%"
            test_width = Math.max (test_width, $(gt.refs.table).outerWidth())
        })
        if (test_width > gr_width) { // some table does not fit into the width we have calculated, thus we make it wider
            this.refs.gramrel_container.forEach(gc => {
              gc.style.width = test_width + "px";
            })
        }

        // adjust height of gramrel name cells

        for (var r in card_rows) {
            let max_height = 0
            for (let i of card_rows[r]) {
                let h = $(this.refs.gramrel_tag[i].refs.gramrelname).outerHeight(true)
                if (h > max_height)
                    max_height = h
            }
            for (let i of card_rows[r]) {
                $(this.refs.gramrel_tag[i].refs.gramrelname).outerHeight(max_height)
            }
        }

        // show tables again
        gramrelbox.fadeTo(250, 1)
        $(this.refs.main_spinner).hide()
    },

    scheduleAdjustSizes: function() {
        clearTimeout(window.resizedFinished);
        window.resizedFinished = setTimeout(this.adjustSizes, 500);
    },

    init: function() {
        this.on("mount", () => {
            SettingsStore.on('change', this.scheduleAdjustSizes) // XXX there should be a specific event, not just change!
            $(window).on('resize', this.scheduleAdjustSizes)
            $(window).on('popstate', this.scheduleAdjustSizes) // needed to re-align columns after browser 'back' to ws page
        })

        this.on("unmount", () => {
            SettingsStore.off('change', this.scheduleAdjustSizes)
            $(window).off('resize', this.scheduleAdjustSizes)
            $(window).off('popstate', this.scheduleAdjustSizes)
        })

        this.on("update", () => {
            if(!this.data.noSizeAdjust){
                $(this.refs.gramrelbox).fadeTo(250, 0) // for the case gramrels are already displayed (changing view)
                $(this.refs.main_spinner).show()
            }
        })

        this.on("updated", () => {
            if(!this.data.noSizeAdjust){
                $(this.refs.gramrelbox).fadeTo(50, 0) // for the case gramrels are not yet displayed (loading)
                $(this.refs.main_spinner).show()
                this.scheduleAdjustSizes()
            }
        })
    }
})

