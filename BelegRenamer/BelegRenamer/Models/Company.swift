import Foundation

struct Company: Identifiable, Codable, Equatable {
    var id: String { name }
    let name: String
    let keywords: [String]
    let defaultType: ReceiptType?
    let isLearned: Bool

    init(name: String, keywords: [String], defaultType: ReceiptType? = nil, isLearned: Bool = false) {
        self.name = name
        self.keywords = keywords.map { $0.lowercased() }
        self.defaultType = defaultType
        self.isLearned = isLearned
    }
}

struct CompanyDatabase {
    static let standardCompanies: [Company] = [
        // ============ PARKEN ============
        // HINWEIS: APCOA kann auch E-Lade-Belege sein - wird in ClassificationService korrigiert
        Company(name: "APCOA", keywords: ["apcoa", "apcoa parking", "apcoa flow", "stafa tower"], defaultType: .parkbeleg),
        Company(name: "Wipark", keywords: ["wipark", "wien parking"], defaultType: .parkbeleg),
        Company(name: "Contipark", keywords: ["contipark"], defaultType: .parkbeleg),
        Company(name: "ParkAndRide", keywords: ["park and ride", "park+ride", "p+r"], defaultType: .parkbeleg),
        Company(name: "ÖAMTC-Parken", keywords: ["öamtc park", "easy way", "easyway"], defaultType: .parkbeleg),
        Company(name: "Parkster", keywords: ["parkster"], defaultType: .parkbeleg),
        Company(name: "EasyPark", keywords: ["easypark", "easy park"], defaultType: .parkbeleg),
        Company(name: "ParkNow", keywords: ["parknow", "park now"], defaultType: .parkbeleg),
        Company(name: "PayByPhone", keywords: ["paybyphone", "pay by phone"], defaultType: .parkbeleg),

        // ============ TANKEN ============
        // WICHTIG: Avanti muss VOR OMV stehen, da Avanti-Belege "OMV Downstream GmbH" enthalten
        Company(name: "Avanti", keywords: ["avanti"], defaultType: .tankbeleg),
        Company(name: "OMV", keywords: ["omv", "viva ", "omv viva"], defaultType: .tankbeleg),
        Company(name: "Shell", keywords: ["shell", "shell austria", "shell deutschland"], defaultType: .tankbeleg),
        Company(name: "BP", keywords: [" bp ", "bp tankstelle", "british petroleum", "bp station"], defaultType: .tankbeleg),
        Company(name: "Turmöl", keywords: ["turmöl", "turmoil"], defaultType: .tankbeleg),
        Company(name: "JET", keywords: ["jet tankstelle", "jet-tankstelle", "jet station"], defaultType: .tankbeleg),
        Company(name: "Eni", keywords: ["eni ", "agip", "eni station"], defaultType: .tankbeleg),
        Company(name: "Diskont", keywords: ["diskont tanken", "diskonttank"], defaultType: .tankbeleg),
        Company(name: "Aral", keywords: ["aral"], defaultType: .tankbeleg),
        Company(name: "Total", keywords: ["total energies", "totalenergies"], defaultType: .tankbeleg),
        Company(name: "Esso", keywords: ["esso"], defaultType: .tankbeleg),

        // ============ E-TANKEN ============
        Company(name: "EVN", keywords: ["evn", "evn naturkraft", "evn mobil"], defaultType: .eTankbeleg),
        Company(name: "Smatrics", keywords: ["smatrics", "smatrics.com"], defaultType: .eTankbeleg),
        Company(name: "Ionity", keywords: ["ionity"], defaultType: .eTankbeleg),
        Company(name: "Tesla", keywords: ["tesla supercharger", "tesla charging", "supercharger"], defaultType: .eTankbeleg),
        Company(name: "EnBW", keywords: ["enbw", "enbw mobility"], defaultType: .eTankbeleg),
        Company(name: "WienEnergie", keywords: ["wien energie", "tanke wien energie"], defaultType: .eTankbeleg),
        Company(name: "DaEmobility", keywords: ["da emobility", "da e-mobility"], defaultType: .eTankbeleg),
        Company(name: "Fastned", keywords: ["fastned"], defaultType: .eTankbeleg),
        Company(name: "Allego", keywords: ["allego"], defaultType: .eTankbeleg),
        Company(name: "ChargePoint", keywords: ["chargepoint"], defaultType: .eTankbeleg),
        Company(name: "Plugsurfing", keywords: ["plugsurfing"], defaultType: .eTankbeleg),
        Company(name: "NewMotion", keywords: ["newmotion", "new motion"], defaultType: .eTankbeleg),
        Company(name: "Maingau", keywords: ["maingau"], defaultType: .eTankbeleg),

        // ============ DRUCKER / HARDWARE ============
        Company(name: "HP", keywords: ["hp ", " hp", "hewlett-packard", "hewlett packard", "hp inc", "hp instant ink", "hpinstantink", "hp.com"], defaultType: .rechnung),
        Company(name: "Canon", keywords: ["canon"], defaultType: .rechnung),
        Company(name: "Epson", keywords: ["epson"], defaultType: .rechnung),
        Company(name: "Brother", keywords: ["brother"], defaultType: .rechnung),
        Company(name: "Dell", keywords: ["dell"], defaultType: .rechnung),
        Company(name: "Lenovo", keywords: ["lenovo"], defaultType: .rechnung),
        Company(name: "Logitech", keywords: ["logitech"], defaultType: .rechnung),
        Company(name: "Samsung", keywords: ["samsung"], defaultType: .rechnung),
        Company(name: "LG", keywords: [" lg ", "lg electronics"], defaultType: .rechnung),
        Company(name: "Sony", keywords: ["sony"], defaultType: .rechnung),

        // ============ MEDIEN / ABOS ============
        Company(name: "DiePresse", keywords: ["die presse", "diepresse.com", "diepresse"], defaultType: .abo),
        Company(name: "DerStandard", keywords: ["der standard", "derstandard.at", "derstandard"], defaultType: .abo),
        Company(name: "NYT", keywords: ["new york times", "nytimes", "nyt.com"], defaultType: .abo),
        Company(name: "Medium", keywords: ["medium.com", "medium membership", "medium inc"], defaultType: .abo),
        Company(name: "Economist", keywords: ["the economist", "economist.com"], defaultType: .abo),
        Company(name: "Substack", keywords: ["substack"], defaultType: .abo),
        Company(name: "Readwise", keywords: ["readwise"], defaultType: .abo),
        Company(name: "Blinkist", keywords: ["blinkist"], defaultType: .abo),
        Company(name: "Kindle", keywords: ["kindle unlimited"], defaultType: .abo),
        Company(name: "Audible", keywords: ["audible"], defaultType: .abo),
        Company(name: "Kurier", keywords: ["kurier.at", "kurier "], defaultType: .abo),
        Company(name: "Krone", keywords: ["krone.at", "kronen zeitung"], defaultType: .abo),
        Company(name: "Mediaprint", keywords: ["mediaprint"], defaultType: .abo),
        Company(name: "Kleine", keywords: ["kleine zeitung"], defaultType: .abo),

        // ============ STREAMING ============
        Company(name: "Netflix", keywords: ["netflix"], defaultType: .abo),
        Company(name: "Spotify", keywords: ["spotify"], defaultType: .abo),
        Company(name: "YouTubePremium", keywords: ["youtube premium", "youtube music"], defaultType: .appAbo),
        Company(name: "Zattoo", keywords: ["zattoo"], defaultType: .abo),
        Company(name: "Disney+", keywords: ["disney+", "disney plus"], defaultType: .abo),
        Company(name: "AmazonPrime", keywords: ["amazon prime", "prime video"], defaultType: .abo),
        Company(name: "AppleTV", keywords: ["apple tv+", "apple tv plus", "appletv"], defaultType: .appAbo),
        Company(name: "Paramount", keywords: ["paramount+", "paramount plus"], defaultType: .abo),
        Company(name: "HBO", keywords: ["hbo max", "hbo"], defaultType: .abo),
        Company(name: "Crunchyroll", keywords: ["crunchyroll"], defaultType: .abo),
        Company(name: "DAZN", keywords: ["dazn"], defaultType: .abo),
        Company(name: "Sky", keywords: ["sky ticket", "sky go", "sky.at"], defaultType: .abo),

        // ============ SOFTWARE / TECH ============
        Company(name: "Apple", keywords: ["apple.com/bill", "apple distribution", "apple services", "itunes", "app store", "apple inc"], defaultType: .appAbo),
        Company(name: "Google", keywords: ["google.com/pay", "google play", "google one", "google cloud", "google llc"], defaultType: .appAbo),
        Company(name: "Microsoft", keywords: ["microsoft 365", "microsoft corporation", "office 365", "microsoft azure", "microsoft.com"], defaultType: .abo),
        Company(name: "Anthropic", keywords: ["anthropic", "claude.ai", "claude pro", "anthropic pbc"], defaultType: .appAbo),
        Company(name: "OpenAI", keywords: ["openai", "chatgpt plus", "chatgpt pro"], defaultType: .appAbo),
        Company(name: "Perplexity", keywords: ["perplexity", "perplexity.ai"], defaultType: .appAbo),
        Company(name: "Canva", keywords: ["canva"], defaultType: .appAbo),
        Company(name: "Adobe", keywords: ["adobe", "creative cloud", "adobe inc"], defaultType: .abo),
        Company(name: "Dropbox", keywords: ["dropbox"], defaultType: .abo),
        Company(name: "GitHub", keywords: ["github"], defaultType: .abo),
        Company(name: "JetBrains", keywords: ["jetbrains"], defaultType: .abo),
        Company(name: "1Password", keywords: ["1password", "agilebits"], defaultType: .abo),
        Company(name: "Notion", keywords: ["notion"], defaultType: .abo),
        Company(name: "Slack", keywords: ["slack"], defaultType: .abo),
        Company(name: "Zoom", keywords: ["zoom video", "zoom.us", "zoom communications"], defaultType: .abo),
        Company(name: "Figma", keywords: ["figma"], defaultType: .abo),
        Company(name: "Miro", keywords: ["miro.com", "miro board"], defaultType: .abo),
        Company(name: "Asana", keywords: ["asana"], defaultType: .abo),
        Company(name: "Monday", keywords: ["monday.com"], defaultType: .abo),
        Company(name: "Trello", keywords: ["trello"], defaultType: .abo),
        Company(name: "Todoist", keywords: ["todoist"], defaultType: .abo),
        Company(name: "Evernote", keywords: ["evernote"], defaultType: .abo),
        Company(name: "Grammarly", keywords: ["grammarly"], defaultType: .abo),
        Company(name: "DeepL", keywords: ["deepl"], defaultType: .abo),
        Company(name: "LastPass", keywords: ["lastpass"], defaultType: .abo),
        Company(name: "Bitwarden", keywords: ["bitwarden"], defaultType: .abo),
        Company(name: "NordVPN", keywords: ["nordvpn", "nord vpn"], defaultType: .abo),
        Company(name: "ExpressVPN", keywords: ["expressvpn"], defaultType: .abo),
        Company(name: "Surfshark", keywords: ["surfshark"], defaultType: .abo),
        Company(name: "ProtonVPN", keywords: ["protonvpn", "proton vpn", "proton ag"], defaultType: .abo),
        Company(name: "Paddle", keywords: ["paddle.com", "paddle.net", "paddle payment"], defaultType: .rechnung),
        Company(name: "Gumroad", keywords: ["gumroad"], defaultType: .rechnung),
        Company(name: "Lemon", keywords: ["lemon squeezy", "lemonsqueezy"], defaultType: .rechnung),
        Company(name: "Stripe", keywords: ["stripe.com", "stripe payments"], defaultType: .rechnung),
        Company(name: "PayPal", keywords: ["paypal"], defaultType: .rechnung),
        Company(name: "Wise", keywords: ["wise.com", "transferwise"], defaultType: .rechnung),
        Company(name: "Revolut", keywords: ["revolut"], defaultType: .rechnung),

        // ============ STOCK PHOTOS / CREATIVE ============
        Company(name: "Unsplash", keywords: ["unsplash", "unsplash+", "unsplash plus", "unsplash inc"], defaultType: .abo),
        Company(name: "Shutterstock", keywords: ["shutterstock"], defaultType: .abo),
        Company(name: "iStock", keywords: ["istock", "istockphoto"], defaultType: .abo),
        Company(name: "Getty", keywords: ["getty images", "gettyimages"], defaultType: .abo),
        Company(name: "AdobeStock", keywords: ["adobe stock"], defaultType: .abo),
        Company(name: "Envato", keywords: ["envato", "envato elements"], defaultType: .abo),
        Company(name: "Freepik", keywords: ["freepik"], defaultType: .abo),
        Company(name: "Pexels", keywords: ["pexels"], defaultType: .abo),

        // ============ DOMAINS / HOSTING ============
        Company(name: "GoDaddy", keywords: ["godaddy"], defaultType: .rechnung),
        Company(name: "Namecheap", keywords: ["namecheap"], defaultType: .rechnung),
        Company(name: "Cloudflare", keywords: ["cloudflare"], defaultType: .rechnung),
        Company(name: "Vercel", keywords: ["vercel"], defaultType: .rechnung),
        Company(name: "Netlify", keywords: ["netlify"], defaultType: .rechnung),
        Company(name: "Heroku", keywords: ["heroku"], defaultType: .rechnung),
        Company(name: "DigitalOcean", keywords: ["digitalocean"], defaultType: .rechnung),
        Company(name: "Hetzner", keywords: ["hetzner"], defaultType: .rechnung),
        Company(name: "AWS", keywords: ["amazon web services", "aws.amazon"], defaultType: .rechnung),
        Company(name: "WorldForYou", keywords: ["world4you"], defaultType: .rechnung),
        Company(name: "Strato", keywords: ["strato"], defaultType: .rechnung),
        Company(name: "1und1", keywords: ["1&1", "1und1", "ionos"], defaultType: .rechnung),

        // ============ EINZELHANDEL ============
        Company(name: "Billa", keywords: ["billa", "billa plus"], defaultType: .kassenbon),
        Company(name: "Spar", keywords: ["spar", "interspar", "eurospar"], defaultType: .kassenbon),
        Company(name: "Hofer", keywords: ["hofer", "aldi süd"], defaultType: .kassenbon),
        Company(name: "Lidl", keywords: ["lidl"], defaultType: .kassenbon),
        Company(name: "IKEA", keywords: ["ikea"], defaultType: .kassenbon),
        Company(name: "MediaMarkt", keywords: ["media markt", "mediamarkt"], defaultType: .kassenbon),
        Company(name: "Saturn", keywords: ["saturn"], defaultType: .kassenbon),
        Company(name: "Amazon", keywords: ["amazon.de", "amazon.at", "amazon.com", "amazon eu"], defaultType: .rechnung),
        Company(name: "Zalando", keywords: ["zalando"], defaultType: .rechnung),
        Company(name: "DM", keywords: ["dm drogerie", "dm-drogerie"], defaultType: .kassenbon),
        Company(name: "Müller", keywords: ["müller drogerie"], defaultType: .kassenbon),
        Company(name: "HundM", keywords: ["h&m", "h & m", "hennes"], defaultType: .kassenbon),
        Company(name: "Zara", keywords: ["zara"], defaultType: .kassenbon),
        Company(name: "Tchibo", keywords: ["tchibo"], defaultType: .kassenbon),
        Company(name: "Thalia", keywords: ["thalia"], defaultType: .kassenbon),
        Company(name: "OBI", keywords: ["obi baumarkt", "obi "], defaultType: .kassenbon),
        Company(name: "Hornbach", keywords: ["hornbach"], defaultType: .kassenbon),
        Company(name: "Bauhaus", keywords: ["bauhaus"], defaultType: .kassenbon),
        Company(name: "XXXLutz", keywords: ["xxxlutz", "xxx lutz", "lutz"], defaultType: .kassenbon),
        Company(name: "Kika", keywords: ["kika", "leiner"], defaultType: .kassenbon),
        Company(name: "Conrad", keywords: ["conrad electronic", "conrad.at", "conrad.de"], defaultType: .kassenbon),

        // ============ HOTELS ============
        Company(name: "Booking", keywords: ["booking.com", "booking confirmation"], defaultType: .hotelbeleg),
        Company(name: "Airbnb", keywords: ["airbnb"], defaultType: .hotelbeleg),
        Company(name: "Hotels.com", keywords: ["hotels.com"], defaultType: .hotelbeleg),
        Company(name: "Expedia", keywords: ["expedia"], defaultType: .hotelbeleg),
        Company(name: "Trivago", keywords: ["trivago"], defaultType: .hotelbeleg),
        Company(name: "HRS", keywords: ["hrs.de", "hrs.com"], defaultType: .hotelbeleg),

        // ============ TRANSPORT ============
        Company(name: "ÖBB", keywords: ["öbb", "oebb", "österreichische bundesbahnen"], defaultType: .rechnung),
        Company(name: "WienerLinien", keywords: ["wiener linien"], defaultType: .rechnung),
        Company(name: "Flixbus", keywords: ["flixbus", "flix"], defaultType: .rechnung),
        Company(name: "Uber", keywords: ["uber"], defaultType: .rechnung),
        Company(name: "Bolt", keywords: ["bolt"], defaultType: .rechnung),
        Company(name: "Lime", keywords: ["lime", "li.me"], defaultType: .rechnung),
        Company(name: "Tier", keywords: ["tier mobility", "tier scooter"], defaultType: .rechnung),
        Company(name: "Ryanair", keywords: ["ryanair"], defaultType: .rechnung),
        Company(name: "EasyJet", keywords: ["easyjet"], defaultType: .rechnung),
        Company(name: "Eurowings", keywords: ["eurowings"], defaultType: .rechnung),
        Company(name: "Austrian", keywords: ["austrian airlines", "austrian.com"], defaultType: .rechnung),
        Company(name: "Lufthansa", keywords: ["lufthansa"], defaultType: .rechnung),
        Company(name: "KLM", keywords: ["klm"], defaultType: .rechnung),

        // ============ TELEKOMMUNIKATION ============
        Company(name: "A1", keywords: ["a1 telekom", "a1.net"], defaultType: .rechnung),
        Company(name: "Magenta", keywords: ["magenta", "t-mobile austria"], defaultType: .rechnung),
        Company(name: "Drei", keywords: ["drei.at", "hutchison drei"], defaultType: .rechnung),
        Company(name: "HoT", keywords: ["hot.at", "hot hofer telekom"], defaultType: .rechnung),
        Company(name: "Yesss", keywords: ["yesss"], defaultType: .rechnung),
        Company(name: "Spusu", keywords: ["spusu"], defaultType: .rechnung),
        Company(name: "BobVodafone", keywords: ["bob.at", "vodafone"], defaultType: .rechnung),

        // ============ VERSICHERUNG ============
        Company(name: "Allianz", keywords: ["allianz"], defaultType: .rechnung),
        Company(name: "Uniqa", keywords: ["uniqa"], defaultType: .rechnung),
        Company(name: "Generali", keywords: ["generali"], defaultType: .rechnung),
        Company(name: "WienerStädtische", keywords: ["wiener städtische"], defaultType: .rechnung),
        Company(name: "Ergo", keywords: ["ergo versicherung"], defaultType: .rechnung),
        Company(name: "Zurich", keywords: ["zurich versicherung", "zürich versicherung"], defaultType: .rechnung),
        Company(name: "HDI", keywords: ["hdi versicherung"], defaultType: .rechnung),

        // ============ BANKEN ============
        Company(name: "ErsteBank", keywords: ["erste bank", "sparkasse"], defaultType: .rechnung),
        Company(name: "RaiffeisenBank", keywords: ["raiffeisen"], defaultType: .rechnung),
        Company(name: "BankAustria", keywords: ["bank austria", "unicredit"], defaultType: .rechnung),
        Company(name: "BAWAG", keywords: ["bawag", "psk"], defaultType: .rechnung),
        Company(name: "ING", keywords: ["ing diba", "ing bank"], defaultType: .rechnung),
        Company(name: "N26", keywords: ["n26"], defaultType: .rechnung),

        // ============ KREDITKARTEN ============
        // WICHTIG: PayLife mit VISA oder Mastercard - spezifische Erkennung in ClassificationService
        Company(name: "PayLife-VISA", keywords: ["paylife black visa", "paylife gold visa", "paylife visa"], defaultType: .kreditkartenabrechnung),
        Company(name: "PayLife-Mastercard", keywords: ["paylife mastercard", "paylife black mastercard", "paylife gold mastercard"], defaultType: .kreditkartenabrechnung),
        Company(name: "PayLife", keywords: ["paylife", "monatsabrechnung", "rechnungsübersicht"], defaultType: .kreditkartenabrechnung),
        Company(name: "card complete", keywords: ["card complete"], defaultType: .kreditkartenabrechnung),
        Company(name: "AmericanExpress", keywords: ["american express", "amex"], defaultType: .kreditkartenabrechnung),
        Company(name: "Diners", keywords: ["diners club"], defaultType: .kreditkartenabrechnung),

        // ============ ENERGIE ============
        Company(name: "Verbund", keywords: ["verbund"], defaultType: .rechnung),
        Company(name: "Kelag", keywords: ["kelag"], defaultType: .rechnung),
        Company(name: "Salzburg-AG", keywords: ["salzburg ag"], defaultType: .rechnung),
        Company(name: "Energie-AG", keywords: ["energie ag"], defaultType: .rechnung),
        Company(name: "TIWAG", keywords: ["tiwag"], defaultType: .rechnung),

        // ============ RESTAURANTS / LIEFERUNG ============
        Company(name: "Lieferando", keywords: ["lieferando"], defaultType: .bewirtungsbeleg),
        Company(name: "MjamFoodora", keywords: ["mjam", "foodora"], defaultType: .bewirtungsbeleg),
        Company(name: "UberEats", keywords: ["uber eats", "ubereats"], defaultType: .bewirtungsbeleg),
        Company(name: "Wolt", keywords: ["wolt"], defaultType: .bewirtungsbeleg),
        Company(name: "McDonalds", keywords: ["mcdonald", "mcd", "mc donald"], defaultType: .bewirtungsbeleg),
        Company(name: "BurgerKing", keywords: ["burger king"], defaultType: .bewirtungsbeleg),
        Company(name: "Starbucks", keywords: ["starbucks"], defaultType: .bewirtungsbeleg),
        Company(name: "Subway", keywords: ["subway"], defaultType: .bewirtungsbeleg),

        // ============ APPS / DIENSTE ============
        Company(name: "Duolingo", keywords: ["duolingo"], defaultType: .appAbo),
        Company(name: "Babbel", keywords: ["babbel"], defaultType: .appAbo),
        Company(name: "Headspace", keywords: ["headspace"], defaultType: .appAbo),
        Company(name: "Calm", keywords: ["calm app"], defaultType: .appAbo),
        Company(name: "Strava", keywords: ["strava"], defaultType: .appAbo),
        Company(name: "Komoot", keywords: ["komoot"], defaultType: .appAbo),
        Company(name: "AllTrails", keywords: ["alltrails"], defaultType: .appAbo),
        Company(name: "MyFitnessPal", keywords: ["myfitnesspal"], defaultType: .appAbo),
        Company(name: "Setapp", keywords: ["setapp"], defaultType: .appAbo),
        Company(name: "CleanMyMac", keywords: ["cleanmymac", "macpaw"], defaultType: .appAbo),
        Company(name: "Alfred", keywords: ["alfred", "alfredapp"], defaultType: .appAbo),
        Company(name: "Raycast", keywords: ["raycast"], defaultType: .appAbo),
        Company(name: "BetterTouchTool", keywords: ["bettertouchtool"], defaultType: .appAbo),

        // ============ GAMING ============
        Company(name: "Steam", keywords: ["steam", "valve corporation"], defaultType: .appAbo),
        Company(name: "PlayStation", keywords: ["playstation", "sony interactive"], defaultType: .appAbo),
        Company(name: "Xbox", keywords: ["xbox", "xbox game pass"], defaultType: .appAbo),
        Company(name: "Nintendo", keywords: ["nintendo"], defaultType: .appAbo),
        Company(name: "EpicGames", keywords: ["epic games", "epicgames"], defaultType: .appAbo),

        // ============ NANO BANANA / NISCHENDIENSTE ============
        Company(name: "NanoBanana", keywords: ["nano banana", "nanobanana"], defaultType: .appAbo),
    ]
}
