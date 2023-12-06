const {AppStore} = require('core/AppStore.js')
const {FeatureStoreMixin} = require("core/FeatureStoreMixin.js")
const {Auth} = require('core/Auth.js')
const {Connection} = require('core/Connection.js')
const {Url} = require("core/url.js")

class AnnotationStoreClass extends FeatureStoreMixin {
    constructor () {
        super()

        this.feature = "annotation"
        this.annotconc = ""
        this.queries = []
        this.labels = []
        this.nsublabels = 0
        this.lngroup2label = {}
        this.nodes = {}
        this.schema = null
        this.model = null
        this.loading_queries = false
        this.annotation_group = ""
        this.slotid = -1
        this.labelidx = -1

        Dispatcher.on("AUTH_LOGIN", function () {
            this.annotation_group = Auth.getAnnotationGroup()
            if (this.corpus && this.corpus.corpname) {
                this.model = this.models[this.annotation_group] || this.models.generic
                this.schema = this.schemas[this.annotation_group] || this.schemas.generic
                this.getAnnotations()
            }
        }.bind(this))
        Dispatcher.on("CORPUS_INFO_LOADED", function (payload) {
            this.corpus = payload
            if (this.annotation_group) {
                this.model = this.models[this.annotation_group] || this.models.generic
                this.schema = this.schemas[this.annotation_group] || this.schemas.generic
                this.getAnnotations()
            }
        }.bind(this))
        Dispatcher.on("ROUTER_CHANGE", this._onPageChange.bind(this))

        // TODO: attribute auto not necessary?
        this.schemas = {
            generic: [
                {id: 'query', type: 'string', label: 'annotation'},
                {id: 'label_count', type: 'num', auto: true},
                {id: 'size', type: 'num', label: 'freq'},
                {id: 'status', type: 'string'},
                {id: 'edited', type: 'datetime', label: 'edited'},
                {id: 'editor', type: 'string', label: 'editor'},
            ],
            pdev: [
                {id: 'query', type: 'string', label: 'verb'},
                {id: 'label_count', type: 'num', auto: true, label: 'patternCount'},
                {id: 'size', type: 'num', label: 'freq', desc: true},
                {id: 'status', type: 'string'},
                {id: 'sample', type: 'num', label: 'sample'},
                {id: 'edited', type: 'datetime', label: 'edited'},
                {id: 'editor', type: 'string', label: 'editor'},
            ],
            tpas: [
                {id: 'query', type: 'string', label: 'annotation'},
                {id: 'label_count', type: 'num', auto: true},
                {id: 'size', type: 'num', label: 'freq'},
                {id: 'relsize', type: 'num', label: 'relFreq'},
                {id: 'status', type: 'string'},
                {id: 'edited', type: 'datetime', label: 'edited'},
                {id: 'editor', type: 'string', label: 'editor'},
            ],
            ivdnt: [
                {id: 'query', type: 'string', label: 'annotation'},
                {id: 'label_count', type: 'num', auto: true},
                {id: 'size', type: 'num', label: 'freq'},
                {id: 'status', type: 'string'},
                {id: 'edited', type: 'datetime', label: 'edited'},
                {id: 'editor', type: 'string', label: 'editor'},
            ],
            croatpas: [
                {id: 'query', type: 'string', label: 'annotation'},
                {id: 'label_count', type: 'num', auto: true},
                {id: 'size', type: 'num', label: 'freq'},
                {id: 'status', type: 'string'},
                {id: 'edited', type: 'datetime', label: 'edited'},
                {id: 'editor', type: 'string', label: 'editor'},
            ]
        }

        this.models = {
            generic: {
                browse_labels: false,
                browse_values: false,
                status_codes: null,
                ontology: false
            },
            ivdnt: {
                show_percents: true,
                detail_under_label: 'implicature',
                status_codes: ["FINISHED", "NEW"], // max 10 char
                status_codes_select: true,
                ontology: true,
                browse_labels: false,
                browse_values: false,
                styles: ["formeel", "informeel", "literair", "Bijbels", "specialistisch", "overige", "vulgair"],
                attitudes: ["beledigend", "eufemistisch", "humoristisch", "liefkozend", "pejoratief", "overige"],
                time: ["verouderend", "archaisch", "neologisme"],
                domains: ["agricultuur", "biologie", "astrologie", "bouw", "business, economie en financien", "chemie en mineralogie", "media, communicatie en telecommunicatie", "cultuur en samenleving", "dans", "dieren", "emoties", "eten en drinken", "fietssport", "filosofie en psychologie", "filmkunst en fotografie", "fysica en astronomie", "geografie en plaatsen", "geologie en geofysica", "geschiedenis", "gezondheid en geneeskunde", "golf", "heraldiek en banistiek", "ict", "jacht en visserij", "kleuren", "kunst en architectuur", "archeologie", "literatuur en theater", "meteorologie", "muziek", "natuur en milieu", "nautica", "numismatiek en valuta", "onderwijs en opvoeding", "oorlogvoering en defensie", "planten", "politiek en bestuur", "recht en misdaad", "religie, mystiek en mythologie", "royalty en adel", "seks", "sport en recreatie", "taal en taalkunde", "techniek en technologie", "mode, textiel en kleding", "paardensport", "tennis", "tijd", "transport, verkeer en reizen", "voetbal", "watersport", "wetenschap", "wintersport", "wiskunde"],
                medium: ["(vooral) geschreven taal", "(vooral) gesproken taal"],
                semtypes: ["Abstract Entity", "Action", "Activity", "Agreement", "Air", "Alcoholic Drink", "Animal", "Animal Group", "Animate", "Anything", "Aperture", "Artifact", "Artwork", "Asset", "Attitude", "Ball", "Beverage", "Bird", "Body", "Bomb", "Bone", "Building", "Business Enterprise", "Cat", "Claim", "Cloth", "Cognitive State", "Colour", "Command", "Computer", "Concept", "Container", "Cow", "Decision", "Deficit", "Deity", "Device", "Disease", "Document", "Dog", "Dough", "Drug", "Dust", "Emotion", "Energy", "Engine", "Entity", "Event", "Eventuality", "Explosion", "Fantasy Character", "Field of Interest", "Finger", "Fire", "Firearm", "Fish", "Flag", "Flavour", "Floor", "Flower", "Fluid", "Flying Vehicle", "Food", "Fruit", "Fuel", "Furniture", "Garment", "Gas", "Geopolitical Area", "Goal", "Goat", "Hair", "Head", "Heat", "Hill", "Horse", "Human", "Human Group", "Illness", "Image", "Inanimate", "Information", "Injury", "Insect", "Institution", "Investigation", "Language", "Light", "Light Source", "Limit", "Liquid", "Location", "Machine", "Material", "Medium", "Metal", "Money", "Money Value", "Movie", "Musical Composition", "Musical Instrument", "Musical Performance", "Nail", "Name", "Narrative", "Natural Landscape Feature", "Number", "Numerical Value", "Obligation", "Offer", "Opportunity", "Part of Body", "Part of Language", "Particle", "Performance", "Permission", "Physical Entity", "Picture", "Plan", "Plant", "Power", "Price", "Privilege", "Process", "Projectile", "Property", "Proposition", "Psych", "Punctual Event", "Quantity", "Question", "Relationship", "Reputation", "Request", "Resource", "Responsibility", "Road Vehicle", "Role", "Route", "Rule", "Sculpture", "Sheep", "Signal", "Skill", "Smell", "Snake", "Software", "Soil", "Solid", "Sound", "Sound Maker", "Speech Act", "Spider", "State", "String", "Stuff", "System", "TV Program", "Temperature", "Theatrical Performance", "Thread", "Time Period", "Time Point", "Uncertainty", "Vapour", "Vehicle", "Video", "Virtual Location", "Wall", "Water", "Water Vehicle", "Watercourse", "Waterway", "Wavelength", "Weapon", "Weather Event", "Weight", "Wind", "Wine"]
            },
            tpas: {
                show_raw: true,
                detail_under_label: 'sense',
                status_codes: ["ready", "complete", "WIP", "invalid", "NEW"], // max 10 char
                positions: [["subject", "subject"], ["object", "object"], ["prep_compl", "prepositional complement"], ["adverbial", "adverbial"], ["clausals", "clausals"], ["predic_compl", "predicative complement"]],
                ontology: true,
                ontology_label: "System of Semantic Types",
                browse_labels: true,
                browse_values: false,
                adverbial_types: ["Direction", "Location", "Manner", "Time Point", "Time Period", "Causation", "Completive", "Privative"],
                predic_compl_types: ["subject", "object"],
                registers: ["volgare", "cortesia", "dispregiativo"],
                domains: ["football journalism", "atomic physics, chemistry, physics", "fisica", "informatics", "stock exchange, financial journalism", "calcio", "cucina", "law, court procedure", "fotografia", "football", "Sport", "law", "military", "mec"],
                roles: ["Academic/Course of Study", "Actor/Actress", "Adult", "Artist", "Assault", "Bottle", "Camera", "Celestial Body", "Child", "Coach", "Competition", "Conference", "Country", "Crime", "Criminal", "Dead", "Director", "Discipline", "Division/Difference", "Doctor/Nurse", "Dough", "Economic", "Enemy", "Exam", "External", "Famous", "Fantasy", "Female", "Fictional Character", "Field", "Flower", "Flower/Fruit", "Flying", "Flying Company", "Food", "Football Player", "Football Team", "Form", "Fruit", "Future", "Game", "Ground", "Guilty", "Herbivorous", "Hiding Place", "Informatics", "Institutional", "Internal", "Judge/Minister/Mayor", "Legal", "Legal-Institutional", "Legal-Political", "Limit", "Magazine", "Married Couple", "Mathematical", "Medical Scientist", "Militar", "Mistake", "Money Value", "Moving", "Multi-Part", "Murder", "Negative", "Novel", "Novel/Play", "Nuclear", "Opinion", "Part", "Patient", "Payment", "Pilot", "Player", "Plural", "Plurale", "Police", "Policeman/Policewoman", "Positive", "Price", "Prisoner", "Punishment", "Rails", "Rain", "Referee", "Reflective", "Refugee", "Religious", "Religious-Institutional", "Revolt", "Room", "Room/Floor", "Runner/Pilot", "Sculpture", "Service", "Sharp-pointed", "Singer", "Sport", "Sportsperson", "Sport Team", "Stylist", "Team", "Telephone Number", "Trainer", "Victim", "Violation", "Virtual", "Virtual+Plural", "Wall", "War", "Weapon", "Whole", "Whole/Part", "Writer/Director", "Years"],
                semtypes: ["Abstract Entity", "Action", "Activity", "Agreement", "Air", "Alcoholic Drink", "Animal", "Animal Group", "Animate", "Anything", "Aperture", "Area", "Artifact", "Artwork", "Asset", "Atest", "Attitude", "Ball", "Beverage", "Bird", "Body", "Body Part", "Bomb", "Bone", "Bridge", "Building", "Building Part", "Business Enterprise", "Cat", "Character Trait", "Cloth", "Cognitive State", "Colour", "Comand", "Command", "Computer", "Concept", "Container", "Cow", "Decision", "Deficit", "Deity", "Desease", "Device", "Disease", "Document", "Document Part", "Dog", "Drug", "Dust", "Emotion", "Energy", "Engine", "Entity", "Event", "Evento", "Eventuality", "Evenuality", "Explosion", "Fire", "Firearm", "Fish", "Flag", "Fluid", "Flying Vehicle", "Food", "Function", "Furniture", "Garment", "Gas", "Goal", "Goat", "God", "Group", "Hair", "Heat", "Hill", "Horse", "Human", "Human Group", "Idea", "Illness", "Image", "Inanimate", "Information", "Information Source", "Injury", "Insect", "Insitution", "Institution", "Investigation", "Language", "Language Part", "Light", "Light Source", "Liquid", "Location", "Machine", "Material", "Medium", "Metal", "Money", "Money Value", "Movie", "Movie Part", "Musical Instrument", "Musical Performance", "Music Part", "Name", "Narrative", "Natural Landscape", "Natural Landscape Feature", "Number", "Numerical Value", "Obligation", "Obligaton", "Offer", "Opportunity", "Pace", "Part", "Particle", "Part of Body", "Path", "Performance", "Permission", "Physical Object", "Physical Object Part", "Picture", "Plan", "Plant", "Plant Part", "Power", "Privilege", "Process", "Property", "Property of Human", "Property of Physical Object", "Proposition", "Psych", "Quantity", "Question", "Recording Part", "Relationship", "Reputation", "Request", "Resource", "Responsibility", "Road Vehicle", "Role", "Route", "Rule", "Sheep", "Signal", "Skill", "Smell", "Snake", "Software", "Soil", "Solid", "Sound", "Speech Act", "Speech Act Part", "Spider", "State", "State of Affairs", "String", "Structure", "Stuff", "Surface", "System", "Temperature", "Theatrical Performance", "Thread", "Time Period", "Time Point", "TV Program", "Uncertainty", "Use", "Vapor", "Vapour", "Vehicle", "Video", "Virtual Location", "Visible Feature", "Water", "Watercourse", "Water Vehicle", "Waterway", "Wavelength", "Weapon", "Weather Event", "Weight", "Wind", "Wine"]
            },
            croatpas: {
                show_percents: false,
                detail_under_label: 'sense',
                status_codes: ["ready", "complete", "WIP", "invalid", "NEW"],
                positions: [["subject", "subject"], ["object", "object"], ["ind_compl", "indirect complement"], ["adverbial", "adverbial"], ["clausals", "clausals"], ["predic_compl", "predicative complement"]],
                ontology: true,
                ontology_label: "System of Semantic Types",
                browse_labels: true,
                browse_values: false,
                adverbial_types: ["Direction", "Location", "Manner", "Time Point", "Time Period", "Causation", "Completive", "Privative"],
                predic_compl_types: ["subject", "object"],
                registers: ["volgare", "cortesia", "dispregiativo"],
                domains: ["football journalism", "atomic physics, chemistry, physics", "fisica", "informatics", "stock exchange, financial journalism", "calcio", "cucina", "law, court procedure", "fotografia", "football", "Sport", "law", "military", "mec"],
                roles: ["Academic/Course of Study", "Actor/Actress", "Adult", "Artist", "Assault", "Bottle", "Camera", "Celestial Body", "Child", "Coach", "Competition", "Conference", "Country", "Crime", "Criminal", "Dead", "Director", "Discipline", "Division/Difference", "Doctor/Nurse", "Dough", "Economic", "Enemy", "Exam", "External", "Famous", "Fantasy", "Female", "Fictional Character", "Field", "Flower", "Flower/Fruit", "Flying", "Flying Company", "Food", "Football Player", "Football Team", "Form", "Fruit", "Future", "Game", "Ground", "Guilty", "Herbivorous", "Hiding Place", "Informatics", "Institutional", "Internal", "Judge/Minister/Mayor", "Legal", "Legal-Institutional", "Legal-Political", "Limit", "Magazine", "Married Couple", "Mathematical", "Medical Scientist", "Militar", "Mistake", "Money Value", "Moving", "Multi-Part", "Murder", "Negative", "Novel", "Novel/Play", "Nuclear", "Opinion", "Part", "Patient", "Payment", "Pilot", "Player", "Plural", "Plurale", "Police", "Policeman/Policewoman", "Positive", "Price", "Prisoner", "Punishment", "Rails", "Rain", "Referee", "Reflective", "Refugee", "Religious", "Religious-Institutional", "Revolt", "Room", "Room/Floor", "Runner/Pilot", "Sculpture", "Service", "Sharp-pointed", "Singer", "Sport", "Sportsperson", "Sport Team", "Stylist", "Team", "Telephone Number", "Trainer", "Victim", "Violation", "Virtual", "Virtual+Plural", "Wall", "War", "Weapon", "Whole", "Whole/Part", "Writer/Director", "Years"],
                semtypes: ["Abstract Entity", "Action", "Activity", "Agreement", "Air", "Alcoholic Drink", "Animal", "Animal Group", "Animate", "Anything", "Aperture", "Area", "Artifact", "Artwork", "Asset", "Atest", "Attitude", "Ball", "Beverage", "Bird", "Body", "Body Part", "Bomb", "Bone", "Bridge", "Building", "Building Part", "Business Enterprise", "Cat", "Character Trait", "Cloth", "Cognitive State", "Colour", "Comand", "Command", "Computer", "Concept", "Container", "Cow", "Decision", "Deficit", "Deity", "Desease", "Device", "Disease", "Document", "Document Part", "Dog", "Drug", "Dust", "Emotion", "Energy", "Engine", "Entity", "Event", "Evento", "Eventuality", "Evenuality", "Explosion", "Fire", "Firearm", "Fish", "Flag", "Fuel", "Fluid", "Flying Vehicle", "Food", "Function", "Furniture", "Garment", "Gas", "Goal", "Goat", "God", "Group", "Hair", "Heat", "Hill", "Horse", "Human", "Human Group", "Idea", "Illness", "Image", "Inanimate", "Information", "Information Source", "Injury", "Insect", "Insitution", "Institution", "Investigation", "Language", "Language Part", "Light", "Light Source", "Liquid", "Location", "Machine", "Material", "Medium", "Metal", "Money", "Money Value", "Movie", "Movie Part", "Musical Instrument", "Musical Performance", "Musical Composition", "Music Part", "Name", "Narrative", "Natural Landscape", "Natural Landscape Feature", "Number", "Numerical Value", "Obligation", "Obligaton", "Offer", "Opportunity", "Pace", "Part", "Particle", "Part of Body", "Path", "Performance", "Permission", "Physical Object", "Physical Object Part", "Picture", "Plan", "Plant", "Plant Part", "Power", "Privilege", "Process", "Property", "Property of Human", "Property of Physical Object", "Proposition", "Psych", "Quantity", "Question", "Recording Part", "Relationship", "Reputation", "Request", "Resource", "Responsibility", "Road Vehicle", "Role", "Role", "Route", "Rule", "Sheep", "Signal", "Skill", "Smell", "Snake", "Software", "Soil", "Solid", "Sound", "Speech Act", "Speech Act Part", "Spider", "State", "State of Affairs", "String", "Structure", "Stuff", "Surface", "System", "Temperature", "Theatrical Performance", "Thread", "Time Period", "Time Point", "TV Program", "Uncertainty", "Use", "Vapor", "Vapour", "Vehicle", "Video", "Virtual Location", "Visible Feature", "Water", "Watercourse", "Water Vehicle", "Waterway", "Wavelength", "Weapon", "Weather Event", "Weight", "Wind", "Wine"]
            },
            pdev: {
                show_percents: true,
                ontology: true,
                browse_labels: false,
                browse_values: true,
                detail_under_label: 'implicature',
                detail_below: 'old',
                status_codes: ['complete', 'NYS', 'ready', 'WIP', 'modal', 'quarantine', 'auxiliary', 'garbled', 's'],
                registers: ["British", "American", "archaic", "dated", "dialect", "euphemism", "formal", "humorous", "informal", "jargon", "literary", "obsolescent", "obsolete", "offensive", "old-fashioned", "rural dialect", "slang", "spoken", "technical", "written"],
                adverbial_types: ["Direction", "Location", "Manner", "Time Point", "Time Period", "Causation", "Completive", "Privative"],
                domains: ["Academic", "Academic Writing", "Accountancy", "Acoustics", "Agriculture", "Air Force", "Anatomy", "Archaeology", "Architecture", "Arms and Armoury", "Art history", "Artist", "Astrophysics", "Atomic Physics", "Auctioneering", "authoritative", "Baking", "Ball Games", "Banking", "Baseball", "behaviour", "Biblical", "Biochemistry", "Biology", "Botany", "British", "Building", "Building Trades", "Business", "Card games: bridge", "Chemistry", "Christian Church", "Christian Church Practice", "Christian eccesiastical", "Christianity", "Christian mysticism", "Computing", "Cookery", "Cooking", "Court procedure", "Cricket", "Dentistry", "Ecology", "Economics", "Electronic Engineering", "Electronics", "Experience", "exploration", "Falconry", "Field Hockey", "Finance", "financial journalism", "Financial Journalism", "Fishing competition", "Food and Drink Culture", "Football journalism", "Formal", "Gardening", "Geology", "Geometry", "Golf", "Government", "Guitar playing", "Historical", "History", "Horse racing", "Horticulture", "Humanities", "Industrial Relations", "Informal", "Informatics", "journalism", "Journalism", "Judaism", "law", "Law", "Law: court procedure", "Law: court proceedings", "Law Enforcement", "Legal", "Life Science", "Linguistics", "Logic", "Manufacturing", "Marketing", "Mathematics", "medical", "Medical", "Medicine", "Microbiology", "Midwifery", "military", "Military", "Mining", "Motor Technology", "Motor trade", "Music", "Natural Science", "Naval", "Needlework", "Northern England", "Optician", "Ornithology", "Parenting", "parliamentary jargon", "Philosophy", "Phonetics", "Physics", "Physiology", "Poker", "Politics", "Pottery", "Pre-industrial agriculture", "Property Law", "Psychology", "railway", "Religion", "Roman Catholic Church", "Rugby", "Sailing", "Science", "scientific", "Scientific Laboratory Experiments", "Scientific language", "Scotland", "Sedimentology", "Slang", "Snooker", "Soccer", "Soccer journalism", "Social History", "Social services", "Sociological", "Sport", "Sports", "Sports journalism", "Statistics", "Stock exchange", "Theatre", "Town Planning", "U.S.", "Warfare", "Weather Reports", "Wine"],
                framenets: ["Abandon", "Abounding_with", "Absorb_heat", "Abundance", "Abusing", "Accomplishment", "Achieving_first", "Activity_finish", "Activity_ongoing", "Activity_start", "Activity_stop", "Adducing", "Adjusting", "Adopt_selection", "Adorning", "Aging", "Agree_or_refuse_to_act", "Amalgamation", "Amassing", "Amounting_to", "Appeal", "Appearance", "Apply_heat", "Appointing", "Arraignment", "Arranging", "Arrest", "Arriving", "Assessing", "Assistance", "Atonement", "Attaching", "Attack", "Attempt_suasion", "Attend", "Attending", "Avoiding", "Bearing_arms", "Become_silent", "Becoming", "Becoming_a_member", "Becoming_attached", "Becoming_aware", "Behind_the_scenes", "Be_in_agreement_on_assessment", "Being_attached", "Being_awake", "Being_in_category", "Being_in_operation", "Being_located", "Being_named", "Being_obligated", "Be_subset_of", "Birth", "Body_movement", "Bragging", "Breaking_apart", "Breathing", "Bringing", "Building", "Building_subparts", "Bungling", "Capability", "Categorization", "Categorizaton", "Causation", "Cause_change", "Cause_change_of_consistency", "Cause_change_of_phase", "Cause_change_of_position_on_a_scale", "Cause_expansion", "Cause_Expansion", "Cause_fluidic_motion", "Cause_harm", "Cause_impact", "Cause_motion", "Cause_temperature_change", "Cause_to_amalgamate", "Cause_to_be_wet", "Cause_to_end", "Cause_to_experience", "Cause_to_fragment", "Cause_to_make_progress", "Cause_to_move_in_place", "Cause_to_start", "Cause_to_wake", "Change_direction", "Change_event_duration", "Change_event_time", "Change_of_consistency", "Change_of_leadership", "Change_of_phase", "Change_operational_state", "Change_position_on_a_scale", "Change_posture", "Chatting", "Chemical-sense_description", "Choosing", "Claim_ownership", "Closure", "Cogitation", "Collaboration", "Colonization", "Coming_to_be", "Coming_to_believe", "Commerce_collect", "Commerce_pay", "Commerce_sell", "Commitment", "Communicate_categorization", "Communication", "Communication_manner", "Communication_noise", "Communication_response", "Communicaton_manner", "Compatibility", "Complaining", "Compliance", "Concept", "Conduct", "Congregating", "Connecting_architecture", "Contacting", "Containing", "Contingency", "Convey_importance", "Cooking_creation", "Corporal_punishment", "Corroding", "Corroding_caused", "Cotheme", "Court_examination", "Create_physical_artwork", "Create_representation", "Creating", "Cure", "Cutting", "Damaging", "Daring", "Death", "Departing", "Deserving", "Desirable_event", "Desiring", "Destroying", "Differentiation", "Discussion", "Disembarking", "Dispersal", "Duplication", "Eclipse", "Education_teaching", "Emanating", "Emitting", "Emotion_active", "Emotion_directed", "Emotion_heat", "Emptying", "Entering_of_plea", "Escaping", "Evading", "Event", "Evidence", "Evoking", "Exchange", "Exchange_currency", "Excreting", "Execution", "Expansion", "Expectation", "Expensiveness", "Experience_bodily_harm", "Experiencer_obj", "Experiencer_subj", "Explaining_the_facts", "Exporting", "Expressing_publicly", "Facial_expression", "Fall_asleep", "Feigning", "Filling", "Fining", "Finish_competition", "Firing", "Fleeing", "Fludic_motion", "Fluidic_motion", "Forging", "Forgoing", "Forming_relationships", "Fragmentation_scenario", "Frugality", "Gathering_up", "Gesture", "Getting", "Giving", "Giving_birth", "Giving_in", "Grant_permission", "Grasp", "Grinding", "Grooming", "Halt", "Have_as_requirement", "Have_associated", "Hiding_objects", "Hindering", "Hit_target", "Hostile_encounter", "Imitating", "Immobilization", "Impact", "Import_export", "Importing", "Imposing_obligation", "Imprisonment", "Inchoative_attaching", "Inchoative_change_of_temperature", "Inclusion", "Ingestion", "Ingest_substance", "Inhibit_movement", "Inspecting", "Intentionally_act", "Intentionally_affect", "Intentional_traversing", "Invention", "Judgement_communication", "Judgment", "Judgment_communication", "Judgment_direct_address", "Just_found_out", "Justifying", "Kidnapping", "Killing", "Knot_creation", "Labeling", "Leadership", "Light_movement", "Likelihood", "Lively_place", "Location_of_light", "Locative_relation", "Make_agreement_on_action", "Make_cognitive_connection", "Make_noise", "Making_faces", "Manipulate_into_doing", "Manipulation", "Mass_motion", "Memory", "Motion", "Motion_directional", "Motion_noise", "Motion_Sound", "Moving_in_place", "Name_conferral", "Needing", "Notification_of_charges", "Objective_influence", "Omen", "Operate_vehicle", "Operating_a_system", "Partiality", "Participation", "Path_shape", "People_by_vocation", "Perception_active", "Perception_body", "Perception_experience", "Performers_and_roles", "Permitting", "Personal_relationship", "Piracy", "Place_weight_on", "Placing", "Political_party", "Possession", "Posture", "Precipitation", "Preserving", "Prevarication", "Preventing", "Processing_materials", "Process_start", "Progress", "Prohibiting", "Proposition", "Protecting", "Provide_lodging", "Public_services", "Purpose", "Quarreling", "Questioning", "Quitting_a_place", "Reading", "Reasoning", "Receive", "Receiving", "Recovery", "Reference_text", "Referring_by_name", "Regard", "Relational_quantity", "Relative_time", "Remembering_experience", "Remembering_to_do", "Removing", "Render_nonfuctional", "Render_nonfunctional", "Renting", "Renting_out", "Replacing", "Reporting", "Request", "Required_event", "Reshaping", "Residence", "Resolve_problem", "Respond_to_proposal", "Reveal_secret", "Revenge", "Rewards_and_punishments", "Ride_vehicle", "Rite", "Robbery", "Rope_manipulation", "Rotting", "Run_risk", "Scouring", "Scrutiny", "Seeking", "Self_motion", "Semantically", "Sending", "Sentencing", "Separating", "Setting_fire", "Shoot_projectiles", "Sign_agreeement", "Sign_agreement", "Simple_naming", "Simultaneity", "Sleep", "Soaking", "Social_event", "Sound_movement", "Speak_on_topic", "Spelling_and_pronouncing", "Statement", "Stimulus_focus", "Storing", "Suasion", "Subjective_influence", "Subject_stimulus", "Submitting_documents", "Subordinates_and_Superiors", "Subversion", "Successful_action", "Success_or_failure", "Surpassing", "Surrendering_possession", "Take_place_of", "Taking_sides", "Talking_into", "Telling", "Text_creation", "Theft", "Thriving", "Thwarting", "Topic", "Touring", "Translating", "Travel", "Traversing", "Treating_and_mistreating", "Undergo_change", "Undressing", "Use_firearm", "Using", "Verdict", "Visiting", "Waking_up", "Waver_between_options", "Wearing", "Win_prize", "Working_on"], 'semclasses': ["Action", "Attitude", "Become", "Cooking", "Destroy", "Drink", "Drinking", "Eating", "Giving", "Laugh", "Make Noise", "Move", "Perception", "Read", "Reading", "Risk", "Speech Act", "Weather", "Write"],
                roles: ["Abdomen", "Abrasive", "Absorbent", "Abstract", "Abuse", "Academic", "Accident", "Accommodation", "Accountant", "Accounts", "Accusation", "Accused", "Accuser", "Achievement", "Aching", "Acid", "Action", "Activity", "Actor", "Adhesive", "Adult", "Advantage", "advantageous", "Adventurer", "Adversity", "Advertisement", "Affected by Rule", "Age", "Age in Years", "Agent", "Agitated", "Aircrew", "Airline", "Alias", "Amount", "Amplifier", "Animal Food", "Answer", "Aquatic", "Arbitrator", "Archaeologist", "Arduous", "Argument", "Armed", "Armed Forces", "Armed with Gun", "Army", "Aromatic", "Art", "Art Collection", "Article", "Artisan", "Artist", "Artwork", "Assessor", "Asset", "Assistance", "Attack", "Attacker", "Attention", "Attitude", "Auctioneer", "Audience", "Audience Member", "Audio Equipment", "Audiotape", "Author", "Authority", "Authority Figure", "Baby", "Background", "Bacteria", "Bad", "Bad Experience", "Bad Guy", "Bad Outcome", "Baking Pan", "Ball", "Ball Player", "Barrier", "Barrister", "Batsman", "Beam", "Beautiful", "Beer", "Being Digested", "Belief", "Belief", "Belt", "beneficial", "Benefit", "Beverage", "Bidder", "Bill", "Biological", "Biological Process", "Bishop", "Blame", "Blanket", "Bloodhound", "Bomb", "Bone", "Book", "Bookkeeper", "Border", "Boring", "Bottle of Wine", "Bowler", "Boxer", "Branch", "Brass", "Bread dough", "Bright", "Brittle", "Broadcasting Company", "Buffalo", "Building", "Bulky", "Bullets", "Burden", "Burglar", "Burning", "Business", "Business Competitor", "Business Enterprise", "Business Leader", "Businessman", "Business Person", "Button", "Buyer", "Camera", "Campaign", "Canal", "Candidate", "Candle", "Canine", "Capital Cost", "Captain", "Car", "Cardinal", "Career", "Cargo", "Carpet", "Cart", "Case", "Cash", "Casualty", "Category", "Cattle", "Causative Agent", "Cause", "Celebrity", "Cell", "Chairman", "Challenge", "Change", "Character", "Charge", "Chartered Professional", "Checkout operator", "Chemical", "Cheque", "Child", "Chimney", "Chord", "Christian", "Church Authority", "City", "Claim", "Class", "Classification", "Clerk", "Client", "Cloth", "Clothes", "Cloud", "Cocaine", "Coffee", "Coffee Beans", "Coin", "Collaborative", "Combustible", "Commander", "Commercial", "Commercial Product", "Commissioned Officer", "Commitment", "Commodity", "Competing team", "Competition", "Competitive", "Competitor", "Competitor in Race", "Complex", "Complex Predicate", "Complicated", "Component", "Compost", "Computer", "Computer File", "Computerized", "Computer Screen", "Computer User", "Concept", "Concern", "Conflict", "Confrontation", "Confused", "Connection", "Considered Opinion", "Constituency", "Constituent Parts", "Constraint", "Container", "Continuous", "Contract", "Convention", "Conversation", "Cook", "Cooking Ingredients", "Cooking Pot", "Cost", "Costs Money", "Country of Residence", "Couple", "Course of Study", "Court", "Court", "Craftsman", "Cream", "Crew", "Crew of Plane", "Cricket Team", "Crime", "Criminal", "Criminal Gang", "Criterion", "Crop", "Cuddly Toy", "Culturally or Scientifically Interesting", "Cultural System", "Currency Unit", "Curve", "Cutting", "Damaged", "Dance", "Dangerous", "Data", "Dead", "Dead Enemy", "Debt", "Decoration", "Decrease", "Degree", "Delegate", "Demand", "Dentist", "Design", "Desirable", "Desired", "Desired Objective", "Destination", "Destructive", "Dial", "Digital", "Diplomat", "Director", "Director of Performance", "Dirt", "Disagreement", "Disciple", "Disease", "Display", "Dispute", "Disputed", "Distance", "Disturbing", "Dividing Line", "DNA", "Doctor", "Doctor's Prescription", "Document", "Dog", "Domestic", "Donkey", "Door", "Dope", "Doubt", "Draft Animal", "Dragon", "Dramatic", "Dramatic Role", "Dressing", "Drink", "Driver", "Drug", "Duck", "Dull", "Dust", "Earth", "Economy", "Editor", "Education", "Educational", "Educational Establishment", "Egg", "Electrical", "Electric Current", "Electronic", "Emergency Service", "Employee", "Employer", "Employment", "Endeavour", "Enemy", "Enemy Nation", "Engine", "Entertainer", "Enthusiasm", "Environmentalist", "Enzyme", "Erosion", "Evaluation Scale", "Eventuality", "Evidence", "Executive", "Exercise Bike", "Exhibition", "Existing", "Experience", "Experiment", "Expert", "Exploding", "Explosive", "Explosive Device", "External", "Extremes", "Eye", "Eyes", "Facade", "Facial Expression", "Facility", "Fact", "Factory", "Factory Worker", "false", "Family Member", "Famous", "Far Away", "Far-away Country", "Farm Animal", "Farmer", "Fast", "Favour", "Fear", "Feature", "Feeling", "Female", "Fence", "Fertilizer", "Field", "Film", "Film Director", "Financial", "Financial Accounts", "Financial Loss", "Fine", "Firm of Accountants", "Fish", "Fisherman", "Fishing Match", "Floating Charge", "Flood", "Flour", "Flower", "Flower Bed", "Fluffy", "Fog", "Food", "Food Source", "Footballer", "Football Striker", "Football Team", "Force", "Forebear", "Forecast", "Forest", "Formal", "Formal Meeting", "Former Associate", "For Sale", "Foul", "Four-legged", "Fox", "Fragment", "Friend", "Frozen", "Fuel", "Function", "Functional", "Fur", "Furniture", "Future", "Future Outcome", "Garden", "Gardener", "Gaze", "Gene", "Gentry", "Glass", "Glue", "Goal", "Goal-directed", "Goal-oriented", "Goat", "Golfer", "Good", "Goods", "Government", "Government Department", "Government Employee", "Grain", "Greyhound", "Group", "Guard", "Guess", "Guitar", "Gun", "Gunman", "Gut", "Habitation", "Habitual", "Hair", "Hammer", "Hand", "Handwritten", "Hard", "Hardware", "Has Sails", "Hasty", "Hat", "Hay", "Head", "Heading", "Head of Government", "Head of Institution", "Health Professional", "Heat", "Heavy", "Hedge", "Help", "Hen", "High Status", "Hinge", "Historic Figure", "Hockey Player", "Hollow", "Holy", "Holy Person", "Home", "Home Country", "Home of Human Group", "Honour", "Hoover", "Horror", "Horse", "Horses", "Horse's Feet", "Hospital", "Hostile", "Hot", "Hotel", "Hot Metal", "Householder", "Human", "Hunter", "Hypothesis", "Idea", "Ideology", "Ill", "Illegal", "Illness", "Imagination", "Impasse", "Improvement", "Inconvenient", "Increase", "Infant", "Inflatable", "Inflated", "Information", "Ingredient", "Injured", "Injury", "Installation", "Intense", "Interest Rate", "Inventor", "Investigator", "Investor", "Issue", "Item", "Item in List", "Jail", "Jazz Musician or Rock Musician", "Jewellery", "Job", "Journal", "Journalist", "Judge", "Judicial Decision", "Jury", "Kitchen Cloth", "Knees", "Knife", "Knowledge", "Laboratory Animal", "Lake", "Land", "Large", "Large Amount", "Law", "Lawn", "Lawsuit", "Lawyer", "Leader", "Lecture", "Legal", "Legal Party", "Legal Protection", "Legal Right", "Legislation", "Legislature", "Legless", "Legs", "Liability", "Life", "Light", "Limb", "Limit", "Limited Access", "Limited Membership", "Liquid", "Literary", "Livestock", "Loan", "Local Authority", "Local Government", "Long", "Long and Thin", "Loved One", "Ludicrous", "Lung", "Luxurious", "Lying Down", "Machine", "Machine gun", "Machine Part", "Mail", "Male", "Male Suitor", "Manager", "Many", "Mark", "Market", "Mass", "Mathematical Calculation", "Meal", "Meaning", "Meat", "Mechanism", "Medical", "Medical Condition", "Medical Organization", "Medical Patient", "Medical Professional", "Medical Treatment", "Medicine", "Meeting", "Meeting", "Member", "Members", "Memory", "Mental Hospital", "Metal", "Metropolitan", "Microorganism", "Micro-organisms", "Migrating", "Miiltary Leader", "Military", "Military Authority", "Military Commander", "Military Force", "Military Leader", "Mill", "Mineral", "Minister", "Minor", "Minority Students", "Minor Problem", "Mob", "Molecule", "Monarch", "Money", "Monotonous", "Mop", "More of the Same", "More Senior", "Mother", "Motivation", "Mountain", "Mountains", "Mouth", "Movie Director", "Mud", "Mule", "Multi-paged", "Muscle", "Musical Note", "Music Band", "Musician", "Mythical Creature", "Nails", "Nasty", "Nation", "Naturally Occurring", "Naval", "Negative", "Nest", "Neurological", "New", "Newspaper", "New State of Affairs", "Noise", "Note", "Notice", "Not Monarch", "Novel", "Nutrient", "Objective", "Obstacle", "Offence", "Offence in Civil Law", "Offender", "Offspring", "Ongoing", "Open Prison", "Operator", "Ophthalmologist", "Opponent", "Opportunity", "Orchestra", "Organ", "Organic Waste", "Organization", "Organized Service", "Ornament", "Outcome", "Outdoors", "Owner", "Oxen", "Package", "Page", "Paid Driver", "Painter", "Pair", "Paparazzo", "Paper", "Paramilitary", "Parasite", "Parent", "Parliament", "Parrot", "Participant in Law Case", "Party", "Passage", "Passenger", "Passengers", "Passive", "Past Event", "Patent Application", "Patient", "Payable", "Payment", "Peer", "Percentage", "Percussion", "Performance", "Performer", "Performers", "Periodical Publication", "Perpetrator", "Pet", "Pharmacist", "Phone Caller", "Photograph", "Photographer", "Phrase", "Physical Object", "Physical Sense", "Picture", "Pilot", "Pimp", "Pitch", "Plaintiff", "Player", "Playing card", "Plural", "Poem", "Pointed", "Poison", "Police", "Policeman", "Policemen", "Police Officer", "Political", "Political Debate", "Political figure", "Political Leader", "Political Leader", "Political Party", "Political Party Leader", "Political Power", "Politician", "Pollution", "Pope", "Population", "Port", "Position", "Positive", "Possession", "Possibility", "Poster", "Pot", "Potential", "Potter", "Pottery", "Poultry", "Powder", "Powdered", "Power", "Powerful", "Praise", "Precedent", "Predator", "Predecessor", "Pregnancy", "Pressure", "Prevention", "Previous", "Prey", "Price", "Priest", "Principle", "Private", "Prize", "Problem", "Problems", "Procedure", "Product", "Professional Dancer", "Professional Role", "Project", "Proposed", "Proposed Action", "Proposition", "Protest", "Protestors", "Public", "Public Figure", "Public Speaker", "Public Transport", "Publisher", "Punishment", "Pupil", "Puppy", "Purchase", "{Qualified Person}", "Quantifiable", "Question", "Questioner", "Quote", "Race", "Race Car", "Racehorse", "Racing horse", "Railway", "Railway Engine", "Railway line", "Railway Locomotive", "Rainstorm", "Rainwater", "Raw Material", "Reader", "Receptacle", "Receptionist", "Recording Artist", "Referee", "Region", "Relationship", "Relative", "Religion", "Remedy", "Report", "Reproductive", "Research Scientist", "Resistance", "Resource", "Response", "Restaurant", "Restraint", "Result", "Revolt", "Rhythm", "Rider", "Rival", "River", "Road", "Rock", "Rocket", "Rockface", "Rodent", "Role", "Rolling Stock", "Roof", "Room", "Round", "Route", "Royal", "Rugby Player", "Sacrifice", "Sailboat", "Sailor", "Sailors", "Saleable Product", "Sales Pitch", "Salient Fact", "School", "Schoolchild", "Schoolchildren", "School Student", "Scientific", "Scientific Methodology", "Scientific Principle", "Scientist", "Score", "Screen", "Sea", "Sea Animal", "Sealed", "Secret", "Sect", "Security Official", "Seed", "Seedling", "Seller", "Semiconductor", "Sense Organ", "Service", "Service Provider", "Session Musician", "Shallow", "Shape", "Shareholder", "Shares", "Sharp", "Sheep", "Shell of snail or ammonoid", "Shiny", "Shoe", "Shoemaker", "Shooter", "Shore", "Short", "Shoulders", "Sick", "Sight", "Sights", "Signal", "Signpost", "Silence", "Singer", "Siren", "Skill", "Skilled Worker", "Slice", "Small", "Smell", "Smelling Unpleasant", "Soccer Player", "Social", "Sociological", "Soft", "Soldier", "Soldiers", "Solicitor", "Solid", "Solution", "Song", "Sound", "Source", "Source of Pride", "Source of Support", "Speaker", "Species", "Speed", "Spillage", "Spinners", "Spiritual", "Sporting", "Sports Competition", "Sports Contest", "Sports Pitch", "Sports Player", "Sports team", "Sports Team", "Staff", "Stage", "Staining", "Standard", "Standing", "Statue", "Steam Locomotive", "Stem", "Stock Exchange", "Stock of Items", "Stolen", "Store", "Storm", "Story", "Straw", "Student", "Study", "Style of Speech", "Subject of Study", "Success", "Supply", "Surface", "Surfer", "Surgeon", "Surgical Nurse", "Suspect", "Suspected Crime", "Suspected Criminal", "Sweet", "Switch", "Symptom", "System", "Table", "Tap", "Target", "Task", "Tax", "Tax Return", "Teacher", "Team", "Tears", "Telephone Number", "Television", "Terrorist", "Test", "Tethered", "Text", "Theatrical", "Theory", "Thought", "Thread", "Threat", "Ticket", "Time", "Tobacco", "Tone", "Tool", "Tooth", "Topic", "Tornado", "Town", "Toxic", "Trader", "Tradesperson", "Trade Union", "Traditional", "Traffic", "Trainee", "Training", "Transaction", "Translation", "Transport", "Transport Service", "Traveller", "Treatment", "Tricky", "Trivial Topic", "Troops", "Troublesome", "Truck", "Tune", "Turkey", "TV Channel", "Two", "Two: Newly Married Couple", "Typesetter", "Ugly", "Unattainable", "Uncertainty", "Unconscious", "Undesirable", "Unexpected", "Unfolding", "Unhappy", "University", "Unpaid Car Owner", "Unpleasant", "Unruly", "Unsatisfactory", "Untrue", "Unwanted", "Unwanted Mark", "Unwell", "Urine", "Vacation", "Vaccine", "Valuable", "Valuable Owned Property", "Valuable Resource", "Value", "Valued", "Valve", "Vapour", "Vegetable", "Vegetable Garden", "Vegetation", "Vehicle", "Verse", "Vet", "Victim", "Video Game", "Videotape", "Village", "Violent", "Virus", "Visual Delight", "Visual or Physical Aid", "Voice", "Volcano", "Volume", "Voter", "Wagon", "wall", "Wall", "War", "Water", "Waterbird", "Water Surface", "Wave", "Waves", "Weapon", "Weaponry", "Weather", "Weeds", "Well-known Musician", "Wet Cloth", "Whale", "Whole", "Widely Accepted", "Wild", "Wind", "Wind Instrument", "Wind or Brass", "Window", "Wind Speed", "Winged", "Witch", "Witness", "Wood", "Word", "Work", "Worker", "Workers", "Work of Art", "Worse", "Woven Fabric", "Writer", "Written Record", "Wrongdoer", "Year"],
                semtypes: ["Abstract Entity", "Action", "Activity", "Admin", "Agreement", "Air", "Aircraft", "Alcoholic Drink", "Aminate", "Animal", "Animal Group", "Animate", "Anything", "Aperture", "Area", "Artifact", "Artifact Part", "Artwork", "Asset", "Attitiude", "Attitude", "Ball", "Belief", "Benefit", "Beverage", "Bicycle", "Bird", "Blemish", "Blood", "Boat", "Body", "Body Part", "Bomb", "Broadcast", "Budget", "Building", "Building Part", "Business Enterprise", "Car", "Cat", "Ceramic", "Cetacean", "Character Trait", "Chord", "Cinema", "Cloth", "Cognitive State", "Colour", "Command", "Computer", "Concept", "Container", "Cow", "Currency", "Decision", "Deficit", "Deity", "Device", "Disease", "Dispute", "Document", "Document Part", "Dog", "Drink", "Drug", "Elements", "Emotion", "Employer", "Energy", "Engine", "Entity", "Environment", "Event", "Eventuality", "Explosion", "Facts", "Fetus", "Fire", "Firearm", "Fish", "Flag", "Flame", "Fluid", "Food", "Footware", "Footwear", "Force", "Furniture", "Garbage", "Garment", "Gas", "Ghost", "Glass", "Goal", "Group", "Hair", "Happen", "Head", "Heat", "Heat Source", "Heaven", "Horse", "Human", "Human Group", "Human Role", "Illness", "Image", "Inanimate", "Information", "Information Source", "Injury", "Insect", "Institution", "Investigation", "Land", "Language", "Language Part", "Light", "Light Source", "Limb", "Line", "Liquid", "Location", "Location Safety", "Machine", "Man", "Material", "Meat", "Medieval Times", "Medium", "Mental Activity", "Metal", "Modern Day", "Money", "Money value", "Money Value", "Motorbike", "Movie", "Movie Part", "Musical Instrument", "Musical Performance", "Music Part", "Name", "Narrative", "Natural Elements", "Natural Landscape Feature", "Number", "Numerical Value", "Obligation", "Offer", "Opportunity", "Pace", "Part", "Particle", "Performance", "Permission", "Phrase", "Physical Object", "Picture", "Plan", "Plane", "Plant", "Plant Part", "Position", "Power", "Precipitation", "Primate", "Privilege", "Procedure", "Process", "Projectile", "Property", "Proposition", "Psych", "Quantity", "Question", "Radiation", "Radio Program", "Recording", "Recording Part", "Relationship", "Reputation", "Request", "Resource", "Responsibility", "Road Vehicle", "Role", "Room", "Route", "Rule", "Sail", "Self", "Sense Organ", "Shape", "Ship", "Signal", "Skill", "Smell", "Snake", "Software", "Soil", "Solid", "Sound", "Speech Act", "Speech Act Part", "Speech Sound", "Spider", "State", "State of Affairs", "Status", "Storm", "String", "Structure", "Stuff", "Surface", "System", "Temperature", "Territory", "Theatrical Performance", "Thread", "Time Period", "Time Point", "Topic", "Train", "Tree", "TV Program", "Uncertainty", "Use", "Vacation", "Vapour", "Vegetable", "Vehicle", "Vehicle Group", "Vehicle Part", "Visible Feature", "Water", "Watercourse", "Water Vehicle", "Water Vehicle Group", "Waterway", "Wave", "Wavelength", "Weapon", "Weather Event", "Weight", "Wind", "Wine", "Wood", "Word"]
            }
        }
    }

