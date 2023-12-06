const {Connection} = require('core/Connection.js')
const {AppStore} = require("core/AppStore.js")
const {StoreMixin} = require("core/StoreMixin.js")
const {AsyncResults} = require("core/asyncresults.js")
const {Url} = require("core/url.js")
require("./ca-space-dialog.tag")

class CAStoreClass extends StoreMixin {
    constructor(){
        super()
        this.EMPTY_POST = {
            method: "POST",
            contentType: "application/json",
            data: JSON.stringify({})
        }
        this._reset()
        this._refreshCorpus()
        AppStore.on("corpusChanged", this._onCorpusChange.bind(this))
        Dispatcher.on("GRAMMAR_CREATED", this.loadSketchGrammars.bind(this))
    }

    updateUrl(){
        this.corpus && Url.updateQuery({corpname: this.corpus.corpname})
    }

    allFilesetsReady(){
        return !this.data.filesets.some(fileset => {
            return !this.isFilesetReady(fileset)
        }, this)
    }

    isFilesetReady(fileset){
        return (fileset.progress == 100 || fileset.progress == -1) && !fileset.verticalInProgress
    }

    loadFilesets(corpus_id){
        if(this.data.requests["filesets_" + corpus_id]){
            return
        }
        this.data.filesWithoutfFolderLoaded = false
        this.data.requests["filesets_" + corpus_id] = Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets",
            xhrParams:{method: "GET"},
            done: (payload) => {
                this.data.requests["filesets_" + corpus_id] = null
                this._onFilesetsLoaded(payload)
                this._startFolderUploadedChecking(corpus_id)
                this._startFilesetsChecking(corpus_id)
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadFilesetFiles(corpus_id, fileset_id){
        let r_id = "files_" + corpus_id
        this.data.requests[r_id] && this._cancelPreviousRequest(r_id)
        this.data.filesLoading = true
        this.data.requests[r_id] = Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents?fileset_id=" + fileset_id,
            done: this._onFilesLoaded.bind(this, corpus_id),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadFile(corpus_id, file_id){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_id,
            done: this._onFileLoaded.bind(this, file_id),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadSomefile(somefile_id){
        return Connection.get({
            query: {},
            url: window.config.URL_CA + "somefiles/" + somefile_id
        })
    }

    loadTagSets(language_id){
        this.data.isTagsetsLoading = true
        Connection.get({
            url: window.config.URL_CA + "tagsets?language_id=" + language_id,
            done: this._onTagsetsLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadActualTagSet(){
        if(!this.data.tagset || this.data.tagset.id != this.corpus.tagset_id){
            Connection.get({
                url: window.config.URL_CA + "tagsets/" + this.corpus.tagset_id,
                done: this._onActualTagsetLoaded.bind(this),
                fail: this._defaultOnFail.bind(this)
            })
        }
    }

    loadSketchGrammars(corpus_id){
        if(!this.data.isSketchGrammarsLoading){
            this.data.isSketchGrammarsLoading = true
            Connection.get({
                url: window.config.URL_CA + "sketch_grammars?corpus_id=" + corpus_id,
                done: this._onSketchGrammarsLoaded.bind(this),
                fail: this._defaultOnFail.bind(this)
            })
        }
    }

    loadSketchGrammar(grammar_id, onDone){
        Connection.get({
            url: window.config.URL_CA + "sketch_grammars/" + grammar_id,
            done: onDone,
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadTerms(corpus_id){
        Connection.get({
            url: window.config.URL_CA + "sketch_grammars?corpus_id=" + corpus_id + "&is_term=1",
            done: this._onTermsLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadSharing(corpus_id){
        this.data.filesLoaded = false
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/sharing",
            done: this._onSharingLoaded.bind(this),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadFileContent(corpus_id, file_id, type, start){
        // type = plaintext | vertical
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_id + "/" + type,
            xhrParams: {
                "headers": {
                    Range: "bytes=" + start + "-"
                },
                "Content-Type": "text/plain"
            },
            done: (payload, request) => {
                let tmp = request.xhr.getResponseHeader("Content-Range").split("-")[1].split("/")
                let loaded = Math.min(tmp[0], tmp[1])
                let total = tmp[1]
                this.trigger("fileContentLoaded", payload, loaded, total)
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    createCorpus(name, language_id, tagset_id, info){
        return Connection.get({
            url: window.config.URL_CA + "corpora",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    language_id: language_id,
                    tagset_id: tagset_id,
                    name: name,
                    info: info || ""
                })
            },
            done: this._onCorpusCreated.bind(this),
            fail: this._onCorpusCreateFail.bind(this)
        }).xhr
    }

    createGrammar(grammar){
        Connection.get({
            url: window.config.URL_CA + "sketch_grammars",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(grammar)
            },
            done: payload => {
                SkE.showToast(_("grammarCreated", [payload.data.name]), 8000)
                if(payload.data.is_term){
                    this.loadTerms(this.corpus.id)
                } else {
                    this.loadSketchGrammars(this.corpus.id)
                }
            },
            fail: (payload) => {
                SkE.showError(payload.error == "INVALID_FORMAT" ? _("grammarInvalidFormat") : payload.error)
            }
        })
    }

    updateSharing(corpus_id, sharing){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/sharing",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(sharing)
            },
            done: this._onSharingSaved.bind(this)
        })
    }

    updateCompilerSettings(corpus_id, settings, done){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id,
            xhrParams:{
                method: "PUT",
                data: JSON.stringify(settings)
            },
            done: done,
            fail: this._defaultOnFail.bind(this)
        })
    }

    uploadFiles(corpus_id, files){
        let startUpload = false
        if(!this.data.uploadInProgress){
            let fileset = this._getFilesetUploaded()
            startUpload = true
            fileset.progress = 0
            this.data.uploadInProgress = true
            this.data.filesToUpload = []
            this.data.totalFiles = 0
        }
        this.data.filesToUpload = this.data.filesToUpload.concat(files)
        this.data.totalFiles += files.length

        if(startUpload){
            this.trigger("isUploadingChange", this.data.uploadInProgress)
            this.trigger("filesetsChanged")
            this._uploadNextFile(corpus_id)
        }
    }

    cancelFileJob(corpus_id, document_id){
        let file = this._getFileById(document_id)
        file.progress = -1
        file.cancelling = true
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + document_id + "/cancel_job",
            xhrParams: this._getEmptyXhrParams(),
            fail: this._defaultOnFail.bind(this)
        })
    }

    uploadAlignedDataFile(file){
        let formData = new FormData()
        formData.append("file", file)
        return Connection.get({
            url: window.config.URL_CA + "somefiles",
            xhrParams: {
                method: "POST",
                processData: false,
                contentType: false,
                data: formData
            }
        })
    }

    changeAlignedDataSettings(somefile_id, settings){
        return Connection.get({
            url: window.config.URL_CA + "somefiles/" + somefile_id,
            xhrParams: {
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify(settings)
            }
        }).xhr
    }

    uploadPlainText(corpus_id, text){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    plaintext: text
                })
            },
            done:() => {
                this._onFilesUploadFinished(corpus_id)
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    deleteFileset(corpus_id, fileset_id){
        if(this.data.activeFilesetId == fileset_id){
            this.setActiveFilesetId(corpus_id, null)
        }
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets/" + fileset_id,
            xhrParams:{method: "DELETE"},
            done: this._onFilesetDeleted.bind(this, fileset_id),
            fail: function(fileset_id, payload){
                let fileset = this._getFileset(fileset_id)
                fileset.deleteInProgress = false
                this._defaultOnFail(payload)
                this.trigger("filesetsChanged")
            }.bind(this, fileset_id)
        })
    }

    deleteFiles(corpus_id, file_ids, fileset_id, all_file_ids){
        file_ids = Array.isArray(file_ids) ? file_ids : [file_ids]
        all_file_ids = isDef(all_file_ids) ? all_file_ids : file_ids.slice()
        // delete files in batch of 100 max. Otherwise url length limit might be reached
        let file_ids_str = file_ids.splice(0, 100).join(",")  // file IDs joined with ","
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_ids_str,
            xhrParams:{method: "DELETE"},
            done: function(corpus_id, file_ids, fileset_id){
                if(file_ids.length){
                    this.deleteFiles(corpus_id, file_ids, fileset_id, all_file_ids)
                } else {
                    this._onFileDeleted(corpus_id, all_file_ids, fileset_id)
                }
            }.bind(this, corpus_id, file_ids, fileset_id, all_file_ids),
            fail: this._defaultOnFail.bind(this)
        })
    }

