# Beleg-Renamer

Eine macOS-App zur automatischen Erkennung und Umbenennung von Belegen (Rechnungen, Quittungen, Tankbelege, etc.) für Steuerzwecke.

![Beleg-Renamer Icon](BelegRenamer/BelegRenamer/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

## Features

- **OCR-Texterkennung** für PDFs und Bilder (JPG, PNG, HEIC, TIFF)
- **Intelligente Klassifizierung** mit 200+ vordefinierten Firmen
- **10 Belegarten**: Rechnung, Parkbeleg, Tankbeleg, E-Tankbeleg, Hotelbeleg, Bewirtungsbeleg, Abo, App-Abo, Kassenbon, Kreditkartenabrechnung
- **Automatische Datumserkennung** (DE/EN, verschiedene Formate)
- **Produkterkennung** für Apple/Amazon/Google Abos
- **Lernfähig**: Eigene Firmen mit Keywords hinzufügen
- **Batch-Verarbeitung**: Mehrere Belege gleichzeitig umbenennen
- **Backup**: Originale werden automatisch gesichert

## Installation

### Option 1: Selbst bauen
1. Xcode 15+ installieren
2. Repository klonen:
   ```bash
   git clone https://github.com/DEIN-USERNAME/Beleg-Renamer.git
   ```
3. `BelegRenamer.xcodeproj` in Xcode öffnen
4. Build (⌘+B) und Run (⌘+R)

### Option 2: Release herunterladen
1. Gehe zu [Releases](../../releases)
2. Lade die neueste `.dmg` oder `.zip` herunter
3. App nach `/Applications` verschieben

## Verwendung

1. **Belege laden**: Ordner öffnen, Dateien wählen oder per Drag & Drop
2. **OCR starten**: Texterkennung für alle Belege
3. **Prüfen**: Erkannte Werte kontrollieren/bearbeiten
4. **Umbenennen**: "Alle umbenennen" klickt - fertig!

### Dateiformat
```
DD.MM.YYYY-Firma-Typ[-Produkt].ext
```

Beispiele:
- `17.12.2025-Avanti-tankbeleg.pdf`
- `30.11.2025-Apple-app-abo-Perplexity.pdf`
- `05.12.2025-PayLife-VISA-kk-abrechnung.pdf`

## Unterstützte Firmen (Auszug)

| Kategorie | Firmen |
|-----------|--------|
| Parken | APCOA, EasyPark, Wipark, ParkNow |
| Tanken | OMV, Avanti, Shell, BP, Turmöl |
| E-Tanken | Tesla, Ionity, Smatrics, EnBW |
| Streaming | Netflix, Spotify, Disney+, Zattoo |
| Software | Apple, Google, Microsoft, Adobe |
| Einzelhandel | Amazon, Billa, Spar, IKEA |
| ... | 200+ weitere |

## Systemanforderungen

- macOS 13.0 (Ventura) oder neuer
- Apple Silicon (M1/M2/M3) oder Intel Mac

## Lizenz

MIT License - siehe [LICENSE](LICENSE)

## Beitragen

Pull Requests willkommen! Bitte erst ein Issue erstellen für größere Änderungen.

### Firma hinzufügen
In `Models/Company.swift`:
```swift
Company(name: "FirmaName", keywords: ["keyword1", "keyword2"], defaultType: .rechnung),
```
