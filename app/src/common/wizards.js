let introJs = require("intro.js")
let wizard_list = {}

wizard_list["newui"] = [
    {
        element: '#intro_lang_overview',
        intro: "You can just start by choosing a language...",
    },
    {
        element: '#intro_tutorial',
        intro: "...or watching a two-minute video with overview of Sketch Engine functions.",
    },
    {
        element: '.header-corpus .ui-input',
        intro: "At any time you can change the working corpus in this menu...",
    },
    {
        element: '[ref=link-advanced]',
        intro: "...or find a specific a corpus as well as create a new one in the advanced search.",
    },
    {
        element: '#header-menu-feedback',
        intro: "...or you can contact us if you have any problem or question through the form here.",
    },
	{
		element: '#menuDropdownButton',
		intro: "The language of the interface and other settings can be changed here.",
	},
	{
		element: '#menuDropdownButton',
		intro: "Here are your subscriptions and invoices. Your storage space for your own corpora can also be changed here.",
	},
    {
        element: '#header-menu-help',
        intro: "You can replay this wizard as well as find more guides, videos and documentation here.",
    }
];

for (let w in wizard_list) {
    let intro = introJs()
    intro.setOptions({steps: wizard_list[w]})
    wizard_list[w] = intro
}

export let intros = wizard_list
