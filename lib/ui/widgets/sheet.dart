import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext) builder,
  Widget? foot,
  Widget? trailing,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return AppSheet(title: title, foot: foot, trailing: trailing, child: builder(ctx));
    },
  );
}

class AppSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? foot;
  final Widget? trailing;
  const AppSheet({super.key, required this.title, required this.child, this.foot, this.trailing});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 7),
            Container(width: 44, height: 4.5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 14, 10),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.02))),
                  ?trailing,
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(padding: EdgeInsets.all(6), child: AppIcon('x', size: 20)),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: child,
              ),
            ),
            if (foot != null)
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                  color: AppColors.surface,
                ),
                child: foot,
              ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  String? icon,
  Color iconColor = AppColors.blue,
  Color iconBg = AppColors.blueSoft,
  required String title,
  String? body,
  required Widget actions,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                width: 56, height: 56,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                child: Center(child: AppIcon(icon, size: 28, color: iconColor)),
              ),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: AppColors.text2, height: 1.5, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 18),
            actions,
          ],
        ),
      ),
    ),
  );
}
