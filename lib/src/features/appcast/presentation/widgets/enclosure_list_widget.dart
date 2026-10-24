import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';
import '../../models/appcast_enclosure.dart';

class EnclosureListWidget extends StatelessWidget {
  final String releaseId;
  final List<AppcastEnclosure> enclosures;

  const EnclosureListWidget({
    super.key,
    required this.releaseId,
    required this.enclosures,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payload Enclosures (${enclosures.length})',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Add platform binaries (macOS .dmg, Windows .exe, Linux .tar.gz)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TactileButton(
              label: 'Add Binary',
              icon: Icons.add,
              compact: true,
              onPressed: () {
                context.read<AppcastBloc>().add(EnclosureAdded(releaseId));
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (enclosures.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              'No enclosures added for this release. Click "Add Binary" to add a download target.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          )
        else
          ...enclosures.asMap().entries.map((entry) {
            final idx = entry.key;
            final enc = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EnclosureItemCard(
                releaseId: releaseId,
                index: idx + 1,
                enclosure: enc,
              ),
            );
          }),
      ],
    );
  }
}

class _EnclosureItemCard extends StatelessWidget {
  final String releaseId;
  final int index;
  final AppcastEnclosure enclosure;

  const _EnclosureItemCard({
    required this.releaseId,
    required this.index,
    required this.enclosure,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Binary #$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              TactileBadge(label: enclosure.os.toUpperCase()),
              if (enclosure.arch != 'all') ...[
                const SizedBox(width: 6),
                TactileBadge(label: enclosure.arch),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete Binary',
                color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                onPressed: () {
                  context.read<AppcastBloc>().add(
                    EnclosureRemoved(releaseId, enclosure.id),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TactileTextField(
            label: 'Download URL',
            hint: 'https://example.com/downloads/app-v1.0.0.dmg',
            value: enclosure.url,
            isMonospace: true,
            required: true,
            onChanged: (v) {
              context.read<AppcastBloc>().add(
                EnclosureUpdated(releaseId, enclosure.copyWith(url: v)),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TactileSelectField(
                  label: 'Target OS',
                  value: enclosure.os,
                  options: const [
                    ('all', 'All Platforms'),
                    ('macos', 'macOS'),
                    ('windows', 'Windows'),
                    ('linux', 'Linux'),
                    ('android', 'Android'),
                    ('ios', 'iOS'),
                  ],
                  onChanged: (v) {
                    context.read<AppcastBloc>().add(
                      EnclosureUpdated(releaseId, enclosure.copyWith(os: v ?? 'all')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TactileSelectField(
                  label: 'Target Architecture',
                  value: enclosure.arch,
                  options: const [
                    ('all', 'Universal / Any'),
                    ('arm64', 'ARM64 (Apple Silicon)'),
                    ('x86_64', 'x86_64 (Intel/AMD)'),
                  ],
                  onChanged: (v) {
                    context.read<AppcastBloc>().add(
                      EnclosureUpdated(releaseId, enclosure.copyWith(arch: v ?? 'all')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TactileTextField(
                  label: 'File Size (Bytes)',
                  hint: '10485760',
                  value: enclosure.fileLength > 0 ? enclosure.fileLength.toString() : '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  helper: _formatBytes(enclosure.fileLength),
                  onChanged: (v) {
                    context.read<AppcastBloc>().add(
                      EnclosureUpdated(
                        releaseId,
                        enclosure.copyWith(fileLength: int.tryParse(v) ?? 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TactileTextField(
                  label: 'Ed25519 Signature (sparkle:edSignature)',
                  hint: 'Base64 EdDSA signature from sign_update tool',
                  value: enclosure.edSignature,
                  isMonospace: true,
                  onChanged: (v) {
                    context.read<AppcastBloc>().add(
                      EnclosureUpdated(releaseId, enclosure.copyWith(edSignature: v)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TactileSelectField(
                  label: 'MIME Type',
                  value: enclosure.mimeType,
                  options: const [
                    ('application/octet-stream', 'Binary (.bin)'),
                    ('application/zip', 'ZIP Archive (.zip)'),
                    ('application/x-apple-diskimage', 'macOS Disk Image (.dmg)'),
                    ('application/x-ms-dos-executable', 'Windows Executable (.exe)'),
                    ('application/x-msi', 'Windows MSI (.msi)'),
                    ('application/x-tar', 'Tarball (.tar.gz)'),
                    ('application/vnd.android.package-archive', 'Android APK (.apk)'),
                  ],
                  onChanged: (v) {
                    context.read<AppcastBloc>().add(
                      EnclosureUpdated(
                        releaseId,
                        enclosure.copyWith(mimeType: v ?? 'application/octet-stream'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
