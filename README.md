# SlideSync

A modern, cross-platform Flutter application for students to organize, read, and manage educational materials (PDFs, images, notes, links) with AI-powered study assistance, automated reading tracking, and cloud backup.

---

## Key Features

### 📚 Course & Module Organization
- **Hierarchical Taxonomy** — Group materials cleanly into **Courses $\rightarrow$ Modules $\rightarrow$ Contents** with relational Isar database links.
- **Categorization by Content Type** — Dedicated handling for Documents (PDF/Text), Images, Web Links, Notes, and References.
- **Organized Sub-grouping** — View-level grouping by `groupId` with thumbnail previews and aggregation.

### 📄 Comprehensive Document & PDF Viewer
- **High-Performance PDF Engine** — Powered by `syncfusion_flutter_pdfviewer` with support for local and remote documents.
- **Custom Reader Experience**:
  - **Inverted Dark Mode** — High-contrast white-on-black viewing using difference blend filters.
  - **Immersive Full-Screen** — Clean toggle between focus mode and edge-to-edge system UI with touch gesture filtering (distinguishing tap, scroll, and double-tap zoom).
  - **In-Document Search** — Real-time keyword search with match navigation and query highlights.
  - **Dynamic Scrollbar Overlay** — Live page indicators (`"Page X of Y"`).
  - **Integrated Screenshot Tool** — In-app capture wrapper for quick note-taking.
- **Image & Text Viewers** — Multi-image gallery with pinch-to-zoom (`photo_view`) and text viewer with selectable text and copy utilities.

### 🤖 AI Study Assistant & Quiz Engine
- **Interactive AI Tutor** — Live streaming Markdown chat powered by **Google Gemini (`gemini-2.5-flash`)** with contextual study-guide prompting.
- **Automated Quiz & Exam Generator** — Synthesizes multiple-choice questions directly from study materials:
  - Supports timed exam modes, question shuffling, and instant answer validation.
  - Generates detailed answer explanations and performance metrics.
  - Stores generated quizzes in Isar for offline revision.

### ⏱️ Smart Reading Tracker
- **Dwell-Time Validated Tracking** — Tracks genuine reading activity using a 13-second page dwell threshold to prevent inflated statistics.
- **"Continue Reading" Dashboard** — Quick-resume card on the home screen that returns to the exact last-read page.
- **Recents Feed** — Searchable access history with progress percentage rings, bookmarks, and sharing options.

### 📁 Smart File Management & Optimization
- **Content Deduplication (`xxh3`)** — Fast 64-bit hashing detects identical files across courses, preventing duplicate storage consumption.
- **Asynchronous Thumbnail Pipeline** — Generates lightweight cached previews using `pdfx` (1st page rendering) and `flutter_image_compress`.
- **Multi-Format Archive Extraction** — Unpacks `.zip`, `.tar`, `.gz`, and `.bz2` course archives with Zip-Slip path sanitization and concurrent batch execution.
- **File Actions** — Move, copy, single-item rename, and database-level multi-attribute sorting (Name, Date Created, Date Modified, Course Code).

### 📱 Platform-Specific Capabilities
- **Android**:
  - Storage Access Framework (SAF) stream support via `saf_stream` / `saf_util`.
  - OS Share Intent receiver (`receive_sharing_intent`) to import external files directly into course collections.
  - Automated release APK build pipeline with symbol obfuscation and icon tree-shaking.
- **Windows Desktop**:
  - Desktop window management with `window_manager` (framing, centering, min-size constraints).
  - Desktop drag-and-drop file import wrapper.
  - Inno Setup installer script (`installer.iss`) and MSIX packaging configuration.

---

## Tech Stack & Architecture

- **Framework**: Flutter (Dart 3.x)
- **State Management**: Riverpod (Pod architecture pattern)
- **Local Storage & Database**:
  - **Isar Database (NoSQL)** — Relational queries, indexed search, and progress tracking
  - **Hive & Flutter Secure Storage** — UI preferences, sort keys, and credentials
- **AI Integration**: Google Generative AI SDK (`google_generative_ai` / Gemini 2.5 Flash)
- **Document & Media Engines**: `syncfusion_flutter_pdfviewer`, `pdfx`, `photo_view`, `archive`
- **Cloud & Auth**: Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage, Google Drive APIs
- **Supported Platforms**: Android & Windows

---

## Planned / In Progress Roadmap

- Local network WiFi sync & real-time desktop casting
- Multi-select gestures & bulk file renaming
- Manual drag-and-drop reordering for files and modules
- Auto-ordering for hierarchically numbered filenames (e.g., `Lecture 1`, `Lecture 2`)
- Custom color tags and alias naming for modules

---

## Getting Started

### 1. Prerequisites
Ensure you have the Flutter SDK installed (`>=3.41.0`) and configured.

### 2. Code Generation
SlideSync uses `build_runner` for Isar collections and Dart Mappable classes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Running the Application
```bash
flutter run
```

### 4. Release Builds
- **Android APK**: Run `release_build_app.bat` or:
  ```bash
  flutter build apk --release --obfuscate --split-debug-info=build/symbols --tree-shake-icons
  ```
- **Windows Setup Installer**: Compile `installer.iss` using Inno Setup compiler after building release binaries (`flutter build windows --release`).
