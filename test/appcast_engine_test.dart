import 'package:flutter_test/flutter_test.dart';
import 'package:appcast_generator/src/features/appcast/models/appcast_feed.dart';
import 'package:appcast_generator/src/features/appcast/models/appcast_item.dart';
import 'package:appcast_generator/src/features/appcast/models/appcast_enclosure.dart';
import 'package:appcast_generator/src/features/appcast/models/preset_profile.dart';
import 'package:appcast_generator/src/features/appcast/services/xml_generator_service.dart';
import 'package:appcast_generator/src/features/appcast/services/xml_parser_service.dart';
import 'package:appcast_generator/src/features/appcast/services/schema_validator.dart';

void main() {
  group('Appcast Engine Tests', () {
    test('Generates Sparkle 2 XML with multiple enclosures', () {
      final feed = const AppcastFeed(
        title: 'Acme App Updates',
        link: 'https://acme.com',
        atomLink: 'https://acme.com/appcast.xml',
        preset: PresetProfile.sparkle2,
      );

      final item = AppcastItem(
        id: '1',
        title: 'Release 2.5.0',
        version: '2.5.0',
        shortVersionString: '2.5.0',
        pubDate: DateTime.utc(2026, 1, 15, 12, 0, 0),
        criticalUpdate: true,
        enclosures: const [
          AppcastEnclosure(
            id: 'e1',
            url: 'https://acme.com/acme-mac-arm64.dmg',
            fileLength: 52428800,
            os: 'macos',
            arch: 'arm64',
            edSignature: 'sig_arm64_base64',
          ),
          AppcastEnclosure(
            id: 'e2',
            url: 'https://acme.com/acme-win-x64.exe',
            fileLength: 62914560,
            os: 'windows',
            arch: 'x86_64',
            edSignature: 'sig_win_base64',
          ),
        ],
      );

      final xml = XmlGeneratorService.generate(feed, [item]);

      expect(xml, contains('<sparkle:version>2.5.0</sparkle:version>'));
      expect(xml, contains('<sparkle:criticalUpdate/>'));
      expect(xml, contains('sparkle:arch="arm64"'));
      expect(xml, contains('sparkle:arch="x86_64"'));
      expect(xml, contains('sparkle:edSignature="sig_arm64_base64"'));
    });

    test('Generates Flutter Upgrader XML with enclosure attributes', () {
      final feed = const AppcastFeed(
        title: 'Flutter Desktop Updates',
        preset: PresetProfile.flutterUpgrader,
      );

      final item = AppcastItem(
        id: '2',
        title: 'Version 3.0.0',
        version: '3.0.0',
        shortVersionString: '3.0.0',
        pubDate: DateTime.utc(2026, 2, 1, 0, 0, 0),
        enclosures: const [
          AppcastEnclosure(
            id: 'e3',
            url: 'https://acme.com/app.zip',
            fileLength: 10485760,
            os: 'windows',
          ),
        ],
      );

      final xml = XmlGeneratorService.generate(feed, [item]);

      expect(xml, contains('<enclosure'));
      expect(xml, contains('sparkle:version="3.0.0"'));
      expect(xml, contains('sparkle:os="windows"'));
      // In Flutter Upgrader, sparkle:version is attribute on enclosure, not standalone tag
      expect(xml, isNot(contains('<sparkle:version>3.0.0</sparkle:version>')));
    });

    test('Parses XML roundtrip correctly', () {
      const sourceXml = '''<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Sample Feed</title>
    <link>https://example.com</link>
    <description>Sample Description</description>
    <language>en</language>
    <item>
      <title>v1.2.0</title>
      <pubDate>Mon, 01 Jan 2026 00:00:00 +0000</pubDate>
      <sparkle:version>1.2.0</sparkle:version>
      <enclosure url="https://example.com/app.dmg" length="12345" type="application/octet-stream" sparkle:edSignature="sample_sig"/>
    </item>
  </channel>
</rss>''';

      final (feed, items) = XmlParserService.parse(sourceXml);

      expect(feed.title, 'Sample Feed');
      expect(feed.link, 'https://example.com');
      expect(items.length, 1);
      expect(items.first.version, '1.2.0');
      expect(items.first.enclosures.length, 1);
      expect(items.first.enclosures.first.url, 'https://example.com/app.dmg');
      expect(items.first.enclosures.first.edSignature, 'sample_sig');
    });

    test('SchemaValidator detects invalid URLs and missing version', () {
      final feed = const AppcastFeed(title: '', link: 'invalid-url');
      final item = AppcastItem(
        id: 'bad',
        version: '',
        pubDate: DateTime.now(),
        enclosures: const [
          AppcastEnclosure(id: 'bad_enc', url: 'http://insecure.com'),
        ],
      );

      final issues = SchemaValidator.validate(feed, [item]);

      expect(issues.any((i) => i.message.contains('Feed title is empty')), isTrue);
      expect(issues.any((i) => i.message.contains('is missing a version')), isTrue);
      expect(issues.any((i) => i.message.contains('does not use HTTPS')), isTrue);
    });
  });
}
