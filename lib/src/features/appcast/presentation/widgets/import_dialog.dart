import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/utils/web_picker_helper.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _ctrl = TextEditingController();
  String? _pickedFileName;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final file = await WebPickerHelper.pickTextFile();
    if (!mounted) return;

    if (file != null) {
      setState(() {
        _loading = false;
        _pickedFileName = file.name;
        _ctrl.text = file.content;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _import() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please paste XML content or pick an appcast file.');
      return;
    }

    context.read<AppcastBloc>().add(XmlImported(text));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  size: 18,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Import Appcast XML Feed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Load an existing appcast.xml feed from Sparkle, WinSparkle, or Flutter Upgrader to edit or convert.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Pick file button
            InkWell(
              onTap: _loading ? null : _pickFile,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _pickedFileName != null
                        ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pickedFileName != null ? Icons.check_circle : Icons.upload_file,
                      size: 16,
                      color: _pickedFileName != null
                          ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                          : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _pickedFileName != null
                          ? 'Loaded: $_pickedFileName'
                          : 'Select .xml file from computer',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _pickedFileName != null
                            ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or paste raw XML',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Textarea
            TextField(
              controller: _ctrl,
              maxLines: 8,
              style: AppTheme.monoStyle(isDark: isDark, fontSize: 11.5),
              decoration: const InputDecoration(
                hintText: '<?xml version="1.0" encoding="utf-8"?>\n<rss version="2.0" ...>\n  <channel>\n    ...\n  </channel>\n</rss>',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.darkDanger),
                  const SizedBox(width: 6),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 12, color: AppColors.darkDanger),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TactileButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                TactileButton(
                  label: 'Import XML',
                  primary: true,
                  icon: Icons.check,
                  onPressed: _import,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
