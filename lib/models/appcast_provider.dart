// lib/models/appcast_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'appcast_item.dart';

class AppcastProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  AppcastFeedConfig feedConfig = AppcastFeedConfig();
  List<AppcastItem> items = [];
  String _generatedXml = '';
  String _activeTab = 'editor';

  String get generatedXml => _generatedXml;
  String get activeTab => _activeTab;

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void updateFeedConfig(AppcastFeedConfig config) {
    feedConfig = config;
    _regenerate();
    notifyListeners();
  }

  void addItem() {
    items.insert(
      0,
      AppcastItem(
        id: _uuid.v4(),
        title: 'Version ${items.length + 1}.0.0',
        version: '${items.length + 1}.0.0',
        shortVersionString: '${items.length + 1}.0.0',
        buildNumber: (items.length + 1) * 100,
        pubDate: DateTime.now(),
        downloadUrl: 'https://example.com/app-${items.length + 1}.0.0.zip',
        mimeType: 'application/zip',
        fileLength: 10485760,
      ),
    );
    _regenerate();
    notifyListeners();
  }

  void updateItem(String id, AppcastItem updated) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      items[idx] = updated;
      _regenerate();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    items.removeWhere((e) => e.id == id);
    _regenerate();
    notifyListeners();
  }

  void reorderItems(int oldIdx, int newIdx) {
    if (oldIdx < newIdx) newIdx--;
    final item = items.removeAt(oldIdx);
    items.insert(newIdx, item);
    _regenerate();
    notifyListeners();
  }

  void toggleItemExpanded(String id) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(isExpanded: !items[idx].isExpanded);
      notifyListeners();
    }
  }

  void duplicateItem(String id) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final src = items[idx];
      final copy = src.copyWith(
        id: _uuid.v4(),
        title: '${src.title} (copy)',
        isExpanded: true,
      );
      items.insert(idx + 1, copy);
      _regenerate();
      notifyListeners();
    }
  }

  void _regenerate() {
    _generatedXml = AppcastXmlGenerator.generate(feedConfig, items);
  }

  String regenerateAndGet() {
    _regenerate();
    notifyListeners();
    return _generatedXml;
  }

  void loadFromXml(String xml) {
    try {
      final parsed = AppcastXmlParser.parse(xml);
      feedConfig = parsed.$1;
      items = parsed.$2;
      _regenerate();
      notifyListeners();
    } catch (e) {
      debugPrint('loadFromXml error: $e');
    }
  }
}

