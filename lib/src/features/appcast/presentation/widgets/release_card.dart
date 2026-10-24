import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';
import '../../models/appcast_item.dart';
import 'enclosure_list_widget.dart';

class ReleaseCard extends StatefulWidget {
  final AppcastItem item;
  final int index;

  const ReleaseCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<ReleaseCard> createState() => _ReleaseCardState();
}

class _ReleaseCardState extends State<ReleaseCard> {
  int _activeTab = 0; // 0=Info, 1=Enclosures, 2=Advanced, 3=Notes

  AppcastItem get item => widget.item;

  void _update(AppcastItem updated) {
    context.read<AppcastBloc>().add(ReleaseUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.criticalUpdate
              ? (isDark ? AppColors.darkDanger : AppColors.lightDanger)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: item.criticalUpdate ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ─── Accordion Header ───
          InkWell(
            onTap: () {
              context.read<AppcastBloc>().add(ReleaseExpansionToggled(item.id));
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(8),
              bottom: Radius.circular(item.isExpanded ? 0 : 8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 8),
                  TactileBadge(
                    label: item.version.isNotEmpty ? 'v${item.version}' : 'v?.?.?',
                    color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title.isNotEmpty ? item.title : 'Untitled Release',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.criticalUpdate) ...[
                    const SizedBox(width: 6),
                    TactileBadge(
                      label: 'CRITICAL',
                      color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                    ),
                  ],
                  const SizedBox(width: 6),
                  TactileBadge(
                    label: '${item.enclosures.length} package${item.enclosures.length == 1 ? '' : 's'}',
                    color: isDark ? AppColors.darkInfo : AppColors.lightInfo,
                  ),
                  const SizedBox(width: 6),
                  TactileBadge(label: item.channel.toUpperCase()),
                  const SizedBox(width: 12),
                  // Duplicate
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Duplicate release',
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    onPressed: () {
                      context.read<AppcastBloc>().add(ReleaseDuplicated(item.id));
                    },
                  ),
                  const SizedBox(width: 8),
                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 15),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete release',
                    color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                    onPressed: () => _confirmDelete(context),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    item.isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ],
              ),
            ),
          ),

          if (item.isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            // ─── Sub Tabs ───
            Container(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _TabItem(
                    label: 'Release Info',
                    index: 0,
                    active: _activeTab,
                    onTap: (i) => setState(() => _activeTab = i),
                  ),
                  const SizedBox(width: 6),
                  _TabItem(
                    label: 'Packages (${item.enclosures.length})',
                    index: 1,
                    active: _activeTab,
                    onTap: (i) => setState(() => _activeTab = i),
                  ),
                  const SizedBox(width: 6),
                  _TabItem(
                    label: 'Advanced Requirements',
                    index: 2,
                    active: _activeTab,
                    onTap: (i) => setState(() => _activeTab = i),
                  ),
                  const SizedBox(width: 6),
                  _TabItem(
                    label: 'Release Notes',
                    index: 3,
                    active: _activeTab,
                    onTap: (i) => setState(() => _activeTab = i),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: switch (_activeTab) {
                0 => _buildReleaseInfo(context),
                1 => EnclosureListWidget(releaseId: item.id, enclosures: item.enclosures),
                2 => _buildAdvancedRequirements(context),
                _ => _buildReleaseNotes(context),
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReleaseInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TactileTextField(
                label: 'Release Title',
                hint: 'Version 2.0.0',
                value: item.title,
                required: true,
                onChanged: (v) => _update(item.copyWith(title: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TactileSelectField(
                label: 'Release Channel',
                value: item.channel,
                options: const [
                  ('stable', 'Stable Channel'),
                  ('beta', 'Beta Channel'),
                  ('alpha', 'Alpha Channel'),
                  ('nightly', 'Nightly Build'),
                ],
                onChanged: (v) => _update(item.copyWith(channel: v ?? 'stable')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TactileTextField(
                label: 'Version String',
                hint: '2.0.0',
                value: item.version,
                isMonospace: true,
                required: true,
                helper: 'sparkle:version or CFBundleVersion',
                onChanged: (v) => _update(item.copyWith(version: v, shortVersionString: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TactileTextField(
                label: 'Display Version',
                hint: '2.0.0',
                value: item.shortVersionString,
                helper: 'sparkle:shortVersionString (user facing)',
                onChanged: (v) => _update(item.copyWith(shortVersionString: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TactileTextField(
                label: 'Release Date',
                hint: '2026-01-15',
                value: item.pubDate.toIso8601String().split('T').first,
                onChanged: (v) {
                  final dt = DateTime.tryParse(v);
                  if (dt != null) _update(item.copyWith(pubDate: dt));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TactileSwitchRow(
          title: 'Critical Update',
          subtitle: 'Forces immediate installation; users cannot skip this version',
          value: item.criticalUpdate,
          activeColor: AppColors.darkDanger,
          onChanged: (v) => _update(item.copyWith(criticalUpdate: v)),
        ),
        const SizedBox(height: 8),
        TactileSwitchRow(
          title: 'Informational Update Only',
          subtitle: 'Directs users to a website without automated download payload',
          value: item.informationalUpdate,
          onChanged: (v) => _update(item.copyWith(informationalUpdate: v)),
        ),
      ],
    );
  }

  Widget _buildAdvancedRequirements(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TactileTextField(
                label: 'Minimum System Version',
                hint: '12.0',
                value: item.minimumSystemVersion,
                helper: 'e.g. 12.0 for macOS Monterey, or Windows 10 build',
                onChanged: (v) => _update(item.copyWith(minimumSystemVersion: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TactileTextField(
                label: 'Maximum System Version',
                hint: '15.0',
                value: item.maximumSystemVersion,
                helper: 'Optional upper OS version limit',
                onChanged: (v) => _update(item.copyWith(maximumSystemVersion: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TactileTextField(
                label: 'Minimum Auto-Update Version',
                hint: '1.2.0',
                value: item.minimumAutoUpdateVersion,
                helper: 'Oldest version permitted to update directly',
                onChanged: (v) => _update(item.copyWith(minimumAutoUpdateVersion: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TactileTextField(
                label: 'Phased Rollout Interval (seconds)',
                hint: '86400',
                value: item.phasedRolloutInterval,
                helper: 'e.g. 86400 for 1 day, 604800 for 7 days',
                onChanged: (v) => _update(item.copyWith(phasedRolloutInterval: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReleaseNotes(BuildContext context) {
    return Column(
      children: [
        TactileTextField(
          label: 'Release Notes URL',
          hint: 'https://example.com/changelog/v2.0.0.html',
          value: item.releaseNotesUrl,
          helper: 'Direct link to external HTML or Markdown changelog',
          onChanged: (v) => _update(item.copyWith(releaseNotesUrl: v)),
        ),
        const SizedBox(height: 12),
        TactileTextField(
          label: 'Inline Changelog (HTML / CDATA)',
          hint: '<ul>\n  <li>Added multi-enclosure support</li>\n  <li>Fixed crash on macOS Ventura</li>\n</ul>',
          value: item.releaseNotesInline,
          isMonospace: true,
          maxLines: 5,
          helper: 'Embedded in feed via <![CDATA[ ... ]]>. Rendered in Sparkle update dialog.',
          onChanged: (v) => _update(item.copyWith(releaseNotesInline: v)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Release?'),
        content: Text('Remove "${item.title}" from this Appcast feed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppcastBloc>().add(ReleaseRemoved(item.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int index;
  final int active;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.label,
    required this.index,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = index == active;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface1 : AppColors.lightSurface1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ),
        ),
      ),
    );
  }
}
