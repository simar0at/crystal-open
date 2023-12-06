class StoreMixin {

    constructor(){
        riot.observable(this);

        this.data = {}
    }

    get(path){
        // returns deep value
        // path - string eg. "some.deep.value" (returns this.data.some.deep.value))
        return this._getDataObject(path);
    }

    set(path, value){
        // sets deep value
        // path - string eg. "options.advanced.lpos"
        if(!path){
            throw "StoreMixin: tried to set value of undefined path"
        }
        const lastDotIdx = path.lastIndexOf(".");
        if(lastDotIdx != -1){
            // need to get object one level higher, to get reference to object and not value
            let obj = this._getDataObject(path.substring(0, lastDotIdx), true)
            obj[path.substring(lastDotIdx + 1)] = value;
        } else{
            this.data[path] = value;
        }
    }

    _getDataObject(path, create){
        //path = "data", "data.options",...
        //create - if path doesnt exist, create it
        if(!path){
            return this.data;
        } else{
            let obj = this.data;
            const parts = path.split(".");
            for (let i = 0; i < parts.length; i++) {
                let key = parts[i];
                if (typeof obj == "object" && obj !== null && key in obj) {
                    obj = obj[key];
                } else {
                    if(create/* && i < parts.length - 1*/){
                        obj[key] = {};
                        obj = obj[key];
                    } else {
                        return;
                    }
                }
           }
           return obj;
        }
    }
}

export {StoreMixin};
