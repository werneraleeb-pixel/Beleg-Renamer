import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = ReceiptListViewModel()
    @State private var isDragOver = false

    var body: some View {
        HSplitView {
            // Left panel - File list
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: selectFolder) {
                        Label("Ordner öffnen", systemImage: "folder")
                    }

                    Button(action: selectFiles) {
                        Label("Dateien", systemImage: "doc.badge.plus")
                    }

                    Spacer()

                    if !viewModel.receipts.isEmpty {
                        Button(action: { viewModel.clearAll() }) {
                            Label("Leeren", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // File list or drop zone
                if viewModel.receipts.isEmpty {
                    dropZoneView
                } else {
                    fileListView
                }

                Divider()

                // Bottom toolbar with actions
                bottomToolbar
            }
            .frame(minWidth: 350)

            // Right panel - Preview
            ReceiptPreview(receipt: viewModel.selectedReceipt)
                .frame(minWidth: 400)
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $viewModel.showEditSheet) {
            if let receipt = viewModel.selectedReceipt {
                EditSheet(receipt: receipt) { updatedReceipt in
                    viewModel.updateReceipt(updatedReceipt)
                }
            }
        }
        .sheet(isPresented: $viewModel.showLearnCompanySheet) {
            if let receipt = viewModel.selectedReceipt {
                LearnCompanySheet(extractedText: receipt.extractedText)
            }
        }
        .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var dropZoneView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Belege hier ablegen")
                .font(.headline)

            Text("oder Ordner/Dateien über die Schaltflächen oben auswählen")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Unterstützte Formate: PDF, JPG, PNG, HEIC")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDragOver ? Color.accentColor.opacity(0.1) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isDragOver ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .padding(16)
        )
        .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private var fileListView: some View {
        List(viewModel.receipts, selection: Binding(
            get: { viewModel.selectedReceipt?.id },
            set: { id in
                Task { @MainActor in
                    if let id = id {
                        viewModel.selectedReceipt = viewModel.receipts.first { $0.id == id }
                    }
                }
            }
        )) { receipt in
            ReceiptRow(receipt: receipt)
                .tag(receipt.id)
                .contextMenu {
                    Button("Bearbeiten") {
                        viewModel.selectReceipt(receipt)
                        viewModel.showEditSheet = true
                    }

                    Button("Firma lernen") {
                        viewModel.selectReceipt(receipt)
                        viewModel.showLearnCompanySheet = true
                    }

                    Divider()

                    Button("Entfernen", role: .destructive) {
                        viewModel.removeReceipt(receipt)
                    }
                }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private var bottomToolbar: some View {
        HStack {
            if viewModel.isProcessing {
                ProgressView(value: viewModel.processingProgress)
                    .progressViewStyle(.linear)
                    .frame(width: 150)

                Text("\(Int(viewModel.processingProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !viewModel.receipts.isEmpty {
                Button("OCR starten") {
                    Task {
                        await viewModel.processAllReceipts()
                    }
                }
                .disabled(viewModel.isProcessing)

                Button("Alle umbenennen") {
                    Task {
                        await viewModel.renameAllReceipts()
                    }
                }
                .disabled(viewModel.isProcessing || !hasCompletedReceipts)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var hasCompletedReceipts: Bool {
        viewModel.receipts.contains { receipt in
            if case .completed = receipt.status { return true }
            return false
        }
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            viewModel.loadFolder(url: url)
        }
    }

    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [
            .pdf,
            .jpeg,
            .png,
            .heic,
            .tiff
        ]

        if panel.runModal() == .OK {
            viewModel.loadFiles(from: panel.urls)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                DispatchQueue.main.async {
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            viewModel.loadFolder(url: url)
                        } else {
                            viewModel.loadFiles(from: [url])
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
