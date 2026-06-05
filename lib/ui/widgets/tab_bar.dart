import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

class TabSpec {
  final String id;
  final String label;
  final String icon;
  final int badge;
  const TabSpec({required this.id, required this.label, required this.icon, this.badge = 0});
}

class AppTabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  final List<TabSpec> tabs;
  const AppTabBar({super.key, required this.active, required this.onChange, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(top: 8, bottom: bottom + 6, left: 6, right: 6),
      child: Row(
        children: tabs.map((t) {
          final on = t.id == active;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChange(t.id),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AppIcon(t.icon, size: 23, color: on ? AppColors.blue : AppColors.text3),
                          if (t.badge > 0)
                            Positioned(
                              top: -3, right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.surface, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text('${t.badge}', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(t.label, style: TextStyle(color: on ? AppColors.blue : AppColors.text3, fontSize: 10.5, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
