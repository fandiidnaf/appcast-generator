import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../models/appcast_enclosure.dart';
import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';
import '../models/delta_update.dart';
import '../models/preset_profile.dart';
import '../../../core/utils/date_formatter.dart';

/// Robust DOM-based parser for Appcast feeds.
class XmlParserService {
  XmlParserService._();

  static const _uuid = Uuid();

  static (AppcastFeed, List<AppcastItem>) parse(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final channel = document.findAllElements('channel').firstOrNull;

    var feed = const AppcastFeed();
    if (channel != null) {
      final title = channel.findElements('title').firstOrNull?.innerText ?? '';
      final link = channel.findElements('link').firstOrNull?.innerText ?? '';
      final desc = channel.findElements('description').firstOrNull?.innerText ?? '';
      final lang = channel.findElements('language').firstOrNull?.innerText ?? 'en';

      String atomLink = '';
      for (final el in channel.findElements('atom:link')) {
        final rel = el.getAttribute('rel');
        if (rel == 'self') {
          atomLink = el.getAttribute('href') ?? '';
          break;
        }
      }

      // Check if enclosure tags use sparkle:version (Flutter Upgrader signature)
      bool hasEnclosureVersion = false;
      for (final enc in document.findAllElements('enclosure')) {
        if (enc.getAttribute('sparkle:version') != null) {
          hasEnclosureVersion = true;
          break;
        }
      }

      feed = feed.copyWith(
        title: title.isNotEmpty ? title : feed.title,
        link: link.isNotEmpty ? link : feed.link,
        description: desc,
        language: lang,
        atomLink: atomLink,
        preset: hasEnclosureVersion ? PresetProfile.flutterUpgrader : PresetProfile.sparkle2,
      );
    }

    final items = <AppcastItem>[];
    for (final itemEl in document.findAllElements('item')) {
      final item = _parseItem(itemEl);
      if (item != null) items.add(item);
    }

    return (feed, items);
  }

  static AppcastItem? _parseItem(XmlElement itemEl) {
    try {
      final title = itemEl.findElements('title').firstOrNull?.innerText ?? '';
      final pubDateStr = itemEl.findElements('pubDate').firstOrNull?.innerText ?? '';
      final pubDate = DateFormatter.parseRfc822(pubDateStr);

      String version = itemEl.findElements('sparkle:version').firstOrNull?.innerText ?? '';
      String shortVer = itemEl.findElements('sparkle:shortVersionString').firstOrNull?.innerText ?? '';
      final minSys = itemEl.findElements('sparkle:minimumSystemVersion').firstOrNull?.innerText ?? '';
      final maxSys = itemEl.findElements('sparkle:maximumSystemVersion').firstOrNull?.innerText ?? '';
      final minAuto = itemEl.findElements('sparkle:minimumAutoupdateVersion').firstOrNull?.innerText ?? '';
      final channel = itemEl.findElements('sparkle:channel').firstOrNull?.innerText ?? 'stable';
      final critical = itemEl.findElements('sparkle:criticalUpdate').isNotEmpty;
      final infoOnly = itemEl.findElements('sparkle:informationalUpdate').isNotEmpty;
      final phaseGroup = itemEl.findElements('sparkle:phasedRolloutInterval').firstOrNull?.innerText ?? '';

      // Release Notes
      String rnUrl = '';
      String rnInline = '';
      final rnEl = itemEl.findElements('sparkle:releaseNotesLink').firstOrNull;
      if (rnEl != null) {
        final cdata = rnEl.children.whereType<XmlCDATA>().firstOrNull;
        if (cdata != null) {
          rnInline = cdata.value.trim();
        } else {
          final text = rnEl.innerText.trim();
          if (text.startsWith('http')) {
            rnUrl = text;
          } else {
            rnInline = text;
          }
        }
      }

      // Enclosures
      final enclosures = <AppcastEnclosure>[];
      for (final encEl in itemEl.children.whereType<XmlElement>().where((e) => e.name.local == 'enclosure')) {
        final url = encEl.getAttribute('url') ?? '';
        final len = int.tryParse(encEl.getAttribute('length') ?? '') ?? 0;
        final mime = encEl.getAttribute('type') ?? 'application/octet-stream';
        final os = encEl.getAttribute('sparkle:os') ?? 'all';
        final arch = encEl.getAttribute('sparkle:arch') ?? 'all';
        final edSig = encEl.getAttribute('sparkle:edSignature') ?? '';
        final dsaSig = encEl.getAttribute('sparkle:dsaSignature') ?? '';
        final instType = encEl.getAttribute('sparkle:installationType') ?? '';

        // If version wasn't found at item level, check enclosure attribute
        final encVer = encEl.getAttribute('sparkle:version');
        if (version.isEmpty && encVer != null) version = encVer;

        final encShortVer = encEl.getAttribute('sparkle:shortVersionString');
        if (shortVer.isEmpty && encShortVer != null) shortVer = encShortVer;

        enclosures.add(AppcastEnclosure(
          id: _uuid.v4(),
          url: url,
          fileLength: len,
          mimeType: mime,
          os: os,
          arch: arch,
          edSignature: edSig,
          dsaSignature: dsaSig,
          installationType: instType,
        ));
      }

      // Deltas
      final deltas = <DeltaUpdate>[];
      for (final deltaParent in itemEl.findElements('sparkle:deltas')) {
        for (final dEnc in deltaParent.findElements('enclosure')) {
          deltas.add(DeltaUpdate(
            id: _uuid.v4(),
            fromVersion: dEnc.getAttribute('sparkle:deltaFrom') ?? '',
            url: dEnc.getAttribute('url') ?? '',
            fileLength: int.tryParse(dEnc.getAttribute('length') ?? '') ?? 0,
            mimeType: dEnc.getAttribute('type') ?? 'application/octet-stream',
            edSignature: dEnc.getAttribute('sparkle:edSignature') ?? '',
          ));
        }
      }

      return AppcastItem(
        id: _uuid.v4(),
        title: title,
        version: version,
        shortVersionString: shortVer.isNotEmpty ? shortVer : version,
        pubDate: pubDate,
        releaseNotesUrl: rnUrl,
        releaseNotesInline: rnInline,
        channel: channel,
        minimumSystemVersion: minSys,
        maximumSystemVersion: maxSys,
        minimumAutoUpdateVersion: minAuto,
        criticalUpdate: critical,
        informationalUpdate: infoOnly,
        phasedRolloutInterval: phaseGroup,
        enclosures: enclosures,
        deltas: deltas,
        isExpanded: true,
      );
    } catch (_) {
      return null;
    }
  }
}
