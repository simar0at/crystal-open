<feedback-dialog class="feedback-dialog">
    <div if={sent} class="feedbackSent">
        <br>{_("fb.sent")}<br>
    </div>

    <div if={!sent}>
        {_("fb.info")}
        <feedback-form ref="feedback"
                on-done={onFeedbackSent}
                on-fail={onFeedbackFail}
                on-valid-change={onFeedbackValidChange}></feedback-form>
    </div>

    <script>
        this.sent = false

        onFeedbackSent(){
            this.sent = true
            this.update()
            jQuery(".modal-dialog .feedback-dialog").parent().find("h4").html(capitalize(_("success")))
            $(".modal-dialog a.sendFeedbackBtn").hide()
        }

        onFeedbackFail(){
            this.sent = false
            this.update()
        }

        onFeedbackValidChange(isValid){
            $(".sendFeedbackBtn").toggleClass("disabled", !isValid)
        }
    </script>
</feedback-dialog>
