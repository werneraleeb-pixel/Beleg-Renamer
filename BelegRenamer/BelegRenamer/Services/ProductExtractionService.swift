import Foundation

struct ProductExtractionService {
    static let shared = ProductExtractionService()

    // Bekannte Apps/Produkte mit Keywords zur Erkennung
    private let knownProducts: [(name: String, keywords: [String])] = [
        // Stock Photos & Creative
        ("Unsplash+", ["unsplash+", "unsplash plus", "unsplash subscription"]),
        ("Shutterstock", ["shutterstock"]),
        ("iStock", ["istock"]),
        ("AdobeStock", ["adobe stock"]),
        ("Envato", ["envato elements"]),

        // Hardware Abos
        ("InstantInk", ["instant ink", "instantink", "hp instant"]),

        // Produktivität & AI
        ("Perplexity", ["perplexity"]),
        ("ChatGPT", ["chatgpt", "openai"]),
        ("Claude", ["claude", "anthropic"]),
        ("Notion", ["notion"]),
        ("Todoist", ["todoist"]),
        ("Things", ["things 3", "things3"]),
        ("Bear", ["bear app", "bear writer"]),
        ("Ulysses", ["ulysses"]),
        ("iAWriter", ["ia writer"]),
        ("Craft", ["craft docs", "craft -"]),
        ("GoodNotes", ["goodnotes"]),
        ("Notability", ["notability"]),
        ("Scanner Pro", ["scanner pro"]),
        ("PDF Expert", ["pdf expert"]),
        ("Fantastical", ["fantastical"]),
        ("Cardhop", ["cardhop"]),
        ("Spark", ["spark mail", "spark email"]),
        ("Airmail", ["airmail"]),
        ("DirEqual", ["direqual"]),

        // Streaming via Amazon
        ("ARDPlus", ["ard plus", "ard+"]),
        ("ZDFplus", ["zdf plus", "zdf+"]),
        ("ZattooPremium", ["zattoo premium"]),
        ("RTLplus", ["rtl+", "rtl plus"]),
        ("Joyn", ["joyn plus", "joyn+"]),
        ("WOW", ["wow tv", "wow streaming"]),

        // Streaming & Medien
        ("Netflix", ["netflix"]),
        ("Spotify", ["spotify"]),
        ("YouTubePremium", ["youtube premium", "youtube music"]),
        ("AppleMusic", ["apple music"]),
        ("AppleTV", ["apple tv+", "apple tv plus"]),
        ("DisneyPlus", ["disney+", "disney plus"]),
        ("AmazonPrime", ["amazon prime", "prime video"]),
        ("Zattoo", ["zattoo"]),
        ("Crunchyroll", ["crunchyroll"]),
        ("Audible", ["audible"]),
        ("Kindle", ["kindle unlimited"]),
        ("AppleArcade", ["apple arcade"]),
        ("AppleNews", ["apple news+"]),
        ("AppleFitness", ["apple fitness+", "fitness+"]),

        // Cloud & Speicher
        ("iCloud", ["icloud", "icloud+"]),
        ("GoogleOne", ["google one"]),
        ("Dropbox", ["dropbox"]),
        ("OneDrive", ["onedrive", "microsoft onedrive"]),
        ("pCloud", ["pcloud"]),

        // Passwort & Sicherheit
        ("1Password", ["1password"]),
        ("Bitwarden", ["bitwarden"]),
        ("Dashlane", ["dashlane"]),
        ("NordVPN", ["nordvpn"]),
        ("ExpressVPN", ["expressvpn"]),
        ("Surfshark", ["surfshark"]),

        // Foto & Video
        ("Lightroom", ["lightroom"]),
        ("Darkroom", ["darkroom"]),
        ("VSCO", ["vsco"]),
        ("Halide", ["halide"]),
        ("ProCamera", ["procamera"]),
        ("LumaFusion", ["lumafusion"]),
        ("Procreate", ["procreate"]),
        ("Affinity", ["affinity photo", "affinity designer"]),
        ("Pixelmator", ["pixelmator"]),
        ("Canva", ["canva"]),

        // Entwicklung
        ("GitHub", ["github"]),
        ("GitLab", ["gitlab"]),
        ("Sourcetree", ["sourcetree"]),
        ("Tower", ["tower git"]),
        ("Kaleidoscope", ["kaleidoscope"]),
        ("Paw", ["paw api", "rapidapi"]),
        ("Proxyman", ["proxyman"]),
        ("TablePlus", ["tableplus"]),
        ("Sequel Pro", ["sequel pro"]),

        // Kommunikation
        ("Zoom", ["zoom"]),
        ("Slack", ["slack"]),
        ("Discord", ["discord"]),
        ("Telegram", ["telegram premium"]),
        ("WhatsApp", ["whatsapp"]),

        // Fitness & Gesundheit
        ("Strava", ["strava"]),
        ("Komoot", ["komoot"]),
        ("MyFitnessPal", ["myfitnesspal"]),
        ("Headspace", ["headspace"]),
        ("Calm", ["calm app", "calm -"]),

        // Finanzen
        ("YNAB", ["ynab", "you need a budget"]),
        ("MoneyMoney", ["moneymoney"]),
        ("Finanzguru", ["finanzguru"]),

        // Wetter
        ("Carrot", ["carrot weather"]),
        ("WeatherPro", ["weatherpro"]),

        // Nachrichten & Medien
        ("DiePresse", ["die presse"]),
        ("DerStandard", ["der standard"]),
        ("NYTimes", ["new york times", "nytimes"]),
        ("Guardian", ["the guardian"]),
        ("Medium", ["medium membership"]),
        ("Economist", ["the economist"]),
        ("Readwise", ["readwise"]),
        ("Pocket", ["pocket premium"]),
        ("Instapaper", ["instapaper"]),
        ("Feedly", ["feedly"]),
        ("Reeder", ["reeder"]),

        // Spiele
        ("Minecraft", ["minecraft"]),
        ("Monument Valley", ["monument valley"]),
        ("Alto", ["alto's adventure", "alto's odyssey"]),

        // Sonstiges
        ("Duolingo", ["duolingo"]),
        ("Babbel", ["babbel"]),
        ("Setapp", ["setapp"]),
        ("CleanMyMac", ["cleanmymac"]),
        ("BetterTouchTool", ["bettertouchtool"]),
        ("Alfred", ["alfred powerpack"]),
        ("Raycast", ["raycast"]),
        ("Bartender", ["bartender"]),
        ("iStatMenus", ["istat menus"]),
        ("LittleSnitch", ["little snitch"]),
        ("TextExpander", ["textexpander"]),
        ("Keyboard Maestro", ["keyboard maestro"]),
        ("Hazel", ["hazel"]),
        ("PopClip", ["popclip"]),
        ("Paste", ["paste app"]),
        ("Copied", ["copied"]),
    ]

