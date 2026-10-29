# MarkPDF Studio 📄✨

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-7C3AED?logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Offline](https://img.shields.io/badge/Privacy-100%25%20Offline-success?logo=shield&logoColor=white)](https://github.com/roberthoferzuerich-alt/MarkPDF)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**MarkPDF Studio** ist ein eleganter, schneller und datenschutzfreundlicher plattformübergreifender Markdown-Editor mit integrierter A4-PDF-Druck-Engine. Entwickelt mit **Flutter** für Android, iOS, Windows, macOS, Linux und Web.

Alle Daten, Notizen und generierten PDF-Dokumente verbleiben zu **100% lokal** auf dem Endgerät – ohne Cloud-Zwang, ohne Tracking und ohne Werbung.

---

## 🌟 Hauptfunktionen (Features)

### ✍️ Leistungsstarker Markdown-Editor
* **Live-Vorschau & Split-View**: Nahtloses Umschalten zwischen Bearbeitungsmodus, strukturierter Markdown-Vorschau und PDF-Druckansicht.
* **Historie mit Undo & Redo**: Beliebig viele Bearbeitungsschritte rückgängig machen (`Strg+Z`) und wiederholen (`Strg+Y`) über Toolbar-Buttons oder Tastaturkürzel.
* **Anpassbares Editor-Ambiente**:
  * Stufenlose Schriftgrößen-Regulierung (12 pt bis 22 pt).
  * Augenschonende Editor-Hintergründe mit Farbverläufen (*Subtle Blue*, *Ocean Teal*, *Warm Sunset*, *Emerald Mint* oder *Klassisch*).
* **Formatierungs-Toolbar**: Schneller Zugriff auf Überschriften (H1–H3), Fett, Kursiv, Listen, Checkboxen, Zitate, Codeblöcke und Links.

### 📊 Visueller Tabellen-Assistent
* Tabellen einfach ohne mühsames Eintippen von Pipes (`|`) und Bindestrichen erstellen.
* Vorgefertigte Vorlagen für **Preislisten**, **Feature-Vergleiche** und **Notizen**.
* Spalten und Zeilen interaktiv hinzufügen oder entfernen.
* Flexible Ausrichtung: Links-, Zentriert- oder Rechtsbündig pro Spalte.

### 🖼️ Integrierter Foto-Editor & Bild-Import
* Fotos direkt aus der Galerie, per Kamera oder Dateimanager einfügen.
* Bilder direkt in der App zuschneiden (*Crop*), stufenlos skalieren und rotieren.
* Automatische Optimierung für den gestochen scharfen A4-PDF-Druck.

### 🎨 5 Professionelle PDF-Themes
Wähle per Fingertipp den passenden Stil für dein Dokument:
1. **Modern Business**: Elegante blaue Akzente, strukturierte Trennlinien und serifenlose Typografie – ideal für Angebote, Berichte und Rechnungen.
2. **Minimalist Clean**: Zeitloses Schwarz-Weiß-Design mit perfekter Weißraum-Ausnutzung für Puristen und Handouts.
3. **Academic Paper**: Traditionelle Serifenschrift, feine Zitate und zentrierte Überschriften für Essays und Abhandlungen.
4. **Creative Coral**: Frische Korallen- und Teal-Farbtöne für Magazine, Produktbeschreibungen und kreative Entwürfe.
5. **Sunset Elegance**: Warme Amber- und Burgunder-Nuancen für hochwertige Zertifikate, Einladungen und Exposés.

### 📈 Dokument-Statistiken in Echtzeit
* Zählung von Wörtern, Zeichen (mit/ohne Leerzeichen) und Zeilen.
* Schätzung der **Lesezeit** (bei durchschnittlich 200 Wörtern/Minute).
* Schätzung der **Redezeit** für Vorträge und Präsentationen (ca. 130 Wörter/Minute).

### 🌓 Erscheinungsbild (Theme Mode)
* Vollständige Unterstützung für **Material 3**.
* Umschalten zwischen **Hellem Modus**, **Dunklem Modus (Dark Mode)** oder automatischer Systemanpassung.

### 👤 Entwicklerprofil mit Bild-Import
* Integrierte „Über mich & MarkPDF“-Seite mit Profil- und Entwicklerinformationen.
* Eigener **Bild-Import**: Profilfoto aus Galerie, Kamera oder Datei importieren und persistent speichern.
* Kontaktinformationen mit Ein-Klick-Kopierfunktion für E-Mail und Standort.

---

## 🛠️ Technische Architektur & Verzeichnisstruktur

```text
pdf_writer/
├── assets/
│   ├── icon/              # App-Icons (Android, iOS, Desktop, Web)
│   ├── img/               # Bild-Ressourcen
│   ├── md/                # Markdown-Vorlagen
│   └── sound/             # Audio-Assets
├── lib/
│   ├── models/            # Zustands- & Datenmodelle
│   │   ├── app_state.dart                 # Zentraler ChangeNotifier (State Management)
│   │   ├── editor_background_style.dart   # Editor-Farbverläufe
│   │   ├── editor_history_manager.dart    # Undo/Redo Logik
│   │   └── pdf_theme_config.dart          # Konfiguration der 5 PDF-Themes
│   ├── screens/           # Hauptansichten
│   │   ├── about_me_screen.dart           # Entwicklerprofil & Bild-Import
│   │   ├── help_screen.dart               # Benutzerhandbuch & Shortcuts
│   │   ├── markdown_editor_screen.dart    # Haupt-Editor mit Split-Screen
│   │   ├── pdf_reader_screen.dart         # PDF-Betrachter
│   │   └── settings_screen.dart           # Einstellungen (Themes, Fonts, Hintergründe)
│   ├── services/          # Logik & Plattform-Schnittstellen
│   │   ├── file_service.dart              # Datei- und Bildauswahl (Picker, I/O)
│   │   └── markdown_to_pdf_service.dart   # Markdown-to-PDF Render-Engine
│   ├── theme/             # Material 3 Themes & Farben
│   │   └── app_theme.dart
│   ├── widgets/           # Wiederverwendbare UI-Komponenten
│   │   ├── document_statistics_dialog.dart# Live-Statistiken
│   │   ├── editor_toolbar.dart            # Formatierungs-Werkzeugleiste
│   │   ├── image_cropper_dialog.dart      # Foto-Zuschnitt & Bildeditor
│   │   ├── sample_markdown.dart           # Standard-Mustervorlage
│   │   └── table_assistant_dialog.dart    # Visueller Tabellen-Editor
│   └── main.dart          # App-Einstiegspunkt
└── test/                  # Automatisierte Widget- & Unit-Tests
    ├── about_me_screen_test.dart
    ├── document_statistics_test.dart
    ├── help_screen_test.dart
    ├── markdown_to_pdf_service_test.dart
    ├── settings_screen_test.dart
    ├── table_assistant_test.dart
    └── undo_test.dart
```

---

## 🚀 Installation & Lokales Setup

### Voraussetzungen
Stelle sicher, dass folgende Werkzeuge auf deinem System installiert sind:
* **Flutter SDK** (Version `>= 3.24.0` empfohlen, getestet mit `3.47+`): [Flutter Installationsanleitung](https://docs.flutter.dev/get-started/install)
* **Dart SDK** (Version `>= 3.13.0`)
* Eine IDE deiner Wahl: **VS Code** (mit Flutter-Erweiterung) oder **Android Studio**
* Für Desktop:
  * **Windows**: Visual Studio 2022 mit „Desktopentwicklung mit C++“
  * **macOS**: Xcode & CocoaPods
  * **Linux**: Clang, CMake, GTK-Entwicklungsbibliotheken

### Schritt 1: Repository klonen
```bash
git clone https://github.com/roberthoferzuerich-alt/MarkPDF.git
cd MarkPDF
```

### Schritt 2: Abhängigkeiten installieren
```bash
flutter pub get
```

### Schritt 3: Automatisierte Tests ausführen
Um sicherzustellen, dass alle Komponenten, Formatierungsfunktionen und PDF-Generatoren einwandfrei arbeiten:
```bash
flutter test
```

### Schritt 4: App starten
Wähle dein Zielgerät (angeschlossenes Smartphone, Emulator oder Desktop):
```bash
# Verfügbare Geräte auflisten
flutter devices

# Auf Standardgerät starten
flutter run

# Gezielt für Windows Desktop starten
flutter run -d windows

# Gezielt für Chrome (Web) starten
flutter run -d chrome
```

---

## 📦 Release Builds erstellen

```bash
# Android APK erstellen
flutter build apk --release

# Android App Bundle (für Google Play Store)
flutter build appbundle --release

# Windows Desktop Anwendung (.exe)
flutter build windows --release

# macOS Desktop App
flutter build macos --release

# Web App
flutter build web --release
```

---

## ⌨️ Tastatur-Kurzbefehle (Shortcuts)

| Shortcut | Funktion |
| :--- | :--- |
| `Strg + Z` / `Cmd + Z` | Rückgängig machen (Undo) |
| `Strg + Y` / `Cmd + Shift + Z` | Wiederholen (Redo) |
| `Strg + B` / `Cmd + B` | Text **fett** formatieren |
| `Strg + I` / `Cmd + I` | Text *kursiv* formatieren |
| `Strg + P` / `Cmd + P` | PDF-Export & Druckvorschau |

---

## 👥 Entwickler-Team

* **Robert Hofer**
  * **Rolle**: Initiator, Konzept & Lead Developer
  * **Standort**: Zürich, Schweiz 🇨🇭
  * **E-Mail**: [robert.hofer.zuerich@bluewin.ch](mailto:robert.hofer.zuerich@bluewin.ch)

* **Antigravity**
  * **Rolle**: AI Co-Entwickler & Code-Architekt (Google DeepMind)
  * **Beitrag**: Co-Pilot für Architektur, PDF-Rendering-Pipeline, reaktives State Management und umfassende Testabdeckung.

---

## 📄 Lizenz

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert. Weitere Informationen findest du in der Datei [LICENSE](LICENSE).
