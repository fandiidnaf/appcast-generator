import 'preset_profile.dart';

class AppcastFeed {
  final String title;
  final String description;
  final String link;
  final String language;
  final String atomLink;
  final PresetProfile preset;

  const AppcastFeed({
    this.title = 'My App Updates',
    this.description = 'Latest version updates and changelogs',
    this.link = 'https://example.com',
    this.language = 'en',
    this.atomLink = '',
    this.preset = PresetProfile.sparkle2,
  });

  AppcastFeed copyWith({
    String? title,
    String? description,
    String? link,
    String? language,
    String? atomLink,
    PresetProfile? preset,
  }) {
    return AppcastFeed(
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      language: language ?? this.language,
      atomLink: atomLink ?? this.atomLink,
      preset: preset ?? this.preset,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'link': link,
    'language': language,
    'atomLink': atomLink,
    'preset': preset.name,
  };

  factory AppcastFeed.fromJson(Map<String, dynamic> json) => AppcastFeed(
    title: json['title'] as String? ?? 'My App Updates',
    description: json['description'] as String? ?? '',
    link: json['link'] as String? ?? 'https://example.com',
    language: json['language'] as String? ?? 'en',
    atomLink: json['atomLink'] as String? ?? '',
    preset: PresetProfile.values.firstWhere(
      (p) => p.name == json['preset'],
      orElse: () => PresetProfile.sparkle2,
    ),
  );
}