// ─── XML Generator ────────────────────────────────────────────────────────────
class AppcastXmlGenerator {
  static String generate(AppcastFeedConfig config, List<AppcastItem> items) {
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="utf-8"?>');

    final sparkleNs = config.sparkle
        ? '\n    xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"'
        : '';
    const dcNs = '\n    xmlns:dc="http://purl.org/dc/elements/1.1/"';
    final atomNs = config.atomLink.isNotEmpty
        ? '\n    xmlns:atom="http://www.w3.org/2005/Atom"'
        : '';

    buf.writeln('<rss version="2.0"$sparkleNs$dcNs$atomNs>');
    buf.writeln('  <channel>');
    buf.writeln('    <title>${_esc(config.title)}</title>');
    buf.writeln('    <link>${_esc(config.link)}</link>');
    buf.writeln('    <description>${_esc(config.description)}</description>');
    buf.writeln('    <language>${config.language}</language>');

    if (config.atomLink.isNotEmpty) {
      buf.writeln(
        '    <atom:link href="${_esc(config.atomLink)}" rel="self" type="application/rss+xml"/>',
      );
    }

    for (final item in items) {
      buf.writeln('');
      buf.writeln('    <item>');
      if (item.title.isNotEmpty)
        buf.writeln('      <title>${_esc(item.title)}</title>');
      buf.writeln('      <pubDate>${_rfc2822(item.pubDate)}</pubDate>');

      if (config.upgraderCompatible) {
        buf.writeln('      <enclosure');
        buf.writeln('        url="${_esc(item.downloadUrl)}"');
        if (item.fileLength > 0)
          buf.writeln('        length="${item.fileLength}"');
        buf.writeln('        type="${item.mimeType}"');
        if (config.sparkle) {
          if (item.version.isNotEmpty)
            buf.writeln('        sparkle:version="${_esc(item.version)}"');
          if (item.shortVersionString.isNotEmpty)
            buf.writeln(
              '        sparkle:shortVersionString="${_esc(item.shortVersionString)}"',
            );
          if (item.signature.isNotEmpty) {
            final sig = item.signatureAlgorithm == 'ed25519'
                ? 'sparkle:edSignature'
                : 'sparkle:dsaSignature';
            buf.writeln('        $sig="${_esc(item.signature)}"');
          }
          if (item.installationType.isNotEmpty)
            buf.writeln(
              '        sparkle:installationType="${item.installationType}"',
            );
          if (item.os != 'all' && item.os.isNotEmpty)
            buf.writeln('        sparkle:os="${item.os}"');
        }
        buf.writeln('      />');
      } else {
        buf.writeln(
          '      <enclosure url="${_esc(item.downloadUrl)}" length="${item.fileLength}" type="${item.mimeType}"/>',
        );
      }

      if (config.sparkle) {
        if (item.version.isNotEmpty && !config.upgraderCompatible)
          buf.writeln(
            '      <sparkle:version>${_esc(item.version)}</sparkle:version>',
          );
        if (item.shortVersionString.isNotEmpty && !config.upgraderCompatible)
          buf.writeln(
            '      <sparkle:shortVersionString>${_esc(item.shortVersionString)}</sparkle:shortVersionString>',
          );
        if (item.minimumSystemVersion.isNotEmpty)
          buf.writeln(
            '      <sparkle:minimumSystemVersion>${item.minimumSystemVersion}</sparkle:minimumSystemVersion>',
          );
        if (item.maximumSystemVersion.isNotEmpty)
          buf.writeln(
            '      <sparkle:maximumSystemVersion>${item.maximumSystemVersion}</sparkle:maximumSystemVersion>',
          );
        if (item.minimumAutoUpdateVersion.isNotEmpty)
          buf.writeln(
            '      <sparkle:minimumAutoupdateVersion>${item.minimumAutoUpdateVersion}</sparkle:minimumAutoupdateVersion>',
          );
        if (item.criticalUpdate) buf.writeln('      <sparkle:criticalUpdate/>');
        if (item.informationalUpdate)
          buf.writeln('      <sparkle:informationalUpdate/>');
        if (item.phaseGroup.isNotEmpty)
          buf.writeln(
            '      <sparkle:phasedRolloutInterval>${item.phaseGroup}</sparkle:phasedRolloutInterval>',
          );
        if (item.channel.isNotEmpty && item.channel != 'stable')
          buf.writeln(
            '      <sparkle:channel>${item.channel}</sparkle:channel>',
          );
        if (item.releaseNotesUrl.isNotEmpty)
          buf.writeln(
            '      <sparkle:releaseNotesLink>${_esc(item.releaseNotesUrl)}</sparkle:releaseNotesLink>',
          );
        if (item.releaseNotesInline.isNotEmpty)
          buf.writeln(
            '      <sparkle:releaseNotesLink><![CDATA[${item.releaseNotesInline}]]></sparkle:releaseNotesLink>',
          );
        if (item.buildNumber > 0)
          buf.writeln(
            '      <sparkle:version>${item.buildNumber}</sparkle:version>',
          );

        for (final delta in item.deltas) {
          buf.writeln('      <sparkle:deltas>');
          buf.writeln('        <enclosure');
          buf.writeln('          url="${_esc(delta.downloadUrl)}"');
          buf.writeln(
            '          sparkle:deltaFrom="${_esc(delta.fromVersion)}"',
          );
          if (delta.fileLength > 0)
            buf.writeln('          length="${delta.fileLength}"');
          buf.writeln('          type="${delta.mimeType}"');
          if (delta.signature.isNotEmpty)
            buf.writeln(
              '          sparkle:edSignature="${_esc(delta.signature)}"',
            );
          buf.writeln('        />');
          buf.writeln('      </sparkle:deltas>');
        }
      }

      buf.writeln('    </item>');
    }

    buf.writeln('  </channel>');
    buf.write('</rss>');
    return buf.toString();
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static String _rfc2822(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = dt.toUtc();
    return '${days[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')} '
        '${months[d.month - 1]} ${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')} +0000';
  }
}