    loadFilePreview(corpus_id, file_id, parameters){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_id + "/preview",
            xhrParams:{
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(parameters)
            },
            done: function(file_id, payload){
                payload.result = payload.result.substr(0, 1000)
                this.trigger("filePreviewLoaded", file_id, payload.result)
            }.bind(this, file_id),
            fail: function(payload){
                this._defaultOnFail(payload)
                this.trigger("filePreviewLoadFail")
            }.bind(this)
        })
    }

    loadFilePlaintextPreview(corpus_id, file_id, parameters){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_id + "/plaintext",
            always: function(file_id, payload){
                this.trigger("filePlaintextPreviewLoadFinished", file_id, payload)
            }.bind(this, file_id)
        })
    }

    updateFile(corpus_id, file){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file.id,
            xhrParams:{
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify(file)
            },
            done: function(corpus_id, payload){
                let file = payload.data
                this.data.files[this._getFileIndex(file.id)] = file
                this._startFolderUploadedChecking(corpus_id)
                this.startFileChecking(corpus_id, file.id)
                this._checkIfCompilationIsNeeded()
                this.trigger("filesChanged", this.data.files)
            }.bind(this, corpus_id),
            fail: this._defaultOnFail.bind(this)
        })
    }

    expandArchive(corpus_id, file_id){
        let idx = this._getFileIndex(file_id)
        this.data.files.splice(idx, 1)
        this.trigger("filesChanged", this.data.files)
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + file_id + "/expand_archive",
            xhrParams: this._getEmptyXhrParams(),
            done: (payload) => {
                this.loadFilesets(corpus_id)
                this.one("filesetsChanged", this.trigger.bind(this, "fileExpanded", payload.result))
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    getFreeFilesetName(template){
        // searches in filesets names for fileset.name = "templateXXX", where XXX is number
        // returns "templateXXX+1" for greatest XXX found
        if(this.data.filesetsLoaded){
            let lastFilesetNumber = 0
            let templateLength = template.length
            this.data.filesets.forEach(function(fileset){
                if(fileset.name.substr(0, templateLength).toLowerCase() == template){
                    let num = parseInt(fileset.name.substr(templateLength), 10)
                    if(!isNaN(num) && num > lastFilesetNumber){
                        lastFilesetNumber = num
                    }
                }
            })
            return template + (lastFilesetNumber + 1)
        }
        return null
    }

    getTotalWordCount(){
        return this.data.filesets.reduce((total, fileset) => {
            return total += fileset.word_count
        }, 0)
    }

    getAttributeList(){
        let attributes = []
        this.data.files.forEach(f => {
            for(let key in f.metadata){
                attributes.push(key)
            }
        })
        return [...new Set(attributes)].map(key => ({value: key, label: key}))
    }

    setActiveFilesetId(corpus_id, fileset_id){
        if(this.data.activeFilesetId !== fileset_id){
            this.data.activeFilesetId = fileset_id
            this.data.filesLoaded = false
            if(fileset_id !== null){
                this.data.files.forEach(f => {
                    this._stopAsyncResults(`corpus_${corpus_id}_document_${f.id}`)
                }, this)
                this.loadFilesetFiles(this.corpus.id, fileset_id)
            }
            this.trigger("activeFilesetChanged")
        }
    }

    saveFilesMetadata(corpus_id, data){
        return Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents",
            xhrParams: {
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify(data)
            },
            done: payload => {
                payload.data.forEach(file => {
                    let idx = this._getFileIndex(file.id)
                    if(idx != -1){
                        Object.assign(this.data.files[idx], file)
                    }
                }, this)
                SkE.showToast("saved")
                this._checkIfCompilationIsNeeded()
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    compileCorpus(corpus_id, data){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/compile",
            xhrParams: {
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(data || {})
            },
            done: this.checkCorpusStatus.bind(this, corpus_id)
        })
    }

    cancelCompilation(corpus_id){
        this._cancelPreviousRequest("check")
        this._stopAsyncResults("corpus_" + corpus_id)
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/cancel_job",
            xhrParams: this._getEmptyXhrParams(),
            done: this.checkCorpusStatus.bind(this, corpus_id)
        })
    }

    checkCorpusStatus(corpus_id){
        if(this.data.asyncResults["corpus_" + corpus_id]){
            return // already checking
        }
        let callback = function(corpus_id, payload){
            let progress = payload.result.progress

            if(this.corpus && this.corpus.id == corpus_id){
                if(progress <= 0 || progress == 100){
                    AppStore.loadCorpus(this.corpus.corpname)
                    AppStore.loadCorpusList()
                    return
                }
            }
            Dispatcher.trigger("CA_CORPUS_PROGRESS", corpus_id, progress, payload)
        }.bind(this, corpus_id)

        this.data.asyncResults["corpus_" + corpus_id] = new AsyncResults()
        this.data.asyncResults["corpus_" + corpus_id].check({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/get_progress",
            xhrParams: this._getEmptyXhrParams(),
            isFinished: (payload) => {
                return payload.result.progress == 100 || payload.result.progress <= 0
            },
            checkOnStart: true,
            onStop: this.set.bind(this, "asyncResults.corpus_" + corpus_id, null),
            onData: callback,
            onComplete: callback,
            interval: 2000,
            intervalStep: 1000,
            intervalMax: 10000
        })
    }

    upgradeTagset(){
        this.data.upgradeTagsetInProgress = true
        SkE.showToast(_("ca.tagsetUpgradeStarted"), 8000)
        return Connection.get({
            url: window.config.URL_CA + "corpora/" + this.corpus.id + "/upgrade_tagset",
            xhrParams: this._getEmptyXhrParams(),
            done: () => {
                SkE.showToast(_("ca.tagsetUpgradeFinished"), 8000)
                this.data.upgradeTagsetInProgress = false
                AppStore.loadCorpus(this.corpus.corpname)
            },
            fail: this._defaultOnFail.bind(this)
        })
    }

    upgradeTermDef(){
        return Connection.get({
            url: window.config.URL_CA + "corpora/" + this.corpus.id + "/upgrade_termdef",
            xhrParams: this._getEmptyXhrParams(),
            done: (payload) => {
                if(payload.error){
                    SkE.showToast(payload.error, 8000)
                } else {
                    SkE.showToast(_("ca.termdefUpgradeFinished"), 8000)
                }
                AppStore.loadCorpus(this.corpus.corpname)
            }
        })
    }

    loadUrlsFromSeeds(corpus_id, params){
         Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets/search_seeds",
            xhrParams:{
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(params)
            },
            done: function(payload){
                this.trigger("urlsFromSeedsLoaded", payload)
            }.bind(this),
            fail: this._defaultOnFail.bind(this),
        })
    }

    startWebBootCaT(corpus_id, params){
        Dispatcher.trigger("BOOTCAT_STARTING", true)
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets"
                    + (this.data.compileWhenFinished ? "?compile_when_finished=1" : ""),
            xhrParams:{
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(params)
            },
            done: function(corpus_id, payload){
                if(!this._getFileset(payload.data.id)){
                    // webcrawl started, initialize progress
                    this.data.filesets.unshift(Object.assign(payload.data, {
                        progress: 1,
                        time_est_str: "..."
                    }))
                }
                this._startFilesetChecking(corpus_id, payload.data.id)
                this.trigger("filesetsChanged")
                this.trigger("webBotCaTStarted")
            }.bind(this, corpus_id),
            fail: this._defaultOnFail.bind(this),
            always: Dispatcher.trigger.bind(null, "BOOTCAT_STARTING", false)
        })
        SkE.showToast(_("ca.webBootCaTStarted"))
    }

    cancelFilesetProcess(corpus_id, fileset_id){
        if(fileset_id == 0){
            this.data.filesToUpload = []
        } else {
            CAStore.cancelWebBootCaT(corpus_id, fileset_id)
        }
    }

    cancelWebBootCaT(corpus_id, fileset_id){
        let fileset = this._getFileset(fileset_id)
        fileset.progress = -1
        fileset.cancelling = true
        this._stopAsyncResults(corpus_id + "_" + fileset_id)
        Connection.get({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets/"+ fileset_id + "/cancel_job",
            xhrParams: this._getEmptyXhrParams(),
            done: () => {
                this.loadFilesets(corpus_id)
                this.trigger("filesetsChanged")
            }
        })
    }

    startLogChecking(corpus_id){
        if(this.data.asyncResults.log){
            return // already checking
        }
        this._updateLog("")
        let callback = (payload) => {
            let log = typeof payload == "string" ? payload : ""
            if(!this.corpus.isCompiling && !log){
                this.stopLogChecking()
            }
            this._updateLog(log)
        }
        this.data.asyncResults.log = new AsyncResults()
        this.data.asyncResults.log.check({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/logs/last.log",
            isFinished: (payload) => {
                return !this.corpus.isCompiling
            },
            onStop: this.set.bind(this, "asyncResults.log", null),
            onData: callback,
            onComplete: callback,
            interval: 1000
        })
    }

    stopLogChecking(corpus_id){
        this._stopAsyncResults("log")
    }

    turnOffExpertMode(){
        Connection.get({
            url: window.config.URL_CA + "corpora/" + this.corpus.id,
            loadingId: "EXPERT_MODE_OFF",
            xhrParams: {
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify({expert_mode: false})
            },
            done: () => {
                this.corpus.expert_mode = false
                this.trigger("expertModeOff")
            },
            fail: payload => {
                SkE.showError(_("ca.updateCorpusError"), getPayloadError(payload))
            }
        })
    }

    _startFilesChecking(corpus_id){
        this.data.files.forEach(file => {
            if(file.vertical_progress > 0 && file.vertical_progress < 100){
                this.startFileChecking(corpus_id, file.id)
            }
        }, this)
    }

    startFileChecking(corpus_id, document_id, onComplete){
        let ar_id = `corpus_${corpus_id}_document_${document_id}`
        if(this.data.asyncResults[ar_id]){
            return // already checking
        }
        this.data.asyncResults[ar_id] = new AsyncResults()
        this.data.asyncResults[ar_id].check({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents/" + document_id + "/get_progress",
            xhrParams: this._getEmptyXhrParams(),
            isFinished: (payload) => {
                return payload.result.progress == 100 || payload.result.progress <= 0
            },
            checkOnStart: true,
            onStop: this.set.bind(this, "asyncResults." + ar_id, null),
            onData: function(corpus_id, document_id, payload){
                let idx = this._getFileIndex(document_id)
                if(this.corpus && this.corpus.id == corpus_id && idx != -1){
                    this.data.files[idx].vertical_progress = payload.result.progress
                    this.data.files[idx].inProgress = payload.result.progress > 0 && payload.result.progress < 100
                    this.trigger("filesChanged")
                }
            }.bind(this, corpus_id, document_id),
            onComplete: onComplete || this.loadFile.bind(this, corpus_id, document_id),
            interval: 2000,
            intervalStep: 1000,
            intervalMax: 10000
        })
    }

    _uploadNextFile(corpus_id){
        if(this.data.filesToUpload.length){
            let delayTime = 2500
            if(this.data.totalFiles <= 20 ){
                delayTime = 1500
            } else if(this.data.totalFiles <= 10){
                delayTime = 0
            }
            delay(function(corpus_id){
                // wait some time to prevent hitting FUP limit
                let formData = new FormData()
                formData.append("file", this.data.filesToUpload.pop())
                Connection.get({
                    url: window.config.URL_CA + "corpora/" + corpus_id + "/documents",
                    xhrParams: {
                        method: "POST",
                        processData: false,
                        contentType: false,
                        data: formData
                    },
                    done: this._onFileUploaded.bind(this),
                    always: function(payload){
                        let error = payload.responseJSON && payload.responseJSON.error
                        if(!payload.data || error){
                            if(error == "QUOTA_EXCEEDED"){
                                Dispatcher.trigger("openDialog", {
                                    title: _("allSpaceUsed"),
                                    tag: "ca-space-dialog"
                                })
                            } else if(error == "DAILY_TAGGING_EXCEEDED"){
                                Dispatcher.trigger("openDialog", {
                                    tag: "external-text",
                                    opts: {text: "daily_tagging_exceeded.html"}
                                })
                            }
                            this.data.filesToUpload = []
                            this.data.totalFiles = 0
                            this._onFilesUploadFinished(corpus_id)
                        } else{
                            this._uploadNextFile(corpus_id)
                        }
                    }.bind(this)
                })

            }.bind(this, corpus_id), delayTime)
        } else{
            this._onFilesUploadFinished(corpus_id)
        }
    }

    _startFilesetsChecking(corpus_id){
        if(this.data.filesetsLoaded){
            this.data.filesets.forEach(fileset => {
                if(fileset.progress < 100 && fileset.progress != -1){ //error
                    this._startFilesetChecking(corpus_id, fileset.id, {data: fileset})
                }
            })
        }
    }

    _startFilesetChecking(corpus_id, fileset_id, payload){
        if(this.get("asyncResults." + corpus_id + "_" + fileset_id)){
            return // already checking
        }
        // fileset is being crawled / exctracted, check status periodically, until progress==100
        let callback = function(corpus_id, fileset_id, payload){
            this._startSpaceChecking()
            let d = payload ? (payload.data || payload.result) : {}
            this._onFilesetProgressChange(corpus_id, fileset_id, d)
            if(d.progress == 100){
                Dispatcher.trigger("RELOAD_USER_SPACE")
                this._setAsyncResult(corpus_id, fileset_id, null)
                if(this.data.compileWhenFinished){
                    AppStore.loadCorpus(this.corpus.corpname)
                    AppStore.loadCorpusList()
                    Dispatcher.trigger("ROUTER_GO_TO", "ca-compile")
                }
            } else if(d.error){
                Dispatcher.trigger("RELOAD_USER_SPACE")
                SkE.showToast(d.error)
            }
        }.bind(this, corpus_id, fileset_id)

        let asyncResults = new AsyncResults()
        this._setAsyncResult(corpus_id, fileset_id, asyncResults)
        asyncResults.check({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/filesets/"+ fileset_id + "/get_progress",
            xhrParams: this._getEmptyXhrParams(),
            isFinished: (payload) => {
                let d = payload.data || payload.result || {}
                return d.progress == 100 || d.progress == -1 || d.error
            },
            nextTimeout:(payload) => {
                if(!payload.result.time_elapsed){
                    return 5000 // no webcrawl, other kind of processing -> default timeout
                }
                // set next checkout according to estimated remaining time
                let seconds = payload.result.time_elapsed / payload.result.progress * 100
                if(seconds < 20){
                    return 2000
                } else if(seconds < 60){
                    return 4000
                } else if(seconds < 120){
                    return 6000
                } else if(seconds < 240){
                    return 8000
                } else {
                    return 10000
                }
            },
            onStop: this._setAsyncResult.bind(this, corpus_id, fileset_id, null),
            onData: callback,
            onComplete: callback
        }, payload)
    }

    _startSpaceChecking(corpus_id){
        if(!this.spaceCheckHandle){
            this.spaceCheckHandle = setInterval(function(){
                Dispatcher.trigger("RELOAD_USER_SPACE")
                let isChecking = false
                for(let key in this.data.asyncResults){
                    if(this.data.asyncResults[key]){
                        isChecking = true
                        break
                    }
                }
                !isChecking && clearInterval(this.spaceCheckHandle)
            }.bind(this), 5000)
            Dispatcher.one("ROUTER_CHANGE", function() {
                clearInterval(this.spaceCheckHandle)
            }.bind(this))
        }
    }

    _startFolderUploadedChecking(corpus_id){
        if(this.get("asyncResults." + corpus_id + "_0")){
            return // already checking
        }

        let callback = function(payload){
            let changed = !this.data.filesWithoutfFolderLoaded
            this.data.filesWithoutfFolderLoaded = true
            if(payload.data && payload.data.length){
                let fileset = this._getFilesetUploaded()
                fileset.word_count = payload.data.reduce((sum, file) => {
                    return sum + file.word_count
                }, 0)
                fileset.verticalInProgress = payload.data.filter(f => {
                    return f.vertical_progress > 0 && f.vertical_progress < 100
                }).length
                this.trigger("filesetsChanged")
                Dispatcher.trigger("RELOAD_USER_SPACE")
            } else {
                let fileset = this._getFileset(0)
                if(fileset){
                    fileset.verticalInProgress = false
                }
                changed && this.trigger("filesetsChanged")
            }
        }.bind(this)
        let asyncResults = new AsyncResults()
        this._setAsyncResult(corpus_id, 0, asyncResults)
        asyncResults.check({
            url: window.config.URL_CA + "corpora/" + corpus_id + "/documents?fileset_id=0",
            isFinished: (payload) => {
                return !this.data.filesToUpload.length && (!payload.data || !payload.data.filter(f => {
                    return f.vertical_progress > 0 && f.vertical_progress < 100
                }).length)
            },
            checkOnStart: true,
            onStop: this._setAsyncResult.bind(this, corpus_id, 0, null),
            onData: callback,
            onComplete: callback,
            interval: 2000,
            intervalStep: 1000,
            intervalMax: 15000
        })
    }

    _cancelPreviousRequest(type){
        let activeRequest = this.data.requests[type]
        if(activeRequest){
            Connection.abortRequest(activeRequest)
            this.data.requests[type] = null
        }
    }

    _stopAsyncResults(selector){
        let asyncResults = this.get("asyncResults." + selector)
        if(asyncResults){
            asyncResults.stop()
            this.set(selector, null)
        }
    }

    _defaultOnFail(payload, request){
        if(request.xhr.status == 429){
            return
        }
        let message = ""
        if(typeof payload.message == "string"){
            message = payload.message
        }
        if(payload.messages){
            for(let key in payload.messages){
                payload.messages[key].forEach(m => {
                    message += (message ? "<br>" : "") + _("ca." + key) + ": " + m
                })
            }
        }
        SkE.showToast(message || payload.error)
    }

    _onCorpusCreated(payload){
        this.data.error = payload.data.error ? payload.data.error : ""
        this.data.corpus = payload.data
        this.trigger("corpusCreated", this.data.corpus)
    }

    _onCorpusCreateFail(payload){
        this.corpus = null
        this.error = payload.error || payload
        this.trigger("corpusCreateFail")
    }

    _onFilesetsLoaded(payload){
        this.data.filesetsLoaded = true
        this.data.filesets = payload.data
        this.trigger("filesetsChanged")
    }

    _onFilesetDeleted(fileset_id){
        let idx = this._getFilesetIdx(fileset_id)
        let fileset = this.data.filesets[idx]
        this.data.filesets.splice(idx, 1)
        SkE.showToast(_("ca.filesetWasDeleted", [fileset.name]))
        this.trigger("filesetsChanged")
        Dispatcher.trigger("RELOAD_USER_SPACE")
    }

    _onFileLoaded(file_id, payload){
        this._computeFileData(payload.data)
        this.data.files[this._getFileIndex(file_id)] = payload.data
        if(this.data.activeFilesetId === 0){
            let fileset = this._getFilesetUploaded()
            fileset.word_count = this.data.files.reduce((sum, file) => {
                return sum + file.word_count
            }, 0)
        } else {
            this._startFolderUploadedChecking(this.corpus.id)
        }
        Dispatcher.trigger("RELOAD_USER_SPACE")
        this.trigger("filesChanged")
    }

    _onTagsetsLoaded(payload){
        this.data.isTagsetsLoading = false
        this.data.tagsets = payload.data
        this.trigger("tagsetsLoaded", this.data.tagsets)
    }

    _onActualTagsetLoaded(payload){
        this.data.tagset = payload.data
        this.trigger("actualTagsetLoaded")
    }

    _onSketchGrammarsLoaded(payload){
        this.data.isSketchGrammarsLoading = false
        this.data.sketchGrammars = payload.data
        this.trigger("change", this.data)
    }

    _onTermsLoaded(payload){
        this.data.terms = payload.data
        this.trigger("change", this.data)
    }

    _onFilesetProgressChange(corpus_id, fileset_id, data){
        let fileset = this._getFileset(fileset_id)
        if(fileset){
            if(this.data.activeFilesetId == fileset_id){
                // reload files, there could be some new
                this.loadFilesetFiles(corpus_id, fileset_id)
            }
            let time_est = ((data.time_elapsed / data.progress) * 100) - data.time_elapsed
            Object.assign(fileset, {
                progress: data.progress,
                time_est: time_est,
                time_est_str: secondsToString(time_est),
                word_count: data.word_count || 0
            })
            this.trigger("filesetsChanged")
        }
    }

    _onFileUploaded(payload){
        let fileset = this._getFilesetUploaded()
        fileset.progress = Math.round((1 - this.data.filesToUpload.length / this.data.totalFiles) * 100)
        if(this.data.activeFilesetId === 0){
            this.data.files.unshift(payload.data)
            this.startFileChecking(this.corpus.id, payload.data.id)
        } else {
            this._startFolderUploadedChecking(this.corpus.id)
        }
        this.trigger("filesetsChanged")
    }

    _onFilesUploadFinished(corpus_id){
        this.data.uploadInProgress = false
        let fileset = this._getFilesetUploaded(0)
        fileset.progress = 100
        fileset.verticalInProgress = 1
        this._startFolderUploadedChecking(corpus_id)
        this.data.activeFilesetId == 0 && this._startFilesChecking(corpus_id)
        this.trigger("filesetsChanged")
        this.trigger("isUploadingChange", false)
        Dispatcher.trigger("RELOAD_USER_SPACE")
    }

    _onFileDeleted(corpus_id, all_file_ids, fileset_id){
        let index
        let filename_display
        all_file_ids.forEach(file_id => {
            index = this._getFileIndex(file_id)
            if (index > -1) {
                if(isDef(fileset_id)){
                    let fileset = this.data.filesets[this._getFilesetIdx(fileset_id)]
                    if(fileset){
                        fileset.word_count -= this.data.files[index].word_count
                    }
                }
                filename_display = this.data.files[index].filename_display
                this.data.files.splice(index, 1)
            }
        }, this)
        if(all_file_ids.length == 1){
            index != -1 && SkE.showToast(_("ca.fileWasDeleted", [filename_display]))
        } else {
            SkE.showToast(_("ca.filesWereDeleted", [all_file_ids.length]))
        }
        this.trigger("filesChanged", this.data.files)
        Dispatcher.trigger("RELOAD_USER_SPACE")
    }

    _onFilesLoaded(corpus_id, payload){
        this.data.filesLoaded = true
        this.data.filesLoading = false
        this.data.files = payload.data
        this.data.files.forEach(this._computeFileData.bind(this))
        this._startFilesChecking(corpus_id)
        this.trigger("filesChanged", this.data.files)
    }

    _computeFileData(file){
        file.inProgress = file.vertical_progress > 0 && file.vertical_progress < 100
        file.isArchive = ["tar", "zip"].includes(file.parameters.type)
    }

    _onSharingLoaded(payload){
        this.data.sharingLoaded = true
        this.data.sharing = payload.data
        this.trigger("sharingChanged", this.data.sharing)
    }

    _onSharingSaved(payload){
        this.data.sharing = payload.data
        this.trigger("sharingChanged", this.data.sharing)
    }

    _onCorpusChange(){
        if(this.corpus && this.corpus.corpname !== AppStore.getActualCorpname()){
            this._reset()
        }
        this._refreshCorpus()
    }

    _getFilesetUploaded(){
        let fileset = this._getFileset(0)
        if(fileset){
            return fileset
        }
        fileset = {
            name: "upload",
            id: 0,
            progress: 100,
            word_count: 0
        }
        this.data.filesets.push(fileset)
        return fileset
    }

    _getFilesetIdx(fileset_id){
        return this.data.filesets.findIndex(fileset => {
            return fileset.id == fileset_id
        })
    }

    _getFileIndex(file_id){
        return this.data.files.findIndex(file => {
            return file.id == file_id
        })
    }

    _getFileById(file_id){
        return this.data.files[this._getFileIndex(file_id)]
    }

    _getFileset(fileset_id){
        return this.data.filesets[this._getFilesetIdx(fileset_id)]
    }

    _updateLog(log){
        this.data.log = log
        this.trigger("logChanged")
    }

    _setAsyncResult(corpus_id, fileset_id, asyncResult){
        this.set("asyncResults." + corpus_id + "_" + fileset_id, asyncResult)
    }

    _refreshCorpus(){
        this.corpus = AppStore.getActualCorpus()
    }

    _checkIfCompilationIsNeeded(){
        // was compiled earlier, it is not a new corpus, but it changed and needs to be compiled
        if(this.corpus.compiled && !AppStore.get("corpus.needs_recompiling")){
            AppStore._loadCorpusCA(this.corpus.corpname)
            AppStore.one("corpusChanged", () => {
                Dispatcher.trigger('openDialog', {
                    small: true,
                    title: _("db.toCompileTitle"),
                    content: _("changedRecompile")
                })
            })
        }
    }

    _getEmptyXhrParams(){
        return {
            method: "POST",
            contentType: "application/json",
            data: "{}"
        }
    }

    _reset(){
        this.data = {
            error: "",
            corpus: null,
            sketchGrammars: null,
            terms: null,
            tagset: null,
            files: [],
            requests: {},
            filesets: [],
            asyncResults: {}, // object with references to asyncResults
            filesetsLoaded: false,
            filesLoaded: false,
            filesLoading: false,
            uploadInProgress: false,
            sharingLoaded: false,
            space_used: null,
            compileWhenFinished: false,
            spaceCheckHandle: null,
            filesToUpload: [],
            totalFiles: 0,
            isTagsetsLoading: false,
            upgradeTagsetInProgress: false,
            filesWithoutfFolderLoaded: false,
            activeFilesetId: null,
            bootcat: {
                max_urls_per_query: 30,
                tuple_size: 3,
                sites_list: ""
            }
        }
    }
}

export let CAStore = new CAStoreClass()

