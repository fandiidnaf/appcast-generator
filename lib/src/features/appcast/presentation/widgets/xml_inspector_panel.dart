import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_state.dart';
import '../../models/preset_profile.dart';

class XmlInspectorPanel extends StatefulWidget {
  const XmlInspectorPanel({super.key});

  @override
  State<XmlInspectorPanel> createState() => _XmlInspectorPanelState();
}

class _XmlInspectorPanelState extends State<XmlInspectorPanel> {
  bool _copied = false;

  void _copy(String xml) async {
    await Clipboard.setData(ClipboardData(text: xml));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AppcastBloc, AppcastState>(
      builder: (context, state) {
        final xml = state.generatedXml;
        final lines = xml.isEmpty ? <String>[] : xml.split('\n');

        return Container(
          color: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Toolbar ───
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.code,
                      size: 15,
                      color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'appcast.xml',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${lines.length} lines  ·  ${_formatBytes(xml.length)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TactileButton(
                      label: _copied ? 'Copied' : 'Copy XML',
                      icon: _copied ? Icons.check : Icons.copy_outlined,
                      compact: true,
                      primary: _copied,
                      onPressed: xml.isNotEmpty ? () => _copy(xml) : null,
                    ),
                  ],
                ),
              ),

              // ─── Issues Banner if errors exist ───
              if (state.issues.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkWarning : AppColors.lightDanger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.issues.first.message,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightDanger,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (state.issues.length > 1)
                        Text(
                          '+${state.issues.length - 1} more',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightDanger,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ─── XML Code View ───
              Expanded(
                child: xml.isEmpty
                    ? Center(
                        child: Text(
                          'No XML generated yet',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: SelectableText.rich(
                          TextSpan(children: _tokenize(xml, isDark)),
                          style: AppTheme.monoStyle(isDark: isDark),
                        ),
                      ),
              ),

              // ─── Integration Snippet ───
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _integrationTitle(state.feed.preset),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: SelectableText(
                        _integrationSnippet(state.feed.preset, state.feed.atomLink),
                        style: AppTheme.monoStyle(isDark: isDark, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  String _integrationTitle(PresetProfile preset) {
    return switch (preset) {
      PresetProfile.sparkle2 => 'macOS Sparkle 2 (Info.plist):',
      PresetProfile.flutterUpgrader => 'Flutter Upgrader Integration:',
      PresetProfile.winSparkle => 'WinSparkle / NetSparkle Usage:',
    };
  }

  String _integrationSnippet(PresetProfile preset, String url) {
    final effectiveUrl = url.isNotEmpty ? url : 'https://example.com/appcast.xml';
    return switch (preset) {
      PresetProfile.sparkle2 => '<key>SUFeedURL</key>\n<string>$effectiveUrl</string>',
      PresetProfile.flutterUpgrader => "UpgradeAlert(\n  appcastConfig: AppcastConfiguration(url: '$effectiveUrl'),\n)",
      PresetProfile.winSparkle => 'win_sparkle_set_appcast_url("$effectiveUrl");',
    };
  }

  List<TextSpan> _tokenize(String input, bool isDark) {
    final spans = <TextSpan>[];
    final tagColor = isDark ? AppColors.darkXmlTag : AppColors.lightXmlTag;
    final attrColor = isDark ? AppColors.darkXmlAttr : AppColors.lightXmlAttr;
    final valueColor = isDark ? AppColors.darkXmlValue : AppColors.lightXmlValue;
    final commentColor = isDark ? AppColors.darkXmlComment : AppColors.lightXmlComment;
    final piColor = isDark ? AppColors.darkXmlPi : AppColors.lightXmlPi;

    int i = 0;
    while (i < input.length) {
      // XML Processing Instruction <? ... ?>
      if (input.startsWith('<?', i)) {
        final end = input.indexOf('?>', i);
        if (end == -1) {
          spans.add(TextSpan(text: input.substring(i), style: TextStyle(color: piColor)));
          break;
        }
        spans.add(TextSpan(text: input.substring(i, end + 2), style: TextStyle(color: piColor)));
        i = end + 2;
        continue;
      }

      // Comments <!-- ... -->
      if (input.startsWith('<!--', i)) {
        final end = input.indexOf('-->', i);
        if (end == -1) {
          spans.add(TextSpan(text: input.substring(i), style: TextStyle(color: commentColor)));
          break;
        }
        spans.add(TextSpan(text: input.substring(i, end + 3), style: TextStyle(color: commentColor)));
        i = end + 3;
        continue;
      }

      // CDATA <![CDATA[ ... ]]>
      if (input.startsWith('<![CDATA[', i)) {
        final end = input.indexOf(']]>', i);
        if (end == -1) {
          spans.add(TextSpan(text: input.substring(i), style: TextStyle(color: valueColor)));
          break;
        }
        spans.add(TextSpan(text: input.substring(i, end + 3), style: TextStyle(color: valueColor)));
        i = end + 3;
        continue;
      }

      // Tags < ... >
      if (input[i] == '<') {
        final end = input.indexOf('>', i);
        if (end == -1) {
          spans.add(TextSpan(text: input.substring(i), style: TextStyle(color: tagColor)));
          break;
        }
        final tagContent = input.substring(i, end + 1);
        spans.addAll(_tokenizeTag(tagContent, isDark, tagColor, attrColor, valueColor));
        i = end + 1;
        continue;
      }

      // Content
      final nextTag = input.indexOf('<', i);
      if (nextTag == -1) {
        spans.add(TextSpan(
          text: input.substring(i),
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ));
        break;
      }
      spans.add(TextSpan(
        text: input.substring(i, nextTag),
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ));
      i = nextTag;
    }

    return spans;
  }

  List<TextSpan> _tokenizeTag(
    String tag,
    bool isDark,
    Color tagColor,
    Color attrColor,
    Color valueColor,
  ) {
    final spans = <TextSpan>[];
    final bracketColor = isDark ? AppColors.darkXmlBracket : AppColors.lightXmlBracket;
    final attrRegex = RegExp(r'(\s[\w:]+)(=)("(?:[^"]*)")');

    int i = 0;
    spans.add(TextSpan(text: '<', style: TextStyle(color: bracketColor)));
    i = 1;

    if (i < tag.length && tag[i] == '/') {
      spans.add(TextSpan(text: '/', style: TextStyle(color: bracketColor)));
      i++;
    }

    final nameMatch = RegExp(r'^[\w:]+').firstMatch(tag.substring(i));
    if (nameMatch != null) {
      spans.add(TextSpan(text: nameMatch.group(0)!, style: TextStyle(color: tagColor, fontWeight: FontWeight.w600)));
      i += nameMatch.group(0)!.length;
    }

    final rest = tag.substring(i, tag.endsWith('/>') ? tag.length - 2 : tag.length - 1);
    if (rest.isNotEmpty) {
      int r = 0;
      for (final m in attrRegex.allMatches(rest)) {
        if (m.start > r) {
          spans.add(TextSpan(text: rest.substring(r, m.start)));
        }
        spans.add(TextSpan(text: m.group(1)!, style: TextStyle(color: attrColor)));
        spans.add(TextSpan(text: '=', style: TextStyle(color: bracketColor)));
        spans.add(TextSpan(text: m.group(3)!, style: TextStyle(color: valueColor)));
        r = m.end;
      }
      if (r < rest.length) {
        spans.add(TextSpan(text: rest.substring(r)));
      }
    }

    if (tag.endsWith('/>')) {
      spans.add(TextSpan(text: '/>', style: TextStyle(color: bracketColor)));
    } else {
      spans.add(TextSpan(text: '>', style: TextStyle(color: bracketColor)));
    }

    return spans;
  }
}
