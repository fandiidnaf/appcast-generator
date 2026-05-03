#  Appcast Generator

**Generate Sparkle / flutter_upgrader compatible `appcast.xml` feeds with a beautiful web UI.**

Live editor → real-time XML preview → one-click download.

---

##  Features

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

##  Sample Output

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

##  License

MIT — free to use, modify, and deploy.