    _onPageChange(pageId, query) {
        if (query.annotconc) {
            this.annotconc = query.annotconc
            this.getAnnotLabels()
        }
        this.trigger("ANNOTATIONS_UPDATED")
    }

    render(data) {
        if (this[this.annotation_group + "_label"]) {
            return this[this.annotation_group + "_label"](data)
        }
        else {
            return this.generic_label(data)
        }
    }

    removeQueryFromQueries(query) {
        let ind = -1
        for (let i=0; i<this.queries.length; i++) {
            if (this.queries[i].conc == query) {
                ind = i
                break
            }
        }
        if (this.annotconc == query) {
            this.annotconc = ""
        }
        this.queries.splice(ind, 1)
        this.trigger("ANNOTATIONS_UPDATED")
    }

    getAnnotations() {
        this.loading_queries = true
        Connection.get({
            url: window.config.URL_BONITO + 'storedconcs',
            data: {
                corpname: this.corpus.corpname
            },
            done: function (payload) {
                this.loading_queries = false
                this.queries = payload.data || []
                if (payload.data) {
                    for (let i=0; i<payload.data.length; i++) {
                        if (this.queries[i] && this.queries[i].attr) {
                            this.queries[i].attr = JSON.parse(decodeURIComponent(this.queries[i].attr))
                        }
                    }
                }
                this.trigger("ANNOTATIONS_UPDATED")
            }.bind(this),
            fail: function (payload) {
                SkE.showError("Could not load annotations.", getPayloadError(payload))
            }
        })
    }

