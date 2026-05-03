// lib/models/appcast_item.dart

class AppcastItem {
  String id;
  String title;
  String version; // version string e.g. "1.2.3"
  String shortVersionString; // human-readable e.g. "1.2.3"
  int buildNumber;
  String releaseNotesUrl; // external URL for release notes
  String releaseNotesInline; // inline HTML release notes
  String downloadUrl;
  String mimeType;
  int fileLength; // bytes
  String signature; // DSA/EdDSA signature
  String signatureAlgorithm; // dsa or ed25519
  DateTime pubDate;
  String minimumSystemVersion;
  String maximumSystemVersion;
  String minimumAutoUpdateVersion;
  bool criticalUpdate;
  String phaseGroup; // for phased rollout 1-7 days
  String channel; // beta, stable, nightly
  bool informationalUpdate; // link-only, no direct download
  String installationType; // package, tarball, dmg, etc.
  String os; // macos, windows, linux, ios, android, all
  List<DeltaUpdate> deltas;
  bool isExpanded; // UI state

  AppcastItem({
    required this.id,
    this.title = '',
    this.version = '',
    this.shortVersionString = '',
    this.buildNumber = 0,
    this.releaseNotesUrl = '',
    this.releaseNotesInline = '',
    this.downloadUrl = '',
    this.mimeType = 'application/octet-stream',
    this.fileLength = 0,
    this.signature = '',
    this.signatureAlgorithm = 'ed25519',
    required this.pubDate,
    this.minimumSystemVersion = '',
    this.maximumSystemVersion = '',
    this.minimumAutoUpdateVersion = '',
    this.criticalUpdate = false,
    this.phaseGroup = '',
    this.channel = 'stable',
    this.informationalUpdate = false,
    this.installationType = '',
    this.os = 'all',
    List<DeltaUpdate>? deltas,
    this.isExpanded = true,
  }) : deltas = deltas ?? [];

  AppcastItem copyWith({
    String? id,
    String? title,
    String? version,
    String? shortVersionString,
    int? buildNumber,
    String? releaseNotesUrl,
    String? releaseNotesInline,
    String? downloadUrl,
    String? mimeType,
    int? fileLength,
    String? signature,
    String? signatureAlgorithm,
    DateTime? pubDate,
    String? minimumSystemVersion,
    String? maximumSystemVersion,
    String? minimumAutoUpdateVersion,
    bool? criticalUpdate,
    String? phaseGroup,
    String? channel,
    bool? informationalUpdate,
    String? installationType,
    String? os,
    List<DeltaUpdate>? deltas,
    bool? isExpanded,
  }) {
    return AppcastItem(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      shortVersionString: shortVersionString ?? this.shortVersionString,
      buildNumber: buildNumber ?? this.buildNumber,
      releaseNotesUrl: releaseNotesUrl ?? this.releaseNotesUrl,
      releaseNotesInline: releaseNotesInline ?? this.releaseNotesInline,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      mimeType: mimeType ?? this.mimeType,
      fileLength: fileLength ?? this.fileLength,
      signature: signature ?? this.signature,
      signatureAlgorithm: signatureAlgorithm ?? this.signatureAlgorithm,
      pubDate: pubDate ?? this.pubDate,
      minimumSystemVersion: minimumSystemVersion ?? this.minimumSystemVersion,
      maximumSystemVersion: maximumSystemVersion ?? this.maximumSystemVersion,
      minimumAutoUpdateVersion:
          minimumAutoUpdateVersion ?? this.minimumAutoUpdateVersion,
      criticalUpdate: criticalUpdate ?? this.criticalUpdate,
      phaseGroup: phaseGroup ?? this.phaseGroup,
      channel: channel ?? this.channel,
      informationalUpdate: informationalUpdate ?? this.informationalUpdate,
      installationType: installationType ?? this.installationType,
      os: os ?? this.os,
      deltas: deltas ?? this.deltas,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class DeltaUpdate {
  String fromVersion;
  String downloadUrl;
  int fileLength;
  String signature;
  String mimeType;

  DeltaUpdate({
    this.fromVersion = '',
    this.downloadUrl = '',
    this.fileLength = 0,
    this.signature = '',
    this.mimeType = 'application/octet-stream',
  });
}

class AppcastFeedConfig {
  String title;
  String description;
  String link;
  String language;
  String atomLink; // self-reference URL of this appcast
  bool sparkle; // use sparkle namespace
  bool upgraderCompatible; // add extra tags for flutter upgrader package

  AppcastFeedConfig({
    this.title = 'My App Updates',
    this.description = 'Latest versions of My App',
    this.link = 'https://example.com',
    this.language = 'en',
    this.atomLink = '',
    this.sparkle = true,
    this.upgraderCompatible = true,
  });

  AppcastFeedConfig copyWith({
    String? title,
    String? description,
    String? link,
    String? language,
    String? atomLink,
    bool? sparkle,
    bool? upgraderCompatible,
  }) {
    return AppcastFeedConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      language: language ?? this.language,
      atomLink: atomLink ?? this.atomLink,
      sparkle: sparkle ?? this.sparkle,
      upgraderCompatible: upgraderCompatible ?? this.upgraderCompatible,
    );
  }
}
