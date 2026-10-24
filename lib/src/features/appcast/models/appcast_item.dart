import 'appcast_enclosure.dart';
import 'delta_update.dart';

class AppcastItem {
  final String id;
  final String title;
  final String version;
  final String shortVersionString;
  final int buildNumber;
  final DateTime pubDate;
  final String releaseNotesUrl;
  final String releaseNotesInline;
  final String releaseNotesFormat; // 'html', 'markdown', 'plain-text'
  final String channel; // 'stable', 'beta', 'alpha', 'nightly'
  final String minimumSystemVersion;
  final String maximumSystemVersion;
  final String minimumAutoUpdateVersion;
  final bool criticalUpdate;
  final bool informationalUpdate;
  final String phasedRolloutInterval; // In seconds or days
  final List<AppcastEnclosure> enclosures;
  final List<DeltaUpdate> deltas;
  final bool isExpanded;

  const AppcastItem({
    required this.id,
    this.title = '',
    this.version = '',
    this.shortVersionString = '',
    this.buildNumber = 0,
    required this.pubDate,
    this.releaseNotesUrl = '',
    this.releaseNotesInline = '',
    this.releaseNotesFormat = 'html',
    this.channel = 'stable',
    this.minimumSystemVersion = '',
    this.maximumSystemVersion = '',
    this.minimumAutoUpdateVersion = '',
    this.criticalUpdate = false,
    this.informationalUpdate = false,
    this.phasedRolloutInterval = '',
    this.enclosures = const [],
    this.deltas = const [],
    this.isExpanded = true,
  });

  AppcastItem copyWith({
    String? id,
    String? title,
    String? version,
    String? shortVersionString,
    int? buildNumber,
    DateTime? pubDate,
    String? releaseNotesUrl,
    String? releaseNotesInline,
    String? releaseNotesFormat,
    String? channel,
    String? minimumSystemVersion,
    String? maximumSystemVersion,
    String? minimumAutoUpdateVersion,
    bool? criticalUpdate,
    bool? informationalUpdate,
    String? phasedRolloutInterval,
    List<AppcastEnclosure>? enclosures,
    List<DeltaUpdate>? deltas,
    bool? isExpanded,
  }) {
    return AppcastItem(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      shortVersionString: shortVersionString ?? this.shortVersionString,
      buildNumber: buildNumber ?? this.buildNumber,
      pubDate: pubDate ?? this.pubDate,
      releaseNotesUrl: releaseNotesUrl ?? this.releaseNotesUrl,
      releaseNotesInline: releaseNotesInline ?? this.releaseNotesInline,
      releaseNotesFormat: releaseNotesFormat ?? this.releaseNotesFormat,
      channel: channel ?? this.channel,
      minimumSystemVersion: minimumSystemVersion ?? this.minimumSystemVersion,
      maximumSystemVersion: maximumSystemVersion ?? this.maximumSystemVersion,
      minimumAutoUpdateVersion: minimumAutoUpdateVersion ?? this.minimumAutoUpdateVersion,
      criticalUpdate: criticalUpdate ?? this.criticalUpdate,
      informationalUpdate: informationalUpdate ?? this.informationalUpdate,
      phasedRolloutInterval: phasedRolloutInterval ?? this.phasedRolloutInterval,
      enclosures: enclosures ?? this.enclosures,
      deltas: deltas ?? this.deltas,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'version': version,
    'shortVersionString': shortVersionString,
    'buildNumber': buildNumber,
    'pubDate': pubDate.toIso8601String(),
    'releaseNotesUrl': releaseNotesUrl,
    'releaseNotesInline': releaseNotesInline,
    'releaseNotesFormat': releaseNotesFormat,
    'channel': channel,
    'minimumSystemVersion': minimumSystemVersion,
    'maximumSystemVersion': maximumSystemVersion,
    'minimumAutoUpdateVersion': minimumAutoUpdateVersion,
    'criticalUpdate': criticalUpdate,
    'informationalUpdate': informationalUpdate,
    'phasedRolloutInterval': phasedRolloutInterval,
    'enclosures': enclosures.map((e) => e.toJson()).toList(),
    'deltas': deltas.map((d) => d.toJson()).toList(),
    'isExpanded': isExpanded,
  };

  factory AppcastItem.fromJson(Map<String, dynamic> json) => AppcastItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    version: json['version'] as String? ?? '',
    shortVersionString: json['shortVersionString'] as String? ?? '',
    buildNumber: json['buildNumber'] as int? ?? 0,
    pubDate: json['pubDate'] != null ? DateTime.parse(json['pubDate'] as String) : DateTime.now(),
    releaseNotesUrl: json['releaseNotesUrl'] as String? ?? '',
    releaseNotesInline: json['releaseNotesInline'] as String? ?? '',
    releaseNotesFormat: json['releaseNotesFormat'] as String? ?? 'html',
    channel: json['channel'] as String? ?? 'stable',
    minimumSystemVersion: json['minimumSystemVersion'] as String? ?? '',
    maximumSystemVersion: json['maximumSystemVersion'] as String? ?? '',
    minimumAutoUpdateVersion: json['minimumAutoUpdateVersion'] as String? ?? '',
    criticalUpdate: json['criticalUpdate'] as bool? ?? false,
    informationalUpdate: json['informationalUpdate'] as bool? ?? false,
    phasedRolloutInterval: json['phasedRolloutInterval'] as String? ?? '',
    enclosures: (json['enclosures'] as List<dynamic>?)
            ?.map((e) => AppcastEnclosure.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    deltas: (json['deltas'] as List<dynamic>?)
            ?.map((d) => DeltaUpdate.fromJson(d as Map<String, dynamic>))
            .toList() ??
        const [],
    isExpanded: json['isExpanded'] as bool? ?? true,
  );
}
