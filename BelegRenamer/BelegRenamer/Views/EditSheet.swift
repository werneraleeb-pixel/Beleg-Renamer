import SwiftUI

struct EditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let receipt: Receipt
    let onSave: (Receipt) -> Void

    @State private var selectedDate: Date
    @State private var companyName: String
    @State private var selectedType: ReceiptType
    @State private var productName: String
    @State private var customName: String

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    init(receipt: Receipt, onSave: @escaping (Receipt) -> Void) {
        self.receipt = receipt
        self.onSave = onSave
        _selectedDate = State(initialValue: receipt.detectedDate ?? Date())
        _companyName = State(initialValue: receipt.detectedCompany ?? "")
        _selectedType = State(initialValue: receipt.detectedType ?? .rechnung)
        _productName = State(initialValue: receipt.detectedProduct ?? "")
        _customName = State(initialValue: receipt.suggestedName)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Beleg bearbeiten")
                    .font(.headline)
                Spacer()
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Form
            Form {
                Section("Original") {
                    LabeledContent("Dateiname") {
                        Text(receipt.originalFileName)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                Section("Erkannte Werte") {
                    DatePicker("Datum", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.field)

                    TextField("Firmenname", text: $companyName)

                    Picker("Belegart", selection: $selectedType) {
                        ForEach(ReceiptType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    TextField("Produkt/App (optional)", text: $productName)

                    Text("z.B. Perplexity, Netflix, iCloud - für genauere Unterscheidung")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Vorschau") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generierter Name:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(generatedName + "." + receipt.fileExtension)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(4)
                    }
                }

                Section("Oder manueller Name") {
                    TextField("Benutzerdefinierter Name", text: $customName)
                        .font(.system(.body, design: .monospaced))

                    Text("Leer lassen für automatischen Namen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                Button("Zurücksetzen") {
                    selectedDate = receipt.detectedDate ?? Date()
                    companyName = receipt.detectedCompany ?? ""
                    selectedType = receipt.detectedType ?? .rechnung
                    productName = receipt.detectedProduct ?? ""
                    customName = ""
                }

                Spacer()

                Button("Speichern") {
                    saveChanges()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 500, height: 500)
    }

    private var generatedName: String {
        let dateString = dateFormatter.string(from: selectedDate)
        let company = companyName.isEmpty ? "Unbekannt" : companyName
        let baseName = "\(dateString)-\(company)-\(selectedType.rawValue)"

        if !productName.isEmpty {
            return "\(baseName)-\(productName)"
        }
        return baseName
    }

    private func saveChanges() {
        var updatedReceipt = receipt
        updatedReceipt.detectedDate = selectedDate
        updatedReceipt.detectedCompany = companyName.isEmpty ? nil : companyName
        updatedReceipt.detectedType = selectedType
        updatedReceipt.detectedProduct = productName.isEmpty ? nil : productName

        if customName.isEmpty {
            updatedReceipt.suggestedName = generatedName
        } else {
            updatedReceipt.suggestedName = customName
        }

        onSave(updatedReceipt)
        dismiss()
    }
}

#Preview {
    EditSheet(receipt: {
        var r = Receipt(originalURL: URL(fileURLWithPath: "/test/invoice.pdf"))
        r.detectedDate = Date()
        r.detectedCompany = "Apple"
        r.detectedType = .appAbo
        r.suggestedName = "15.01.2025-Apple-app-abo"
        return r
    }()) { _ in }
}
