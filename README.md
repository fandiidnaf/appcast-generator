# Universal Appcast Studio

A developer workstation for authoring, validating, and inspecting multi-platform **Appcast XML feeds** (supporting **Sparkle 2**, **WinSparkle / NetSparkle**, and **Flutter Upgrader**).

Live reactive editor → Real-time syntax inspector → Multi-enclosure payload authoring → One-click export.

---

## Highlights

| Feature | Capabilities |
| :--- | :--- |
| **Universal Multi-Platform** | Native presets for **Sparkle 2 (macOS standard)**, **Flutter Upgrader**, and **WinSparkle / NetSparkle**. |
| **Multi-Enclosure per Release** | Attach distinct platform binaries (macOS `.dmg`/`.zip`, Windows `.exe`/`.msi`, Linux `.tar.gz`/`.AppImage`) in a single version release. |
| **Modern Architecture** | **Feature-First + BLoC / Cubit** state management for deterministic, reactive feed authoring and testability. |
| **Anti-Slop Craftsmanship** | Thoughtfully designed developer aesthetic with **first-class Dark Mode & Light Mode**, WCAG AA contrast, and zero generic AI templates. |
| **Real-Time XML Inspector** | Monospace inspector with syntax tokenization, line numbers, schema validation alerts, and quick integration snippets. |
| **Standards-Compliant Engine** | DOM-based XML generation (`package:xml`) adhering to RFC 822 / 2822 timestamps, Ed25519 signatures, CDATA changelogs, and phased rollout intervals. |
| **Wasm-Ready Web Stack** | Built with **Flutter 3.47.4 (Dart 3.13.3)** and modern `package:web` browser APIs. |

---

## Presets & Standards

```
                     ┌── Sparkle 2 (macOS)       ──> <sparkle:version>, arch, edSignature
                     │
Appcast XML Feed ────┼── Flutter Upgrader        ──> <enclosure sparkle:version="" sparkle:os="" />
                     │
                     └── WinSparkle / NetSparkle ──> Windows installer types & HTTPS enclosures
```

### 1. Sparkle 2 (macOS Standard)
- Child elements `<sparkle:version>`, `<sparkle:shortVersionString>`, `<sparkle:minimumSystemVersion>`.
- Multi-architecture enclosures with `sparkle:arch="arm64"` and `sparkle:arch="x86_64"`.
- Ed25519 signatures via `sparkle:edSignature`.
- Phased rollout interval in seconds (`sparkle:phasedRolloutInterval`).

### 2. Flutter Upgrader
- Compatible with [pub.dev/packages/upgrader](https://pub.dev/packages/upgrader).
- Enclosure-centric attributes: `sparkle:version`, `sparkle:shortVersionString`, and `sparkle:os`.

### 3. WinSparkle / NetSparkle
- Windows executable (`.exe`), MSI installer (`.msi`), and Inno Setup payloads.

---

## Sample Multi-Enclosure Output

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>My App Updates</title>
    <link>https://example.com</link>
    <description>Latest version updates and changelogs</description>
    <language>en</language>
    <atom:link href="https://example.com/appcast.xml" rel="self" type="application/rss+xml"/>
    <item>
      <title>Version 2.0.0</title>
      <pubDate>Thu, 15 Jan 2026 00:00:00 +0000</pubDate>
      <sparkle:version>2.0.0</sparkle:version>
      <sparkle:shortVersionString>2.0.0</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>12.0</sparkle:minimumSystemVersion>
      <sparkle:criticalUpdate/>
      <sparkle:releaseNotesLink><![CDATA[<ul><li>Added multi-platform binary support</li><li>Fixed macOS Ventura crash</li></ul>]]></sparkle:releaseNotesLink>
      <!-- macOS Apple Silicon Binary -->
      <enclosure url="https://example.com/app-2.0.0-arm64.dmg" length="52428800" type="application/x-apple-diskimage" sparkle:os="macos" sparkle:arch="arm64" sparkle:edSignature="YOUR_ED25519_SIG_HERE"/>
      <!-- Windows x64 Installer -->
      <enclosure url="https://example.com/app-2.0.0-x64.exe" length="62914560" type="application/x-ms-dos-executable" sparkle:os="windows" sparkle:arch="x86_64"/>
    </item>
  </channel>
</rss>
```

---

## Development & Verification

Ensure you have [FVM](https://fvm.app/) configured with Flutter 3.47.4:

```bash
# Verify SDK version
fvm flutter --version

# Run static analysis (0 warnings / 0 errors)
fvm flutter analyze

# Run full unit test suite (11/11 tests passing)
fvm flutter test

# Build optimized Web release
fvm flutter build web --release
```

---

## License

MIT — open source for multi-platform software creators.