    private init() {}

    func extractProduct(from text: String, company: String?, type: ReceiptType?) -> String? {
        let lowerText = text.lowercased()

        // Nur für bestimmte Firmen/Typen nach Produkten suchen
        let shouldExtractProduct = shouldSearchForProduct(company: company, type: type)
        guard shouldExtractProduct else { return nil }

        // 1. Zuerst bekannte Produkte prüfen
        for (name, keywords) in knownProducts {
            for keyword in keywords {
                if lowerText.contains(keyword) {
                    return name
                }
            }
        }

        // 2. Spezielle Muster für App Store Rechnungen
        if let appName = extractAppStoreProduct(from: text) {
            return appName
        }

        // 3. Spezielle Muster für Google Play Rechnungen
        if let appName = extractGooglePlayProduct(from: text) {
            return appName
        }

        // 4. Spezielle Muster für Amazon/Prime Video Rechnungen
        if let productName = extractAmazonProduct(from: text) {
            return productName
        }

        // 5. Spezielle Muster für Apple Abo-Bestätigungen (App-Name nach "App" Zeile)
        if let appName = extractAppleSubscriptionApp(from: text) {
            return appName
        }

        return nil
    }

    private func shouldSearchForProduct(company: String?, type: ReceiptType?) -> Bool {
        // Bei diesen Firmen/Typen nach spezifischen Produkten suchen
        let productCompanies = ["Apple", "Google", "Microsoft365", "Amazon", "AmazonPrime"]
        let productTypes: [ReceiptType] = [.appAbo, .abo]

        if let company = company, productCompanies.contains(company) {
            return true
        }

        if let type = type, productTypes.contains(type) {
            return true
        }

        return false
    }

