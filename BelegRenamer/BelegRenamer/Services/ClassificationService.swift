import Foundation

struct ClassificationService {
    static let shared = ClassificationService()

    private init() {}

    func classifyReceipt(text: String, learnedCompanies: [Company]) -> (company: String?, type: ReceiptType?) {
        let lowerText = text.lowercased()
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Try multiple detection methods and combine results
        var detectedCompany: String?
        var detectedType: ReceiptType?

        // Method 1: Check learned companies first (highest priority)
        for company in learnedCompanies {
            for keyword in company.keywords {
                if lowerText.contains(keyword) {
                    return (company.name, company.defaultType ?? detectType(from: lowerText))
                }
            }
        }

        // Method 2: Check FIRST FEW LINES for company names from database
        // This catches cases like "Avanti" appearing at the top of the receipt
        // but "OMV Downstream GmbH" appearing later in the footer
        let headerLines = lines.prefix(5).joined(separator: " ").lowercased()
        for company in CompanyDatabase.standardCompanies {
            for keyword in company.keywords {
                if headerLines.contains(keyword) {
                    detectedCompany = company.name
                    detectedType = company.defaultType
                    break
                }
            }
            if detectedCompany != nil { break }
        }

        // Method 3: Check standard company database (full text) - only if header didn't find anything
        if detectedCompany == nil {
            for company in CompanyDatabase.standardCompanies {
                for keyword in company.keywords {
                    if lowerText.contains(keyword) {
                        detectedCompany = company.name
                        detectedType = company.defaultType
                        break
                    }
                }
                if detectedCompany != nil { break }
            }
        }

        // Method 4: Email sender detection (very reliable for email receipts)
        if detectedCompany == nil {
            detectedCompany = extractEmailSender(from: text)
        }

        // Method 5: Frequency analysis - find most mentioned company-like words
        if detectedCompany == nil {
            detectedCompany = findMostFrequentCompanyName(in: text)
        }

        // Method 6: Header/Footer analysis
        if detectedCompany == nil {
            detectedCompany = extractFromHeaderFooter(from: text)
        }

        // Method 7: Domain extraction from URLs/emails
        if detectedCompany == nil {
            detectedCompany = extractCompanyFromDomains(from: text)
        }

        // Method 8: Generic patterns as fallback
        if detectedCompany == nil {
            detectedCompany = detectGenericCompany(from: lowerText)
        }

        // Detect type if not already set
        if detectedType == nil {
            detectedType = detectType(from: lowerText)
        }

        // WICHTIG: Nachträgliche Typ-Korrektur für spezielle Fälle
        // APCOA kann sowohl Parkbelege als auch E-Lade-Belege sein
        if detectedCompany == "APCOA" {
            if isChargingReceipt(lowerText) {
                detectedType = .eTankbeleg
            }
        }

        // PayLife: Unterscheide VISA von Mastercard
        if detectedCompany == "PayLife" {
            if lowerText.contains("visa") {
                detectedCompany = "PayLife-VISA"
            } else if lowerText.contains("mastercard") {
                detectedCompany = "PayLife-Mastercard"
            }
        }

        return (detectedCompany, detectedType)
    }

    // MARK: - Spezielle Erkennung für E-Lade-Belege (vs Parkbelege)
    private func isChargingReceipt(_ text: String) -> Bool {
        // Keywords die auf E-Laden hindeuten
        let chargingKeywords = [
            "kwh", "ladepreis", "ladevorgang", "verbrauchte energie",
            "charging", "ladepunkt", "ladestation", "elektro",
            "strom", "energy", "kilowatt"
        ]

        for keyword in chargingKeywords {
            if text.contains(keyword) {
                return true
            }
        }
        return false
    }

    // MARK: - Email Sender Detection

    private func extractEmailSender(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)

        // Patterns for email headers
        let senderPatterns = [
            #"[Vv]on:\s*(.+?)(?:\s*<|$)"#,           // Von: Name <email>
            #"[Ff]rom:\s*(.+?)(?:\s*<|$)"#,          // From: Name <email>
            #"[Aa]bsender:\s*(.+?)(?:\s*<|$)"#,      // Absender: Name
            #"[Ss]ender:\s*(.+?)(?:\s*<|$)"#,        // Sender: Name
        ]

