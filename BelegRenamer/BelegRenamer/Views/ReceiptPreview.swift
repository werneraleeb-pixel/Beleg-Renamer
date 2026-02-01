import SwiftUI
import PDFKit
import QuickLook

struct ReceiptPreview: View {
    let receipt: Receipt?

    var body: some View {
        if let receipt = receipt {
            VStack(spacing: 0) {
                // Preview header
                HStack {
                    Text(receipt.originalFileName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    if receipt.isPDF {
                        Text("PDF")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    } else {
                        Text(receipt.fileExtension.uppercased())
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Preview content
                if receipt.isPDF {
                    PDFPreviewView(url: receipt.originalURL)
                } else if receipt.isImage {
                    ImagePreviewView(url: receipt.originalURL)
                } else {
                    Text("Vorschau nicht verfügbar")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // OCR text preview (collapsible)
                if !receipt.extractedText.isEmpty {
                    Divider()

                    DisclosureGroup("Erkannter Text") {
                        ScrollView {
                            Text(receipt.extractedText)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .textSelection(.enabled)
                        }
                        .frame(height: 150)
                        .background(Color(NSColor.textBackgroundColor))
                    }
                    .padding()
                }
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "eye.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Keine Datei ausgewählt")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Wählen Sie einen Beleg aus der Liste aus")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PDFPreviewView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = NSColor.windowBackgroundColor
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}

struct ImagePreviewView: View {
    let url: URL

    var body: some View {
        if let image = NSImage(contentsOf: url) {
            ScrollView([.horizontal, .vertical]) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .background(Color(NSColor.windowBackgroundColor))
        } else {
            Text("Bild konnte nicht geladen werden")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ReceiptPreview(receipt: nil)
        .frame(width: 400, height: 600)
}