// ─── XML Parser — lengkap ─────────────────────────────────────────────────────
class AppcastXmlParser {
  static (AppcastFeedConfig, List<AppcastItem>) parse(String xml) {
    final config = AppcastFeedConfig();

    // ── Feed-level fields ──
    config.title = _tag(xml, 'title') ?? config.title;
    config.link = _tag(xml, 'link') ?? config.link;
    config.description = _tag(xml, 'description') ?? config.description;
    config.language = _tag(xml, 'language') ?? config.language;

    // atom:link self href
    final atomHref = RegExp(
      r'<atom:link[^>]+href="([^"]*)"',
    ).firstMatch(xml)?.group(1);
    if (atomHref != null) config.atomLink = atomHref;

    // sparkle namespace present?
    config.sparkle = xml.contains('xmlns:sparkle') || xml.contains('sparkle:');

    // upgraderCompatible: heuristic — enclosure attrs on same element
    config.upgraderCompatible = RegExp(
      r'<enclosure[^/]*sparkle:version',
      dotAll: true,
    ).hasMatch(xml);

    // ── Items ──
    final items = <AppcastItem>[];
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);
    var idx = 0;
    for (final m in itemRegex.allMatches(xml)) {
      final item = _parseItem(m.group(1) ?? '', idx++);
      if (item != null) items.add(item);
    }

