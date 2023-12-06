<page-not-allowed>
    <div class="card" style="margin: 40px auto 0; max-width: 600px;">
        <div class="card-content z-depth-5" style="background-color:#f2f2f2;">
            <h3>{_("na.title")}</h3>
            <div>
                {_(notLogged ? "na.notLogged" : "na.logged")}
            </div>
            <br>
            <div class="center-align">
                <a href="{window.config.URL_RASPI}" if={notLogged} class="btn contrast">
                    {_("login")}
                </a>
                <a href="#dashboard" class="btn contrast">
                    {_("goToDashboard")}
                </a>
            </div>
        </div>
    </div>

    <script>
        const {Auth} = require("core/Auth.js")

        this.notLogged = Auth.isAnonymous()
    </script>
</page-not-allowed>
