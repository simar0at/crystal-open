class ConnectionClass{

    get(request){
        if(request.loadingId){
            Dispatcher.trigger("LOADING_CHANGED", true, request.loadingId)
        }

        let xhrParams = this._getXhrParams(request)

        let xhr = $.ajax(xhrParams)
            .done(this._onDone.bind(this, request))
            .fail(this._onFail.bind(this, request))
            .always(this._onAlways.bind(this, request));

        request.xhr = xhr

        return request
    }

    abortRequest(request){
        request && request.xhr && request.xhr.abort()
    }

    download(request, format) {
        let xhrParams = this._getXhrParams(request)
        if (xhrParams.method == 'POST') {
            var form = document.createElement("form");
            form.action = request.url
            form.method = "POST"
            form.target = "_blank"
            if (typeof xhrParams.data == "string" && xhrParams.data.indexOf('json=') == 0) {
                var input = document.createElement("textarea")
                input.name = 'json'
                input.value = decodeURIComponent(xhrParams.data.substring(5))
                form.appendChild(input)
            }
            else {
                for (var key in xhrParams.data) {
                    var input = document.createElement("textarea")
                    input.name = key
                    input.value = typeof xhrParams.data[key] === "object" ?
                            JSON.stringify(xhrParams.data[key]) :
                            xhrParams.data[key]
                    form.appendChild(input)
                }
            }
            var input = document.createElement('textarea')
            input.name = 'format'
            input.value = format
            form.appendChild(input)
            form.style.display = 'none'
            document.body.appendChild(form)
            form.submit()
            // remove form from DOM?
        }
        else {
            window.open(xhrParams.url + '&format=' + format, "_blank" + (new Date).getTime())
        }
    }

    _getXhrParams(request){
        // returns object with params for ajax request
        let xhrParams = request.xhrParams || {}
        let url = this._createGETURL(request)

        if(xhrParams.method == "POST" || url.length > 2000){
            // POST or content is too long for URL -> send via POST data
            xhrParams.method = "POST"
            xhrParams.url = request.url || ""
            xhrParams.data = xhrParams.data || request.query
        } else{
            // GET method
            xhrParams.url = url
        }
        xhrParams.xhrFields = {withCredentials: true}
        xhrParams.crossDomain = true
        return xhrParams
    }

    _createGETURL(request){
        const url = request.url || "";
        let query = "";

        if(request.query){
            if(typeof request.query == "string"){
                query = request.query;
            } else if (typeof request.query == "object") {
                query = this._getUrlQuery(request.query);
            }
            query = this._addToQuery(query, "format", "json");
        }
        return url + (url.indexOf('?') >= 0 ? "" : "?") + query
    }

    _getUrlQuery(queryObj){
        let query = "";
        let val;

        // query can be defined as array or dictionary
        if(Array.isArray(queryObj)){
            queryObj.forEach((q) => {
                query = this._addToQuery(query, q.key, q.value)
            })
        } else{
            for(let key in queryObj){
                val = queryObj[key];
                if(val !== ""){
                    query = this._addToQuery(query, key, val)
                }
            }
        }
        return query;
    }

    _addToQuery(query, key, value){
        query += "&" + key + "=" + encodeURIComponent((typeof value == "boolean") ? (value + 0) : value);
        return query;
    }

    _onDone(request, payload){
        request.done && request.done(payload, request)
    }

    _onFail(request, payload){
        if(!request.skipDefaultCallbacks){
            if(request.xhr.statusText == "abort"){
                return
            }
            if(payload.status == 401){
                this._checkSessionAndRedirect(request, payload)
                return
            }
            if(payload.status == 403){
                this._checkSessionAndRedirect(request, payload, (authorized) => {
                    authorized && Dispatcher.trigger("ROUTER_GO_TO", "corpus")
                })
                return
            }
            if (payload.status == 504) {
                SkE.showError(_("err.responseTimeOut", ["<a id=\"openFeedbackLink\" class=\"link\">" + _("sendUsFeedback") + "</a>"]))
                delay(() => {$("#openFeedbackLink").click(() => {
                    Dispatcher.trigger("closeDialog")
                    Dispatcher.trigger('openDialog', {
                        tag: 'feedback-dialog',
                        title: _('fb.feedback'),
                        buttons: [{
                            label: _("send"),
                            class: "sendFeedbackBtn contrast",
                            onClick: (dialog) => {
                                dialog.contentTag.refs.feedback.send()
                            }
                        }]
                    })
                })}, 500) //  wait until dialog is open
            }
        }
        if(payload.status == 429){
            Dispatcher.trigger("FUPLimitReached")
            return
        }
        if(request.fail){
            request.fail(payload.responseJSON ? payload.responseJSON : payload, request);
        }
    }

    _onAlways(request, payload){
        if(request.xhr.statusText == "abort"){
            return
        }
        if(request.loadingId){
            Dispatcher.trigger("LOADING_CHANGED", false, request.loadingId);
        }
        if(request.always){
            request.always(payload, request);
        }
    }

    _checkSessionAndRedirect(request, payload, callback){
        Dispatcher.trigger("CHECK_SESSION_AND_REDIRECT", function(request, payload, authorized){
            if(authorized && request.fail){
                request.fail(payload.responseJSON ? payload.responseJSON : payload, request);
            }
            callback && callback(authorized, request, payload)
        }.bind(this, request, payload))
    }
}

export let Connection = new ConnectionClass();

