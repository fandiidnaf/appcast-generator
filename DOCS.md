# Panduan & Dokumentasi Universal Appcast Studio

Panduan lengkap mengenai konsep **Appcast XML**, cara kerja pada platform **Mobile (Android & iOS)** dan **Desktop (macOS, Windows, Linux)**, serta integrasinya dengan package Flutter [`upgrader`](https://pub.dev/packages/upgrader) dan framework native lainnya.

---

## 1. Apa Itu Appcast?

**Appcast** pada dasarnya adalah feed **RSS 2.0 XML** yang diperluas (*extended*) dengan namespace khusus (dipopulerkan oleh framework [Sparkle](https://sparkle-project.org/) di macOS). 

Jika RSS biasa digunakan untuk feed artikel blog atau podcast, maka Appcast digunakan untuk **feed pembaruan aplikasi (software updates)**. Setiap versi baru aplikasi didaftarkan sebagai satu `<item>` di dalam feed XML yang ditaruh di server publik (misal GitHub Pages, S3, atau server hosting Anda).

---

## 2. Appcast di Mobile (Android & iOS)

### Apakah Flutter `upgrader` Mendukung Mobile dengan Appcast?
**Ya, 100% didukung.**

Secara default, jika Anda menggunakan package `upgrader` di Flutter:
- Di **Android**, `upgrader` mengecek Google Play Store API secara otomatis.
- Di **iOS**, `upgrader` mengecek Apple App Store API secara otomatis.

**Namun**, ada banyak skenario di mana developer **TIDAK** mendistribusikan aplikasi lewat Google Play atau App Store, misalnya:
1. **Distribusi Internal / Enterprise**: Aplikasi internal kantor/perusahaan yang diinstal langsung via file `.apk`.
2. **Sideloading & GitHub Releases**: Aplikasi open-source yang didownload langsung dari GitHub Release atau website resmi.
3. **Perangkat Non-Google**: Android TV, POS Kasir, Huawei AppGallery, atau tablet industri tanpa Google Play Services.
4. **iOS In-House / B2B Enterprise**: Distribusi via Over-The-Air (OTA) manifest link (`itms-services://`).

Pada skenario di atas, **Appcast XML adalah solusi standar industri** untuk memberi tahu aplikasi Flutter bahwa ada update versi baru dan langsung mengunduh paket update-nya.

---

### Contoh Integrasi Flutter `upgrader` dengan Appcast di Mobile & Desktop:

```dart
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // URL tempat file appcast.xml Anda dihosting
    const appcastURL = 'https://fandiidnaf.github.io/appcast-generator/appcast.xml';

    final appcastConfig = AppcastConfiguration(
      url: appcastURL,
      // Target platform yang menggunakan Appcast
      supportedOS: ['android', 'ios', 'windows', 'macos', 'linux'],
    );

    return MaterialApp(
      home: UpgradeAlert(
        upgrader: Upgrader(
          appcastConfig: appcastConfig,
          debugLogging: true, // Ubah ke false saat rilis
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('My App')),
          body: const Center(child: Text('Aplikasi Utama')),
        ),
      ),
    );
  }
}
```

---

## 3. Glosarium & Istilah Penting

### Mengapa Disebut "Enclosure" atau "Package"?
Istilah `<enclosure>` berasal langsung dari spesifikasi resmi RSS 2.0. Di podcast, enclosure berisi file `.mp3`. Di Appcast software, enclosure adalah **file installer / paket unduhan aplikasi** untuk platform target:
- **Android**: File `.apk` (MIME: `application/vnd.android.package-archive`)
- **macOS**: File `.dmg` atau `.zip` (MIME: `application/x-apple-diskimage` atau `application/zip`)
- **Windows**: File installer `.exe` atau `.msi` (MIME: `application/x-ms-dos-executable`)
- **Linux**: File `.AppImage` atau `.tar.gz` (MIME: `application/octet-stream`)
- **iOS**: Link manifest OTA enterprise

### Apa Itu Multi-Enclosure?
Dalam satu versi rilis (misalnya `v2.1.0`), software Anda mungkin tersedia untuk Android, Windows, dan macOS sekaligus. Dengan fitur **Multi-Enclosure** di Universal Appcast Studio, Anda cukup membuat 1 rilis dan melampirkan beberapa file unduhan dengan target OS masing-masing:
```xml
<item>
  <title>Version 2.1.0</title>
  <sparkle:version>2.1.0</sparkle:version>
  <!-- Paket Android APK -->
  <enclosure url="https://example.com/app-v2.1.0.apk" sparkle:os="android" type="application/vnd.android.package-archive" length="18500000"/>
  <!-- Paket Windows EXE -->
  <enclosure url="https://example.com/app-v2.1.0.exe" sparkle:os="windows" type="application/x-ms-dos-executable" length="45000000"/>
  <!-- Paket macOS DMG -->
  <enclosure url="https://example.com/app-v2.1.0.dmg" sparkle:os="macos" sparkle:arch="arm64" type="application/x-apple-diskimage" length="52000000"/>
</item>
```

---

### Fitur-Fitur Lanjutan:

1. **`sparkle:criticalUpdate`**:
   Jika diaktifkan, dialog pembaruan tidak dapat dilewati (*force update*). Sangat berguna saat ada perbaikan celah keamanan kritis atau perubahan breaking API di backend.

2. **`sparkle:edSignature`**:
   Tanda tangan kriptografi menggunakan algoritma **Ed25519**. Mencegah serangan *man-in-the-middle* (MITM) dengan memastikan file unduhan tidak dimodifikasi oleh peretas.

3. **`sparkle:phasedRolloutInterval`**:
   Peluncuran pembaruan secara bertahap kepada pengguna dalam rentang waktu tertentu (misalnya `86400` detik = 1 hari) untuk memantau stabilitas rilis baru.

4. **`sparkle:releaseNotesLink`**:
   Catatan perubahan yang dapat berupa tautan URL ke changelog eksternal atau catatan rilis langsung (HTML) di dalam blok `<![CDATA[ ... ]]>`.
