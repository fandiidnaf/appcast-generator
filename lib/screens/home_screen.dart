import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appcast_provider.dart';
import '../utils/theme.dart';
import '../widgets/feed_config_panel.dart';
import '../widgets/appcast_item_card.dart';
import '../widgets/xml_preview_panel.dart';
import '../utils/download_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPreview = true;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          _AppHeader(
              showPreview: _showPreview,
              onTogglePreview: () =>
                  setState(() => _showPreview = !_showPreview)),
          Expanded(
            child: isWide
                ? _WideLayout(showPreview: _showPreview)
                : _NarrowLayout(showPreview: _showPreview),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final bool showPreview;
  final VoidCallback onTogglePreview;
  const _AppHeader({required this.showPreview, required this.onTogglePreview});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.headerHeight,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ── Logo ──
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.rss_feed_rounded,
                size: 15, color: Colors.white),
          ),
          const SizedBox(width: 9),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appcast Generator',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('Sparkle · flutter_upgrader',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const Spacer(),
          // ── Actions ──
          Consumer<AppcastProvider>(builder: (ctx, provider, _) {
            return Row(children: [
              if (provider.items.isNotEmpty) ...[
                _Pill(
                    '${provider.items.length} release${provider.items.length == 1 ? '' : 's'}'),
                const SizedBox(width: 8),
              ],
              _HBtn(
                  icon: Icons.upload_file_outlined,
                  label: 'Import',
                  onTap: () => _showImportDialog(context, provider)),
              const SizedBox(width: 6),
              if (provider.generatedXml.isNotEmpty) ...[
                _HBtn(
                    icon: Icons.download_rounded,
                    label: 'Download .xml',
                    filled: true,
                    onTap: () => DownloadHelper.downloadXml(
                        provider.generatedXml, 'appcast.xml')),
                const SizedBox(width: 6),
              ],
            ]);
          }),
          // ── Preview toggle ──
          _ToggleChip(active: showPreview, onTap: onTogglePreview),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext ctx, AppcastProvider provider) {
    showDialog(
      context: ctx,
      builder: (dctx) => _ImportDialog(provider: provider),
    );
  }
}

// ─── Layouts ──────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final bool showPreview;
  const _WideLayout({required this.showPreview});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: showPreview ? 11 : 20, child: const _EditorColumn()),
      if (showPreview) ...[
        Container(width: 1, color: AppTheme.border),
        Expanded(
            flex: 9,
            child:
                Container(color: AppTheme.bg, child: const XmlPreviewPanel())),
      ],
    ]);
  }
}

class _NarrowLayout extends StatelessWidget {
  final bool showPreview;
  const _NarrowLayout({required this.showPreview});

  @override
  Widget build(BuildContext context) {
    if (!showPreview) return const _EditorColumn();
    return DefaultTabController(
        length: 2,
        child: Column(children: [
          Container(
            color: AppTheme.surface,
            child: const TabBar(
                tabs: [Tab(text: 'Editor'), Tab(text: 'XML Preview')]),
          ),
          const Expanded(
              child:
                  TabBarView(children: [_EditorColumn(), XmlPreviewPanel()])),
        ]));
  }
}

// ─── Editor Column ────────────────────────────────────────────────────────────
class _EditorColumn extends StatelessWidget {
  const _EditorColumn();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppcastProvider>(builder: (ctx, provider, _) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
        children: [
          const FeedConfigPanel(),
          const SizedBox(height: 14),
          // ── Releases header ──
          Row(children: [
            const Text('Releases',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(width: 7),
            if (provider.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${provider.items.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: provider.addItem,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Release'),
            ),
          ]),
          const SizedBox(height: 10),

          if (provider.items.isEmpty) _EmptyState(onAdd: provider.addItem),

          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.items.length,
            onReorder: provider.reorderItems,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, _, anim) => Material(
                color: Colors.transparent,
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: child),
            itemBuilder: (ctx, idx) {
              final item = provider.items[idx];
              return ReorderableDragStartListener(
                key: ValueKey(item.id),
                index: idx,
                child: Padding(
                  key: ValueKey(item.id),
                  padding: EdgeInsets.only(
                      bottom: idx < provider.items.length - 1 ? 10 : 0),
                  child: AppcastItemCard(item: item),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryBorder),
          ),
          child: const Icon(Icons.rocket_launch_outlined,
              size: 22, color: AppTheme.primary),
        ),
        const SizedBox(height: 12),
        const Text('No releases yet',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 5),
        const Text('Add your first release to generate appcast.xml',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Add Release')),
      ]),
    );
  }
}

