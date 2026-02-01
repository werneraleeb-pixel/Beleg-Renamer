# Beleg-Renamer

## Projektübersicht
Eine macOS SwiftUI-App zur automatischen Erkennung und Umbenennung von Belegen (Rechnungen, Quittungen, etc.) für Steuerzwecke.

## Tech Stack
- **Framework:** SwiftUI (macOS)
- **Sprache:** Swift
- **OCR:** Apple Vision Framework
- **PDF:** PDFKit
- **Mindest-macOS:** 13.0+

## Projektstruktur
```
BelegRenamer/
├── BelegRenamer.xcodeproj/     # Xcode Projekt
├── BelegRenamer/
│   ├── BelegRenamerApp.swift   # App Entry Point
│   ├── Models/
│   │   ├── Receipt.swift       # Beleg-Datenmodell
│   │   ├── Company.swift       # Firmendatenbank (200+ Firmen)
│   │   └── ReceiptType.swift   # Belegarten (10 Typen)
│   ├── Services/
│   │   ├── OCRService.swift           # Text-Extraktion (PDF/Bilder)
│   │   ├── ClassificationService.swift # Firmen/Typ-Erkennung
│   │   ├── DateExtractionService.swift # Datumserkennung
│   │   ├── ProductExtractionService.swift # App/Produkt-Erkennung
│   │   └── LearningService.swift      # Benutzerdefinierte Firmen
│   ├── ViewModels/
│   │   └── ReceiptListViewModel.swift # Hauptlogik
│   ├── Views/
│   │   ├── ContentView.swift          # Hauptansicht
│   │   ├── ReceiptRow.swift           # Listenzeile
│   │   ├── ReceiptPreview.swift       # PDF/Bild-Vorschau
│   │   ├── EditSheet.swift            # Bearbeitung
│   │   └── LearnCompanySheet.swift    # Firma lernen
│   └── Assets.xcassets/               # Icons
└── Musterbelege/                      # Testdokumente
```

## Wichtige Dateien für Änderungen

### Neue Firma hinzufügen
**Datei:** `Models/Company.swift`
```swift
Company(name: "FirmaName", keywords: ["keyword1", "keyword2"], defaultType: .rechnung),
```

### Neuen Belegtyp hinzufügen
**Datei:** `Models/ReceiptType.swift`
1. Neuen case hinzufügen
2. displayName ergänzen
3. keywords ergänzen

### Neue App/Produkt für Erkennung
**Datei:** `Services/ProductExtractionService.swift`
```swift
("AppName", ["keyword1", "keyword2"]),
```

### Datumsformat hinzufügen
**Datei:** `Services/DateExtractionService.swift`
- Neue Pattern in `findDateInLine()` und `findBestDateInText()` ergänzen

## Spezielle Erkennungslogik

### APCOA: Parken vs E-Laden
In `ClassificationService.swift` wird nach APCOA-Erkennung geprüft, ob "kwh", "ladepreis", etc. vorkommen → dann E-Tankbeleg

### PayLife: VISA vs Mastercard
Nach PayLife-Erkennung wird auf "visa" oder "mastercard" im Text geprüft

### Avanti vs OMV
Avanti steht VOR OMV in der Firmenliste, da Avanti-Belege "OMV Downstream GmbH" im Footer haben

### Apple/Amazon Produkterkennung
- Apple: Sucht nach "App" Zeile für App-Namen
- Amazon: Sucht im "Rechnungsdetails" Abschnitt nach Produktnamen

## Build & Deploy
```bash
# In Xcode bauen (⌘+B)
# Dann nach /Applications kopieren:
cp -R ~/Library/Developer/Xcode/DerivedData/BelegRenamer-*/Build/Products/Debug/BelegRenamer.app /Applications/
```

## Dateiformat für Umbenennung
`DD.MM.YYYY-Firma-Typ[-Produkt].ext`

Beispiele:
- `17.12.2025-Avanti-tankbeleg.pdf`
- `30.11.2025-Apple-app-abo-Perplexity.pdf`
- `05.12.2025-PayLife-VISA-kk-abrechnung.pdf`

## Unterstützte Dateitypen
PDF, JPG, JPEG, PNG, HEIC, HEIF, TIFF, TIF
