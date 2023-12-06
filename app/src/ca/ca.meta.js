let CAMeta = {
    links:{
        create: [{
            href: "ca-create?created=1",
            labelId: "createCorpus"
        }, {
            href: "ca-create-content",
            labelId: "addTexts"
        }, {
            href: "ca-create-compile",
            labelId: "ca.compile"
        }],
        createMultiAligned: [{
            href: "ca-create",
            labelId: "createCorpus"
        }, {
            href: "ca-create-alignment",
            labelId: "alignment"
        }, {
            href: "ca-create-upload-aligned",
            labelId: "uploadData"
        }, {
            href: "ca-settings-aligned",
            labelId: "settings"
        }, {
            href: "ca-compile-aligned",
            labelId: "ca.compile"
        }],
        createMultiNonAligned: [{
            href: "ca-create",
            labelId: "createCorpus"
        }, {
            href: "ca-create-alignment",
            labelId: "alignment"
        }, {
            href: "ca-create-upload-nonaligned",
            labelId: "uploadData"
        }, {
            href: "ca-compile-aligned",
            labelId: "ca.compile"
        }]
    }
}

export {CAMeta}