    saveLabel(label) {
        Connection.get({
            url: window.config.URL_BONITO + 'annot_save_label',
            data: {
                corpname: this.corpus.corpname,
                qid: label.qid,
                lid: label.id,
                data: encodeURIComponent(JSON.stringify(label.data)),
                attr: encodeURIComponent(JSON.stringify(label.attr))
            },
            postKeys: ["data"],
            done: function (payload) {
                this.updateQueryRow(payload)
                this.trigger("ANNOTATION_LABEL_SAVED", label)
            }.bind(this),
            error: function (payload) {
                this.trigger("ANNOTATION_LABEL_SAVE_FAILED")
                console.log('ERROR', payload.error)
            }.bind(this),
            always: this.trigger.bind(this, "ANNOTATION_LABEL_SAVE_ALWAYS")
        })
    }

    getLabelByLineGroup(linegroup_id){
        return this.labels.find(l => {
            return l.id == linegroup_id
        }) || null
    }

    addLabelExample(line, coll) {
        // only for IVDNT
        let l = line.Left.filter(p => { return p.str })
        let k = line.Kwic.filter(p => { return p.str })
        let r = line.Right.filter(p => { return p.str })
        let example = l.map(p => {return p.str.trim()}).join(' ') + ' '
                + k.map(p => {return p.str.trim()}).join(' ') + ' '
                + r.map(p => {return p.str.trim()}).join(' ')
        let label = this.getLabelByLineGroup(line.linegroup_id)
        if (label){
            let new_example = {
                text: example,
                toknum: line.toknum,
                slotid: this.slotid,
                lexitem: coll || "",
                type: "",
                variant: "",
                attitude: "",
                style: "",
                domain: ""
            }
            if (label.data.examples && label.data.examples.length
                    && !label.data.examples[label.data.examples.length-1].text.trim()) {
                label.data.examples[label.data.examples.length-1] = new_example
            }
            else if (label.data.examples) {
                label.data.examples.push(new_example)
            } else {
                label.data.examples = []
                label.data.examples.push(new_example)
            }
            this.sortExamples(label.data.examples)
            this.saveLabel(label)
        }
    }

