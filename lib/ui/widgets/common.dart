import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap, this.color, this.border});

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.r),
        border: border ?? Border.all(color: AppColors.border, width: 1.1),
        boxShadow: onTap != null ? AppShadows.sm : const [],
      ),
      child: child,
    );
    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.r),
        child: container,
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHead({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6, left: 4, right: 2),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, letterSpacing: -0.01)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class Meta extends StatelessWidget {
  final String icon;
  final String text;
  const Meta({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 14, color: AppColors.text3),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text2, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? sub;
  final Widget? child;
  const EmptyState({super.key, this.icon = 'inbox', required this.title, this.sub, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: AppIcon('inbox', size: 28, color: AppColors.blue)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text3, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
          if (child != null) ...[const SizedBox(height: 14), child!],
        ],
      ),
    );
  }
}

class KpiTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final Color? bg;
  final Color? borderColor;
  const KpiTile({super.key, required this.value, required this.label, this.valueColor, this.bg, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(
        color: bg ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: valueColor ?? AppColors.ink, letterSpacing: -0.02)),
          const SizedBox(height: 1),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: valueColor != null ? valueColor!.withValues(alpha: 0.92) : AppColors.text3)),
        ],
      ),
    );
  }
}

class KpiRow extends StatelessWidget {
  final List<Widget> tiles;
  const KpiRow({super.key, required this.tiles});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double pct; // 0..1
  final Color? fill;
  const ProgressBar({super.key, required this.pct, this.fill});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: pct.clamp(0, 1).toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: fill ?? AppColors.blue,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> trailing;
  final bool leftAlign;
  const HeaderBar({super.key, this.title, this.subtitle, this.onBack, this.trailing = const [], this.leftAlign = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(width: 38, height: 38, child: Center(child: AppIcon('arrow-left', size: 21))),
            )
          else if (!leftAlign)
            const SizedBox(width: 38),
          Expanded(
            child: Column(
              crossAxisAlignment: leftAlign ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                if (title != null)
                  Text(title!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.02), overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(color: AppColors.text3, fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: [for (final t in trailing) Padding(padding: const EdgeInsets.only(left: 4), child: t)])
          else if (!leftAlign)
            const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? borderColor;
  const ListRow({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap, this.titleColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1.1),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 11)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: titleColor ?? AppColors.ink), overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(color: AppColors.text3, fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
