import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';
import '../../bloc/appcast_state.dart';

class FeedMetadataCard extends StatefulWidget {
  const FeedMetadataCard({super.key});

  @override
  State<FeedMetadataCard> createState() => _FeedMetadataCardState();
}

class _FeedMetadataCardState extends State<FeedMetadataCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AppcastBloc, AppcastState>(
      builder: (context, state) {
        final feed = state.feed;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(8),
                  bottom: Radius.circular(_expanded ? 0 : 8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Feed Channel Settings',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TactileTextField(
                              label: 'Feed Title',
                              hint: 'My App Updates',
                              value: feed.title,
                              required: true,
                              onChanged: (v) => context.read<AppcastBloc>().add(
                                FeedUpdated(feed.copyWith(title: v)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TactileSelectField(
                              label: 'Language',
                              value: feed.language,
                              options: const [
                                ('en', 'English (en)'),
                                ('id', 'Indonesian (id)'),
                                ('ja', 'Japanese (ja)'),
                                ('zh', 'Chinese (zh)'),
                                ('de', 'German (de)'),
                                ('fr', 'French (fr)'),
                                ('es', 'Spanish (es)'),
                                ('ko', 'Korean (ko)'),
                              ],
                              onChanged: (v) => context.read<AppcastBloc>().add(
                                FeedUpdated(feed.copyWith(language: v ?? 'en')),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TactileTextField(
                        label: 'Application Website URL',
                        hint: 'https://example.com',
                        value: feed.link,
                        required: true,
                        helper: 'The public web page associated with this software project',
                        onChanged: (v) => context.read<AppcastBloc>().add(
                          FeedUpdated(feed.copyWith(link: v)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TactileTextField(
                        label: 'Feed Description',
                        hint: 'Latest updates and version changelogs',
                        value: feed.description,
                        onChanged: (v) => context.read<AppcastBloc>().add(
                          FeedUpdated(feed.copyWith(description: v)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TactileTextField(
                        label: 'Appcast Hosting URL (atom:link self)',
                        hint: 'https://example.com/appcast.xml',
                        value: feed.atomLink,
                        isMonospace: true,
                        helper: 'Recommended for RSS readers and Sparkle cache invalidation',
                        onChanged: (v) => context.read<AppcastBloc>().add(
                          FeedUpdated(feed.copyWith(atomLink: v)),
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
