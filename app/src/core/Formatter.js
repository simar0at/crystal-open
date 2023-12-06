const {Localization} = require('core/Localization.js')

class FormatterClass{

    constructor(){
        this.refreshFormatters(Localization.getLocale());
        Dispatcher.on("LOCALIZATION_CHANGE", this.refreshFormatters.bind(this));
    }

    refreshFormatters(locale){
        this.locale = locale
        this.numFormat = new Intl.NumberFormat(locale, {})
        this.dateFormat = new Intl.DateTimeFormat(locale, {year: "numeric", month: "numeric", day: "numeric"})
        this.timeFormat = new Intl.DateTimeFormat(locale, {hour: "numeric", minute: "numeric", second: "numeric"})
        this.dateTimeFormat = new Intl.DateTimeFormat(locale, {year: "numeric", month: "numeric", day: "numeric", hour: "numeric", minute: "numeric", second: "numeric"})
    }

    num(num, options){
        if(options){
            if(typeof options == "number"){
                if(!this["numFormat" + options]){
                    this["numFormat" + options] = new Intl.NumberFormat(this.locale, {
                        minimumFractionDigits: options,
                        maximumFractionDigits: options
                    })
                }
                return this["numFormat" + options].format(num)
            } else {
               return new Intl.NumberFormat(this.locale, options).format(num)
            }
        }
        return this.numFormat.format(num);
    }

    date(dateObj, options){
        if(this._validDate(dateObj)){
            if(options){
                return new Intl.DateTimeFormat(this.locale, options).format(dateObj)
            }
            return this.dateFormat.format(dateObj)
        }
    }

    time(dateObj, options){
        if(this._validDate(dateObj)){
            return this.timeFormat.format(dateObj)
        }
    }

    dateTime(dateObj){
        if(this._validDate(dateObj)){
            return this.dateTimeFormat.format(dateObj)
        }
    }

    _validDate(dateObj){
        return !isNaN(dateObj.getTime())
    }

}

window.Formatter = new FormatterClass()
