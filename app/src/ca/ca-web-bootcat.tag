<ca-web-bootcat class="ca-web-bootcat">
    <div>
        <div class="card-panel columnForm">
            <div class="row">
                <label for="input_type" class="col m4 s12">
                    {_("ca.input_type")}
                </label>
                <span class="col m8 s12 inputTypeOptions">
                    <div each={option, idx in inputTypeList}>
                        <label for={"ito_" + idx}>
                            <input type="radio"
                                id={"ito_" + idx}
                                name="input_type"
                                value={option.value}
                                checked={option.value == parent.inputType}
                                onchange={parent.onInputTypeChange}>
                            <span>
                                {getLabel(option)}
                            </span>
                        </label>
                        <i class="material-icons tooltipped help small-help" data-tooltip={_("ca." + option.value +  "Help")}>help_outline</i>
                   </div>

                     <span if={inputType == "seeds"}>
                        <ui-chips name="seeds"
                            riot-value={seedWords}
                            on-add={onSeedsChange}
                            on-delete={onSeedsChange}
                            placeholder={_("ca.seedsPlaceholder")}
                            secondary-placeholder=" "
                            ref="seeds"
                            ></ui-chips>
                            <i class="material-icons tooltipped help inlineHelp" data-tooltip={_("ca.seedsHelp")}>help_outline</i>
                        <div class="hint">
                            <div ref="seedsHint"></div>
                        </div>
                        <div if={!opts.corpus.status.isEmpty && hasKeywords}>
                            <a href="javascript:void(0);" class="btn kwBtn" onclick={onUseKeywordsClick}>
                                {_("getSeedWords")}
                            </a>
                        </div>
                    </span>
                    <span if={inputType == "urls"}>
                        <ui-textarea name="urls"
                            inline=1
                            placeholder={_("ca.urlsPlaceholder")}
                            rows=1
                            required=1
                            validate=1
                            on-input={refreshGoDisabled}
                            ref="urls"></ui-textarea>
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.urlsHelp")}>help_outline</i>
                    </span>
                    <span if={inputType == "site"}>
                        <ui-input name="site"
                            inline=1
                            placeholder={_("ca.sitePlaceholder")}
                            on-input={refreshGoDisabled}
                            required=1
                            validate=1
                            ref="site"></ui-input>
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.siteHelp")}>help_outline</i>
                    </span>
                </span>
            </div>

            <div class="row">
                <label for="fileset_name" class="col m4 s12 withHelp">
                    {_("ca.fileset_name")}
                    <i class="material-icons tooltipped help" data-tooltip={_("ca.fileset_nameHelp")}>help_outline</i>
                </label>
                <span class="col m8 s12" style="max-width: 250px;">
                    <ui-input ref="fileset_name"
                        placeholder={_("ca.fileset_namePlaceholder")}
                        riot-value={fileset_name}
                        required={true}
                        validate=1
                        on-input={refreshGoDisabled}
                        name="fileset_name"></ui-input>
                </span>
            </div>

            <virtual if={inputType == "seeds"}>
                <div  class="center-align">
                    <a class="btn btn-flat btn-waves" onclick={onSettingsToggle.bind(this, "showWebSearchSettings")} style="text-transform: none;">
                        {_("ca.webSearchSettings")}
                        <i class="material-icons right">{showWebSearchSettings ? "arrow_drop_up" : "arrow_drop_down"}</i>
                    </a>
                </div>
                <div ref="showWebSearchSettings" class="columnForm bootcat-settings" style="display: none;">
                    <div class="row">
                        <label for="max_urls_per_query" class="col m4 s12 withHelp"}>
                            {_("ca.max_urls_per_query")}
                            <i class="material-icons tooltipped help" data-tooltip={_("ca.max_urls_per_queryHelp")}>help_outline</i>
                        </label>
                        <span class="col m8 s12" style="max-width: 100px;">
                            <ui-input ref="max_urls_per_query"
                                name="max_urls_per_query"
                                type="number"
                                size=3
                                inline=1
                                validate=1
                                max=100
                                min=1
                                on-input={refreshGoDisabled}
                                on-change={onOptionChange}
                                riot-value={options.max_urls_per_query}></ui-input>
                        </span>
                    </div>
                    <div class="row">
                        <label for="sites_list" class="col m4 s12 withHelp">
                            {_("ca.sites_list")}
                            <i class="material-icons tooltipped help" data-tooltip={_("ca.sites_listHelp")}>help_outline</i>
                        </label>
                        <span class="col m8 s12">
                            <ui-textarea ref="sites_list"
                                name="sites_list"
                                on-change={onOptionChange}
                                riot-value={options.sites_list}></ui-textarea>
                        </span>
                    </div>
                </div>
            </virtual>

            <div  class="center-align">
                <a class="btn btn-flat btn-waves" onclick={onSettingsToggle.bind(this, "showBlacklistSettings")} style="text-transform: none;">
                    {_("ca.blackList")}
                    <i class="material-icons right">{showBlacklistSettings ? "arrow_drop_up" : "arrow_drop_down"}</i>
                </a>
            </div>
            <div ref="showBlacklistSettings" class="columnForm bootcat-settings" style="display: none;">
                <div class="row">
                    <label for="bl_max_total_kw" class="col m4 s12 withHelp"}>
                        {_("ca.bl_max_total_kw")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.bl_max_total_kwHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="bl_max_total_kw"
                            name="bl_max_total_kw"
                            inline=1
                            riot-value={settings.bl_max_total_kw}></ui-input>
                    </span>
                </div>
                <div class="row">
                    <label for="bl_max_unique_kw" class="col m4 s12 withHelp"}>
                        {_("ca.bl_max_unique_kw")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.bl_max_unique_kwHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="bl_max_unique_kw"
                            name="bl_max_unique_kw"
                            inline=1
                            riot-value={settings.bl_max_unique_kw}></ui-input>
                    </span>
                </div>
                <div class="row">
                    <label for="black_list" class="col m4 s12 withHelp"}>
                        {_("blacklist")}
                        <i class="material-icons tooltipped help" data-tooltip={_("blWlListHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-textarea ref="black_list"
                            name="black_list"
                            inline=1
                            riot-value={settings.black_list}></ui-textarea>
                    </span>
                </div>
            </div>


            <div  class="center-align">
                <a class="btn btn-flat btn-waves" onclick={onSettingsToggle.bind(this, "whitelistSettings")} style="text-transform: none;">
                    {_("ca.whiteList")}
                    <i class="material-icons right">{whitelistSettings ? "arrow_drop_up" : "arrow_drop_down"}</i>
                </a>
            </div>
            <div ref="whitelistSettings" class="columnForm bootcat-settings" style="display: none;">
                <div class="row">
                    <label for="wl_min_total_kw" class="col m4 s12 withHelp"}>
                        {_("ca.wl_min_total_kw")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.wl_min_total_kwHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="wl_min_total_kw"
                            name="wl_min_total_kw"
                            inline=1
                            riot-value={settings.wl_min_total_kw}></ui-input>
                    </span>
                </div>
                <div class="row">
                    <label for="wl_min_unique_kw" class="col m4 s12 withHelp"}>
                        {_("ca.wl_min_unique_kw")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.wl_min_unique_kwHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="wl_min_unique_kw"
                            name="wl_min_unique_kw"
                            inline=1
                            riot-value={settings.wl_min_unique_kw}></ui-input>
                    </span>
                </div>
                <div class="row">
                    <label for="wl_min_kw_ratio" class="col m4 s12 withHelp"}>
                        {_("ca.wl_min_kw_ratio")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.wl_min_kw_ratioHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="wl_min_kw_ratio"
                            name="wl_min_kw_ratio"
                            inline=1
                            riot-value={settings.wl_min_kw_ratio}></ui-input>
                    </span>
                </div>
                <div class="row">
                    <label for="white_list" class="col m4 s12 withHelp"}>
                        {_("whitelist")}
                        <i class="material-icons tooltipped help" data-tooltip={_("blWlListHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-textarea ref="white_list"
                            name="white_list"
                            inline=1
                            riot-value={settings.white_list}></ui-textarea>
                    </span>
                </div>
            </div>

            <div  class="center-align">
                <a class="btn btn-flat btn-waves" onclick={onSettingsToggle.bind(this, "showRestrictionsSettings")} style="text-transform: none;">
                    {_("ca.sizeRestrictions")}
                    <i class="material-icons right">{showRestrictionsSettings ? "arrow_drop_up" : "arrow_drop_down"}</i>
                </a>
            </div>
            <div ref="showRestrictionsSettings" class="columnForm bootcat-settings" style="display: none;">
                <div class="row">
                    <label for="min_file_size" class="col m4 s12 withHelp"}>
                        {_("ca.min_file_size")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.min_file_sizeHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="min_file_size"
                            name="min_file_size"
                            inline=1
                            type="number"
                            validate=1
                            min=0
                            max=1000
                            on-input={refreshGoDisabled}
                            riot-value={settings.min_file_size}></ui-input>
                            <span class="hint">kB</span>
                    </span>
                </div>
                <div class="row">
                    <label for="max_file_size" class="col m4 s12 withHelp"}>
                        {_("ca.max_file_size")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.max_file_sizeHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="max_file_size"
                            name="max_file_size"
                            inline=1
                            type="number"
                            validate=1
                            min=0
                            max=15000
                            on-input={refreshGoDisabled}
                            riot-value={settings.max_file_size}></ui-input>
                            <span class="hint">kB</span>
                    </span>
                </div>
                <div class="row">
                    <label for="min_cleaned_file_size" class="col m4 s12 withHelp"}>
                        {_("ca.min_cleaned_file_size")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.min_cleaned_file_sizeHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="min_cleaned_file_size"
                            name="min_cleaned_file_size"
                            inline=1
                            type="number"
                            validate=1
                            min=0
                            max=1000
                            on-input={refreshGoDisabled}
                            riot-value={settings.min_cleaned_file_size}></ui-input>
                            <span class="hint">kB</span>
                    </span>
                </div>
                <div class="row">
                    <label for="max_cleaned_file_size" class="col m4 s12 withHelp"}>
                        {_("ca.max_cleaned_file_size")}
                        <i class="material-icons tooltipped help" data-tooltip={_("ca.max_file_sizeHelp")}>help_outline</i>
                    </label>
                    <span class="col m8 s12">
                        <ui-input ref="max_cleaned_file_size"
                            name="max_cleaned_file_size"
                            inline=1
                            type="number"
                            validate=1
                            min=1
                            max=15000
                            on-input={refreshGoDisabled}
                            riot-value={settings.max_cleaned_file_size}></ui-input>
                            <span class="hint">kB</span>
                    </span>
                </div>
            </div>


            <br>
            <div class="center-align">
                <br>
                <ui-checkbox on-change={onCompileWhenFinishedChange}
                        inline=1
                        checked=1
                        label={_("compileWhenFinished")}
                        style="margin-right: 0;"></ui-checkbox>
                <i class="material-icons tooltipped help" data-tooltip={_("compileWhenFinishedHelp")} style="font-size: 18px; vertical-align: top;">help_outline</i>
                <br>
                <a id="btnWebBootCaTCancel" class="btn btn-flat" onclick={opts.onCancel}>
                    {_("cancel")}
                </a>
                <a id="btnWebBootCaTGo" class="btn contrast disabled" onclick={onGoClick}>
                    {_("go")}
                </a>
            </div>
        </div>
    </div>


    <script>
        require("./ca-web-bootcat.scss")
        require("./ca-use-keywords-dialog.tag")
        require("./ca-seeds-url-dialog.tag")
        const {CAStore} = require("./castore.js")
        const {AppStore} = require("core/AppStore.js")

        this.mixin("tooltip-mixin")

        this.data = CAStore.data
        this.options = this.data.bootcat
        this.inputType = this.options.inputType || "seeds"
        this.seedWords = []
        this.showSettings = false
        this.showWebSearchSettings = false
        this.showshowBlacklistSettings = false
        this.whitelistSettings = false
        this.showRestrictionsSettings = false
        this.compileWhenFinished = true
        this.hasKeywords = AppStore.hasCorpusFeature("keywords")

        this.inputTypeList = [{
            value: "seeds",
            labelId: "ca.seeds"
        }, {
            value: "urls",
            labelId: "ca.urls"
        }, {
            value: "site",
            labelId: "ca.site"
        }]

        this.settings = {
            "min_file_size": 5,
            "max_file_size": 10000,
            "min_cleaned_file_size": 1,
            "max_cleaned_file_size": 5000,

            "wl_min_total_kw": 30,
            "wl_min_unique_kw": 10,
            "wl_min_kw_ratio": 0.1,
            "white_list": "",

            "bl_max_total_kw": 10,
            "bl_max_unique_kw": 3,
            "black_list": ""
        }
        this.defaultSettings = copy(this.settings)

        onSettingsToggle(settings){
            this[settings] = !this[settings]
            $(this.refs[settings]).toggle(settings)
        }

        onInputTypeChange(evt){
            this.inputType = evt.item.option.value
            CAStore.set("bootcat.inputType", this.inputType)
            this.update()
            this.refreshGoDisabled()
            $(".inputTypeOptions input:visible, .inputTypeOptions textarea:visible", this.root).focus()
        }

        onSeedsChange(value){
            if(value && value.indexOf(" ") != -1){
                // split by space, respect phrases in quotes
                let wordsFromValue = value.match(/"(?:\\"|[^"])+"|([^\s\\])+/g).map(word => {
                    return word.trim().replace(/\"/g, "")
                })
                this.seedWords = this.seedWords.concat(wordsFromValue)
                this.seedWords = [...new Set(this.seedWords)] // remove duplicities
                this.refs.seeds.update()
                $("input", this.refs.seeds.root).focus()
            } else {
                let chips = M.Chips.getInstance($(".chips", this.root));
                this.seedWords = chips.chipsData.map(c => {
                    return c.tag.trim()
                })
            }

            this.refreshSeedsHelp()
            this.refreshGoDisabled()
        }

        onOptionChange(value, name){
            CAStore.set("bootcat." + name, value)
        }

        onUseKeywordsClick(evt){
            Dispatcher.trigger("openDialog", {
                title: _("selectKeywords"),
                tag: "ca-use-keywords-dialog",
                fixedFooter: true,
                buttons: [{
                    label: _("use"),
                    class: "contrast",
                    onClick: function(dialog, modal){
                        this.seedWords = this.seedWords.concat(dialog.contentTag.selection)
                        this.seedWords = [...new Set(this.seedWords)] // remove duplicities
                        this.refs.seeds.update()
                        this.refreshSeedsHelp()
                        this.refreshGoDisabled()
                        modal.close()
                    }.bind(this)
                }]
            })
            evt.stopPropagation()
            evt.preventUpdate = true
        }

        onGoClick(evt){
            let settings = {}
            for(let key in this.settings){
                settings[key] = this.refs[key].getValue()
            }
            CAStore.set("compileWhenFinished", this.compileWhenFinished)

            if(this.inputType == "seeds"){
                Dispatcher.trigger("openDialog", {
                    title: _("selectUrls"),
                    fullScreen: true,
                    tag: "ca-seeds-url-dialog",
                    opts: {
                        corpus_id: this.opts.corpus.id,
                        seed_words: this.seedWords,
                        max_urls_per_query: this.refs.max_urls_per_query.getValue(),
                        sites_list: this.refs.sites_list.getValue(),
                        name: this.refs.fileset_name.getValue() || "",
                        settings: settings
                    }
                })
            } else{
                let value
                let key = this.inputType
                let name = this.refs.fileset_name.getValue()
                let params = {
                    input_type: this.inputType
                }
                if(this.inputType == "urls"){
                    value = []
                    this.refs.urls.getValue().replace(/\s/g, ' ').split(" ").map(word => {
                        let trimmed = word.trim()
                        if(trimmed){
                            value.push(this.addHttpToUrl(trimmed))
                        }
                    })
                } else{
                    value = this.addHttpToUrl(this.refs.site.getValue())
                }
                params[key] = value
                if(name){
                    params.name = name
                }

                Object.assign(params, settings)

                CAStore.startWebBootCaT(this.opts.corpus.id, params)
            }
        }

        onCompileWhenFinishedChange(checked){
            if(checked){
                SkE.showToast(_("compileWhenFinishedWarning"), 8000)
            }
            this.compileWhenFinished = checked
            this.update()
        }

        refreshSeedsHelp(){
            if(this.refs.seedsHint){
                let searchNumber = Math.round(factorial(this.seedWords.length) / (6 * factorial(this.seedWords.length - 3)))
                this.refs.seedsHint.innerHTML = (this.seedWords.length < 3) ? _("ca.seedsHint") : _("ca.seedsSearches", [searchNumber])
            }
        }

        refreshGoDisabled(){
            let disabled = !this.refs.fileset_name.getValue()
            if(this.inputType == "seeds"){
                disabled |= this.seedWords.length < 3
            } else if(this.inputType == "urls"){
                disabled |= this.refs.urls.getValue() == ""
            } else if(this.inputType == "site"){
                disabled |= this.refs.site.getValue() == ""
            }
            disabled |= !!$("input.invalid", this.root).length
            $("#btnWebBootCaTGo", this.root).toggleClass("disabled", !!disabled)
        }

        refreshFilesetName(){
            // set next fileset name to webXXX, where XXX is next free folder number.
            if(this.isMounted && !this.refs.fileset_name.getValue() && this.data.filesetsLoaded){
                let fileset_name = CAStore.getFreeFilesetName("web")
                if(fileset_name){
                    this.fileset_name = fileset_name
                    this.update()
                }
            }
        }

        addHttpToUrl(url){
            if(url.toLowerCase().substr(0, 4) != "http"){
                return "http://" + url
            }
            return url
        }

        this.on("updated", this.refreshSeedsHelp)

        this.on("mount", () => {
            $(".ui-chips input, input[type=text], textarea", this.root).first().focus()
            this.refreshFilesetName()
            this.refreshSeedsHelp()
            Dispatcher.on("toggleSettings", this.onSettingsToggle)
        })
        this.on("unmount", () => {
            Dispatcher.off("toggleSettings", this.onSettingsToggle)
        })
    </script>
</ca-web-bootcat>
