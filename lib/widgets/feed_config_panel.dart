// lib/widgets/feed_config_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appcast_provider.dart';
import '../utils/theme.dart';
import 'form_field_widget.dart';

class FeedConfigPanel extends StatefulWidget {
  const FeedConfigPanel({super.key});
  @override
  State<FeedConfigPanel> createState() => _FeedConfigPanelState();
}

class _FeedConfigPanelState extends State<FeedConfigPanel> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppcastProvider>(
      builder: (ctx, provider, _) {
        final cfg = provider.feedConfig;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              // ── Header ──
              InkWell(
                onTap: () => setState(() => _open = !_open),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(10),
                  bottom: _open ? Radius.zero : const Radius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBg,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppTheme.primaryBorder),
                        ),
                        child: const Icon(
                          Icons.rss_feed_rounded,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feed Configuration',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Channel metadata & settings',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _open
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              if (_open) ...[
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppFormField(
                              label: 'Feed Title',
                              hint: 'My App Updates',
                              value: cfg.title,
                              required: true,
                              onChanged: (v) => provider.updateFeedConfig(
                                cfg.copyWith(title: v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 140,
                            child: AppSelectField(
                              label: 'Language',
                              value: cfg.language,
                              options: const [
                                ('en', 'English'),
                                ('id', 'Indonesian'),
                                ('fr', 'French'),
                                ('de', 'German'),
                                ('es', 'Spanish'),
                                ('ja', 'Japanese'),
                                ('zh', 'Chinese'),
                                ('ko', 'Korean'),
                                ('pt', 'Portuguese'),
                                ('ar', 'Arabic'),
                              ],
                              onChanged: (v) => provider.updateFeedConfig(
                                cfg.copyWith(language: v ?? 'en'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppFormField(
                        label: 'Link (App website)',
                        hint: 'https://example.com',
                        value: cfg.link,
                        required: true,
                        onChanged: (v) =>
                            provider.updateFeedConfig(cfg.copyWith(link: v)),
                      ),
                      const SizedBox(height: 10),
                      AppFormField(
                        label: 'Description',
                        hint: 'Latest versions of My App',
                        value: cfg.description,
                        onChanged: (v) => provider.updateFeedConfig(
                          cfg.copyWith(description: v),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppFormField(
                        label: 'Appcast Hosting URL (Atom self-link)',
                        hint: 'https://example.com/appcast.xml',
                        value: cfg.atomLink,
                        helper:
                            'Recommended: the exact URL where this file will be hosted',
                        onChanged: (v) => provider.updateFeedConfig(
                          cfg.copyWith(atomLink: v),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ── Toggles ──
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceInset,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          children: [
                            _ToggleRow(
                              label: 'Sparkle Namespace',
                              subtitle:
                                  'Include sparkle: XML namespace and attributes',
                              value: cfg.sparkle,
                              onChanged: (v) => provider.updateFeedConfig(
                                cfg.copyWith(sparkle: v),
                              ),
                            ),
                            const Divider(height: 14),
                            _ToggleRow(
                              label: 'Flutter Upgrader Compatible',
                              subtitle:
                                  'Optimize enclosure format for the upgrader package',
                              value: cfg.upgraderCompatible,
                              badge: 'Recommended',
                              onChanged: (v) => provider.updateFeedConfig(
                                cfg.copyWith(upgraderCompatible: v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? badge;
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    TagChip(label: badge!, color: AppTheme.success),
                  ],
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
