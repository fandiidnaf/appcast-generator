import '../models/appcast_feed.dart';
import '../models/appcast_item.dart';

enum ValidationSeverity { info, warning, error }

class ValidationIssue {
  final String message;
  final ValidationSeverity severity;
  final String? itemId;

  const ValidationIssue({
    required this.message,
    required this.severity,
    this.itemId,
  });
}

class SchemaValidator {
  SchemaValidator._();

  static List<ValidationIssue> validate(AppcastFeed feed, List<AppcastItem> items) {
    final issues = <ValidationIssue>[];

    // Feed validations
    if (feed.title.trim().isEmpty) {
      issues.add(const ValidationIssue(
        message: 'Feed title is empty',
        severity: ValidationSeverity.error,
      ));
    }

    if (feed.link.trim().isEmpty) {
      issues.add(const ValidationIssue(
        message: 'Feed website link is empty',
        severity: ValidationSeverity.error,
      ));
    } else {
      final uri = Uri.tryParse(feed.link);
      if (uri == null || !uri.hasScheme) {
        issues.add(const ValidationIssue(
          message: 'Feed website link is not a valid URL',
          severity: ValidationSeverity.warning,
        ));
      }
    }

    if (items.isEmpty) {
      issues.add(const ValidationIssue(
        message: 'Feed contains zero releases',
        severity: ValidationSeverity.warning,
      ));
    }

    // Items validations
    for (final item in items) {
      if (item.version.trim().isEmpty) {
        issues.add(ValidationIssue(
          message: 'Release "${item.title.isNotEmpty ? item.title : 'Untitled'}" is missing a version',
          severity: ValidationSeverity.error,
          itemId: item.id,
        ));
      }

      if (!item.informationalUpdate && item.enclosures.isEmpty) {
        issues.add(ValidationIssue(
          message: 'Release v${item.version} has no enclosures (download files)',
          severity: ValidationSeverity.warning,
          itemId: item.id,
        ));
      }

      for (final enc in item.enclosures) {
        if (enc.url.trim().isEmpty) {
          issues.add(ValidationIssue(
            message: 'Enclosure in v${item.version} has an empty download URL',
            severity: ValidationSeverity.error,
            itemId: item.id,
          ));
        } else {
          final uri = Uri.tryParse(enc.url);
          if (uri == null || !uri.hasScheme) {
            issues.add(ValidationIssue(
              message: 'Invalid enclosure URL in v${item.version}',
              severity: ValidationSeverity.error,
              itemId: item.id,
            ));
          } else if (uri.scheme != 'https') {
            issues.add(ValidationIssue(
              message: 'Enclosure URL in v${item.version} does not use HTTPS',
              severity: ValidationSeverity.warning,
              itemId: item.id,
            ));
          }
        }

        if (enc.edSignature.isEmpty && enc.dsaSignature.isEmpty) {
          issues.add(ValidationIssue(
            message: 'Enclosure in v${item.version} has no security signature (sparkle:edSignature)',
            severity: ValidationSeverity.info,
            itemId: item.id,
          ));
        }
      }
    }

    return issues;
  }
}
