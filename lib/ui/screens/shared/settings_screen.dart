import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final groups = const [
      (
        header: 'Notifications',
        rows: [
          (key: 'pushApps', label: 'New applications', sub: 'When a vendor applies to your event'),
          (key: 'pushUpdates', label: 'Status updates', sub: 'Approvals, declines and reminders'),
          (key: 'email', label: 'Email digest', sub: 'A weekly summary in your inbox'),
        ],
      ),
      (
        header: 'Privacy',
        rows: [
          (key: 'visible', label: 'Public profile', sub: 'Let organizers discover you'),
          (key: 'location', label: 'Share location', sub: 'Show nearby events first'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(title: 'Settings', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: StreamBuilder<Map<String, bool>>(
                stream: vm.settingsStream(),
                builder: (ctx, snap) {
                  final s = snap.data ?? const {};
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    children: [
                      for (final g in groups) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(g.header.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                        ),
                        for (final r in g.rows) ...[
                          ListRow(
                            title: r.label, subtitle: r.sub,
                            trailing: _Toggle(value: s[r.key] ?? false, onChanged: (v) => vm.setSetting(r.key, v)),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 10),
                      ],
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('ACCOUNT', style: TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                      ),
                      const ListRow(title: 'Change password', trailing: AppIcon('chevron-right', size: 18, color: AppColors.text4)),
                      const SizedBox(height: 8),
                      const ListRow(title: 'Payment methods', trailing: AppIcon('chevron-right', size: 18, color: AppColors.text4)),
                      const SizedBox(height: 8),
                      const ListRow(title: 'Delete account', titleColor: AppColors.red, trailing: AppIcon('chevron-right', size: 18, color: AppColors.text4)),
                      const SizedBox(height: 18),
                      const Center(child: Text('wukwembege · v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.text4, fontWeight: FontWeight.w700))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46, height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.blue : AppColors.border,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            top: 3,
            left: value ? 21 : 3,
            child: Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.sm),
            ),
          ),
        ]),
      ),
    );
  }
}