    sortExamples(examples){
        examples.sort(function (a, b) {
            if(a.slotid == b.slotid){
                if(a.lexitem == b.lexitem){
                    return a.text.localeCompare(b.text)
                } else {
                    return a.lexitem.localeCompare(b.lexitem)
                }
            } else {
                if(!isDef(a.slotid)){
                    return -1
                } else if(!isDef(b.slotid)){
                    return 1
                } else {
                    return a.slotid - b.slotid
                }
            }
        })
    }

    getAnnotLabels() {
        if (!this.annotconc) return
        if (this.annotLabelsLoading) {
            return
        }
        this.annotLabelsLoading = true
        Connection.get({
            url: window.config.URL_BONITO + "lngroupinfo",
            data: {
                corpname: this.corpus.corpname,
                annotconc: this.annotconc
            },
            done: function (payload) {
                if (payload.error) {
                    console.log('FAILED', payload.error)
                    this.annotLabelsLoading = false
                }
                else {
                    this.annotLabelsLoading = false
                    this.labels = payload.labels
                    this.lngroup2label = {}
                    this.nsublabels = 0
                    for (let i=0; i<this.labels.length; i++) {
                        this.lngroup2label[this.labels[i].id] = this.labels[i].label
                        try {
                            this.labels[i].data = this.labels[i].data.length ? JSON.parse(decodeURIComponent(this.labels[i].data)) : {}
                            this.labels[i].attr = this.labels[i].attr.length ? JSON.parse(decodeURIComponent(this.labels[i].attr)) : {}
                        }
                        catch (err) {
                            this.labels[i].data = this.labels[i].data.length ? JSON.parse(this.labels[i].data) : {}
                            this.labels[i].attr = this.labels[i].attr.length ? JSON.parse(this.labels[i].attr) : {}
                        }
                        if (this.labels[i].label.indexOf('.') > 0) {
                            this.nsublabels += 1
                        }
                        let rl = this.render(this.labels[i].data)
                        this.labels[i].pattern_string = rl[0]
                        this.labels[i].pattern_string_flat = rl[1]
                    }
                    this.trigger("ANNOTATION_LABELS_UPDATED")
                }
            }.bind(this),
            fail: function(payload) {
                this.annotLabelsLoading = false
                SkE.showError("Could not load annotation labels.", getPayloadError(payload))
            }.bind(this)
        })
    }

