class LocalStorageClass {
    constructor(){
        this.prefix = "SKE_";
    }

    get(key){
        let value = localStorage.getItem(this.prefix + key);
        try{
            return JSON.parse(value)
        } catch(e){
            return value
        }
    }

    set(key, value){
        let valueToSave = value;
        if(typeof value == "object"){
            valueToSave = JSON.stringify(value);
        }
        localStorage.setItem(this.prefix + key, valueToSave);
    }

    remove(key){
        localStorage.removeItem(this.prefix + key);
    }
}

window.LocalStorage = new LocalStorageClass();