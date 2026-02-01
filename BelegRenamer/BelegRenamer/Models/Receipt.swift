import Foundation
import SwiftUI

enum ProcessingStatus: Equatable {
    case pending
    case processing
    case completed
    case error(String)

    var color: Color {
        switch self {
        case .pending: return .gray
        case .processing: return .blue
        case .completed: return .green
        case .error: return .red
        }
    }

    var icon: String {
        switch self {
        case .pending: return "circle"
        case .processing: return "arrow.trianglehead.2.clockwise"
        case .completed: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }
}

struct Receipt: Identifiable, Equatable {
    let id = UUID()
    let originalURL: URL
    var extractedText: String = ""
    var detectedDate: Date?
    var detectedCompany: String?
    var detectedType: ReceiptType?
    var detectedProduct: String?  // Spezifisches Produkt/App (z.B. "Perplexity" bei Apple-app-abo)
    var suggestedName: String = ""
    var status: ProcessingStatus = .pending

    var originalFileName: String {
        originalURL.lastPathComponent
    }

    var fileExtension: String {
        originalURL.pathExtension.lowercased()
    }

    var isImage: Bool {
        ["jpg", "jpeg", "png", "heic", "heif", "tiff", "tif"].contains(fileExtension)
    }

    var isPDF: Bool {
        fileExtension == "pdf"
    }

    static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        lhs.id == rhs.id
    }

    func generateFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        let dateString = detectedDate.map { dateFormatter.string(from: $0) } ?? "00.00.0000"
        let company = detectedCompany ?? "Unbekannt"
        let type = detectedType?.rawValue ?? "beleg"

        // Produkt/App-Name anhängen wenn vorhanden
        if let product = detectedProduct, !product.isEmpty {
            return "\(dateString)-\(company)-\(type)-\(product)"
        }

        return "\(dateString)-\(company)-\(type)"
    }
}
