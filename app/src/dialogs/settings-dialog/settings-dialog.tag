<settings-dialog-general>
    <div class="row">
        <div class="col m5 s12 input-label">
            {_("opts.density")}
        </div>
        <div class="col m7 s12">
            <ui-select
                options={densityOptions}
                value={settings.density}
                name="density"
                on-change={parent.onOptionChange}></ui-select>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("language")}
        </div>
        <div class="col m7 s12">
            <ui-select
                options={languageOptions}
                value={settings.language}
                name="language"
                on-change={parent.onOptionChange}></ui-select>
        </div>
    </div>

    <virtual if={isFullAccount}>
        <div class="row">
            <div class="col m5 s12 input-label">
                {_("opts.lexEmail")}
            </div>
            <div class="col m7 s12">
                <ui-input
                    riot-value={settings.lexonomyEmail}
                    name="lexonomyEmail"
                    placeholder="@"
                    on-change={parent.onOptionChange}>
                </ui-input>
            </div>
        </div>

        <div class="row">
            <div class="col m5 s12 input-label">
                {_("opts.lexKey")}
            </div>
            <div class="col m7 s12">
                <ui-input
                    riot-value={settings.lexonomyApiKey}
                    name="lexonomyApiKey"
                    on-change={parent.onOptionChange}>
                </ui-input>
            </div>
        </div>

        <div class="row">
            <div class="col m5 s12 input-label">
                {_("reset")}
            </div>
            <div class="col m7 s12 input-label">
                <a id="btnResetSettings" class="link" disabled={isResetDisabled} onclick={onReset}>{_("opts.resetLabel")}</a>
            </div>
        </div>
    </virtual>

    <script>
        const {SettingsStore} = require("core/SettingsStore.js")
        const {Localization} = require('core/Localization.js')
        const {LocalizationMeta} = require('core/Meta/Localization.meta.js')
        const {Auth} = require("core/Auth.js")
        this.isFullAccount = Auth.isFullAccount()
        this.email = Auth.getEmail()

        refreshAttributes(){
            this.settings = SettingsStore.getAll()
            this.isResetDisabled = !SettingsStore.hasUserSettings()
        }
        this.refreshAttributes()

        this.densityOptions = ["low", "medium", "high"].map((density) => {
            return {
                value: density,
                label: _(density)
            }
        })

        this.languageOptions = LocalizationMeta.langs.map((lang) => {
            return {
                value: lang.id,
                label: lang.label
            }
        })

        onLanguageChange(language){
            SettingsStore.changeSettings({
                language: language
            })
        }

        onLexonomyChangeEmail(email){
            SettingsStore.changeSettings({
                lexonomyEmail: email
            })
        }

        onLexonomyChangeApiKey(key){
            SettingsStore.changeSettings({
                lexonomyApiKey: key
            })
        }

        onReset(){
            if(!this.isResetDisabled){
                SettingsStore.resetSettings()
            }
        }

        this.on("update", this.refreshAttributes)
    </script>
</settings-dialog-general>

<!-- TODO: remove -->
<settings-dialog-wordlist>
    <div class="row">
        <div class="col m5 s12 input-label">
            {_("minFreq")}
        </div>
        <div class="col m7 s12">
            <ui-input
                value={}
                type="number"
                name="wlminfreq"
                on-change={onOptionChange}
                size=5></ui-input>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("maxFreq")}
        </div>
        <div class="col m7 s12">
            <ui-input
                value=
                type="number"
                name="wlmaxfreq"
                on-change={onOptionChange}
                size=5></ui-input>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("ignorecase")}
        </div>
        <div class="col m7 s12 input-field">
            <ui-checkbox
                checked={wordlist.wlicase}
                name="wlicase"
                on-change={onOptionChange}></ui-checkbox>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("includeNonwords")}
        </div>
        <div class="col m7 s12 input-field">
            <ui-checkbox
                checked={wordlist.include_nonwords}
                name="include_nonwords"
                on-change={onOptionChange}></ui-checkbox>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("reset")}
        </div>
        <div class="col m7 s12 input-label">
            <a id="btnReset" class="link" disabled={isResetDisabled} onclick={onReset}>{_("opts.resetLabel")}</a>
        </div>
    </div>

    <script>

        this.wordlist = {}

    </script>