    addLabel(label) {
        Connection.get({
            url: window.config.URL_BONITO + "addlngroup",
            data: {
                corpname: this.corpus.corpname,
                annotconc: this.annotconc,
                label: label
            },
            done: function (payload) {
                if (payload.error) {
                    console.log('FAILED', payload.error)
                }
                else {
                    // update label count in queries
                    for (let i=0; i<this.queries.length; i++) {
                        if (this.queries[i].conc == this.annotconc) {
                            this.queries[i].label_count += 1
                            break
                        }
                    }
                    if (payload.message) {
                        this.getAnnotLabels()
                    }
                    this.updateQueryRow(payload)
                    SkE.showToast(_("labelSaved", [label]), {duration: 8000})
                }
            }.bind(this),
            fail: function (payload) {
                SkE.showError("Could not add label.", getPayloadError(payload))
            }
        })
    }

    addLabelModal() {
      Dispatcher.trigger("openDialog", {
          title: _("newLabel"),
          small: true,
          showCloseButton: true,
          tag: "ui-input",
          buttons: [{
              label: _("save"),
              class: "btn-primary",
              onClick: function(dialog, modal){
                  this.addLabel(dialog.contentTag.getValue().trim())
                  modal.close()
              }.bind(this)
          }],
          opts: {
              class: "newLabelInput",
              type: "text"
          }
      })
    }

