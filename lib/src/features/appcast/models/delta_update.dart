class DeltaUpdate {
  final String id;
  final String fromVersion;
  final String url;
  final int fileLength;
  final String edSignature;
  final String mimeType;

  const DeltaUpdate({
    required this.id,
    this.fromVersion = '',
    this.url = '',
    this.fileLength = 0,
    this.edSignature = '',
    this.mimeType = 'application/octet-stream',
  });

  DeltaUpdate copyWith({
    String? id,
    String? fromVersion,
    String? url,
    int? fileLength,
    String? edSignature,
    String? mimeType,
  }) {
    return DeltaUpdate(
      id: id ?? this.id,
      fromVersion: fromVersion ?? this.fromVersion,
      url: url ?? this.url,
      fileLength: fileLength ?? this.fileLength,
      edSignature: edSignature ?? this.edSignature,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromVersion': fromVersion,
    'url': url,
    'fileLength': fileLength,
    'edSignature': edSignature,
    'mimeType': mimeType,
  };

  factory DeltaUpdate.fromJson(Map<String, dynamic> json) => DeltaUpdate(
    id: json['id'] as String? ?? '',
    fromVersion: json['fromVersion'] as String? ?? '',
    url: json['url'] as String? ?? '',
    fileLength: json['fileLength'] as int? ?? 0,
    edSignature: json['edSignature'] as String? ?? '',
    mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
  );
}
