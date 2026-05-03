// lib/widgets/form_field_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

/// Controlled text field — controller selalu sync dengan [value].
/// Ketika [value] berubah dari luar (misal setelah import), field ikut update.
class AppFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value; // controlled — bukan initialValue
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool required;
  final String? helper;
  final Widget? suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  const AppFormField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.required = false,
    this.helper,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(AppFormField old) {
    super.didUpdateWidget(old);
    // Jika value dari luar berubah (misal import), update controller
    // tapi jangan ganggu cursor jika user sedang ngetik nilai yang sama
    final incoming = widget.value ?? '';
    if (_ctrl.text != incoming) {
      // Preserve cursor di akhir
      _ctrl.value = TextEditingValue(
        text: incoming,
        selection: TextSelection.collapsed(offset: incoming.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.danger, fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _ctrl,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly,
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.suffix,
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 3),
          Text(
            widget.helper!,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ],
    );
  }
}

/// Controlled dropdown — reactive terhadap perubahan [value] dari luar.
class AppSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?>? onChanged;
  final String? helper;

  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    // Pastikan value selalu valid — jika tidak ada di options, fallback ke opsi pertama
    final validValue = options.any((o) => o.$1 == value)
        ? value
        : (options.isNotEmpty ? options.first.$1 : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: validValue,
          onChanged: onChanged,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          dropdownColor: AppTheme.surface,
          decoration: const InputDecoration(),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o.$1,
                  child: Text(o.$2, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
        ),
        if (helper != null) ...[
          const SizedBox(height: 3),
          Text(
            helper!,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  const TagChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.withValues(alpha: .25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: c),
      ),
    );
  }
}