// ─── Micro widgets ────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.accentBorder),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.accent)),
    );
  }
}

class _HBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _HBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.filled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border:
              Border.all(color: filled ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 13, color: filled ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: filled ? Colors.white : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _ToggleChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: active ? 'Hide XML' : 'Show XML',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBg : AppTheme.surfaceInset,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: active ? AppTheme.primaryBorder : AppTheme.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.code_rounded,
                size: 13,
                color: active ? AppTheme.primary : AppTheme.textMuted),
            const SizedBox(width: 4),
            Text('XML',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? AppTheme.primary : AppTheme.textMuted)),
          ]),
        ),
      ),
    );
  }
}

// ─── Import Dialog ────────────────────────────────────────────────────────────
class _ImportDialog extends StatefulWidget {
  final AppcastProvider provider;
  const _ImportDialog({required this.provider});

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _loadedFileName;
  String? _error;

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

    final result = await FilePickerHelper.pickXmlFile();

    if (!mounted) return;

    if (result == null) {
      // User cancelled
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = false;
      _loadedFileName = result.name;
      _ctrl.text = result.content;
    });
  }

  void _doImport() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Paste XML content or pick a file first.');
      return;
    }
    widget.provider.loadFromXml(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Text('Import Appcast XML',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              const Text('Load an existing appcast.xml to edit',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),

              const SizedBox(height: 16),

              // ── Pick file button ──
              InkWell(
                onTap: _loading ? null : _pickFile,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _loadedFileName != null
                        ? AppTheme.accentBg
                        : AppTheme.primaryBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _loadedFileName != null
                          ? AppTheme.accentBorder
                          : AppTheme.primaryBorder,
                    ),
                  ),
                  child: _loading
                      ? const Center(
                          child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _loadedFileName != null
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_file_outlined,
                              size: 18,
                              color: _loadedFileName != null
                                  ? AppTheme.accent
                                  : AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _loadedFileName != null
                                  ? _loadedFileName!
                                  : 'Click to pick appcast.xml file',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _loadedFileName != null
                                    ? AppTheme.accent
                                    : AppTheme.primary,
                              ),
                            ),
                            if (_loadedFileName != null) ...[
                              const SizedBox(width: 8),
                              const Text('(tap to change)',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Divider OR ──
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or paste below',
                      style:
                          TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ),
                Expanded(child: Divider()),
              ]),

              const SizedBox(height: 10),

              // ── Paste area ──
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceInset,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color:
                          _error != null ? AppTheme.danger : AppTheme.border),
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: 9,
                  style: AppTheme.monoStyle,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: const InputDecoration(
                    hintText:
                        '<?xml version="1.0" encoding="utf-8"?>\n<rss version="2.0" ...>\n  <channel>\n    ...\n  </channel>\n</rss>',
                    hintStyle:
                        TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),

              // ── Error ──
              if (_error != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.error_outline,
                      size: 13, color: AppTheme.danger),
                  const SizedBox(width: 5),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.danger)),
                ]),
              ],

              const SizedBox(height: 16),

              // ── Actions ──
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _doImport,
                  icon: const Icon(Icons.download_done_rounded, size: 15),
                  label: const Text('Import'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