    private func extractAppStoreProduct(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)

        // Apple Rechnungen haben oft das Format:
        // "App Name" oder "App Name (Familienfreigabe)"
        // nach "Artikel" oder "Item" Zeile

        var foundItemSection = false
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let lowerLine = trimmedLine.lowercased()

            // Suche nach Artikelbereich
            if lowerLine.contains("artikel") || lowerLine.contains("item") ||
               lowerLine.contains("beschreibung") || lowerLine.contains("description") {
                foundItemSection = true
                continue
            }

            // Nach dem Artikelbereich: Suche nach App-Namen
            if foundItemSection {
                // Ignoriere bestimmte Zeilen
                if lowerLine.isEmpty ||
                   lowerLine.contains("preis") ||
                   lowerLine.contains("price") ||
                   lowerLine.contains("eur") ||
                   lowerLine.contains("€") ||
                   lowerLine.contains("mwst") ||
                   lowerLine.contains("steuer") ||
                   lowerLine.hasPrefix("ab ") ||
                   trimmedLine.count < 3 {
                    continue
                }

                // Potentieller App-Name gefunden
                let cleanedName = cleanAppName(trimmedLine)
                if isValidAppName(cleanedName) {
                    return cleanedName
                }
            }
        }

        return nil
    }

    private func extractGooglePlayProduct(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)

        // Google Play Rechnungen haben oft:
        // "Bestellung:" oder "Order:" gefolgt vom App-Namen

        for (index, line) in lines.enumerated() {
            let lowerLine = line.lowercased()

            if lowerLine.contains("bestellung") || lowerLine.contains("order") {
                // Nächste nicht-leere Zeile könnte der App-Name sein
                if index + 1 < lines.count {
                    let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                    let cleanedName = cleanAppName(nextLine)
                    if isValidAppName(cleanedName) {
                        return cleanedName
                    }
                }
            }
        }

        return nil
    }

    // MARK: - Amazon Produkterkennung

    private func extractAmazonProduct(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)

        // Amazon Rechnungen haben das Format:
        // "Rechnungsdetails" Abschnitt
        // "Beschreibung" Spalte enthält den Produktnamen
        // z.B. "ARD Plus" oder "Zattoo PREMIUM Trial - 1 month"

        var inDetailsSection = false
        var foundDescriptionHeader = false

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let lowerLine = trimmedLine.lowercased()

            // Suche nach Rechnungsdetails Abschnitt
            if lowerLine.contains("rechnungsdetails") || lowerLine.contains("invoice details") {
                inDetailsSection = true
                continue
            }

            // Suche nach Beschreibung Header
            if inDetailsSection && (lowerLine.contains("beschreibung") || lowerLine.contains("description")) {
                foundDescriptionHeader = true
                continue
            }

            // Nach dem Beschreibung Header: Suche nach Produktnamen
            if foundDescriptionHeader {
                // Ignoriere bestimmte Zeilen
                if lowerLine.isEmpty ||
                   lowerLine.contains("menge") ||
                   lowerLine.contains("stückpreis") ||
                   lowerLine.contains("ust.") ||
                   lowerLine.contains("zwischen") ||
                   lowerLine.hasPrefix("eur") ||
                   lowerLine.hasPrefix("€") ||
                   lowerLine.contains("asin:") ||
                   trimmedLine.count < 3 {
                    // Aber ASIN enthält oft die Zeile davor den Produktnamen
                    if lowerLine.contains("asin:") {
                        continue
                    }
                    continue
                }

                // Potentieller Produktname gefunden
                // Entferne ASIN Teil wenn vorhanden
                var productName = trimmedLine
                if let asinRange = productName.range(of: "ASIN:", options: .caseInsensitive) {
                    productName = String(productName[..<asinRange.lowerBound])
                }

                let cleanedName = cleanAppName(productName)
                if isValidAppName(cleanedName) && cleanedName.count > 2 {
                    return cleanedName
                }
            }
        }

        return nil
    }

    // MARK: - Apple Abo-Bestätigung (App-Name nach "App" Zeile)

    private func extractAppleSubscriptionApp(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)

        // Apple Abo-Bestätigungen haben das Format:
        // "App  DirEqual" oder "App: DirEqual"
        // Oder nach einer Zeile nur mit "App" kommt der Name

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let lowerLine = trimmedLine.lowercased()

            // Muster 1: "App  Name" oder "App: Name" auf einer Zeile
            if lowerLine.hasPrefix("app ") || lowerLine.hasPrefix("app:") || lowerLine.hasPrefix("app\t") {
                let appPart = trimmedLine.dropFirst(3).trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ":"))
                    .trimmingCharacters(in: .whitespaces)
                if !appPart.isEmpty && isValidAppName(appPart) {
                    return cleanAppName(appPart)
                }
            }

            // Muster 2: Zeile ist nur "App", nächste Zeile ist der Name
            if trimmedLine.lowercased() == "app" && index + 1 < lines.count {
                let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                if !nextLine.isEmpty && isValidAppName(nextLine) {
                    return cleanAppName(nextLine)
                }
            }
        }

        return nil
    }

    private func cleanAppName(_ name: String) -> String {
        var cleaned = name

        // Entferne gängige Suffixe
        let suffixesToRemove = [
            "(Familienfreigabe)",
            "(Family Sharing)",
            "- Abo",
            "- Subscription",
            "Subscription",
            "Premium",
            "Pro",
            "Plus",
            "(In-App)",
        ]

        for suffix in suffixesToRemove {
            if cleaned.lowercased().hasSuffix(suffix.lowercased()) {
                cleaned = String(cleaned.dropLast(suffix.count))
            }
            cleaned = cleaned.replacingOccurrences(of: suffix, with: "", options: .caseInsensitive)
        }

        // Entferne Sonderzeichen am Anfang/Ende
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: ":-–—"))
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)

        // Entferne ungültige Zeichen für Dateinamen
        let invalidChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
        cleaned = cleaned.components(separatedBy: invalidChars).joined(separator: "")

        // Leerzeichen durch nichts ersetzen oder behalten? -> Ersetzen durch CamelCase
        let words = cleaned.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if words.count > 1 {
            cleaned = words.map { $0.capitalized }.joined()
        }

        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    private func isValidAppName(_ name: String) -> Bool {
        // Mindestens 2 Zeichen
        guard name.count >= 2 else { return false }

        // Nicht zu lang
        guard name.count <= 50 else { return false }

        // Nicht nur Zahlen
        let onlyDigits = name.allSatisfy { $0.isNumber }
        if onlyDigits { return false }

        // Keine typischen Nicht-App-Namen
        let invalidNames = [
            "total", "summe", "gesamt", "subtotal",
            "mwst", "vat", "tax", "steuer",
            "datum", "date", "invoice", "rechnung",
            "apple", "google", "microsoft"
        ]
        if invalidNames.contains(name.lowercased()) { return false }

        return true
    }
}
