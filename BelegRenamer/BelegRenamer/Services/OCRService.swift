import Foundation
import Vision
import AppKit
import PDFKit
import CoreImage

actor OCRService {
    static let shared = OCRService()

    private init() {}

    func extractText(from url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()

        if fileExtension == "pdf" {
            return try await extractTextFromPDF(url: url)
        } else {
            return try await extractTextFromImage(url: url)
        }
    }

    private func extractTextFromPDF(url: URL) async throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw OCRError.invalidDocument
        }

        var allText = ""

        // First try to get embedded text from ALL pages (not just first 5)
        let maxPages = min(document.pageCount, 10)
        for pageIndex in 0..<maxPages {
            if let page = document.page(at: pageIndex),
               let pageText = page.string {
                allText += pageText + "\n"
            }
        }

        // If embedded text is too short or seems incomplete, also do OCR
        let embeddedTextLength = allText.trimmingCharacters(in: .whitespacesAndNewlines).count
        if embeddedTextLength < 100 {
            allText = ""
            for pageIndex in 0..<min(document.pageCount, 5) {
                if let page = document.page(at: pageIndex) {
                    let pageText = try await performOCROnPDFPage(page: page)
                    allText += pageText + "\n"
                }
            }
        } else {
            // Even with embedded text, do OCR on first page for better recognition
            if let firstPage = document.page(at: 0) {
                let ocrText = try await performOCROnPDFPage(page: firstPage)
                // Combine both for better coverage
                allText = ocrText + "\n---\n" + allText
            }
        }

        return allText
    }

    private func performOCROnPDFPage(page: PDFPage) async throws -> String {
        // Higher resolution for better OCR
        let scale: CGFloat = 3.0
        let pageRect = page.bounds(for: .mediaBox)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

        let image = NSImage(size: scaledSize)
        image.lockFocus()

        if let context = NSGraphicsContext.current?.cgContext {
            context.setFillColor(NSColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: scaledSize))
            context.scaleBy(x: scale, y: scale)
            page.draw(with: .mediaBox, to: context)
        }

        image.unlockFocus()

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageConversionFailed
        }

        // Apply image enhancement
        let enhancedImage = enhanceImageForOCR(cgImage)

        return try await performOCR(on: enhancedImage)
    }

    private func extractTextFromImage(url: URL) async throws -> String {
        guard let image = NSImage(contentsOf: url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageConversionFailed
        }

        // Apply image enhancement for better OCR
        let enhancedImage = enhanceImageForOCR(cgImage)

        // Try OCR with enhanced image first
        var text = try await performOCR(on: enhancedImage)

        // If result is too short, try with original image
        if text.trimmingCharacters(in: .whitespacesAndNewlines).count < 50 {
            let originalText = try await performOCR(on: cgImage)
            if originalText.count > text.count {
                text = originalText
            }
        }

        return text
    }

    private func enhanceImageForOCR(_ cgImage: CGImage) -> CGImage {
        let ciImage = CIImage(cgImage: cgImage)

        // Apply multiple filters for better OCR
        var outputImage = ciImage

        // 1. Increase contrast
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(outputImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.2, forKey: kCIInputContrastKey)  // Increase contrast
            contrastFilter.setValue(0.0, forKey: kCIInputSaturationKey)  // Grayscale
            contrastFilter.setValue(0.05, forKey: kCIInputBrightnessKey)  // Slight brightness increase
            if let result = contrastFilter.outputImage {
                outputImage = result
            }
        }

        // 2. Sharpen
        if let sharpenFilter = CIFilter(name: "CISharpenLuminance") {
            sharpenFilter.setValue(outputImage, forKey: kCIInputImageKey)
            sharpenFilter.setValue(0.5, forKey: kCIInputSharpnessKey)
            if let result = sharpenFilter.outputImage {
                outputImage = result
            }
        }

        // 3. Noise reduction
        if let noiseFilter = CIFilter(name: "CINoiseReduction") {
            noiseFilter.setValue(outputImage, forKey: kCIInputImageKey)
            noiseFilter.setValue(0.02, forKey: "inputNoiseLevel")
            noiseFilter.setValue(0.4, forKey: "inputSharpness")
            if let result = noiseFilter.outputImage {
                outputImage = result
            }
        }

        // Convert back to CGImage
        let context = CIContext(options: [.useSoftwareRenderer: false])
        if let result = context.createCGImage(outputImage, from: outputImage.extent) {
            return result
        }

        return cgImage
    }

    private func performOCR(on cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                // Get multiple candidates for better accuracy
                let text = observations.compactMap { observation -> String? in
                    // Get top 3 candidates and pick the best one
                    let candidates = observation.topCandidates(3)
                    return candidates.first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: text)
            }

            // Optimized settings for receipt OCR
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["de-DE", "en-US", "en-GB"]
            request.usesLanguageCorrection = true
            request.revision = VNRecognizeTextRequestRevision3  // Latest revision
            request.minimumTextHeight = 0.01  // Detect smaller text

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum OCRError: LocalizedError {
    case invalidDocument
    case imageConversionFailed
    case ocrFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidDocument:
            return "Das Dokument konnte nicht geöffnet werden."
        case .imageConversionFailed:
            return "Das Bild konnte nicht konvertiert werden."
        case .ocrFailed(let message):
            return "OCR fehlgeschlagen: \(message)"
        }
    }
}
