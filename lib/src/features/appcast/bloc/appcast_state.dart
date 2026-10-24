import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';
import '../services/schema_validator.dart';

class AppcastState {
  final AppcastFeed feed;
  final List<AppcastItem> items;
  final String generatedXml;
  final List<ValidationIssue> issues;
  final String? importError;

  const AppcastState({
    this.feed = const AppcastFeed(),
    this.items = const [],
    this.generatedXml = '',
    this.issues = const [],
    this.importError,
  });

  AppcastState copyWith({
    AppcastFeed? feed,
    List<AppcastItem>? items,
    String? generatedXml,
    List<ValidationIssue>? issues,
    String? Function()? importError,
  }) {
    return AppcastState(
      feed: feed ?? this.feed,
      items: items ?? this.items,
      generatedXml: generatedXml ?? this.generatedXml,
      issues: issues ?? this.issues,
      importError: importError != null ? importError() : this.importError,
    );
  }
}
