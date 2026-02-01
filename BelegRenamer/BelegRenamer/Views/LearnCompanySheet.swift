import SwiftUI

struct LearnCompanySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var learningService = LearningService.shared

    let extractedText: String

    @State private var companyName: String = ""
    @State private var keywords: String = ""
    @State private var selectedType: ReceiptType = .rechnung
    @State private var showSuccessAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Neue Firma lernen")
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
                Section("Firmendetails") {
                    TextField("Firmenname", text: $companyName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Schlüsselwörter (kommagetrennt)", text: $keywords)
                        .textFieldStyle(.roundedBorder)

                    Text("z.B.: firma gmbh, firma.at, firma ag")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Standard-Belegart", selection: $selectedType) {
                        ForEach(ReceiptType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Erkannter Text (zur Referenz)") {
                    ScrollView {
                        Text(extractedText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(height: 150)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(4)
                }

                Section("Bereits gelernte Firmen") {
                    if learningService.learnedCompanies.isEmpty {
                        Text("Keine gelernten Firmen vorhanden")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        List {
                            ForEach(learningService.learnedCompanies) { company in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(company.name)
                                            .font(.body)
                                        Text(company.keywords.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if let type = company.defaultType {
                                        Text(type.displayName)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.accentColor.opacity(0.2))
                                            .cornerRadius(4)
                                    }

                                    Button {
                                        learningService.removeLearnedCompany(name: company.name)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 120)
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                Spacer()

                Button("Firma speichern") {
                    saveCompany()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(companyName.isEmpty || keywords.isEmpty)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 550, height: 600)
        .alert("Firma gespeichert", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(companyName) wurde erfolgreich zur Datenbank hinzugefügt.")
        }
    }

    private func saveCompany() {
        let keywordList = keywords
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }

        guard !companyName.isEmpty, !keywordList.isEmpty else { return }

        learningService.addLearnedCompany(
            name: companyName,
            keywords: keywordList,
            defaultType: selectedType
        )

        showSuccessAlert = true
    }
}

#Preview {
    LearnCompanySheet(extractedText: """
    MUSTERFIRMA GMBH
    Musterstraße 123
    1010 Wien

    Rechnung Nr. 12345
    Datum: 15.01.2025

    Position 1: Artikel ABC
    EUR 49,99
    """)
}
