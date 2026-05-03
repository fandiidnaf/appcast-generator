// lib/widgets/xml_preview_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appcast_provider.dart';
import '../utils/theme.dart';
import '../utils/download_helper.dart';

class XmlPreviewPanel extends StatefulWidget {
  const XmlPreviewPanel({super.key});

  @override
  State<XmlPreviewPanel> createState() => _XmlPreviewPanelState();
}

class _XmlPreviewPanelState extends State<XmlPreviewPanel> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppcastProvider>(
      builder: (ctx, provider, _) {
        final xml = provider.generatedXml;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Toolbar ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  const Text('appcast.xml',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      )),
                  const Spacer(),
                  // Line count
                  Text(
                    '${xml.split('\n').length} lines  •  ${_formatBytes(xml.length)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 12),
                  // Copy button
                  _ActionButton(
                    icon: _copied ? Icons.check : Icons.copy_outlined,
                    label: _copied ? 'Copied!' : 'Copy',
                    color: _copied ? AppTheme.success : AppTheme.primary,
                    onTap: () async {
                      await ClipboardHelper.copyToClipboard(xml);
                      setState(() => _copied = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _copied = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Download button
                  _ActionButton(
                    icon: Icons.download_outlined,
                    label: 'Download',
                    color: AppTheme.primary,
                    filled: true,
                    onTap: xml.isNotEmpty
                        ? () => DownloadHelper.downloadXml(xml, 'appcast.xml')
                        : null,
                  ),
                ],
              ),
            ),

            // ─── XML Content ───
            Expanded(
              child: xml.isEmpty
                  ? const _EmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SyntaxHighlightedXml(xml: xml),
                    ),
            ),

            // ─── Usage hint ───
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceInset,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usage with flutter_upgrader:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: SelectableText(
                      _upgraderSnippet(provider.feedConfig.atomLink),
                      style: AppTheme.monoStyle.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    return '${(bytes / 1024).toStringAsFixed(1)}KB';
  }

  String _upgraderSnippet(String url) {
    final u = url.isNotEmpty ? url : 'https://example.com/appcast.xml';
    return '''Upgrader(
  appcastURL: '$u',
  // Optional: filter by channel
  // appcastChannel: 'beta',
)''';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 40, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text('Add releases to generate XML',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              )),
          SizedBox(height: 4),
          Text('Fill in feed config and add at least one item',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              )),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(7),
          border:
              filled ? null : Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: filled ? Colors.white : color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: filled ? Colors.white : color,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Syntax Highlighted XML ──────────────────────────────────────────────────
class SyntaxHighlightedXml extends StatelessWidget {
  final String xml;

  const SyntaxHighlightedXml({super.key, required this.xml});

  static Color get _tagColor => AppTheme.syntaxTag;
  static Color get _attrColor => AppTheme.syntaxAttr;
  static Color get _valueColor => AppTheme.syntaxValue;
  static Color get _commentColor => AppTheme.syntaxComment;
  static Color get _piColor => AppTheme.syntaxPi;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(children: _tokenize(xml)),
      style: AppTheme.monoStyle,
    );
  }

  List<TextSpan> _tokenize(String input) {
    final spans = <TextSpan>[];
    int i = 0;

    while (i < input.length) {
      // XML declaration
      if (input.startsWith('<?', i)) {
        final end = input.indexOf('?>', i);
        if (end == -1) {
          spans.add(TextSpan(
              text: input.substring(i), style: TextStyle(color: _piColor)));
          break;
        }
        spans.add(TextSpan(
            text: input.substring(i, end + 2),
            style: TextStyle(color: _piColor)));
        i = end + 2;
        continue;
      }

      // Comments
      if (input.startsWith('<!--', i)) {
        final end = input.indexOf('-->', i);
        if (end == -1) {
          spans.add(TextSpan(
              text: input.substring(i),
              style: TextStyle(color: _commentColor)));
          break;
        }
        spans.add(TextSpan(
            text: input.substring(i, end + 3),
            style: TextStyle(color: _commentColor)));
        i = end + 3;
        continue;
      }

      // CDATA
      if (input.startsWith('<![CDATA[', i)) {
        final end = input.indexOf(']]>', i);
        if (end == -1) {
          spans.add(TextSpan(
              text: input.substring(i), style: TextStyle(color: _valueColor)));
          break;
        }
        spans.add(TextSpan(
            text: input.substring(i, end + 3),
            style: TextStyle(color: _valueColor)));
        i = end + 3;
        continue;
      }

      // Tags
      if (input[i] == '<') {
        final end = input.indexOf('>', i);
        if (end == -1) {
          spans.add(TextSpan(
              text: input.substring(i), style: TextStyle(color: _tagColor)));
          break;
        }
        final tagContent = input.substring(i, end + 1);
        spans.addAll(_tokenizeTag(tagContent));
        i = end + 1;
        continue;
      }

      // Text content
      final next = input.indexOf('<', i);
      if (next == -1) {
        final text = input.substring(i).trim();
        if (text.isNotEmpty) {
          spans.add(TextSpan(
              text: input.substring(i),
              style: const TextStyle(color: Color(0xFF8C93A8))));
        } else {
          spans.add(TextSpan(text: input.substring(i)));
        }
        break;
      }
      spans.add(TextSpan(
        text: input.substring(i, next),
        style: const TextStyle(color: AppTheme.textSecondary),
      ));
      i = next;
    }

    return spans;
  }

  List<TextSpan> _tokenizeTag(String tag) {
    final spans = <TextSpan>[];
    // Simple: highlight < > as tag brackets, tag name, attributes
    final attrRegex = RegExp(r'(\s[\w:]+)(=)("(?:[^"]*)")');
    // final nameRegex = RegExp(r'^</?[\w:]+');

    int i = 0;
    // Opening bracket
    spans.add(const TextSpan(
        text: '<', style: TextStyle(color: AppTheme.syntaxBracket)));
    i = 1;

    // Closing slash for end tags
    if (i < tag.length && tag[i] == '/') {
      spans.add(const TextSpan(
          text: '/', style: TextStyle(color: AppTheme.textMuted)));
      i++;
    }

    // Tag name
    final nameMatch = RegExp(r'^[\w:]+').firstMatch(tag.substring(i));
    if (nameMatch != null) {
      spans.add(TextSpan(
          text: nameMatch.group(0)!, style: TextStyle(color: _tagColor)));
      i += nameMatch.group(0)!.length;
    }

    // Attributes
    final rest =
        tag.substring(i, tag.endsWith('/>') ? tag.length - 2 : tag.length - 1);
    if (rest.isNotEmpty) {
      int r = 0;
      for (final m in attrRegex.allMatches(rest)) {
        if (m.start > r) {
          spans.add(TextSpan(text: rest.substring(r, m.start)));
        }
        spans.add(
            TextSpan(text: m.group(1)!, style: TextStyle(color: _attrColor)));
        spans.add(const TextSpan(
            text: '=', style: TextStyle(color: AppTheme.textMuted)));
        spans.add(
            TextSpan(text: m.group(3)!, style: TextStyle(color: _valueColor)));
        r = m.end;
      }
      if (r < rest.length) {
        spans.add(TextSpan(text: rest.substring(r)));
      }
    }

    // Closing bracket
    if (tag.endsWith('/>')) {
      spans.add(const TextSpan(
          text: '/>', style: TextStyle(color: AppTheme.textMuted)));
    } else {
      spans.add(const TextSpan(
          text: '>', style: TextStyle(color: AppTheme.textMuted)));
    }

    return spans;
  }
}
