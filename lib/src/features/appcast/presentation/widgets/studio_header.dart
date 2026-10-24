import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/utils/web_download_helper.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../../theme/cubit/theme_cubit.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';
import '../../bloc/appcast_state.dart';
import '../../models/preset_profile.dart';
import 'import_dialog.dart';

class StudioHeader extends StatelessWidget {
  final bool showInspector;
  final VoidCallback onToggleInspector;

  const StudioHeader({
    super.key,
    required this.showInspector,
    required this.onToggleInspector,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          // ─── Branding ───
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Icon(
              Icons.rss_feed,
              size: 16,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Universal Appcast Studio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Sparkle 2 · WinSparkle · Flutter Upgrader',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // ─── Preset Switcher ───
          BlocBuilder<AppcastBloc, AppcastState>(
            buildWhen: (prev, curr) => prev.feed.preset != curr.feed.preset,
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: PresetProfile.values.map((preset) {
                    final selected = preset == state.feed.preset;
                    return InkWell(
                      onTap: () {
                        context.read<AppcastBloc>().add(PresetChanged(preset));
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark ? AppColors.darkSurface1 : AppColors.lightSurface1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: selected
                              ? Border.all(
                                  color: isDark
                                      ? AppColors.darkAccent.withValues(alpha: 0.5)
                                      : AppColors.lightAccent.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Text(
                          preset.name == 'sparkle2'
                              ? 'Sparkle 2'
                              : preset.name == 'flutterUpgrader'
                                  ? 'Flutter Upgrader'
                                  : 'WinSparkle',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const Spacer(),

          // ─── Issues Badge ───
          BlocBuilder<AppcastBloc, AppcastState>(
            buildWhen: (prev, curr) => prev.issues != curr.issues,
            builder: (context, state) {
              if (state.issues.isEmpty) {
                return const TactileBadge(
                  label: 'XML VALID',
                  color: AppColors.darkSuccess,
                );
              }
              final errorCount = state.issues.where((i) => i.severity.name == 'error').length;
              return TactileBadge(
                label: '$errorCount issue${errorCount == 1 ? '' : 's'}',
                color: errorCount > 0 ? AppColors.darkDanger : AppColors.darkWarning,
                icon: Icons.info_outline,
              );
            },
          ),
          const SizedBox(width: 10),

          // ─── Import Button ───
          TactileButton(
            label: 'Import',
            icon: Icons.file_upload_outlined,
            compact: true,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const ImportDialog(),
              );
            },
          ),
          const SizedBox(width: 8),

          // ─── Download XML ───
          BlocBuilder<AppcastBloc, AppcastState>(
            buildWhen: (prev, curr) => prev.generatedXml != curr.generatedXml,
            builder: (context, state) {
              return TactileButton(
                label: 'Export .xml',
                icon: Icons.download_outlined,
                primary: true,
                compact: true,
                onPressed: state.generatedXml.isNotEmpty
                    ? () {
                        WebDownloadHelper.downloadString(
                          state.generatedXml,
                          'appcast.xml',
                        );
                      }
                    : null,
              );
            },
          ),
          const SizedBox(width: 8),

          // ─── Theme Toggle ───
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isThemeDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isThemeDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 18,
                ),
                tooltip: isThemeDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),

          // ─── Toggle Inspector on Wide Screens ───
          IconButton(
            icon: Icon(
              showInspector ? Icons.vertical_split : Icons.vertical_split_outlined,
              size: 18,
            ),
            tooltip: showInspector ? 'Hide XML Inspector' : 'Show XML Inspector',
            color: showInspector
                ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            onPressed: onToggleInspector,
          ),
        ],
      ),
    );
  }
}