    return (config, items);
  }

  static AppcastItem? _parseItem(String xml, int idx) {
    try {
      // ── enclosure attributes ──
      final enclosureMatch = RegExp(
        r'<enclosure(.*?)/>',
        dotAll: true,
      ).firstMatch(xml);
      final encXml = enclosureMatch?.group(1) ?? '';

      String eAttr(String name) =>
          RegExp('$name="([^"]*)"').firstMatch(encXml)?.group(1) ?? '';

      final url = eAttr('url');
      final mimeType = eAttr('type');
      final length = int.tryParse(eAttr('length')) ?? 0;
      final version = eAttr('sparkle:version').isNotEmpty
          ? eAttr('sparkle:version')
          : eAttr('sparkle:shortVersionString');
      final shortVer = eAttr('sparkle:shortVersionString');
      final edSig = eAttr('sparkle:edSignature');
      final dsaSig = eAttr('sparkle:dsaSignature');
      final instType = eAttr('sparkle:installationType');
      final os = eAttr('sparkle:os');

      // ── sparkle child elements ──
      String? sTag(String name) => _tag(xml, 'sparkle:$name');

      final minSysVer = sTag('minimumSystemVersion') ?? '';
      final maxSysVer = sTag('maximumSystemVersion') ?? '';
      final minAutoVer = sTag('minimumAutoupdateVersion') ?? '';
      final phaseGroup = sTag('phasedRolloutInterval') ?? '';
      final channel = sTag('channel') ?? 'stable';

      // release notes — URL or inline CDATA
      String releaseNotesUrl = '';
      String releaseNotesInline = '';
      final rnMatch = RegExp(
        r'<sparkle:releaseNotesLink>(.*?)</sparkle:releaseNotesLink>',
        dotAll: true,
      ).firstMatch(xml);
      if (rnMatch != null) {
        final rnContent = rnMatch.group(1) ?? '';
        final cdataMatch = RegExp(
          r'<!\[CDATA\[(.*?)\]\]>',
          dotAll: true,
        ).firstMatch(rnContent);
        if (cdataMatch != null) {
          releaseNotesInline = cdataMatch.group(1)?.trim() ?? '';
        } else {
          final trimmed = rnContent.trim();
          if (trimmed.startsWith('http')) {
            releaseNotesUrl = trimmed;
          } else {
            releaseNotesInline = trimmed;
          }
        }
      }

      // build number — second sparkle:version (if upgraderCompatible puts it as child element)
      int buildNumber = 0;
      final svMatches = RegExp(
        r'<sparkle:version>(\d+)</sparkle:version>',
      ).allMatches(xml);
      if (svMatches.length >= 1) {
        buildNumber = int.tryParse(svMatches.last.group(1) ?? '') ?? 0;
      }

      // ── delta updates ──
      final deltas = <DeltaUpdate>[];
      final deltaRegex = RegExp(
        r'<sparkle:deltas>(.*?)</sparkle:deltas>',
        dotAll: true,
      );
      for (final dm in deltaRegex.allMatches(xml)) {
        final dXml = dm.group(1) ?? '';
        final dEncMatch = RegExp(
          r'<enclosure(.*?)/>',
          dotAll: true,
        ).firstMatch(dXml);
        if (dEncMatch != null) {
          final dx = dEncMatch.group(1) ?? '';
          String da(String n) =>
              RegExp('$n="([^"]*)"').firstMatch(dx)?.group(1) ?? '';
          deltas.add(
            DeltaUpdate(
              fromVersion: da('sparkle:deltaFrom'),
              downloadUrl: da('url'),
              fileLength: int.tryParse(da('length')) ?? 0,
              signature: da('sparkle:edSignature'),
              mimeType: da('type').isNotEmpty
                  ? da('type')
                  : 'application/octet-stream',
            ),
          );
        }
      }

      // ── pubDate ──
      final pubDateStr = _tag(xml, 'pubDate') ?? '';
      DateTime pubDate;
      try {
        pubDate = _parseRfc2822(pubDateStr);
      } catch (_) {
        pubDate = DateTime.now();
      }

      return AppcastItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_$idx',
        title: _tag(xml, 'title') ?? '',
        version: version,
        shortVersionString: shortVer.isNotEmpty ? shortVer : version,
        buildNumber: buildNumber,
        downloadUrl: url,
        mimeType: mimeType.isNotEmpty ? mimeType : 'application/zip',
        fileLength: length,
        signature: edSig.isNotEmpty ? edSig : dsaSig,
        signatureAlgorithm: edSig.isNotEmpty ? 'ed25519' : 'dsa',
        pubDate: pubDate,
        minimumSystemVersion: minSysVer,
        maximumSystemVersion: maxSysVer,
        minimumAutoUpdateVersion: minAutoVer,
        criticalUpdate: xml.contains('<sparkle:criticalUpdate'),
        informationalUpdate: xml.contains('<sparkle:informationalUpdate'),
        phaseGroup: phaseGroup,
        channel: channel.isNotEmpty ? channel : 'stable',
        releaseNotesUrl: releaseNotesUrl,
        releaseNotesInline: releaseNotesInline,
        installationType: instType,
        os: os.isNotEmpty ? os : 'all',
        deltas: deltas,
        isExpanded: true,
      );
    } catch (e) {
      debugPrint('_parseItem error: $e');
      return null;
    }
  }

  /// Extract text content of first matching tag
  static String? _tag(String xml, String tag) {
    final m = RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(xml);
    if (m == null) return null;
    final content = m.group(1)?.trim() ?? '';
    // strip CDATA if present
    final cdata = RegExp(
      r'<!\[CDATA\[(.*?)\]\]>',
      dotAll: true,
    ).firstMatch(content);
    return cdata != null ? cdata.group(1)?.trim() : content;
  }

  static DateTime _parseRfc2822(String s) {
    // Try ISO first
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // Parse RFC 2822: "Mon, 02 Jan 2006 15:04:05 +0000"
    try {
      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final parts = s.replaceAll(',', '').trim().split(RegExp(r'\s+'));
      // parts: [Mon, 02, Jan, 2006, 15:04:05, +0000]
      final day = int.parse(parts[1]);
      final month = months[parts[2]] ?? 1;
      final year = int.parse(parts[3]);
      final time = parts[4].split(':');
      final hour = int.parse(time[0]);
      final min = int.parse(time[1]);
      final sec = int.parse(time[2]);
      return DateTime.utc(year, month, day, hour, min, sec);
    } catch (_) {
      return DateTime.now();
    }
  }
}
