<reset-fup-dialog>
	{_("fupResetInfo")}
	<br><br>
	<div class="center-align">
		<preloader-spinner if={isLoading} center=1></preloader-spinner>
		<img if={image} src="data:image/png;base64,{image}"/>
		<button if={image}
				class="btn btn-flat btn-floating material-clickable"
				onclick={reloadCaptcha}
				style="vertical-align: top">
			<i class="material-icons">replay</i>
		</button>
		<br><br>
		<ui-input ref="input"
				label-id="texFromImage"
				inline={true}
				disabled={isLoading}
				on-input={refreshBtnDisabled}
				on-submit={resetFup}></ui-input>
		<button ref="btn"
				class="btn contrast disabled"
				onclick={onResetFupClick}>verify</button>
		<div class="red-text" style="position: relative;">
			<span>
				{!isReseting &&isIncorrect ? _("fupIncorrect") : "&nbsp"}
			</span>
			<span if={isReseting} class="inlineBlock" style="position: absolute; left: 50%; top: 15px; margin-left: -13px;">
				<preloader-spinner tiny=1></preloader-spinner>
			</span>
		</div>
	</div>


	<script>
		const {Connection} = require("core/Connection.js")

		this.isLoading = true
		this.isIncorrect = false
		this.isReseting = false

		reloadCaptcha(){
			this.isLoading = true
			this.isIncorrect = false
			Connection.get({
				url: window.config.URL_CA + "/other/get_captcha",
				xhrParams: {
					method: "POST",
					contentType: "application/json",
					data: JSON.stringify({})
				},
				done: (payload) => {
					this.image = payload.result.image
					this.hashed = payload.result.hashed
				},
				fail: (payload) => {
					SkE.showError(payload.error || _("somethingWentWrong"))
				},
				always: () =>{
					this.isLoading = false
					this.update()
					this.focus()
				}
			})
			this.update()
		}
		this.reloadCaptcha()

		onResetFupClick(evt){
			evt.preventUpdate = true
			this.resetFup()
		}

		resetFup(){
			if(this.isReseting){
				return
			}
			Connection.get({
				url: window.config.URL_CA + "/users/me/reset_fup",
				xhrParams: {
					method: "POST",
					contentType: "application/json",
					data: JSON.stringify({
						plaintext: this.refs.input.getValue(),
						hashed: this.hashed
					})
				},
				done: (payload) => {
					this.modalParent.close()
					Dispatcher.trigger("openDialog", {
						small: true,
						onTop: true,
						title: _("done"),
						content: _("fupResetDone"),
						buttons: [{
							label: _("reloadPage"),
							class: "contrast",
							onClick: () => {
								window.location.reload()
							}
						}]
					})
				},
				fail: (payload) => {
					if(payload.error == "INVALID_CAPTCHA"){
						this.isIncorrect = true
					} else {
						SkE.showError(payload.error || _("somethingWentWrong"))
					}
				},
				always: () => {
					this.isReseting = false
					this.update()
				}
			})
			this.isReseting = true
			this.update()
		}

		focus(){
			delay(() => {$("input", this.refs.input.root).focus()}, 1)
		}

		refreshBtnDisabled(value){
			this.refs.btn.classList.toggle("disabled", value === "")
		}
	</script>
</reset-fup-dialog>