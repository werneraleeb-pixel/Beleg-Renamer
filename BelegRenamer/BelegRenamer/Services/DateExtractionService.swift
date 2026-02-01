import Foundation

struct DateExtractionService {
    static let shared = DateExtractionService()

    private let germanMonths: [String: Int] = [
        // Januar / January
        "januar": 1, "jänner": 1, "jan": 1, "jan.": 1, "january": 1,
        // Februar / February
        "februar": 2, "feb": 2, "feb.": 2, "feber": 2, "february": 2,
        // März / March
        "märz": 3, "mär": 3, "mrz": 3, "mrz.": 3, "march": 3, "mar": 3, "mar.": 3,
        // April
        "april": 4, "apr": 4, "apr.": 4,
        // Mai / May
        "mai": 5, "may": 5,
        // Juni / June
        "juni": 6, "jun": 6, "jun.": 6, "june": 6,
        // Juli / July
        "juli": 7, "jul": 7, "jul.": 7, "july": 7,
        // August
        "august": 8, "aug": 8, "aug.": 8,
        // September
        "september": 9, "sep": 9, "sep.": 9, "sept": 9, "sept.": 9,
        // Oktober / October
        "oktober": 10, "okt": 10, "okt.": 10, "october": 10, "oct": 10,
        // November
        "november": 11, "nov": 11, "nov.": 11,
        // Dezember / December
        "dezember": 12, "dez": 12, "dez.": 12, "december": 12, "dec": 12
    ]

    // Date-related keywords for priority detection (invoice/receipt date - highest priority)
    private let invoiceDateKeywords = [
        "rechnungsdatum", "invoice date", "belegdatum", "ausstellungsdatum",
        "zahlungsdatum", "payment date", "buchungsdatum", "transaktionsdatum",
        "bestelldatum", "order date", "kaufdatum", "purchase date"
    ]

    // Secondary date keywords (lower priority)
    private let secondaryDateKeywords = [
        "datum:", "date:", "dated:", "erstellt am", "created on", "issued on",
        "gültig ab", "valid from", "vom", "am", "den"
    ]

    // Email header keywords (lowest priority - should not override invoice dates)
    private let emailDateKeywords = [
        "gesendet:", "sent:", "date:"  // Only when at start of line in email context
    ]

    private init() {}

