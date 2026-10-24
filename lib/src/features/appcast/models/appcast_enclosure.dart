class AppcastEnclosure {
  final String id;
  final String url;
  final int fileLength;
  final String mimeType;
  final String os; // 'macos', 'windows', 'linux', 'android', 'ios', 'all'
  final String arch; // 'arm64', 'x86_64', 'universal', 'all'
  final String edSignature;
  final String dsaSignature;
  final String installationType; // 'package', 'application', 'guided-installer'

  const AppcastEnclosure({
    required this.id,
    this.url = '',
    this.fileLength = 0,
    this.mimeType = 'application/octet-stream',
    this.os = 'all',
    this.arch = 'all',
    this.edSignature = '',
    this.dsaSignature = '',
    this.installationType = '',
  });

  AppcastEnclosure copyWith({
    String? id,
    String? url,
    int? fileLength,
    String? mimeType,
    String? os,
    String? arch,
    String? edSignature,
    String? dsaSignature,
    String? installationType,
  }) {
    return AppcastEnclosure(
      id: id ?? this.id,
      url: url ?? this.url,
      fileLength: fileLength ?? this.fileLength,
      mimeType: mimeType ?? this.mimeType,
      os: os ?? this.os,
      arch: arch ?? this.arch,
      edSignature: edSignature ?? this.edSignature,
      dsaSignature: dsaSignature ?? this.dsaSignature,
      installationType: installationType ?? this.installationType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'fileLength': fileLength,
    'mimeType': mimeType,
    'os': os,
    'arch': arch,
    'edSignature': edSignature,
    'dsaSignature': dsaSignature,
    'installationType': installationType,
  };

  factory AppcastEnclosure.fromJson(Map<String, dynamic> json) => AppcastEnclosure(
    id: json['id'] as String? ?? '',
    url: json['url'] as String? ?? '',
    fileLength: json['fileLength'] as int? ?? 0,
    mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
    os: json['os'] as String? ?? 'all',
    arch: json['arch'] as String? ?? 'all',
    edSignature: json['edSignature'] as String? ?? '',
    dsaSignature: json['dsaSignature'] as String? ?? '',
    installationType: json['installationType'] as String? ?? '',
  );
}
