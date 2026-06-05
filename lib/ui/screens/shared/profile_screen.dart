import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/profile.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final profile = vm.profile;
    if (profile == null) return const Center(child: CircularProgressIndicator());
    final isOrg = profile.role == Role.organizer;

    void go(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    final rows = [
      (icon: 'pencil', label: 'Edit profile', onTap: () => go(const EditProfileScreen())),
      (icon: 'settings', label: 'Settings', onTap: () => go(const SettingsScreen())),
      (icon: 'bell', label: 'Notifications', onTap: () => go(const SettingsScreen())),
      (icon: isOrg ? 'users' : 'star', label: isOrg ? 'My vendors' : 'Reviews & ratings', onTap: () {}),
      (icon: 'info', label: 'Help & support', onTap: () {}),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 14, 4),
          child: Row(
            children: [
              const Expanded(child: Text('Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: -0.02))),
              IconBtn(icon: 'settings', ghost: true, onPressed: () => go(const SettingsScreen())),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              AppCard(
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 20),
                child: Column(
                  children: [
                    isOrg
                        ? AvatarInitials(name: profile.owner, color: profile.color, size: 76)
                        : AppThumb(color: profile.color, glyph: profile.glyph, size: 76, radius: 22, glyphSize: 36),
                    const SizedBox(height: 12),
                    Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.02)),
                    const SizedBox(height: 3),
                    Text('${isOrg ? profile.roleLabel ?? 'Organizer' : profile.cuisine ?? ''} · ${profile.owner}',
                        style: const TextStyle(fontSize: 13.5, color: AppColors.text3, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    PlainBadge(
                      isOrg ? 'Organizer account' : 'Vendor account',
                      fg: AppColors.bluePress, bg: AppColors.blueSoft,
                      leading: AppIcon(isOrg ? 'calendar' : 'store', size: 12, color: AppColors.bluePress),
                    ),
                    const SizedBox(height: 14),
                    KpiRow(tiles: isOrg
                        ? [
                            KpiTile(value: '${profile.events ?? 0}', label: 'Events'),
                            KpiTile(value: '${profile.vendors ?? 0}', label: 'Vendors'),
                            const KpiTile(value: '4.9', label: 'Rating'),
                          ]
                        : [
                            KpiTile(value: '${profile.rating ?? 0}', label: 'Rating'),
                            KpiTile(value: '${profile.reviews ?? 0}', label: 'Reviews'),
                            KpiTile(value: '${profile.events ?? 0}', label: 'Events'),
                          ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final r in rows) ...[
                ListRow(
                  leading: SizedBox(width: 36, height: 36, child: Center(child: AppIcon(r.icon, size: 20, color: AppColors.text2))),
                  title: r.label,
                  trailing: const AppIcon('chevron-right', size: 18, color: AppColors.text4),
                  onTap: r.onTap,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blueSofter,
                  borderRadius: BorderRadius.circular(AppRadii.r),
                  border: Border.all(color: AppColors.blueLine, width: 1.1),
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(11)),
                        child: const Center(child: AppIcon('layers', size: 20, color: AppColors.blue)),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preview the other side', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            Text('Jump to the other role experience.', style: TextStyle(color: AppColors.text3, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Btn(
                      label: 'Switch to ${isOrg ? 'vendor' : 'organizer'}',
                      block: true, variant: BtnVariant.secondary,
                      onPressed: () => vm.switchRole(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Btn(label: 'Sign out', block: true, variant: BtnVariant.outline, icon: 'log-out', onPressed: () => vm.signOut()),
            ],
          ),
        ),
      ],
    );
  }
}