        for line in lines {
            for pattern in senderPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let range = Range(match.range(at: 1), in: line) {
                    let sender = String(line[range]).trimmingCharacters(in: .whitespaces)
                    if let cleanedName = cleanCompanyName(sender) {
                        return cleanedName
                    }
                }
            }
        }

        // Also check for "noreply@company.com" style addresses
        let emailPattern = #"[\w.-]+@([\w-]+)\.([\w.-]+)"#
        if let regex = try? NSRegularExpression(pattern: emailPattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let domainRange = Range(match.range(at: 1), in: text) {
                    let domain = String(text[domainRange])
                    // Skip generic email providers
                    let genericDomains = ["gmail", "yahoo", "hotmail", "outlook", "icloud", "mail", "email"]
                    if !genericDomains.contains(domain.lowercased()) {
                        return domain.capitalized
                    }
                }
            }
        }

        return nil
    }

    // MARK: - Frequency Analysis

    private func findMostFrequentCompanyName(in text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        var wordFrequency: [String: Int] = [:]

        // Words to ignore
        let stopWords = Set([
            "der", "die", "das", "und", "oder", "für", "von", "mit", "auf", "aus", "bei", "nach",
            "the", "and", "for", "from", "with", "your", "you", "our", "this", "that", "are", "was",
            "rechnung", "invoice", "beleg", "receipt", "datum", "date", "betrag", "amount", "total",
            "summe", "netto", "brutto", "mwst", "ust", "tax", "eur", "euro", "usd", "preis", "price",
            "zahlung", "payment", "konto", "account", "kunde", "customer", "nummer", "number",
            "januar", "februar", "märz", "april", "mai", "juni", "juli", "august", "september",
            "oktober", "november", "dezember", "january", "february", "march", "april", "may",
            "june", "july", "august", "september", "october", "november", "december",
            "gmbh", "ag", "inc", "ltd", "llc", "corp", "limited", "company", "kg", "ohg"
        ])

        for line in lines {
            let words = line.components(separatedBy: .whitespaces)
                .map { $0.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) }
                .filter { $0.count >= 3 && $0.count <= 25 }

            for word in words {
                let lowerWord = word.lowercased()
                if !stopWords.contains(lowerWord) && word.first?.isUppercase == true {
                    wordFrequency[word, default: 0] += 1
                }
            }
        }

        // Find word that appears multiple times (at least 2)
        let candidates = wordFrequency
            .filter { $0.value >= 2 }
            .sorted { $0.value > $1.value }

        // Return the most frequent capitalized word that looks like a company name
        for (word, _) in candidates.prefix(5) {
            if isLikelyCompanyName(word) {
                return word
            }
        }

        return nil
    }

    private func isLikelyCompanyName(_ word: String) -> Bool {
        // Check if it looks like a company name
        guard word.count >= 3 else { return false }
        guard word.first?.isUppercase == true else { return false }

        // Not just numbers
        if word.allSatisfy({ $0.isNumber }) { return false }

        // Not a common word
        let commonWords = ["Sie", "Ihr", "Ihre", "Der", "Die", "Das", "Ein", "Eine", "Bei", "Nach"]
        if commonWords.contains(word) { return false }

        return true
    }

    // MARK: - Header/Footer Analysis

    private func extractFromHeaderFooter(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Check first 5 lines (header area)
        for line in lines.prefix(5) {
            if let company = extractCompanyFromLine(line) {
                return company
            }
        }

        // Check last 10 lines (footer area often has company info)
        for line in lines.suffix(10) {
            if let company = extractCompanyFromLine(line) {
                return company
            }
        }

        return nil
    }

    private func extractCompanyFromLine(_ line: String) -> String? {
        let lowerLine = line.lowercased()

        // Skip lines that are definitely not company names
        if lowerLine.contains("rechnung") && lowerLine.contains("nr") { return nil }
        if lowerLine.contains("datum") { return nil }
        if lowerLine.contains("seite") || lowerLine.contains("page") { return nil }
        if lowerLine.hasPrefix("tel") || lowerLine.hasPrefix("fax") { return nil }
        if lowerLine.contains("@") && !lowerLine.contains("von:") { return nil }

        // Look for company suffixes
        let companySuffixes = ["gmbh", "ag", "inc", "ltd", "llc", "corp", "limited", "kg", "ohg", "e.u.", "ug"]
        for suffix in companySuffixes {
            if lowerLine.contains(suffix) {
                // Extract the company name before the suffix
                if let range = lowerLine.range(of: suffix) {
                    let beforeSuffix = String(line[..<range.lowerBound])
                    if let cleaned = cleanCompanyName(beforeSuffix) {
                        return cleaned
                    }
                }
            }
        }

        // Check if line looks like a standalone company name (short, capitalized)
        let words = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if words.count >= 1 && words.count <= 4 {
            let firstWord = words[0]
            if firstWord.first?.isUppercase == true && firstWord.count >= 3 {
                if let cleaned = cleanCompanyName(line) {
                    return cleaned
                }
            }
        }

        return nil
    }

    // MARK: - Domain Extraction

    private func extractCompanyFromDomains(from text: String) -> String? {
        // Look for website URLs
        let urlPattern = #"(?:www\.|https?://)([\w-]+)\."#
        if let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            var domainCounts: [String: Int] = [:]

            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let domain = String(text[range]).lowercased()
                    // Skip generic domains
                    let genericDomains = ["www", "http", "https", "mail", "email", "support", "help", "info"]
                    if !genericDomains.contains(domain) && domain.count >= 3 {
                        domainCounts[domain, default: 0] += 1
                    }
                }
            }

            // Return most frequent domain
            if let topDomain = domainCounts.max(by: { $0.value < $1.value })?.key {
                return topDomain.capitalized
            }
        }

        return nil
    }

    // MARK: - Helper Methods

    private func cleanCompanyName(_ name: String) -> String? {
        var cleaned = name
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".,;:-–—|/\\\"'<>()[]{}"))
            .trimmingCharacters(in: .whitespaces)

        // Remove common suffixes for cleaner name
        let suffixesToRemove = [" GmbH", " AG", " Inc.", " Inc", " Ltd.", " Ltd", " LLC", " Corp.", " Corp", " Limited", " KG", " OHG", " e.U.", " UG"]
        for suffix in suffixesToRemove {
            if cleaned.lowercased().hasSuffix(suffix.lowercased()) {
                cleaned = String(cleaned.dropLast(suffix.count))
            }
        }

        cleaned = cleaned.trimmingCharacters(in: .whitespaces)

        // Validate
        guard cleaned.count >= 2 && cleaned.count <= 50 else { return nil }
        guard cleaned.first?.isLetter == true else { return nil }

        // Remove any remaining special characters but keep spaces and umlauts
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " äöüÄÖÜß-"))
        cleaned = cleaned.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()

        // Convert multiple spaces to single space
        while cleaned.contains("  ") {
            cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        }

        cleaned = cleaned.trimmingCharacters(in: .whitespaces)

        guard !cleaned.isEmpty else { return nil }

        // CamelCase for multi-word names
        let words = cleaned.components(separatedBy: " ")
        if words.count > 1 {
            return words.map { $0.capitalized }.joined()
        }

        return cleaned
    }

    // MARK: - Type Detection

    private func detectType(from text: String) -> ReceiptType? {
        var bestMatch: (type: ReceiptType, score: Int)?

        for type in ReceiptType.allCases {
            var score = 0
            for keyword in type.keywords {
                if text.contains(keyword) {
                    score += 1
                }
            }

            if score > 0 {
                if bestMatch == nil || score > bestMatch!.score {
                    bestMatch = (type, score)
                }
            }
        }

        return bestMatch?.type
    }

    // MARK: - Generic Company Detection

    private func detectGenericCompany(from text: String) -> String? {
        let genericPatterns: [(pattern: String, name: String)] = [
            ("hotel", "Hotel"),
            ("restaurant", "Restaurant"),
            ("tankstelle", "Tankstelle"),
            ("apotheke", "Apotheke"),
            ("supermarkt", "Supermarkt"),
            ("bäckerei", "Bäckerei"),
            ("café", "Cafe"),
            ("pizzeria", "Pizzeria"),
            ("metzgerei", "Metzgerei"),
            ("drogerie", "Drogerie"),
            ("buchhandlung", "Buchhandlung"),
            ("optiker", "Optiker"),
            ("friseur", "Friseur"),
            ("werkstatt", "Werkstatt"),
            ("arzt", "Arzt"),
            ("zahnarzt", "Zahnarzt"),
            ("parkhaus", "Parkhaus"),
            ("garage", "Garage"),
            ("kfz", "KFZ"),
        ]

        for (pattern, name) in genericPatterns {
            if text.contains(pattern) {
                return name
            }
        }

        return nil
    }

    func detectCompanyName(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        for line in lines.prefix(5) {
            if line.count < 3 || line.count > 50 { continue }
            if line.lowercased().contains("rechnung") { continue }
            if line.lowercased().contains("datum") { continue }
            if line.first?.isNumber == true { continue }

            let words = line.components(separatedBy: .whitespaces)
            if words.count <= 4 && words.first?.first?.isUppercase == true {
                if let cleaned = cleanCompanyName(line) {
                    return cleaned
                }
            }
        }

        return nil
    }
}
