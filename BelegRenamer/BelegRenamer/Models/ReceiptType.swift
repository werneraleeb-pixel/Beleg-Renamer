import Foundation

enum ReceiptType: String, CaseIterable, Identifiable, Codable {
    case rechnung = "rechnung"
    case parkbeleg = "parkbeleg"
    case tankbeleg = "tankbeleg"
    case eTankbeleg = "e-tankbeleg"
    case hotelbeleg = "hotelbeleg"
    case bewirtungsbeleg = "bewirtungsbeleg"
    case abo = "abo"
    case appAbo = "app-abo"
    case kassenbon = "kassenbon"
    case kreditkartenabrechnung = "kk-abrechnung"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rechnung: return "Rechnung"
        case .parkbeleg: return "Parkbeleg"
        case .tankbeleg: return "Tankbeleg"
        case .eTankbeleg: return "E-Tankbeleg"
        case .hotelbeleg: return "Hotelbeleg"
        case .bewirtungsbeleg: return "Bewirtungsbeleg"
        case .abo: return "Abo"
        case .appAbo: return "App-Abo"
        case .kassenbon: return "Kassenbon"
        case .kreditkartenabrechnung: return "Kreditkartenabrechnung"
        }
    }

    var keywords: [String] {
        switch self {
        case .rechnung:
            return ["rechnung", "invoice", "faktura", "rechnungsnummer", "rechnungsdatum"]
        case .parkbeleg:
            return ["parkschein", "parkhaus", "parkgebühr", "parking", "parkticket", "kurzparken", "dauerparkausweis"]
        case .tankbeleg:
            return ["tankstelle", "benzin", "diesel", "super", "kraftstoff", "liter", "treibstoff", "tankquittung"]
        case .eTankbeleg:
            return ["ladestation", "ladepunkt", "kwh", "elektro", "charging", "ladevorgang", "e-mobility", "elektrotankstelle"]
        case .hotelbeleg:
            return ["hotel", "übernachtung", "zimmer", "accommodation", "nächte", "check-in", "check-out", "room"]
        case .bewirtungsbeleg:
            return ["restaurant", "bewirtung", "speisen", "getränke", "gasthaus", "gastronomie", "trinkgeld", "tip"]
        case .abo:
            return ["abonnement", "subscription", "monatlich", "monthly", "jahresabo", "mitgliedschaft", "membership"]
        case .appAbo:
            return ["app store", "google play", "in-app", "apple.com/bill", "digital content", "itunes"]
        case .kassenbon:
            return ["kassenbon", "kassabon", "quittung", "bon", "kasse", "bar bezahlt", "summe", "gesamt"]
        case .kreditkartenabrechnung:
            return ["kreditkartenabrechnung", "monatsabrechnung", "card statement", "kontoauszug", "ihre abrechnung", "kreditkarten-abrechnung", "credit card statement"]
        }
    }
}
