/*
   version 1.0
   usage:
   var cookieConsent = new SkE_CookieConsent()
   cookieConsent.run()
*/

function SkE_CookieConsent(){
   this.cookies = {
      "ske_cookieSettingsSaved": "necessary",
      "ske_cookieSetting_analytics": "necessary",
      "ske_cookieSetting_marketing": "necessary",
      "hideNotification": "necessary",

      "_ga": "analytics",
      "_gid": "analytics",
      "_gat": "analytics",
      "_gac": "analytics",
      "_ga_*": "analytics",
      "_gac_*": "analytics",

      "__gads": "marketing",
      "_gcl_au": "marketing",
      "_fbp": "marketing"
   }
   this.texts = {
      "cookie_bar_title": "Privacy preferences",
      "cookie_bar_desc": "This site uses cookies to offer you a better browsing experience. Find out more on how",
      "cookie_bar_desc_link": "we use cookies",
      "cookie_bar_btn_settings": "Individual privacy preferences",
      "cookie_settings": "Cookie settings",
      "necessary": "Essential",
      "analytics": "Statistics",
      "marketing": "Marketing",
      "necessary_info": "to browse the site and use its features",
      "analytics_info": "to collect information about how you use the site to improve its functions",
      "marketing_info": "to help advertisers deliver you more relevant advertising",
      "necessary_desc": "These cookies are essential for you to browse the website and use its features, such as accessing secure areas of the site or navigating around the site. Without them, you would not be able to use basic services",
      "analytics_desc": "These cookies collect information about how you use a website, such as which pages you visited and which links you clicked on. None of this information can be used to identify you. It is all aggregated and, therefore, anonymized. Their sole purpose is to improve website functions. This includes cookies from third-party analytics services as long as the cookies are for the exclusive use of the owner of the website visited.",
      "marketing_desc": "These cookies track your online activity to help advertisers deliver more relevant advertising or to limit how many times you see an ad. These cookies can share that information with other organizations or advertisers. These are persistent cookies and almost always of third-party provenance.",
      "settings_popup_desc": "A cookie is a small text file that a website stores on your computer or mobile device when you visit the site. This is in order to remember settings and preferences. For a period of time, you do not have to re-enter them when browsing around the site during the same visit. Cookies can also be used to establish anonymised statistics about the browsing experience on the site. <br><br>Further data processing may be done with your consent or on the basis of a legitimate interest, which you can object to in the individual privacy settings. You have the right to consent to essential services only and to modify or revoke your consent at a later time in the privacy policy. Your consent is also applicable on beta.sketchengine.eu, lexonomy.eu.<br><br><b>Embedded content from other websites</b><br>The site may include embedded content (e.g. videos, charts, etc.). Embedded content from other websites behaves in the exact same way as if the visitor visited the other website. These websites may collect data about you, use cookies, embed additional third-party tracking, and monitor your interaction with that embedded content, including tracing your interaction with the embedded content if you have an account and are logged in to that website.",
      "settings_popup_btn_save": "Save selection",
      "btn_reject_all": "Decline all",
      "btn_accept_all": "Accept all"
   }
   this.locale = "cs"
   this.cookieTypes = ["necessary", "analytics", "marketing"]
   this.optionalCookieTypes = ["analytics", "marketing"]
   this.cookieExpiredInDays = 10 * 365;


   this.run = function (language) {
      this._addStyles()
      document.addEventListener("DOMContentLoaded", function(event) {
         document.getElementsByTagName("body")[0].insertAdjacentHTML("beforeEnd", "<div id=\"SkE_CC\"></div>")
         if(this._getCookie("ske_cookieSettingsSaved") != "yes") {
            this._showCookieBar()
         }
      }.bind(this))
   }

   this.openSettings = function(){
      this._showCookieSettings()
   }

   this.setCookies = function(cookies){
      this.cookies = cookies
   }

   this._overrideDefaultCookies = function() {
      this.cookieDescriptor = Object.getOwnPropertyDescriptor(document, "cookie") ||
                             Object.getOwnPropertyDescriptor(HTMLDocument.prototype, "cookie");

      if (!this.cookieDescriptor) {
         this.cookieDescriptor = {};
         this.cookieDescriptor.get = HTMLDocument.prototype.__lookupGetter__("cookie");
         this.cookieDescriptor.set = HTMLDocument.prototype.__lookupSetter__("cookie");
      }

      Object.defineProperty(document, "cookie", {
         get:function(){
             return this.cookieDescriptor.get.apply(document);
         }.bind(this),
         set: function() {
            if (this._isCookieAllowed(arguments[0], true)) {
               this.cookieDescriptor.set.apply(document, arguments);
            }
         }.bind(this)
      })
   }

   this._getCookie = function(name) {
      name = name + "="
      var cookies = decodeURIComponent(document.cookie).split(';')
      for(var i = 0; i < cookies.length; i++) {
         var cookie = cookies[i].trim()
         if (cookie.indexOf(name) == 0) {
             return cookie.substring(name.length, cookie.length)
         }
     }
     return ""
   }

   this._saveCookie = function(name, value) {
      var date = new Date()
      date.setTime(date.getTime() + (this.cookieExpiredInDays * 24 * 60 * 60 * 1000))
      var expires = "expires=" + date.toUTCString()
      document.cookie = name + "=" + value + ";" + expires + ";path=/"
   }

   this._deleteCookie = function(name) {
      var domains = [window.location.hostname, '.' + window.location.hostname]
      if(window.location.hostname.slice(0, 4) === 'www.'){
          var non_www_domain = window.location.hostname.substr(4)
          domains.push(non_www_domain)
          domains.push('.' + non_www_domain)
      }
      domains.forEach(d => {
         this.cookieDescriptor.set.call(document, name + "=;expires=Thu, 01 Jan 1970 00:00:01 GMT;domain=" + d)
      }, this)
   }

   this._deleteDisabledCookies = function() {
      var allCookies = document.cookie.split(";");
      for (var i = 0; i < allCookies.length; i++){
         var name = allCookies[i].split("=")[0].trim();
         if (!this._isCookieAllowed(name, true)) {
            this._deleteCookie(name)
         }
      }
   }

   this._isCookieAllowed = function(cookie, splitCookie) {
      var allowed_types = {
         necessary: true
      }
      if(this.optionalCookieTypes.forEach(type => {
         allowed_types[type] = this._getCookie("ske_cookieSetting_" + type) == "yes"
      }))

      if(allowed_types.preference && allowed_types.analytics && allowed_types.marketing) {
         // everything is allowed
         return true
      }

      if(splitCookie){
         cookie = cookie.split("=")[0];
      }
      cookie = cookie.trim();
      var cookie_type = this.cookies[cookie]
      if(!cookie_type){
         // not the exact match, try to use regex
         for(var c in this.cookies){
            if(allowed_types[this.cookies[c]]){
               if(new RegExp(c).test(cookie)){
                  return true
               }
            }
         }
         return false
      } else {
         return allowed_types[cookie_type]
      }
   }

   this._showCookieSettings = function(){
      var cookieSettings = document.getElementById("SkE_CC_popup")
      if(cookieSettings){
         cookieSettings.style.display = "block"
      } else {
         var html = `<div id="SkE_CC_popup" class="ske_cc_popup_container">
            <div class="ske_cc_popup_overlay"></div>
            <div class="ske_cc_popup" style="display: block;">
               <a id="SkE_CC_popup_btn_close" href="#" class="ske_cc_popup_close ske_icon ske_icon_style_1">
                  <svg x="0px" y="0px" width="122.878px" height="20px" viewBox="0 0 123 123" enable-background="new 0 0 20 20" xml:space="preserve"><g><path d="M1.426,8.313c-1.901-1.901-1.901-4.984,0-6.886c1.901-1.902,4.984-1.902,6.886,0l53.127,53.127l53.127-53.127 c1.901-1.902,4.984-1.902,6.887,0c1.901,1.901,1.901,4.985,0,6.886L68.324,61.439l53.128,53.128c1.901,1.901,1.901,4.984,0,6.886 c-1.902,1.902-4.985,1.902-6.887,0L61.438,68.326L8.312,121.453c-1.901,1.902-4.984,1.902-6.886,0 c-1.901-1.901-1.901-4.984,0-6.886l53.127-53.128L1.426,8.313L1.426,8.313z"/></g></svg>
               </a>
               <div class="ske_cc_popup_text">
                  <div class="ske_cc_title ske_cc_title">${this.texts.cookie_settings}</div>
                  <p>${this.texts.settings_popup_desc}</p>
               </div>
               <div class="ske_cc_popup_settings">
            `

         for(var i = 0; i < this.cookieTypes.length; i++){
            var type = this.cookieTypes[i];
            html += `<div class="ske_cc_popup_item">
               <div class="ske_cc_popup_item_head" data-container="SkE_CC_popup_item-${i}" data-arrow="SkE_CC_popup_itemArrow-${i}">
                  <div class="ske_cc_switch_container ">
                     <div class="ske_cc_switch">
                        <label>
                           <input id="SkE_CC_popup_toggle_${type}" type="checkbox" name="${type}" checked="checked" ${type == "necessary" ? "disabled=disabled" : ""}">
                           <span class="lever"></span>
                           <b>${this.texts[type]}</b>
                        </label>
                     </div>
                     <div class="ske_cc_switch_info">
                        ${this.texts[type + "_info"]}
                     </div>
                  </div>
                  <span id="SkE_CC_popup_itemArrow-${i}" class="ske_cc_popup_arrow">
                  </span>
               </div>
               <div id="SkE_CC_popup_item-${i}" class="ske_cc_popup_item_text">${this.texts[type + "_desc"]}</div>
            </div>`
         }
         html += `</div>
               <div class="ske_cc_popup_buttons">
                  <a id="SkE_CC_popup_btn_save" class="ske_cc_btn ske_cc_btn_secondary" href="#">${this.texts.settings_popup_btn_save}</a>
                  <div class="ske_cc_popup_buttons_left">
                     <a id="SkE_CC_popup_btn_reject_all" class="ske_cc_btn ske_cc_btn_secondary ske_cc_popup_btn_reject_all" href="#">${this.texts.btn_reject_all}</a>
                     <a id="SkE_CC_popup_btn_accept_all" class="ske_cc_btn ske_cc_btn_primary ske_cc_popup_btn_accept_all" href="#">${this.texts.btn_accept_all}</a></div>
               </div>
            </div>
         </div>`
         document.getElementById("SkE_CC").insertAdjacentHTML("beforeEnd", html)
         document.getElementById("SkE_CC_popup_btn_close").onclick = function(evt){
            evt.preventDefault()
            this._hideCookieSettings()
            if(this._getCookie("ske_cookieSettingsSaved") != "yes"){
               this._showCookieBar()
            }
         }.bind(this)

         document.getElementById("SkE_CC_popup_btn_save").onclick = this._onCookieSettingSaveClick.bind(this)
         document.getElementById("SkE_CC_popup_btn_reject_all").onclick = this._onRejectAllCookiesClick.bind(this)
         document.getElementById("SkE_CC_popup_btn_accept_all").onclick = this._onAcceptAllCookiesClick.bind(this)

         var headList = document.getElementsByClassName("ske_cc_switch")
         for(var i = 0; i < headList.length; i++){
            headList[i].onclick = function(evt){
               // prevent description toggle
               evt.stopPropagation()
            }
         }
         headList = document.getElementsByClassName("ske_cc_popup_item_head")
         for(var i = 0; i < headList.length; i++){
            headList[i].onclick = this._slide_toggle
         }
      }

      this.optionalCookieTypes.forEach(type => {
         document.getElementById("SkE_CC_popup_toggle_" + type).checked = (this._getCookie("ske_cookieSetting_" + type) == "yes")
      })
   }

   this._showCookieBar = function(){
      var cookie_bar = document.getElementById("SkE_CC_bar")
      if(!cookie_bar){
         var html = `
            <div id="SkE_CC_bar">
               <div class="ske_cc_bar">
                  <div class="ske_cc_bar_text">
                     <div class="ske_cc_bar_title ske_cc_title">
                       ${this.texts.cookie_bar_title}
                     </div>
                     <p>${this.texts.cookie_bar_desc}
                        <a id="SkE_CC_bar_btn_more" class="ske_cc_btn_link ske_cc_bar_btn_settings" href="#">${this.texts.cookie_bar_desc_link}</a>.
                     </p>
                  </div>
                  <div class="ske_cc_bar_buttons">
                    <a id="SkE_CC_bar_btn_settings" class="ske_cc_btn_link ske_cc_bar_btn_settings" href="#">${this.texts.cookie_settings}</a>
                    <a id="SkE_CC_bar_btn_reject_all" class="ske_cc_btn ske_cc_btn_secondary ske_cc_bar_btn_reject_all" href="#">${this.texts.btn_reject_all}</a>
                    <a id="SkE_CC_bar_btn_accept_all" class="ske_cc_btn ske_cc_btn_primary  ske_cc_bar_btn_accept_all" href="#">${this.texts.btn_accept_all}</a>
                  </div>
               </div>
            </div>`
         document.getElementById("SkE_CC").insertAdjacentHTML("beforeEnd", html)
         document.getElementById("SkE_CC_bar_btn_settings").onclick = function(evt){
            evt.preventDefault()
            this._hideCookieBar()
            this._showCookieSettings()
         }.bind(this)
         document.getElementById("SkE_CC_bar_btn_more").onclick = function(evt){
            evt.preventDefault()
            this._hideCookieBar()
            this._showCookieSettings()
         }.bind(this)
         document.getElementById("SkE_CC_bar_btn_reject_all").onclick = this._onRejectAllCookiesClick.bind(this)
         document.getElementById("SkE_CC_bar_btn_accept_all").onclick = this._onAcceptAllCookiesClick.bind(this)
      } else {
         cookie_bar.style.display = "block"
      }
   }

   this._onCookieSettingSaveClick = function(evt){
      evt.stopPropagation()
      evt.preventDefault()
      this.optionalCookieTypes.forEach(type => {
         var value = document.getElementById("SkE_CC_popup_toggle_" + type).checked ? "yes" : "no"
         this._saveCookie("ske_cookieSetting_" + type, value);
      })
      this._saveCookie("ske_cookieSettingsSaved", "yes");
      this._hideCookieBar()
      this._hideCookieSettings()
      this._deleteDisabledCookies()
   }

   this._saveCookieSettings = function(value){
      this.optionalCookieTypes.forEach(type => {
         this._saveCookie("ske_cookieSetting_" + type, value);
      })
      this._saveCookie("ske_cookieSettingsSaved", "yes");
      this._hideCookieBar()
      this._hideCookieSettings()
      this._deleteDisabledCookies()
   }

   this._onRejectAllCookiesClick = function(evt){
      evt.preventDefault()
      this._saveCookieSettings("no")
   }

   this._onAcceptAllCookiesClick = function(evt){
      evt.preventDefault()
      this._saveCookieSettings("yes")
   }

   this._hideCookieBar = function(){
      var bar = document.getElementById("SkE_CC_bar")
      if(bar){
         bar.style.display = "none"
      }
   }

   this._hideCookieSettings = function(){
      var popup = document.getElementById("SkE_CC_popup")
      if(popup){
         popup.style.display = "none"
      }
   }

   this._slide_toggle = function(evt){
      evt.preventDefault();
      var container = document.getElementById(this.dataset.container);
      var arrow = document.getElementById(this.dataset.arrow);
      if (!container.classList.contains("active")) {
         container.classList.add("active");
         arrow.classList.add("active");
         container.style.height = "auto";
         var height = container.clientHeight + "px";
         container.style.height = "0px";
         setTimeout(function () {
            container.style.height = height;
         }, 0);
      } else {
         container.style.height = "0px";
         container.addEventListener("transitionend", function () {
            container.classList.remove("active");
            arrow.classList.remove("active");
         }, {
            once: true
         });
      }
   }

   this._addStyles = function(){
      var style = `<style>
         #SkE_CC .ske_cc_btn_link {
            text-decoration: underline;
            color: grey;
         }
         #SkE_CC .ske_cc_btn{
            display: inline-block;
            text-decoration: none;
            color: #fff;
            background-color: #b1b1b1;
            text-align: center;
            letter-spacing: .5px;
            border: none;
            border-radius: 2px;
            height: 36px;
            line-height: 36px;
            padding: 0 16px;
            white-space: nowrap;
            text-transform: uppercase;
             -webkit-box-shadow: 0 2px 2px 0 rgb(0 0 0 / 14%), 0 3px 1px -2px rgb(0 0 0 / 12%), 0 1px 5px 0 rgb(0 0 0 / 20%);
            box-shadow: 0 2px 2px 0 rgb(0 0 0 / 14%), 0 3px 1px -2px rgb(0 0 0 / 12%), 0 1px 5px 0 rgb(0 0 0 / 20%);
         }
         #SkE_CC .ske_cc_btn.ske_cc_btn_primary{
            background-color: #C52031;
         }
         #SkE_CC .ske_cc_bar,
         #SkE_CC .ske_cc_popup{
            background: #fff;
            color: #555;
            -moz-box-shadow: 0 0 30px rgba(0, 0, 0, 0.2);
            -webkit-box-shadow: 0 0 30px rgb(0 0 0 / 20%);
            box-shadow: 0 0 30px rgb(0 0 0 / 20%);
         }
         #SkE_CC .ske_cc_bar{
            bottom: 0;
            left: 0;
            width: 100%;
            align-items: center;
            justify-content: space-between;
            position: fixed;
            padding: 30px;
            font-size: 15px;
            line-height: 1.4em;
            z-index: 999999999;
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
            display: flex;
         }
         #SkE_CC .ske_cc_bar_text{
            padding-right: 50px;
         }
         #SkE_CC .ske_cc_bar_title{
            font-size: 24px;
            padding-bottom: 18px;
            color: #111;
            line-height: 1.4em;
         }
         #SkE_CC .ske_cc_bar_buttons{
            text-align: center;
            display: flex;
            flex-flow: column;
         }
         #SkE_CC .ske_cc_bar_btn_settings{
            margin-bottom: 15px;
         }
         #SkE_CC .ske_cc_bar_btn_reject_all{
            margin-bottom: 5px;
         }
         #SkE_CC .ske_cc_popup_overlay{
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 9999999998;
            background-color: #00000066;
         }
         #SkE_CC .ske_cc_popup{
            background-color: #fff;
            display: none;
            padding: 40px;
            font-size: 15px;
            line-height: 1.4em;
            z-index: 9999999999;
            -webkit-box-shadow: 0 0 20px 0 rgb(0 0 0 / 20%);
            box-shadow: 0 0 20px 0 rgb(0 0 0 / 20%);
            max-width: 790px;
            width: 90%;
            max-height: 95vh;
            overflow-y: scroll;
            overscroll-behavior: contain;
            box-sizing: border-box;
            position: fixed;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%,-50%);
            transform: translate(-50%,-50%);
            text-align: left;
         }
         #SkE_CC .ske_cc_popup_close {
            position: absolute;
            right: 20px;
            top: 20px;
            color: #888 !important;
            font-size: 19px;
         }
         #SkE_CC .ske_cc_popup_close svg{
            max-width: 20px;
            max-height: 20px;
         }
         #SkE_CC .ske_cc_title{
            font-size: 28px;
            padding-bottom: 15px;
            color: #111;
            line-height: 1.4em;
         }
         #SkE_CC .ske_cc_popup_buttons {
            padding-top: 30px;
            display: flex;
            justify-content: space-between;
         }
         #SkE_CC .ske_cc_popup_btn_reject_all{
            margin-right: 5px;
         }
         #SkE_CC .ske_cc_popup_item {
            border-bottom: 1px solid rgba(0,0,0,0.1);
         }
         #SkE_CC .ske_cc_popup_item_head {
            cursor: pointer;
            position: relative;
            padding: 0;
            padding-right: 50px;
         }
         #SkE_CC .ske_cc_switch_container {
            display: flex;
         }
         #SkE_CC .ske_cc_switch_container > *{
            line-height: 50px;
         }
         #SkE_CC .ske_cc_switch_info{
            color: #868686;
            padding-left: 20px;
         }
         #SkE_CC .ske_cc_switch{
            min-height: 50px;
            display: inline-block;
            color: #111;
            line-height: 20px;
            white-space: nowrap;
            -webkit-tap-highlight-color: transparent;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
         }
         #SkE_CC .ske_cc_switch label{
            color: #111;
            cursor: pointer;
            display: inline-block;
            line-height: 50px;
         }
         #SkE_CC .ske_cc_switch input{
            opacity: 0;
            width: 0;
            height: 0;
         }
         #SkE_CC .ske_cc_switch .lever{
            background-color: #84c7c1;
            content: "";
            display: inline-block;
            position: relative;
            width: 36px;
            height: 14px;
            background-color: rgb(177 177 177);
            border-radius: 15px;
            margin-right: 10px;
            -webkit-transition: background 0.3s ease;
            transition: background 0.3s ease;
            vertical-align: middle;
         }
         #SkE_CC .ske_cc_switch label input[type=checkbox]:checked+.lever{
            background-color: rgb(223 133 142);
         }
         #SkE_CC .ske_cc_switch .lever:before,
         #SkE_CC .ske_cc_switch .lever:after{
            content: "";
            position: absolute;
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            left: 0;
            top: -3px;
            -webkit-transition: left 0.3s ease, background .3s ease, -webkit-box-shadow 0.1s ease, -webkit-transform .1s ease;
            transition: left 0.3s ease, background .3s ease, -webkit-box-shadow 0.1s ease, -webkit-transform .1s ease;
            transition: left 0.3s ease, background .3s ease, box-shadow 0.1s ease, transform .1s ease;
            transition: left 0.3s ease, background .3s ease, box-shadow 0.1s ease, transform .1s ease, -webkit-box-shadow 0.1s ease, -webkit-transform .1s ease;
         }
         #SkE_CC .ske_cc_switch .lever:before{
            background-color: #c5203126!important;
            border: none;
         }
         #SkE_CC .ske_cc_switch .lever:after{
            background-color: #F1F1F1;
            -webkit-box-shadow: 0px 3px 1px -2px rgb(0 0 0 / 20%), 0px 2px 2px 0px rgb(0 0 0 / 14%), 0px 1px 5px 0px rgb(0 0 0 / 12%);
            box-shadow: 0px 3px 1px -2px rgb(0 0 0 / 20%), 0px 2px 2px 0px rgb(0 0 0 / 14%), 0px 1px 5px 0px rgb(0 0 0 / 12%);
         }
         #SkE_CC .ske_cc_switch label input[type=checkbox]:checked+.lever:before,
         #SkE_CC .ske_cc_switch label input[type=checkbox]:checked+.lever:after{
            left: 18px;
         }
         #SkE_CC .ske_cc_switch label input[type=checkbox]:checked+.lever:after{
            background-color: rgb(205 74 87);
         }
         #SkE_CC .ske_cc_switch label input[type=checkbox][disabled]+.lever{
            cursor: default;
            background-color: rgba(0,0,0,0.12);
         }
         #SkE_CC .ske_cc_switch label input[type=checkbox][disabled]+.lever:after,
         #SkE_CC .ske_cc_switch label input[type=checkbox][disabled]:checked+.lever:after{
            background-color: #949494;
         }
         #SkE_CC .ske_cc_popup_item_text {
            transition: height 0.35s ease-in-out;
            overflow: hidden;
         }
         #SkE_CC .ske_cc_popup_item_text:not(.active) {
            display: none;
         }
         #SkE_CC .ske_cc_popup_arrow{
            border-right: 1px solid rgba(0,0,0,0.2);
            border-bottom: 1px solid rgba(0,0,0,0.2);
            width: 10px;
            height: 10px;
            display: block;
            transform: rotate(45deg);
            position: absolute;
            top: 50%;
            right: 10px;
            margin-top: -7px;
         }
         #SkE_CC .ske_cc_popup_arrow.active{
            transform: rotate(-135deg);
         }
         #SkE_CC .ske_cc_popup_item_text {
            padding-bottom: 15px;
            padding-left: 69px;
         }
         @media screen and (max-width: 767px){
            #SkE_CC .ske_cc_bar,
            #SkE_CC .ske_cc_popup_buttons{
               flex-flow: column;
               align-items: stretch;
            }
            #SkE_CC .ske_cc_bar_text {
               padding-right: 0;
            }
            #SkE_CC .ske_cc_bar_buttons{
               text-align: left;
               padding-top: 30px;
            }
            #SkE_CC .ske_cc_popup{
               padding: 20px;
            }
            #SkE_CC .ske_cc_switch_container{
               flex-direction: column;
            }
            #SkE_CC .ske_cc_switch_info{
               padding-left: 50px;
            }
            #SkE_CC .ske_cc_popup_buttons_left{
               display: flex;
               margin-top: 15px;
            }
            #SkE_CC .ske_cc_popup_buttons_left .ske_cc_btn {
               width: 50%;
               flex-grow: 1;
            }
         }
      </style>`
      document.head.insertAdjacentHTML("beforeend", style)
   }

   this._overrideDefaultCookies()
}
window.SkE_CookieConsent = new SkE_CookieConsent()
window.SkE_CookieConsent.run()
