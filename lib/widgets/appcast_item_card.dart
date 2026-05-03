// lib/widgets/appcast_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/appcast_provider.dart';
import '../models/appcast_item.dart';
import '../utils/theme.dart';
import 'form_field_widget.dart';

class AppcastItemCard extends StatefulWidget {
  final AppcastItem item;

  const AppcastItemCard({super.key, required this.item});

  @override
  State<AppcastItemCard> createState() => _AppcastItemCardState();
}

class _AppcastItemCardState extends State<AppcastItemCard> {
  int _activeSection = 0; // 0=basic, 1=advanced, 2=deltas

  AppcastItem get item => widget.item;

  void _update(AppcastItem updated) {
    context.read<AppcastProvider>().updateItem(item.id, updated);
  }

  @override
  Widget build(BuildContext context) {
    final channelColor = _channelColor(item.channel);
    final osLabel = _osLabel(item.os);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.criticalUpdate
              ? AppTheme.danger.withValues(alpha: .4)
              : AppTheme.border,
          width: item.criticalUpdate ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ─── Header ───
          InkWell(
            onTap: () =>
                context.read<AppcastProvider>().toggleItemExpanded(item.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Drag handle
                  const Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  // Version badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.version.isNotEmpty ? 'v${item.version}' : 'v?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      item.title.isNotEmpty ? item.title : 'Untitled Release',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Chips
                  if (item.criticalUpdate)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: TagChip(label: 'Critical', color: AppTheme.danger),
                    ),
                  if (item.informationalUpdate)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: TagChip(label: 'Info Only'),
                    ),
                  TagChip(label: item.channel, color: channelColor),
                  const SizedBox(width: 6),
                  if (osLabel.isNotEmpty)
                    TagChip(label: osLabel, color: AppTheme.info),
                  const SizedBox(width: 8),
                  // Actions
                  _HeaderAction(
                    icon: Icons.copy_outlined,
                    tooltip: 'Duplicate',
                    onTap: () =>
                        context.read<AppcastProvider>().duplicateItem(item.id),
                  ),
                  const SizedBox(width: 4),
                  _HeaderAction(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete',
                    color: AppTheme.danger,
                    onTap: () => _confirmDelete(context),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    item.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          if (item.isExpanded) ...[
            const Divider(height: 0),

            // ─── Tab bar ───
            Container(
              color: AppTheme.surfaceInset,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  _Tab(
                    label: 'Basic Info',
                    index: 0,
                    active: _activeSection,
                    onTap: (i) => setState(() => _activeSection = i),
                  ),
                  const SizedBox(width: 6),
                  _Tab(
                    label: 'Advanced',
                    index: 1,
                    active: _activeSection,
                    onTap: (i) => setState(() => _activeSection = i),
                  ),
                  const SizedBox(width: 6),
                  _Tab(
                    label: 'Deltas (${item.deltas.length})',
                    index: 2,
                    active: _activeSection,
                    onTap: (i) => setState(() => _activeSection = i),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),

            // ─── Content ───
            Padding(
              padding: const EdgeInsets.all(16),
              child: _activeSection == 0
                  ? _BasicSection(item: item, onUpdate: _update)
                  : _activeSection == 1
                  ? _AdvancedSection(item: item, onUpdate: _update)
                  : _DeltasSection(item: item, onUpdate: _update),
            ),
          ],
        ],
      ),
    );
  }

  Color _channelColor(String ch) {
    return switch (ch) {
      'beta' => AppTheme.warning,
      'nightly' || 'alpha' => AppTheme.danger,
      _ => AppTheme.success,
    };
  }

  String _osLabel(String os) {
    return switch (os) {
      'macos' => 'macOS',
      'windows' => 'Win',
      'linux' => 'Linux',
      'ios' => 'iOS',
      'android' => 'Android',
      'all' || '' => '',
      _ => os,
    };
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Release?'),
        content: Text(
          'Remove "${item.title.isNotEmpty ? item.title : 'this release'}" from the feed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppcastProvider>().removeItem(item.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Basic Section ───────────────────────────────────────────────────────────
class _BasicSection extends StatelessWidget {
  final AppcastItem item;
  final ValueChanged<AppcastItem> onUpdate;

  const _BasicSection({required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Title',
                hint: 'Version 2.0.0',
                value: item.title,
                required: true,
                onChanged: (v) => onUpdate(item.copyWith(title: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSelectField(
                label: 'Channel',
                value: item.channel,
                options: const [
                  ('stable', 'Stable'),
                  ('beta', 'Beta'),
                  ('alpha', 'Alpha'),
                  ('nightly', 'Nightly'),
                ],
                onChanged: (v) =>
                    onUpdate(item.copyWith(channel: v ?? 'stable')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Version String',
                hint: '2.0.0',
                value: item.version,
                required: true,
                helper: 'sparkle:version / CFBundleVersion',
                onChanged: (v) =>
                    onUpdate(item.copyWith(version: v, shortVersionString: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Short Version',
                hint: '2.0.0',
                value: item.shortVersionString,
                helper: 'sparkle:shortVersionString (human-readable)',
                onChanged: (v) =>
                    onUpdate(item.copyWith(shortVersionString: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Build Number',
                hint: '200',
                value: item.buildNumber > 0 ? item.buildNumber.toString() : '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) =>
                    onUpdate(item.copyWith(buildNumber: int.tryParse(v) ?? 0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppFormField(
          label: 'Download URL',
          hint: 'https://example.com/app-2.0.0.zip',
          value: item.downloadUrl,
          required: true,
          onChanged: (v) => onUpdate(item.copyWith(downloadUrl: v)),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppSelectField(
                label: 'MIME Type',
                value: item.mimeType,
                options: const [
                  ('application/zip', 'ZIP (.zip)'),
                  ('application/octet-stream', 'Binary (.bin)'),
                  ('application/x-apple-diskimage', 'Disk Image (.dmg)'),
                  ('application/x-bzip2', 'BZip2 (.bz2)'),
                  ('application/x-tar', 'Tarball (.tar)'),
                  ('application/x-gzip', 'GZip (.gz)'),
                  ('application/vnd.android.package-archive', 'APK (.apk)'),
                  ('application/x-ms-dos-executable', 'Windows EXE'),
                  ('application/x-msi', 'Windows MSI'),
                ],
                onChanged: (v) =>
                    onUpdate(item.copyWith(mimeType: v ?? 'application/zip')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'File Size (bytes)',
                hint: '10485760',
                value: item.fileLength > 0 ? item.fileLength.toString() : '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                helper: _formatBytes(item.fileLength),
                onChanged: (v) =>
                    onUpdate(item.copyWith(fileLength: int.tryParse(v) ?? 0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Pub Date',
                hint: '2024-01-15',
                value: item.pubDate.toIso8601String().split('T').first,
                onChanged: (v) {
                  final d = DateTime.tryParse(v);
                  if (d != null) onUpdate(item.copyWith(pubDate: d));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSelectField(
                label: 'Target OS',
                value: item.os,
                options: const [
                  ('all', 'All Platforms'),
                  ('macos', 'macOS'),
                  ('windows', 'Windows'),
                  ('linux', 'Linux'),
                  ('ios', 'iOS'),
                  ('android', 'Android'),
                ],
                onChanged: (v) => onUpdate(item.copyWith(os: v ?? 'all')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Signature
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              flex: 2,
              child: AppFormField(
                label: 'Signature',
                hint: 'Base64 encoded signature',
                value: item.signature,
                helper: 'EdDSA/DSA signature for file verification',
                onChanged: (v) => onUpdate(item.copyWith(signature: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSelectField(
                label: 'Algorithm',
                value: item.signatureAlgorithm,
                options: const [
                  ('ed25519', 'EdDSA (ed25519) — Recommended'),
                  ('dsa', 'DSA (legacy)'),
                ],
                onChanged: (v) =>
                    onUpdate(item.copyWith(signatureAlgorithm: v ?? 'ed25519')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Release notes
        AppFormField(
          label: 'Release Notes URL',
          hint: 'https://example.com/changelog/2.0.0',
          value: item.releaseNotesUrl,
          helper: 'Link to HTML release notes page',
          onChanged: (v) => onUpdate(item.copyWith(releaseNotesUrl: v)),
        ),
        const SizedBox(height: 12),
        AppFormField(
          label: 'Inline Release Notes (HTML)',
          hint: '<ul><li>New feature</li><li>Bug fix</li></ul>',
          value: item.releaseNotesInline,
          maxLines: 4,
          helper:
              'Inline HTML shown directly in update dialog (alternative to URL)',
          onChanged: (v) => onUpdate(item.copyWith(releaseNotesInline: v)),
        ),
        const SizedBox(height: 12),
        // Flags
        _FlagsRow(item: item, onUpdate: onUpdate),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return 'Enter size in bytes';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}

class _FlagsRow extends StatelessWidget {
  final AppcastItem item;
  final ValueChanged<AppcastItem> onUpdate;

  const _FlagsRow({required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceInset,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FlagSwitch(
                  label: 'Critical Update',
                  subtitle: 'Force immediate update',
                  value: item.criticalUpdate,
                  color: AppTheme.danger,
                  onChanged: (v) => onUpdate(item.copyWith(criticalUpdate: v)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FlagSwitch(
                  label: 'Informational Only',
                  subtitle: 'Link only, no auto-download',
                  value: item.informationalUpdate,
                  onChanged: (v) =>
                      onUpdate(item.copyWith(informationalUpdate: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlagSwitch extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;

  const _FlagSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(value: value, onChanged: onChanged),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: value && color != null ? color : AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Advanced Section ────────────────────────────────────────────────────────
class _AdvancedSection extends StatelessWidget {
  final AppcastItem item;
  final ValueChanged<AppcastItem> onUpdate;

  const _AdvancedSection({required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'System Requirements',
          subtitle: 'Minimum/maximum OS version constraints',
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Minimum System Version',
                hint: '10.14',
                value: item.minimumSystemVersion,
                helper: 'e.g. 10.14 for macOS Mojave',
                onChanged: (v) =>
                    onUpdate(item.copyWith(minimumSystemVersion: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormField(
                label: 'Maximum System Version',
                hint: '14.0',
                value: item.maximumSystemVersion,
                helper: 'Upper bound (rarely needed)',
                onChanged: (v) =>
                    onUpdate(item.copyWith(maximumSystemVersion: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Update Behavior',
          subtitle: 'Control rollout and auto-update logic',
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Minimum Auto-Update Version',
                hint: '1.5.0',
                value: item.minimumAutoUpdateVersion,
                helper: 'Oldest version that can auto-update to this',
                onChanged: (v) =>
                    onUpdate(item.copyWith(minimumAutoUpdateVersion: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSelectField(
                label: 'Phased Rollout (days)',
                value: item.phaseGroup,
                options: const [
                  ('', 'No phased rollout'),
                  ('1', '1 day'),
                  ('2', '2 days'),
                  ('3', '3 days'),
                  ('4', '4 days'),
                  ('5', '5 days'),
                  ('6', '6 days'),
                  ('7', '7 days (max)'),
                ],
                helper: 'Gradually rollout to users over N days',
                onChanged: (v) => onUpdate(item.copyWith(phaseGroup: v ?? '')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppSelectField(
          label: 'Installation Type',
          value: item.installationType.isNotEmpty ? item.installationType : '',
          options: const [
            ('', 'Not specified'),
            ('package', 'Package Installer'),
            ('application', 'Application Bundle'),
            ('guided-installer', 'Guided Installer'),
          ],
          helper: 'How Sparkle should handle the download',
          onChanged: (v) => onUpdate(item.copyWith(installationType: v ?? '')),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.infoBorder),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppTheme.info),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Advanced options like phased rollout and installation type are primarily for Sparkle (macOS). '
                  'The flutter_upgrader package uses version, downloadUrl, and criticalUpdate.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Deltas Section ──────────────────────────────────────────────────────────
class _DeltasSection extends StatelessWidget {
  final AppcastItem item;
  final ValueChanged<AppcastItem> onUpdate;

  const _DeltasSection({required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: SectionHeader(
                title: 'Delta Updates',
                subtitle: 'Incremental patches from specific older versions',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final deltas = List<DeltaUpdate>.from(item.deltas);
                deltas.add(DeltaUpdate());
                onUpdate(item.copyWith(deltas: deltas));
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Delta'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (item.deltas.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.compress, size: 24, color: AppTheme.textMuted),
                SizedBox(height: 6),
                Text(
                  'No delta updates',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                Text(
                  'Delta updates let users download only the diff from a specific version',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...item.deltas.asMap().entries.map((entry) {
            final idx = entry.key;
            final delta = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: idx < item.deltas.length - 1 ? 12 : 0,
              ),
              child: _DeltaCard(
                delta: delta,
                index: idx,
                onUpdate: (updated) {
                  final deltas = List<DeltaUpdate>.from(item.deltas);
                  deltas[idx] = updated;
                  onUpdate(item.copyWith(deltas: deltas));
                },
                onRemove: () {
                  final deltas = List<DeltaUpdate>.from(item.deltas)
                    ..removeAt(idx);
                  onUpdate(item.copyWith(deltas: deltas));
                },
              ),
            );
          }),
      ],
    );
  }
}

class _DeltaCard extends StatelessWidget {
  final DeltaUpdate delta;
  final int index;
  final ValueChanged<DeltaUpdate> onUpdate;
  final VoidCallback onRemove;

  const _DeltaCard({
    required this.delta,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceInset,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Delta #${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppTheme.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: AppFormField(
                  label: 'From Version',
                  hint: '1.9.0',
                  value: delta.fromVersion,
                  onChanged: (v) => onUpdate(
                    DeltaUpdate(
                      fromVersion: v,
                      downloadUrl: delta.downloadUrl,
                      fileLength: delta.fileLength,
                      signature: delta.signature,
                      mimeType: delta.mimeType,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppFormField(
                  label: 'Patch URL',
                  hint: 'https://example.com/patches/1.9.0-2.0.0.delta',
                  value: delta.downloadUrl,
                  onChanged: (v) => onUpdate(
                    DeltaUpdate(
                      fromVersion: delta.fromVersion,
                      downloadUrl: v,
                      fileLength: delta.fileLength,
                      signature: delta.signature,
                      mimeType: delta.mimeType,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: AppFormField(
                  label: 'Size (bytes)',
                  hint: '524288',
                  value: delta.fileLength > 0
                      ? delta.fileLength.toString()
                      : '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => onUpdate(
                    DeltaUpdate(
                      fromVersion: delta.fromVersion,
                      downloadUrl: delta.downloadUrl,
                      fileLength: int.tryParse(v) ?? 0,
                      signature: delta.signature,
                      mimeType: delta.mimeType,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppFormField(
                  label: 'EdDSA Signature',
                  hint: 'Base64 signature',
                  value: delta.signature,
                  onChanged: (v) => onUpdate(
                    DeltaUpdate(
                      fromVersion: delta.fromVersion,
                      downloadUrl: delta.downloadUrl,
                      fileLength: delta.fileLength,
                      signature: v,
                      mimeType: delta.mimeType,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared ──────────────────────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final int index;
  final int active;
  final ValueChanged<int> onTap;

  const _Tab({
    required this.label,
    required this.index,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == active;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppTheme.primaryBorder : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color ?? AppTheme.textMuted),
        ),
      ),
    );
  }
}
