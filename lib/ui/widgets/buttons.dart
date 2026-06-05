import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

enum BtnVariant { primary, secondary, outline, ghost, danger, success }
enum BtnSize { sm, md, lg }

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final BtnSize size;
  final bool block;
  final String? icon;
  final String? iconRight;
  final bool disabled;
  const Btn({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.md,
    this.block = false,
    this.icon,
    this.iconRight,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSm = size == BtnSize.sm;
    final isLg = size == BtnSize.lg;
    final pad = EdgeInsets.symmetric(
      horizontal: isSm ? 12 : isLg ? 18 : 16,
      vertical: isSm ? 8 : isLg ? 15 : 12,
    );
    final fontSize = isSm ? 13.0 : isLg ? 15.0 : 14.0;
    final iconSize = isSm ? 16.0 : 18.0;

    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow> shadow = const [];
    switch (variant) {
      case BtnVariant.primary:
        bg = AppColors.blue; fg = Colors.white; shadow = AppShadows.blue;
        break;
      case BtnVariant.secondary:
        bg = AppColors.blueSoft; fg = AppColors.bluePress;
        break;
      case BtnVariant.outline:
        bg = Colors.white; fg = AppColors.ink;
        border = Border.all(color: AppColors.border, width: 1.4);
        break;
      case BtnVariant.ghost:
        bg = Colors.transparent; fg = AppColors.text2;
        break;
      case BtnVariant.danger:
        bg = AppColors.red; fg = Colors.white;
        break;
      case BtnVariant.success:
        bg = AppColors.green; fg = Colors.white;
        break;
    }
    if (disabled) {
      bg = variant == BtnVariant.primary ? const Color(0xFFB7C8F0) : bg;
      fg = variant == BtnVariant.primary ? Colors.white : AppColors.text4;
      shadow = const [];
    }

    final child = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          AppIcon(icon!, size: iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: fontSize, letterSpacing: -0.01)),
        if (iconRight != null) ...[
          const SizedBox(width: 8),
          AppIcon(iconRight!, size: iconSize, color: fg),
        ],
      ],
    );

    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: disabled ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: border,
              boxShadow: shadow,
            ),
            child: Padding(padding: pad, child: child),
          ),
        ),
      ),
    );
  }
}

class IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final bool ghost;
  final Color? color;
  final Color? bg;
  final Color? borderColor;
  final double size;
  final String? tooltip;
  const IconBtn({
    super.key,
    required this.icon,
    this.onPressed,
    this.ghost = false,
    this.color,
    this.bg,
    this.borderColor,
    this.size = 38,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final w = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: bg ?? (ghost ? Colors.transparent : Colors.white),
            border: ghost ? null : Border.all(color: borderColor ?? AppColors.border, width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: size, height: size,
            child: Center(child: AppIcon(icon, size: 19, color: color ?? AppColors.ink)),
          ),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: w) : w;
  }
}
