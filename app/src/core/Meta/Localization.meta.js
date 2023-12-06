const LocalizationMeta = {
    default: "en",
    langs: [{
        id: 'en',
        label: 'English',
        labelEn: 'English'
    }, {
        id: 'fr',
        label: 'français',
        labelEn: 'French'
    }, {
        id: 'es',
        label: 'español',
        labelEn: 'Spanish'
    }, {
        id: 'cs',
        label: 'čeština',
        labelEn: 'Czech'
    }, {
        id: 'ar',
        label: 'العربية',
        labelEn: 'Arabic',
        dir: 'rtl'
    }, {
        id: 'de',
        label: 'Deutsch',
        labelEn: 'German'
    }, {
        id: 'it',
        label: 'Italiano',
        labelEn: 'Italian'
    }, {
        id: 'nko',
        label: 'ߒߞߏ',
        labelEn: 'Nko',
        dir: 'rtl'
    }]
}

const GetLangMeta = function(langId){
    let lang = LocalizationMeta.langs.find(function(lang) {
        return lang.id ==  langId
    })
    return lang || null;
}

export {LocalizationMeta, GetLangMeta}
