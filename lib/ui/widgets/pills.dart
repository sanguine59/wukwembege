import 'package:flutter/material.dart';
import '../../theme.dart';

class Pills extends StatelessWidget {
  final List<String> items;
  final String? active;
  final ValueChanged<String> onChange;
  final bool wrap;
  const Pills({super.key, required this.items, required this.active, required this.onChange, this.wrap = false});

  @override
  Widget build(BuildContext context) {
    final children = items.map((it) {
      final on = active == it;
      return GestureDetector(
        onTap: () => onChange(it),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: on ? AppColors.blue : AppColors.surface,
            border: Border.all(color: on ? AppColors.blue : AppColors.border, width: 1.2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(it, style: TextStyle(color: on ? Colors.white : AppColors.ink, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ),
      );
    }).toList();

    if (wrap) {
      return Wrap(spacing: 8, runSpacing: 8, children: children);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          children[i],
        ],
      ]),
    );
  }
}

class SegmentedControl extends StatelessWidget {
  final List<String> items;
  final String active;
  final ValueChanged<String> onChange;
  const SegmentedControl({super.key, required this.items, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.1),
      ),
      child: Row(
        children: items.map((it) {
          final on = active == it;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(it),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: on ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: on ? AppShadows.sm : const [],
                ),
                alignment: Alignment.center,
                child: Text(it, style: TextStyle(color: on ? AppColors.ink : AppColors.text3, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
