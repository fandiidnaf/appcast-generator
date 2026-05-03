# 🛰️ Appcast Generator

**Generate Sparkle / flutter_upgrader compatible `appcast.xml` feeds with a beautiful web UI.**

Live editor → real-time XML preview → one-click download.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Feed Configuration** | Title, description, link, language, Atom self-link |
| **Sparkle Namespace** | Full `sparkle:` attribute support |
| **flutter_upgrader compatible** | Enclosure format optimized for the upgrader package |
| **Multiple releases** | Add, reorder (drag & drop), duplicate, delete |
| **Channels** | stable, beta, alpha, nightly |
| **Target OS** | all, macOS, Windows, Linux, iOS, Android |
| **Signatures** | EdDSA (ed25519) and DSA (legacy) |
| **Critical updates** | `sparkle:criticalUpdate` flag |
| **Informational updates** | Link-only updates |
| **Phased rollout** | 1–7 day rollout via `sparkle:phasedRolloutInterval` |
| **Delta updates** | Multiple delta patches per release |
| **System version** | min/max system version constraints |
| **Release notes** | External URL or inline HTML (CDATA) |
| **Syntax highlighting** | Real-time colored XML preview |
| **Import XML** | Paste existing appcast to edit |
| **Download** | One-click `appcast.xml` download |
| **Copy** | Copy to clipboard |
| **Responsive** | Works on desktop and tablet |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10.0
- Chrome browser (for web development)

### Run locally

```bash
# Clone this repo
git clone https://github.com/yourname/appcast_generator.git
cd appcast_generator

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Or run on all web
flutter run -d web-server --web-port 8080
```

### Build for production

```bash
flutter build web --release --base-href /
```

Output is in `build/web/` — deploy to any static host.

---

## 🌐 Free Hosting Options

| Platform | Notes |
|---|---|
| **Vercel** | `vercel --prod` after `flutter build web` |
| **Netlify** | Drag & drop `build/web/` folder |
| **GitHub Pages** | Push `build/web/` to `gh-pages` branch |
| **Firebase Hosting** | `firebase deploy` |
| **Cloudflare Pages** | Connect repo, build command: `flutter build web` |

### Deploy to GitHub Pages (automatic)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build web --release --base-href /appcast_generator/
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

---

## 📦 Usage with flutter_upgrader

After hosting your `appcast.xml`, use it in your Flutter app:

```dart
// pubspec.yaml
dependencies:
  upgrader: ^10.0.0
```

```dart
// main.dart
import 'package:upgrader/upgrader.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UpgradeAlert(
        upgrader: Upgrader(
          appcastURL: 'https://yoursite.com/appcast.xml',
          // Optional: only show updates for a specific channel
          // appcastChannel: 'beta',
        ),
        child: MyHomePage(),
      ),
    );
  }
}
```

### Appcast URL tips

- Host at a memorable, stable URL (e.g. `https://yourapp.com/appcast.xml`)
- Use HTTPS always
- Set `Content-Type: application/xml` on your server
- The Atom self-link in Feed Config should match the hosting URL

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── appcast_item.dart        # Data models (AppcastItem, AppcastFeedConfig)
│   └── appcast_provider.dart    # State management + XML generator + parser
├── screens/
│   └── home_screen.dart         # Main screen with editor + preview layout
├── utils/
│   ├── theme.dart               # Colors, typography, Material theme
│   └── download_helper.dart     # Web download + clipboard utilities
└── widgets/
    ├── appcast_item_card.dart    # Per-release editor card (Basic/Advanced/Deltas tabs)
    ├── feed_config_panel.dart    # Feed-level configuration panel
    ├── form_field_widget.dart    # Reusable form components
    └── xml_preview_panel.dart   # Syntax-highlighted live XML preview
```

---

## 📄 Sample Output

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
    xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>My App Updates</title>
    <link>https://example.com</link>
    <description>Latest versions of My App</description>
    <language>en</language>
    <atom:link href="https://example.com/appcast.xml" rel="self" type="application/rss+xml"/>

    <item>
      <title>Version 2.0.0</title>
      <pubDate>Thu, 15 Jan 2025 00:00:00 +0000</pubDate>
      <enclosure
        url="https://example.com/app-2.0.0.zip"
        length="10485760"
        type="application/zip"
        sparkle:version="2.0.0"
        sparkle:shortVersionString="2.0.0"
        sparkle:edSignature="YOUR_SIGNATURE_HERE"
      />
      <sparkle:minimumSystemVersion>10.14</sparkle:minimumSystemVersion>
      <sparkle:criticalUpdate/>
      <sparkle:releaseNotesLink>https://example.com/changelog/2.0.0</sparkle:releaseNotesLink>
    </item>

  </channel>
</rss>
```

---

## 🧩 Dependencies

```yaml
dependencies:
  provider: ^6.1.1        # State management
  google_fonts: ^6.1.0    # Plus Jakarta Sans + JetBrains Mono
  universal_html: ^2.2.4  # Web download
  file_picker: ^8.0.3     # File import
  uuid: ^4.3.3            # Unique IDs
  intl: ^0.19.0           # Date formatting
  xml: ^6.5.0             # XML parsing
  crypto: ^3.0.3          # Hash utilities
  path: ^1.9.0            # Path utilities
```

---

## 📝 License

MIT — free to use, modify, and deploy.
