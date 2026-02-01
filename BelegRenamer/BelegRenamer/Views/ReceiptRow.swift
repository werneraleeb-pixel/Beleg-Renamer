import SwiftUI

struct ReceiptRow: View {
    let receipt: Receipt

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Image(systemName: receipt.status.icon)
                .foregroundColor(receipt.status.color)
                .frame(width: 20)

            // File type icon
            Image(systemName: receipt.isPDF ? "doc.fill" : "photo.fill")
                .foregroundColor(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                // Original filename
                Text(receipt.originalFileName)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)

                // Suggested name (if processed)
                if !receipt.suggestedName.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                        Text(receipt.suggestedName + "." + receipt.fileExtension)
                            .font(.system(.caption, design: .monospaced))
                    }
                    .foregroundColor(.green)
                }

                // Status details
                statusDetails
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusDetails: some View {
        switch receipt.status {
        case .pending:
            Text("Ausstehend")
                .font(.caption2)
                .foregroundColor(.secondary)

        case .processing:
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Verarbeite...")
                    .font(.caption2)
            }
            .foregroundColor(.blue)

        case .completed:
            HStack(spacing: 8) {
                if let date = receipt.detectedDate {
                    Label(formatDate(date), systemImage: "calendar")
                }

                if let company = receipt.detectedCompany {
                    Label(company, systemImage: "building.2")
                }

                if let type = receipt.detectedType {
                    Label(type.displayName, systemImage: "tag")
                }

                if let product = receipt.detectedProduct {
                    Label(product, systemImage: "app.badge")
                        .foregroundColor(.blue)
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)

        case .error(let message):
            Text(message)
                .font(.caption2)
                .foregroundColor(.red)
                .lineLimit(2)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack {
        ReceiptRow(receipt: Receipt(
            originalURL: URL(fileURLWithPath: "/test/invoice.pdf")
        ))

        ReceiptRow(receipt: {
            var r = Receipt(originalURL: URL(fileURLWithPath: "/test/receipt.jpg"))
            r.status = .processing
            return r
        }())

        ReceiptRow(receipt: {
            var r = Receipt(originalURL: URL(fileURLWithPath: "/test/bill.pdf"))
            r.status = .completed
            r.detectedDate = Date()
            r.detectedCompany = "Apple"
            r.detectedType = .appAbo
            r.suggestedName = "15.01.2025-Apple-app-abo"
            return r
        }())

        ReceiptRow(receipt: {
            var r = Receipt(originalURL: URL(fileURLWithPath: "/test/error.pdf"))
            r.status = .error("OCR fehlgeschlagen")
            return r
        }())
    }
    .padding()
    .frame(width: 400)
}
