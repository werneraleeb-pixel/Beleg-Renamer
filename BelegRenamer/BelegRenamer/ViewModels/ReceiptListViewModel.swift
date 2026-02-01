import Foundation
import SwiftUI
import Combine

@MainActor
class ReceiptListViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    @Published var selectedReceipt: Receipt?
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0
    @Published var showEditSheet = false
    @Published var showLearnCompanySheet = false
    @Published var errorMessage: String?

    private let learningService = LearningService.shared

    var selectedIndex: Int? {
        guard let selected = selectedReceipt else { return nil }
        return receipts.firstIndex(where: { $0.id == selected.id })
    }

    func loadFiles(from urls: [URL]) {
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "heic", "heif", "tiff", "tif"]

        let newReceipts = urls
            .filter { supportedExtensions.contains($0.pathExtension.lowercased()) }
            .map { Receipt(originalURL: $0) }

        receipts.append(contentsOf: newReceipts)
    }

    func loadFolder(url: URL) {
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return }

        var urls: [URL] = []
        for case let fileURL as URL in enumerator {
            urls.append(fileURL)
        }

        loadFiles(from: urls)
    }

    func processAllReceipts() async {
        guard !receipts.isEmpty else { return }

        isProcessing = true
        processingProgress = 0

        let total = Double(receipts.count)

        for index in receipts.indices {
            await processReceipt(at: index)
            processingProgress = Double(index + 1) / total
        }

        isProcessing = false
    }

    func processReceipt(at index: Int) async {
        guard index < receipts.count else { return }

        receipts[index].status = .processing

        do {
            // Extract text via OCR
            let text = try await OCRService.shared.extractText(from: receipts[index].originalURL)
            receipts[index].extractedText = text

            // Extract date
            receipts[index].detectedDate = DateExtractionService.shared.extractDate(from: text)

            // Classify company and type
            let classification = ClassificationService.shared.classifyReceipt(
                text: text,
                learnedCompanies: learningService.learnedCompanies
            )
            receipts[index].detectedCompany = classification.company
            receipts[index].detectedType = classification.type

            // Extract specific product/app name
            receipts[index].detectedProduct = ProductExtractionService.shared.extractProduct(
                from: text,
                company: classification.company,
                type: classification.type
            )

            // Generate suggested name
            receipts[index].suggestedName = receipts[index].generateFileName()

            receipts[index].status = .completed
        } catch {
            receipts[index].status = .error(error.localizedDescription)
        }

        // Update selection if this receipt was selected
        if selectedReceipt?.id == receipts[index].id {
            selectedReceipt = receipts[index]
        }
    }

    func renameAllReceipts() async {
        guard !receipts.isEmpty else { return }

        isProcessing = true
        processingProgress = 0

        let total = Double(receipts.count)

        for index in receipts.indices {
            if case .completed = receipts[index].status {
                await renameReceipt(at: index)
            }
            processingProgress = Double(index + 1) / total
        }

        isProcessing = false
    }

    func renameReceipt(at index: Int) async {
        guard index < receipts.count else { return }

        let receipt = receipts[index]
        let fileManager = FileManager.default
        let originalURL = receipt.originalURL
        let directory = originalURL.deletingLastPathComponent()

        // Create backup directory
        let backupDir = directory.appendingPathComponent("Originalbelege")
        if !fileManager.fileExists(atPath: backupDir.path) {
            do {
                try fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
            } catch {
                receipts[index].status = .error("Backup-Ordner konnte nicht erstellt werden: \(error.localizedDescription)")
                return
            }
        }

        // Generate unique filename
        let baseName = receipt.suggestedName.isEmpty ? receipt.generateFileName() : receipt.suggestedName
        let ext = receipt.fileExtension
        let newFileName = generateUniqueFileName(baseName: baseName, extension: ext, in: directory)
        let newURL = directory.appendingPathComponent(newFileName)

        do {
            // Move original to backup
            let backupURL = backupDir.appendingPathComponent(receipt.originalFileName)
            try fileManager.moveItem(at: originalURL, to: backupURL)

            // Copy from backup to new name
            try fileManager.copyItem(at: backupURL, to: newURL)

            receipts[index].status = .completed
        } catch {
            receipts[index].status = .error("Umbenennung fehlgeschlagen: \(error.localizedDescription)")
        }
    }

    private func generateUniqueFileName(baseName: String, extension ext: String, in directory: URL) -> String {
        let fileManager = FileManager.default
        var fileName = "\(baseName).\(ext)"
        var counter = 1

        while fileManager.fileExists(atPath: directory.appendingPathComponent(fileName).path) {
            fileName = "\(baseName) (\(counter)).\(ext)"
            counter += 1
        }

        return fileName
    }

    func updateReceipt(_ receipt: Receipt) {
        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts[index] = receipt
            receipts[index].suggestedName = receipt.generateFileName()

            if selectedReceipt?.id == receipt.id {
                selectedReceipt = receipts[index]
            }
        }
    }

    func removeReceipt(_ receipt: Receipt) {
        receipts.removeAll { $0.id == receipt.id }
        if selectedReceipt?.id == receipt.id {
            selectedReceipt = nil
        }
    }

    func clearAll() {
        receipts.removeAll()
        selectedReceipt = nil
        processingProgress = 0
    }

    func selectReceipt(_ receipt: Receipt) {
        selectedReceipt = receipt
    }
}
