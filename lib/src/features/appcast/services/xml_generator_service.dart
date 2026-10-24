import 'package:xml/xml.dart';
import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';
import '../models/preset_profile.dart';
import '../../../core/utils/date_formatter.dart';

/// Builds well-formed, standards-compliant Appcast RSS 2.0 XML using package:xml DOM.
class XmlGeneratorService {
  XmlGeneratorService._();

  static const String sparkleNs = 'http://www.andymatuschak.org/xml-namespaces/sparkle';
  static const String dcNs = 'http://purl.org/dc/elements/1.1/';
  static const String atomNs = 'http://www.w3.org/2005/Atom';

  static String generate(AppcastFeed feed, List<AppcastItem> items) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="utf-8"');

    final rootAttributes = <String, String>{
      'version': '2.0',
      'xmlns:sparkle': sparkleNs,
      'xmlns:dc': dcNs,
    };
    if (feed.atomLink.isNotEmpty) {
      rootAttributes['xmlns:atom'] = atomNs;
    }

    builder.element('rss', attributes: rootAttributes, nest: () {
      builder.element('channel', nest: () {
        builder.element('title', nest: feed.title);
        builder.element('link', nest: feed.link);
        if (feed.description.isNotEmpty) {
          builder.element('description', nest: feed.description);
        }
        builder.element('language', nest: feed.language);

        if (feed.atomLink.isNotEmpty) {
          builder.element('atom:link', attributes: {
            'href': feed.atomLink,
            'rel': 'self',
            'type': 'application/rss+xml',
          });
        }

        for (final item in items) {
          _buildItem(builder, feed.preset, item);
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  static void _buildItem(XmlBuilder builder, PresetProfile preset, AppcastItem item) {
    builder.element('item', nest: () {
      if (item.title.isNotEmpty) {
        builder.element('title', nest: item.title);
      }
      builder.element('pubDate', nest: DateFormatter.toRfc822(item.pubDate));

      // In Sparkle 2 / WinSparkle, versions appear as child tags
      if (preset != PresetProfile.flutterUpgrader) {
        if (item.version.isNotEmpty) {
          builder.element('sparkle:version', nest: item.version);
        }
        if (item.shortVersionString.isNotEmpty) {
          builder.element('sparkle:shortVersionString', nest: item.shortVersionString);
        }
      }

      if (item.minimumSystemVersion.isNotEmpty) {
        builder.element('sparkle:minimumSystemVersion', nest: item.minimumSystemVersion);
      }
      if (item.maximumSystemVersion.isNotEmpty) {
        builder.element('sparkle:maximumSystemVersion', nest: item.maximumSystemVersion);
      }
      if (item.minimumAutoUpdateVersion.isNotEmpty) {
        builder.element('sparkle:minimumAutoupdateVersion', nest: item.minimumAutoUpdateVersion);
      }
      if (item.channel.isNotEmpty && item.channel != 'stable') {
        builder.element('sparkle:channel', nest: item.channel);
      }
      if (item.criticalUpdate) {
        builder.element('sparkle:criticalUpdate');
      }
      if (item.informationalUpdate) {
        builder.element('sparkle:informationalUpdate');
      }
      if (item.phasedRolloutInterval.isNotEmpty) {
        builder.element('sparkle:phasedRolloutInterval', nest: item.phasedRolloutInterval);
      }
      if (item.releaseNotesUrl.isNotEmpty) {
        builder.element('sparkle:releaseNotesLink', nest: item.releaseNotesUrl);
      }
      if (item.releaseNotesInline.isNotEmpty) {
        builder.element('sparkle:releaseNotesLink', nest: () {
          builder.cdata(item.releaseNotesInline);
        });
      }

      // Enclosures
      for (final enc in item.enclosures) {
        final attrs = <String, String>{
          'url': enc.url,
          'length': enc.fileLength.toString(),
          'type': enc.mimeType.isNotEmpty ? enc.mimeType : 'application/octet-stream',
        };

        if (preset == PresetProfile.flutterUpgrader) {
          // Flutter Upgrader reads sparkle attributes off the enclosure tag
          if (item.version.isNotEmpty) attrs['sparkle:version'] = item.version;
          if (item.shortVersionString.isNotEmpty) {
            attrs['sparkle:shortVersionString'] = item.shortVersionString;
          }
          if (enc.os != 'all' && enc.os.isNotEmpty) {
            attrs['sparkle:os'] = enc.os;
          }
        } else {
          // Sparkle 2 / WinSparkle
          if (enc.os != 'all' && enc.os.isNotEmpty) {
            attrs['sparkle:os'] = enc.os;
          }
          if (enc.arch != 'all' && enc.arch.isNotEmpty) {
            attrs['sparkle:arch'] = enc.arch;
          }
          if (enc.installationType.isNotEmpty) {
            attrs['sparkle:installationType'] = enc.installationType;
          }
        }

        if (enc.edSignature.isNotEmpty) {
          attrs['sparkle:edSignature'] = enc.edSignature;
        } else if (enc.dsaSignature.isNotEmpty) {
          attrs['sparkle:dsaSignature'] = enc.dsaSignature;
        }

        builder.element('enclosure', attributes: attrs);
      }

      // Delta patches
      for (final delta in item.deltas) {
        builder.element('sparkle:deltas', nest: () {
          final deltaAttrs = <String, String>{
            'url': delta.url,
            'length': delta.fileLength.toString(),
            'type': delta.mimeType.isNotEmpty ? delta.mimeType : 'application/octet-stream',
            'sparkle:deltaFrom': delta.fromVersion,
          };
          if (delta.edSignature.isNotEmpty) {
            deltaAttrs['sparkle:edSignature'] = delta.edSignature;
          }
          builder.element('enclosure', attributes: deltaAttrs);
        });
      }
    });
  }
}