    labelToknums(toknums, lid) {
        Connection.get({
            url: window.config.URL_BONITO + "setlngroup",
            data: {
                corpname: this.corpus.corpname,
                annotconc: this.annotconc,
                toknum: toknums.join(" "),
                group: lid
            },
            done: function (payload) {
                if (payload.count) {
                    this.trigger("ANNOTATION_SUCCESSFUL", payload)
                }
            }.bind(this),
            fail: function (payload) {
                SkE.showError("Could not label line.", getPayloadError(payload))
            }
        })
    }

    ivdnt_label(data) {
        if (!data || !data.slots || !data.slots.length) {
            return ["", ""]
        }
        let type2color = {
            "vc_inf": "p",
            "vc_ti": "p",
            "vc_oti": "p",
            "vc_om te inf": "p",
            "vc_ahi": "p",
            "vc_dat_of": "p",
            "vc_dat": "p",
            "vc_of": "p",
            "vc_qw": "p",
            "vc_als-zin": "p",
            "vc_alsof-zin": "p",
            "vc_rhd": "p",
            "quote ": "p",
            "subject": "o",
            "object": "o",
            "obj": "o",
            "indir_obj": "o",
            "aux": "b",
            "head": "b",
            "se": "b",
            "svp": "b",
            "predc": "g",
            "me": "g",
            "ld": "g",
            "predm": "g",
            "mod": "g"
        }
        let vc_dummies = {
            "vc_inf": "Infinitive",
            "vc_ti": "te + <i>inf</i>",
            "vc_oti": "om te + <i>inf",
            "vc_om te inf": "(om) te + <i>inf</i>",
            "vc_ahi": "aan het + <i>inf</i>",
            "vc_dat": "<i>dat</i>-zin",
            "vc_of": "<i>of</i>-zin",
            "vc_qw": "vraagwoordzin",
            "vc_als-zin": "<i>als</i>-zin",
            "vc_alsof-zin": "<i>alsof</i>-zin",
            "vc_rhd": "relatieve zin",
            "quote": "quote"
        }
        let slots = []
        let fslots = []
        data.slots.forEach(function (slot) {
            let slot_str = `<span class="${type2color[slot.type] || 'x'}">`
            let slot_f = ""
            let fix = slot["fixed"] || ""
            let ds = ""
            let dsf = ""
            let fs = ""
            let fsf = ""
            if (fix) {
                fs = '<span class="fixed">' + fix + '</span> '
                fsf = fix + ' '
            }
            let lexsets = slot.lexset.filter(function (x) { return x.trim() }).map(function (x) { return x.trim() })
            let dummies = slot.dummies.filter(function (x) { return x.trim() }).map(function (x) { return x.trim() })
            if (!dummies.length && slot.type != "head") {
                if (lexsets.length) {
                    ds = '<span class="lsdummy' + (lexsets.length > 1 ? "2" : "") + '">' + lexsets.join(', ') + '</span>'
                    dsf = lexsets.join(' ')
                }
            }
            else if (dummies.length == 1) {
                ds = '<span class="' + (vc_dummies.hasOwnProperty(dummies[0]) ? "vc_" : "") + 'dummy">' + (vc_dummies[dummies[0]] || dummies[0]) + "</span>"
                dsf = vc_dummies[dummies[0]] || dummies[0]
                if (lexsets.length) {
                    ds += '<sup class="ils">' + lexsets.join(', ') + '</sup>'
                    dsf += " " + lexsets.join(', ')
                }
            }
            else {
                ds = dummies.map(function (x) { return "<span class='dummy'>" + (vc_dummies[x] || x) + "</span>" }).join(' <span class="of">of</span> ')
                dsf = dummies.map(function (x) { return vc_dummies[x] || x }).join(' | ')
                if (lexsets.length) {
                    ds += '<sup class="ils">' + lexsets.join(', ') + '</sup>'
                    dsf += " " + lexsets.join(', ')
                }
            }
            if (slot.opt) {
                slot_str += '<span class="opt">' + fs + ds + '</span>'
                slot_f += '(' + fsf + dsf + ')'
            }
            else {
                slot_str += fs + ds
                slot_f += fsf + dsf.trim()
            }
            slot_str += '</span>'
            if (slot.or && slot.type != "head") {
                slot_str += "<span class='of'>of </span>"
            }
            slots.push(slot_str)
            fslots.push(slot_f + (slot.or ? " of" : ""))
        })
        return [
            slots.join("").replace(/{/g, '&#123;'),
            fslots.filter(function (x) { return x }).join(" ").replace(/{/g, '&#123;')
        ]
    }

    tpas_label(data) {
        if (!data || !data.slots) {
            return ["", ""]
        }
        let slots = []
        let fslots = []
        let has_subject = false
        data.slots.forEach(function (slot) {
            if (slot.slot == "subject") {
                has_subject = true
            }
            let slot_str = `<span class="${slot.slot} ${slot.or ? "or" : ""} ${slot.optional ? "opt" : ""}">`
            let slot_f = slot.optional ? "(" : ""
            if (slot.come === true || (Array.isArray(slot.come) && slot.come.indexOf(true) >= 0)) {
                slot_str += "<span class='come'>come</span>"
                slot_f += "come "
            }
            let opts = slot.opt
            if (!Array.isArray(opts)) {
                opts = [opts]
            }
            let sslist = []
            let sslist_f = []
            let maxl = Math.max(slot.semtype.length, slot.role.length, slot.feature.length, opts.length, slot.prep.length, slot.lexset.length, slot.qdm.length, slot.prep_part.length)
            let ls = ""
            let ls_f = ""
            let prep_s = ""
            let prepp_s = ""
            let feature_s = ""
            let role_s = ""
            let ssi = ""
            let ssi_f = ""
            for (let i=0; i<maxl; i++) {
                let s = (slot.semtype[i] || "").trim()
                let r = slot.role[i] || ""
                let f = slot.feature[i] || ""
                let o = opts[i] || ""
                let p = (slot.prep[i] || "").trim()
                let l = (slot.lexset[i] || "").trim()
                let q = slot.qdm[i] || ""
                let pp = (slot.prep_part[i] || "").trim()
                ls = "<span class='ls'>" + (q && ("<span class='qdm'>" + q + "</span> ")) + l + "</span>"
                ls_f = q + " {" + l + "}"
                prep_s = "<span class='prep'>" + p + "</span>"
                prepp_s = "<span class='prep_part'>" + pp + "</span>"
                feature_s = f && ("<span class='feature'>" + f + "</span>")
                role_s = r && ("<span class='role'>" + r + "</span>")
                ssi = s + feature_s + role_s
                ssi_f = s + " " + f + " " + r
                let ss = ""
                let ss_f = ""
                if (s && l) {
                    if (p) {
                        ss = prep_s + "<span class='st'>" + ssi + " " + ls + "</span>"
                        ss_f = p + " " + ssi_f + " " + ls_f
                    }
                    else if (pp) {
                        ss = prepp_s + "<span class='st'>" + ssi + " " + ls + "</span>"
                        ss_f = pp + " " + ssi_f + " " + ls_f
                    }
                    else {
                        ss = "<span class='st'>" + ssi + " " + ls + "</span>"
                        ss_f = ssi_f + " " + ls_f
                    }
                }
                else if (s) {
                    if (p) {
                        ss = prep_s + "<span class='st'>" + ssi + "</span>"
                        ss_f = p + " " + ssi_f
                    }
                    else if (pp) {
                        ss = prepp_s + "<span class='st'>" + ssi + "</span>"
                        ss_f = pp + " " + ssi_f
                    }
                    else {
                        ss = "<span class='st'>" + ssi + "</span>"
                        ss_f = ssi_f
                    }
                }
                else if (l) {
                    if (p) {
                        ss = prep_s + ls
                        ss_f = p + " " + ls_f
                    }
                    else if(pp) {
                        ss = prepp_s + ls
                        ss_f = pp + " " + ls_f
                    }
                    else {
                        ss = ls
                        ss_f = ls_f
                    }
                }
                else {
                    if (p) {
                        ss = prep_s
                        ss_f = p
                    }
                    else if (pp) {
                        ss = prepp_s
                        ss_f = pp
                    }
                    else {
                        continue
                    }
                }
                if (o) {
                    ss = "<span class='opt'>" + ss + "</span>"
                    ss_f = "(" + ss_f + ")"
                }
                sslist.push(ss)
                sslist_f.push(ss_f)
            }
            let inter = sslist.join("<span class='stor'>|</span>")
            let inter_f = sslist_f.join(" | ")
            let infs = slot.inf || ""
            if (infs) {
                inter = infs + " " + inter
                inter_f = infs + " " + inter_f
            }
            let fins = slot.fin || ""
            if (fins) {
                if (infs) {
                    inter = "<span class='infsep'>|</span>" + inter
                    inter_f = " | " + inter_f
                }
                inter = fins + " " + inter
                inter_f = fins + " " + inter_f
            }
            if (slot.slot == "clausals" && slot.quote === true) {
                inter = "<span class='quote'>:</span> " + inter
                inter_f = " : " + inter_f
            }
            let types = slot.type || []
            // TODO: remove when all types are lists
            if (!Array.isArray(types)) {
                types = [types]
            }
            if (types.filter(function (x) { return x }).length && slot.slot != "predic_compl") {
                inter = "<span class='type'>" + types.join('|') + "</span>" + " " + inter
                inter_f = types.join('|') + ' ' + inter_f
            }
            slot_str += inter
            slot_f += inter_f.trim()
            slot_str += '</span>'
            if (slot.optional) {
                slot_f += ')'
            }
            slots.push(slot_str)
            fslots.push(slot_f + (slot.or ? " |" : ""))
        })
        slots.splice(has_subject ? 1 : 0, 0, '<span class="verb">' + data.verb_form + '</span>')
        let v = (data.verb_form || "").trim()
        if (v) {
            fslots.splice(has_subject ? 1 : 0, 0, v)
        }
        return [slots.join(""), fslots.filter(function (x) { return !!x }).join(" ")]
    }

    pdev_label(data) {
        if (!data || !data.slots || !data.slots.length) {
            return ["", ""]
        }
        let slots = []
        let fslots = []
        let idiom = data.idiom
        let phrasal = data.phrasal
        if (idiom || phrasal) {
            let idiompv_str = ""
            if (idiom) {
                idiompv_str += "idiom"
            }
            if (idiom && phrasal) {
                idiompv_str += ", "
            }
            if (phrasal) {
                idiompv_str += "phrasal"
            }
            slots.push("<span class='idiompv'>" + idiompv_str + "</span>")
        }
        let has_obj = data.slots.filter(function (x) { return x.type == "object" }).length
        let ctm = {
            cl_to: "to+INF",
            cl_that: "THAT",
            cl_ing: "ING",
            cl_quote: "QUOTE",
            cl_wh: "WH+"
        }
        data.slots.forEach(function (slot) {
            if (slot.type == "head") {
                slots.push(`<span class='verb'>${slot.head}</span>`)
                fslots.push(slot.head)
                if (!has_obj) {
                    slots.push("<span class='noobj'>NO OBJ</span>")
                    fslots.push("[NO OBJ]")
                }
                return
            }
            let slot_str = ""
            let slot_f = ""
            if (slot.optional) {
                slot_str = `<span class="opt">`
                slot_f = "("
            }
            else {
                slot_str = ""
                slot_f = ""
            }
            slot_str += `<span class="${slot.type} ${slot.or ? "or" : ""}">`
            let semtypes = []
            for (let i=0; i<Math.max(slot.semtype.length, slot.role.length); i++) {
                if (slot.semtype[i] && slot.semtype[i].trim()) {
                    semtypes.push(slot.semtype[i] + (slot.role[i] ? (" = <i>" + slot.role[i] + '</i>') : ""))
                }
            }
            let opts = slot.opt || []
            if (!Array.isArray(opts)) {
                opts = [opts]
            }
            let ssl = []
            let ssfl = []
            let ss = ""
            let ssf = ""
            if (opts.reduce(function (x, y) { return x || y }).length) {
                let maxl = Math.max(semtypes.length, opts.length)
                for (let i=0; i<maxl; i++) {
                    let x = semtypes[i] || ""
                    let y = opts[i] || ""
                    ssl.push((y && "<span class='opt'>" || "") + "<span class='st'>" + x + '</span>' + (y && "</span>" || ""))
                    ssfl.push((y && '(' || '') + x + (y && ')' || ''))
                }
                ss = ssl.join(" | ")
                ssf = ssfl.join(' | ')
            }
            else {
                ss = "<span class='st'>" + semtypes.join(' | ') + '</span>'
                ssf = semtypes.join(' | ')
            }
            let inter = ""
            let inter_f = ""
            if (slot.type == "adverbial") {
                if (slot.advl_head) {
                    inter += "<span class='adverbial_head'>" + slot.advl_head + "</span>"
                    inter_f += slot.advl_head + " " + ssf
                }
                else if (slot.advl_func) {
                    inter += "<span>Adv <span class='adverbial_func'>" + slot.advl_func + "</span></span>"
                    inter_f += slot.advl_func + " " + ssf
                }
            }
            if (semtypes.length) {
                inter += ss
                inter_f += "[" + ssf + "]"
            }
            let maxl = Math.max(slot.lexset.length, slot.det_quant.length)
            let lexsets = []
            for (let i=0; i<maxl; i++) {
                let x = slot.lexset[i] || ""
                let y = slot.det_quant || ""
                if (x.trim()) {
                    lexsets.push(((y ? (y + " ") : "") + x.trim()))
                }
            }
            let sl = '<span class="ls">' + lexsets.join(' | ') + '</span>'
            let slf = lexsets.join(', ')
            if (lexsets.length && semtypes.length) {
                if (slot.semtype.length) {
                    inter += ' '
                    inter_f += ' '
                }
                else {
                    inter += ' | '
                    inter_f += ' | '
                }
            }
            if (lexsets.length) {
                inter += sl
                inter_f += "{" + slf + "}"
            }
            for (let ct in ctm) {
                if (slot[ct]) {
                    inter += `<span class='cl'>${ctm[ct]}</span>`
                    inter_f += ctm[ct]
                }
            }
            slot_str += inter.replace('{', '(').replace('}', ')')
            slot_f += inter_f.trim()
            slot_str += '</span>'
            if (slot.optional) {
                slot_str += "</span>"
                slot_f += ')'
            }
            slots.push(slot_str)
            fslots.push(slot_f + (slot.or ? " |" : ""))
        })
        return [slots.join(""), fslots.filter(function (x) { return !!x.trim() }).join(" ")]
    }

    croatpas_label(data) {
        if (!data || !data.slots || !data.slots.length) {
            return ["", ""]
        }
        let slots = []
        let fslots = []
        data.slots.forEach(function (slot) {
            if (slot.slot == 'verb') {
                slots.push('<span class="verb">' + (data.verb_form || "VERB") + '</span>')
                fslots.push(data.verb_form || "VERB")
                return
            }
            let slot_str = `<span class="${slot.slot} ${slot.or ? "or" : ""} ${slot.optional ? "opt" : ""}">`
            let slot_f = slot.optional ? "(" : ""
            let inter = ""
            let inter_f = ""
            let maxl = Math.max(slot.semtype.length, slot.role ? slot.role.length : 0, slot.feature ? slot.feature.length : 0)
            let semtypes = []
            for (let i=0; i<maxl; i++) {
                let x = slot.semtype[i] || ""
                let y = slot.role[i] || ""
                let z = slot.feature[i] || ""
                if (x.trim()) {
                    semtypes.push((x + (y && (" = <i>" + y + '</i>') || "") + (z && (" : <i>" + z + '</i>') || "")))
                }
            }
            let opts = slot.opt
            if (!Array.isArray(opts)) {
                opts = [opts]
            }
            let ss = ""
            let ssf = ""
            let ssl = []
            let ssfl = []
            if (slot.prep.filter(function (x) { return x.trim() }).length) {
                if (opts.filter(function (x) { return x }).length) {
                    let maxl = Math.max(semtypes.length, slot.prep.length, opts.length)
                    for (let i=0; i<maxl; i++) {
                        let x = semtypes[i] || ""
                        let y = slot.prep[i] || ""
                        let z = opts[i] || ""
                        ssl.push((z && "<span class='opt'>" || "") + (y && (y + " ") || "") + "<span class='st'>" + x + (z && "</span>" || "") + "</span>")
                        ssfl.push((z && "(" || "") + (y && (y + " ") || "") + x + (z && ")" || ""))
                    }
                    ss = ssl.join(" | ")
                    ssf = ssfl.join(" | ")
                }
                else {
                    let maxl = Math.max(semtypes.length, slot.prep.length)
                    for (let i=0; i<maxl; i++) {
                        let x = semtypes[i] || ""
                        let y = slot.prep[i] || ""
                        ssl.push((y && y + " " || "") + "<span class='st'>" + x + "</span>")
                        ssfl.push((y && y + " " || "") + x)
                    }
                    ss = ssl.join(" | ")
                    ssf = ssfl.join(" | ")
                }
            }
            else {
                if (opts.filter(function (x) { return x }).length) {
                    let maxl = Math.max(semtypes.length, opts.length)
                    for (let i=0; i<maxl; i++) {
                        let x = semtypes[i] || ""
                        let y = opts[i] || ""
                        ssl.push((y ? "<span class='opt'>" : "") + "<span class='st'>" + x + '</span>' + (y ? "</span>" : ""))
                        ssfl.push((y ? '(' : '') + x + (y ? ')' : ''))
                    }
                    ss = ssl.join(" | ")
                    ssf = ssfl.join(" | ")
                }
                else {
                    ss = "<span class='st'>" + semtypes.join(' | ') + '</span>'
                    ssf = semtypes.join(' | ')
                }
            }
            let c = slot.case
            if (c && ["object", "ind_compl", "subject", "predic_compl", "adverbial"].indexOf(slot.slot) >= 0) {
                ss += "<span class='case'>" + c + "</span>"
                ssf += " " + c
            }
            if (semtypes.length) {
                inter += ss
                inter_f += "[" + ssf + "]"
            }
            let lexsets = []
            for (let i=0; i<Math.max(slot.lexset.length, slot.qdm.length); i++) {
                let x = slot.lexset[i] || ""
                let y = slot.qdm[i] || ""
                if (x.trim()) {
                    lexsets.push(((y ? (y + " ") : "") + x))
                }
            }
            let sl = ""
            let slf = ""
            if (slot.prep.reduce(function (x, y) { return x || y })) {
                let preps = slot.prep.filter(function (x) { return x.trim() }).join(', ')
                sl = '<span class="prep">' + preps + '</span>'
                sl += '<span class="ls">' + lexsets.join(' | ') + '</span>'
                slf = preps + lexsets.join(', ')
            }
            else {
                sl = '<span class="ls">' + lexsets.join(' | ') + '</span>'
                slf = lexsets.join(', ')
            }
            if (lexsets.length && semtypes.length) {
                if (slot.lexset.filter(function (x) { return !!x.trim() }).length &&
                        slot.semtype.filter(function (x) { return x.trim() }).length) {
                    inter += ' '
                    inter_f += ' '
                }
                else {
                    inter += ' | '
                    inter_f += ' | '
                }
            }
            if (lexsets.length) {
                inter += sl
                inter_f += "{" + slf + "}"
            }
            let fins = slot.slot == "clausals" && slot.fin
            if (fins.length) {
                inter = fins + " " + inter
                inter_f = fins + " " + inter_f
            }
            let prep_parts = slot.prep_part.filter(function (x) { return x.trim() })
            if (prep_parts.length) {
                inter = "<span class='prep_part'>" + prep_part.join('|') + '</span>' + inter
                inter_f = prep_parts.join('|') + ' ' + inter
            }
            let kaoza = slot.kaoza || ""
            if (kaoza.length) {
                inter = "<span class='kaoza'>" + kaoza + "</span> " + inter
                inter_f = kaoza + " " + inter_f
            }
            let types = slot.type || []
            // TODO: remove when all types are lists
            if (!Array.isArray(types)) {
                types = [types]
            }
            if (types.reduce(function (x, y) { return x || y }) && slot.slot != "predic_compl") {
                inter = "<span class='type'>" + types.join('|') + "</span>" + " " + inter
                inter_f = types.join('|') + ' ' + inter_f
            }
            slot_str += inter
            slot_f += inter_f.trim()
            slot_str += '</span>'
            if (slot.optional) {
                slot_f += ')'
            }
            slots.push(slot_str)
            fslots.push(slot_f + (slot.or ? " |" : ""))
        })
        return [slots.join(""), fslots.filter(function (x) { return x.trim() }).join(" ")]
    }

    generic_label(data) {
        if (!data || !data.attributes || !data.attributes.length) {
            return ["", ""]
        }
        let attrs = []
        let fattrs = []
        let a = {}
        for (let i=0; i<data.attributes.length; i++) {
            a = data.attributes[i]
            if (a.label && a.value) {
                attrs.push(`<span class="attr"><span class="value">${a.value}</span><span class="name">${a.label}</span></span>`)
                fattrs.push(a.label + ": " + a.value)
            }
        }
        return [attrs.join(""), fattrs.join(",")]
    }

    annotconcToUrl(annotconc) {
        this.annotconc = annotconc
        Url.updateQuery({
            corpname: this.corpus.corpname,
            annotconc: this.annotconc
        }, false, false)
    }

    updateQueryRow(payload){
        let query = this.queries.find(q => q.id == payload.qid)
        if(query){
            query.editor = payload.user
            query.edited = payload.dt
        }
    }
}

export let AnnotationStore = new AnnotationStoreClass()