    func extractDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: .newlines)

        // Priority 1: Look for invoice/receipt date keywords (HIGHEST PRIORITY)
        // These are the actual document dates, not email transmission dates
        for line in lines {
            let lowerLine = line.lowercased()
            for keyword in invoiceDateKeywords {
                if lowerLine.contains(keyword) {
                    if let date = findDateInLine(line) {
                        if isReasonableDate(date) {
                            return date
                        }
                    }
                }
            }
        }

        // Priority 2: Look for date immediately after "Rechnung" header
        // This handles Apple invoices where date is on line after "Rechnung"
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces).lowercased()
            if trimmedLine == "rechnung" || trimmedLine == "invoice" {
                // Check next 3 lines for a date
                for nextIndex in (index + 1)..<min(index + 4, lines.count) {
                    if let date = findDateInLine(lines[nextIndex]) {
                        if isReasonableDate(date) {
                            return date
                        }
                    }
                }
            }
        }

        // Priority 3: Secondary date keywords
        for line in lines {
            let lowerLine = line.lowercased()
            for keyword in secondaryDateKeywords {
                if lowerLine.contains(keyword) {
                    // Skip if this looks like an email header (Von:/From:/Datum: at start)
                    if isEmailHeaderLine(lowerLine) {
                        continue
                    }
                    if let date = findDateInLine(line) {
                        if isReasonableDate(date) {
                            return date
                        }
                    }
                }
            }
        }

        // Priority 4: Check first 15 lines (header area) - but skip email headers
        for line in lines.prefix(15) {
            let lowerLine = line.lowercased()
            // Skip email header lines
            if isEmailHeaderLine(lowerLine) {
                continue
            }
            if let date = findDateInLine(line) {
                if isReasonableDate(date) {
                    return date
                }
            }
        }

        // Priority 5: Full text search with all patterns
        if let date = findBestDateInText(text) {
            return date
        }

        // Priority 6: Email headers (LOWEST PRIORITY - only if nothing else found)
        for line in lines {
            let lowerLine = line.lowercased()
            if isEmailHeaderLine(lowerLine) {
                if let date = findDateInLine(line) {
                    if isReasonableDate(date) {
                        return date
                    }
                }
            }
        }

        // Priority 7: Check remaining lines
        for line in lines.dropFirst(15) {
            if let date = findDateInLine(line) {
                if isReasonableDate(date) {
                    return date
                }
            }
        }

        return nil
    }

    private func isEmailHeaderLine(_ lowerLine: String) -> Bool {
        return lowerLine.hasPrefix("von:") ||
               lowerLine.hasPrefix("from:") ||
               lowerLine.hasPrefix("datum:") && lowerLine.contains("@") ||
               lowerLine.hasPrefix("date:") && lowerLine.contains("@") ||
               lowerLine.hasPrefix("an:") ||
               lowerLine.hasPrefix("to:") ||
               lowerLine.hasPrefix("betreff:") ||
               lowerLine.hasPrefix("subject:") ||
               lowerLine.contains("gesendet:") ||
               lowerLine.contains("sent:")
    }

    private func findBestDateInText(_ text: String) -> Date? {
        var foundDates: [(date: Date, position: Int)] = []

        // Find all dates with their positions
        let patterns: [(String, (String) -> Date?)] = [
            (#"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})"#, extractNumericDateYYYY),
            (#"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{2})"#, extractNumericDateYY),
            (#"(\d{4})-(\d{2})-(\d{2})"#, extractISODate),
            (#"(\d{4})\.(\d{2})\.(\d{2})"#, extractYYYYMMDDDotDate),  // Format: 2025.12.17
            (#"(\d{1,2})\.?\s*([A-Za-zäöüÄÖÜ]+)\.?\s*(\d{4})"#, extractWrittenDateDMY),
            (#"([A-Za-zäöüÄÖÜ]+)\.?\s*(\d{1,2}),?\s*(\d{4})"#, extractWrittenDateMDY),
        ]

        for (pattern, extractor) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let matchString = String(text[range])
                        if let date = extractor(matchString), isReasonableDate(date) {
                            foundDates.append((date, match.range.location))
                        }
                    }
                }
            }
        }

        // Return the date that appears earliest and is most recent
        // (prefer dates near the beginning of the document)
        let sortedDates = foundDates.sorted { a, b in
            // Prioritize dates in the first 500 characters
            let aEarly = a.position < 500
            let bEarly = b.position < 500
            if aEarly != bEarly {
                return aEarly
            }
            // Then prefer more recent dates
            return a.date > b.date
        }

        return sortedDates.first?.date
    }

    private func isReasonableDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let yearAgo = calendar.date(byAdding: .year, value: -2, to: now)!
        let yearAhead = calendar.date(byAdding: .year, value: 1, to: now)!

        return date >= yearAgo && date <= yearAhead
    }

    private func findDateInLine(_ line: String) -> Date? {
        // Try all patterns
        if let date = extractNumericDateYYYY(from: line) { return date }
        if let date = extractNumericDateYY(from: line) { return date }
        if let date = extractISODate(from: line) { return date }
        if let date = extractYYYYMMDDDotDate(from: line) { return date }  // Format: 2025.12.17
        if let date = extractWrittenDate(from: line) { return date }
        if let date = extractCompactDate(from: line) { return date }

        return nil
    }

    // MARK: - Numeric Date (DD.MM.YYYY)

    private func extractNumericDateYYYY(from text: String) -> Date? {
        let pattern = #"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})"#
        return matchNumericDate(text: text, pattern: pattern)
    }

    private func extractNumericDateYY(from text: String) -> Date? {
        let pattern = #"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{2})(?!\d)"#
        return matchNumericDate(text: text, pattern: pattern)
    }

    private func matchNumericDate(text: String, pattern: String) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        guard let range1 = Range(match.range(at: 1), in: text),
              let range2 = Range(match.range(at: 2), in: text),
              let range3 = Range(match.range(at: 3), in: text) else {
            return nil
        }

        guard let num1 = Int(text[range1]),
              let num2 = Int(text[range2]),
              var year = Int(text[range3]) else {
            return nil
        }

        // Handle 2-digit years
        if year < 100 {
            year += year < 50 ? 2000 : 1900
        }

        // Determine day and month (DD.MM vs MM.DD)
        var day: Int
        var month: Int

        if num1 > 12 {
            // First number > 12, must be day
            day = num1
            month = num2
        } else if num2 > 12 {
            // Second number > 12, must be day (US format)
            day = num2
            month = num1
        } else {
            // Ambiguous - assume European format (DD.MM)
            day = num1
            month = num2
        }

        guard day >= 1 && day <= 31,
              month >= 1 && month <= 12,
              year >= 1990 && year <= 2100 else {
            return nil
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components)
    }

    // MARK: - ISO Date (YYYY-MM-DD)

    private func extractISODate(from text: String) -> Date? {
        let pattern = #"(\d{4})-(\d{2})-(\d{2})"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        guard let yearRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 2), in: text),
              let dayRange = Range(match.range(at: 3), in: text) else {
            return nil
        }

        guard let year = Int(text[yearRange]),
              let month = Int(text[monthRange]),
              let day = Int(text[dayRange]) else {
            return nil
        }

        guard day >= 1 && day <= 31,
              month >= 1 && month <= 12,
              year >= 1990 && year <= 2100 else {
            return nil
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components)
    }

    // MARK: - Dot-separated Date (YYYY.MM.DD) - used by some terminals like Avanti

    private func extractYYYYMMDDDotDate(from text: String) -> Date? {
        // Pattern: 2025.12.17 (often followed by time like 13:06)
        let pattern = #"(\d{4})\.(\d{2})\.(\d{2})"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        guard let yearRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 2), in: text),
              let dayRange = Range(match.range(at: 3), in: text) else {
            return nil
        }

        guard let year = Int(text[yearRange]),
              let month = Int(text[monthRange]),
              let day = Int(text[dayRange]) else {
            return nil
        }

        guard day >= 1 && day <= 31,
              month >= 1 && month <= 12,
              year >= 1990 && year <= 2100 else {
            return nil
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components)
    }

    // MARK: - Written Date

    private func extractWrittenDate(from text: String) -> Date? {
        let lowerText = text.lowercased()

        // Pattern: "12. September 2024" or "12 September 2024" or "12.Sep.2024"
        if let date = extractWrittenDateDMY(from: lowerText) {
            return date
        }

        // Pattern: "September 12, 2024" or "Sep 12, 2024"
        if let date = extractWrittenDateMDY(from: lowerText) {
            return date
        }

        return nil
    }

    private func extractWrittenDateDMY(from text: String) -> Date? {
        // Matches: "12. September 2024", "12 Sep 2024", "12.Sep.2024"
        let pattern = #"(\d{1,2})[\.\s]+([a-zäöü]+)[\.\s,]+(\d{4})"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        return extractDateFromWrittenMatch(text: text, match: match, dayGroup: 1, monthGroup: 2, yearGroup: 3)
    }

    private func extractWrittenDateMDY(from text: String) -> Date? {
        // Matches: "September 12, 2024", "Sep 12 2024"
        let pattern = #"([a-zäöü]+)[\.\s]+(\d{1,2})[,\.\s]+(\d{4})"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        return extractDateFromWrittenMatch(text: text, match: match, dayGroup: 2, monthGroup: 1, yearGroup: 3)
    }

    private func extractDateFromWrittenMatch(text: String, match: NSTextCheckingResult, dayGroup: Int, monthGroup: Int, yearGroup: Int) -> Date? {
        guard let dayRange = Range(match.range(at: dayGroup), in: text),
              let monthRange = Range(match.range(at: monthGroup), in: text),
              let yearRange = Range(match.range(at: yearGroup), in: text) else {
            return nil
        }

        guard let day = Int(text[dayRange]),
              let year = Int(text[yearRange]) else {
            return nil
        }

        let monthString = String(text[monthRange]).lowercased().trimmingCharacters(in: .whitespaces)
        guard let month = germanMonths[monthString] else {
            return nil
        }

        guard day >= 1 && day <= 31,
              year >= 1990 && year <= 2100 else {
            return nil
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components)
    }

    // MARK: - Compact Date (YYYYMMDD or DDMMYYYY)

    private func extractCompactDate(from text: String) -> Date? {
        // Pattern for 8-digit dates like 20241215 or 15122024
        let pattern = #"\b(\d{8})\b"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let digits = String(text[range])

        // Try YYYYMMDD first
        if let date = parseCompactDate(digits, format: .yearFirst) {
            return date
        }

        // Try DDMMYYYY
        if let date = parseCompactDate(digits, format: .dayFirst) {
            return date
        }

        return nil
    }

    private enum CompactDateFormat {
        case yearFirst  // YYYYMMDD
        case dayFirst   // DDMMYYYY
    }

    private func parseCompactDate(_ digits: String, format: CompactDateFormat) -> Date? {
        guard digits.count == 8 else { return nil }

        let year: Int
        let month: Int
        let day: Int

        switch format {
        case .yearFirst:
            year = Int(digits.prefix(4)) ?? 0
            month = Int(digits.dropFirst(4).prefix(2)) ?? 0
            day = Int(digits.suffix(2)) ?? 0
        case .dayFirst:
            day = Int(digits.prefix(2)) ?? 0
            month = Int(digits.dropFirst(2).prefix(2)) ?? 0
            year = Int(digits.suffix(4)) ?? 0
        }

        guard day >= 1 && day <= 31,
              month >= 1 && month <= 12,
              year >= 2000 && year <= 2100 else {
            return nil
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components)
    }
}