</settings-dialog-wordlist>

<!-- TODO: remove -->
<settings-dialog-thesaurus>
    <div class="row">
        <div class="col m5 s12 input-label">
            {_("th.maxThesItems")}
        </div>
        <div class="col m7 s12">
            <ui-input
                value={thesaurus.maxthesitems}
                type="number"
                name="maxthesitems"
                on-change={onOptionChange}
                size=5></ui-input>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("th.minThesScore")}
        </div>
        <div class="col m7 s12">
            <ui-input
                value={thesaurus.minthesscore}
                type="number"
                name="minthesscore"
                on-change={onOptionChange}
                size=5></ui-input>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("th.minThesSim")}
        </div>
        <div class="col m7 s12">
            <ui-input
                value={thesaurus.minsim}
                type="number"
                name="minsim"
                on-change={onOptionChange}
                size=5></ui-input>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("th.clusteritems")}
        </div>
        <div class="col m7 s12 input-field">
            <ui-checkbox
                checked={thesaurus.clusteritems}
                name="clusteritems"
                on-change={onOptionChange}></ui-checkbox>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("th.includeHeadword")}
        </div>
        <div class="col m7 s12 input-field">
            <ui-checkbox
                checked={thesaurus.includeHeadword}
                name="includeHeadword"
                on-change={onOptionChange}></ui-checkbox>
        </div>
    </div>

    <div class="row">
        <div class="col m5 s12 input-label">
            {_("reset")}
        </div>
        <div class="col m7 s12 input-label">
            <a class="link" disabled={isResetDisabled} onclick={onReset}>{_("opts.resetLabel")}</a>
        </div>
    </div>

    <script>

        this.thesaurus = {}

    </script>
</settings-dialog-thesaurus>




<settings-dialog class="settings-dialog">
    <h4>{_('settings')}</h4>
    <small style="opacity: 0.6; position: relative; top:-10px;">{savingMsg}&nbsp;</small>
    <div class="content">
        <div class="row dense" style="position: relative;">
            <!--span class="verticalLine col offset-m3 hide-on-small-only"></span>
            <div class="col m3 s12">
                <ul class="menu">
                    <li each={section in sections} class={active: section.id == this.actualSection}>
                        <a onclick={onSectionClick}>{_(section.label)}</a>
                    </li>
                </ul>
            </div-->

            <div class="col m9 s12">
                <div data-is={"settings-dialog-" + actualSection} class="settingsSection"></div>
            </div>
        </div>
    </div>

    <script>
        require("./settings-dialog.scss")
        const {SettingsStore} = require("core/SettingsStore.js")

        this.actualSection = "general"
        this.sections = [{
            label: "general",
            id:"general"
        }, {
            label: "wordlist",
            id:"wordlist"
        },{
            label: "thesaurus",
            id:"thesaurus"
        }]
        this.savingMsg = ""

        refreshAttributes(){
            this.settings = SettingsStore.getAll()
            this.isResetDisabled = !SettingsStore.hasUserSettings()
        }
        this.refreshAttributes()


        onSectionClick(evt){
            this.actualSection = evt.item.section.id
        }

        onReset(){
            if(!this.isResetDisabled){
                SettingsStore.resetSettings()
            }
        }

        onOptionChange(value, name){
            SettingsStore.changeSettings({
                [name]: value,
                noToast: true
            })
            if(this.isFullAccount){
                this.savingMsg = _("saving")
                this.update()
            }
        }

        settingsSaved(){
            this.savingMsg = _("opts.allSaved")
            clearTimeout(this.handle)
            this.handle = setTimeout(function(){
                this.savingMsg = ""
                this.mounted && this.update()
            }.bind(this), 5000)
            this.update()
        }

        this.on("update", this.refreshAttributes)

        this.on("mount", () => {
            SettingsStore.on("settingsSaved", this.settingsSaved)
            SettingsStore.on("change", this.update)
        })

        this.on("unmount", () => {
            SettingsStore.off("change", this.update)
            SettingsStore.off("settingsSaved", this.settingsSaved)
        })
    </script>
</settings-dialog>
