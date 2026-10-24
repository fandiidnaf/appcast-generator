import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/tactile_components.dart';
import '../../bloc/appcast_bloc.dart';
import '../../bloc/appcast_event.dart';
import '../../bloc/appcast_state.dart';
import '../widgets/feed_metadata_card.dart';
import '../widgets/release_card.dart';
import '../widgets/studio_header.dart';
import '../widgets/xml_inspector_panel.dart';

class AppcastStudioScreen extends StatefulWidget {
  const AppcastStudioScreen({super.key});

  @override
  State<AppcastStudioScreen> createState() => _AppcastStudioScreenState();
}

class _AppcastStudioScreenState extends State<AppcastStudioScreen> {
  bool _showInspector = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
      body: Column(
        children: [
          StudioHeader(
            showInspector: _showInspector,
            onToggleInspector: () => setState(() => _showInspector = !_showInspector),
          ),
          Expanded(
            child: isWide
                ? _buildWideWorkspace(isDark)
                : _buildNarrowWorkspace(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWideWorkspace(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Editor Pane
        Expanded(
          flex: _showInspector ? 11 : 20,
          child: const _EditorPane(),
        ),

        // Right XML Inspector Pane
        if (_showInspector) ...[
          VerticalDivider(
            width: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const Expanded(
            flex: 9,
            child: XmlInspectorPanel(),
          ),
        ],
      ],
    );
  }

  Widget _buildNarrowWorkspace(bool isDark) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
            child: TabBar(
              indicatorColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              labelColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              tabs: const [
                Tab(text: 'Feed & Releases Editor'),
                Tab(text: 'XML Inspector'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _EditorPane(),
                XmlInspectorPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AppcastBloc, AppcastState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FeedMetadataCard(),
            const SizedBox(height: 16),

            // Releases Header
            Row(
              children: [
                Text(
                  'Releases',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                TactileBadge(
                  label: '${state.items.length}',
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
                const Spacer(),
                TactileButton(
                  label: 'Add Release',
                  icon: Icons.add,
                  primary: true,
                  compact: true,
                  onPressed: () {
                    context.read<AppcastBloc>().add(const ReleaseAdded());
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (state.items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.layers_clear_outlined,
                        size: 32,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No releases authored yet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create your first version release to generate the appcast XML.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TactileButton(
                        label: 'Add First Release',
                        icon: Icons.add,
                        primary: true,
                        onPressed: () {
                          context.read<AppcastBloc>().add(const ReleaseAdded());
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                onReorderItem: (oldIdx, newIdx) {
                  context.read<AppcastBloc>().add(ReleaseReordered(oldIdx, newIdx));
                },
                buildDefaultDragHandles: false,
                itemBuilder: (ctx, idx) {
                  final item = state.items[idx];
                  return ReorderableDragStartListener(
                    key: ValueKey(item.id),
                    index: idx,
                    child: Padding(
                      key: ValueKey(item.id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ReleaseCard(
                        item: item,
                        index: idx,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
