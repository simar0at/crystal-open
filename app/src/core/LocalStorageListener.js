const {Localization} = require("core/Localization.js");
const {AppStore} = require("core/AppStore.js")

class LocalStorageListenerClass{

    constructor(){
        let t = setTimeout(() => {
            //async call -> wait for other code to load
            this.init()
            clearTimeout(t)
        });
    }

    init(){
        // listen to store events and save specific data to LocalStorage
        [
            // store, storeEvent, storageKey, selector

            [Localization, "change", "locale"],
            [AppStore, "corpusChanged", "corpname", this.getCorpname]
        ].forEach((item) => {
            let emitter = typeof item[0] == "string" ? window[item[0]] : item[0]; //emiter is object or global variable
            let event = item[1];
            let storageKey = item[2];
            let selector = item[3];
            if(emitter){
                emitter.on(event, (args) => {
                    let value = selector ? selector(args) : args;
                    if(value === null){
                        LocalStorage.remove(storageKey);
                    } else{
                        LocalStorage.set(storageKey, value);
                    }
                });
            }
        })
    }

    getCorpname(){
        return AppStore.getActualCorpname() || null
    }
}

let LocalStorageListener = new LocalStorageListenerClass()
