require('libs/mousetrap/mousetrap.min.js') //https://craig.is/killing/mice
const {HotkeysMeta} = require("core/Meta/Hotkeys.meta.js")


class HotkeysClass{
    constructor(){
        Dispatcher.on("ROUTER_CHANGE", this._refreshBindings.bind(this))
        this._refreshBindings()
    }

    _refreshBindings(actualPage){
        Mousetrap.reset();
        for(let feature in HotkeysMeta){
            if(feature == "global" || feature == actualPage){
                HotkeysMeta[feature].bindings.forEach((keyCfg) => {
                    Mousetrap.bind(keyCfg.key, (evt, key) => {
                        evt.preventDefault()
                        let args = [keyCfg.event]
                        if(Array.isArray(keyCfg.args)){
                            args = args.concat(keyCfg.args)
                        } else{
                            args.push(keyCfg.args)
                        }
                        Dispatcher.trigger.apply(null, args)
                    }, "keyup")
                })
            }
        }
    }
}
export let Hotkeys = new HotkeysClass();
