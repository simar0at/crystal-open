<introduction class="introduction">
    <div class="modal" id="intro_modal">
        <div class="modal-content valign-wrapper" style="height: 70vh">
            <div class="center-align valign" style="margin: auto;">
                <h1 id="welcome">Welcome!</h1>
                <img id="intro_logo" src="images/logo_blue.png" loading="lazy">
                <div id="first_time">
                    <h3>First time in our new interface?</h3>
                    <div id="cards">
                        <div class="hoverable card" style="background-color: #a3f2b1;" name="novice" onclick={onIntroStart}>Yes, show me how to use it in one minute!</div>
                        <div class="hoverable card" style="background-color: #fae471;" name="existing" onclick={onDismissNow}>Dismiss now, but show up next time.</div>
                        <div class="hoverable card" style="background-color: #ff8b8b;" onclick={onDismiss}>Dismiss forever.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        require("./introduction.scss")
        const {intros} = require("common/wizards.js")
        const {UserDataStore} = require("core/UserDataStore.js")
        const jQueryPulse = require("libs/jquery/jquery.pulsate.min.js")

        this.on("mount", () => {
            $("#intro_modal").modal({dismissible: false})
            $("#intro_modal").modal("open")
            $("#welcome").delay(1000).fadeIn(1000).delay(1000).fadeOut(1000, () => {
                $("#intro_logo").show()
                $("#first_time").show()
                $("#intro_logo").css({"transform": "scale(0.5)", "opacity": "100"})
                delay(() => {
                    $("#first_time").css({"opacity": 100})
                }, 2000)
            })
        })

        onDismiss() {
            UserDataStore.saveGlobalData({"skipWizard": 1})
            $("#intro_modal").modal("close")
            intros["newui"].goToStepNumber(8).start()
        }

        onDismissNow() {
            $("#intro_modal").modal("close")
        }

        onIntroStart (event) {
            $("#intro_modal").modal("close")
            intros["newui"].oncomplete(function () {
                UserDataStore.saveGlobalData({"skipWizard": 1})
            }).start()
        }
    </script>
</introduction>
