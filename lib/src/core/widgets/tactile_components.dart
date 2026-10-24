import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/color_tokens.dart';

/// Reusable tactile UI components crafted to satisfy anti-slop guidelines:
/// - No excessive pill radius (strictly 4px-6px)
/// - High contrast ratio (WCAG AA compliant)
/// - Visible focus and keyboard accessibility
/// - Functional completeness

class TactileButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool danger;
  final bool compact;

  const TactileButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.primary = false,
    this.danger = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border;

    if (danger) {
      bg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
      fg = isDark ? AppColors.darkDanger : AppColors.lightDanger;
      border = BorderSide(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA));
    } else if (primary) {
      bg = isDark ? AppColors.darkAccent : AppColors.lightAccent;
      fg = isDark ? AppColors.darkCanvas : Colors.white;
      border = BorderSide.none;
    } else {
      bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;
      fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      border = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 9,
          ),
          decoration: BoxDecoration(
            color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.fromBorderSide(border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 13 : 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11.5 : 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TactileBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const TactileBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: baseColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: baseColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class TactileTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool required;
  final String? helper;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isMonospace;

  const TactileTextField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.required = false,
    this.helper,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isMonospace = false,
  });

  @override
  State<TactileTextField> createState() => _TactileTextFieldState();
}

class _TactileTextFieldState extends State<TactileTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(TactileTextField old) {
    super.didUpdateWidget(old);
    final incoming = widget.value ?? '';
    if (_ctrl.text != incoming) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = widget.isMonospace
        ? AppTheme.monoStyle(isDark: isDark, fontSize: 12)
        : TextStyle(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            if (widget.required)
              const Text(' *', style: TextStyle(color: AppColors.darkDanger, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _ctrl,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: textStyle,
          decoration: InputDecoration(
            hintText: widget.hint,
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helper!,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class TactileSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?>? onChanged;
  final String? helper;

  const TactileSelectField({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validValue = options.any((o) => o.$1 == value)
        ? value
        : (options.isNotEmpty ? options.first.$1 : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: validValue,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o.$1,
                  child: Text(o.$2),
                ),
              )
              .toList(),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class TactileSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const TactileSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor ?? (isDark ? AppColors.darkAccent : AppColors.lightAccent),
        ),
      ],
    );
  }
}
