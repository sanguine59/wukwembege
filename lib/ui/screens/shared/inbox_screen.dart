import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/notif.dart';
import '../../../models/profile.dart';
import '../../../models/stall.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../organizer/event_manage_screen.dart';
import '../vendor/event_detail_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final notifs = vm.notifs;
    final fresh = notifs.where((n) => !n.read).toList();
    final earlier = notifs.where((n) => n.read).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 14, 4),
          child: Row(
            children: [
              const Expanded(child: Text('Inbox', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: -0.02))),
              if (fresh.isNotEmpty)
                TextButton(
                  onPressed: () => vm.markAllRead(),
                  child: const Text('Mark all read', style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        ),
        Expanded(
          child: notifs.isEmpty
              ? const Center(child: EmptyState(icon: 'inbox', title: "You're all caught up", sub: 'New applications and updates will land here.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                  children: [
                    if (fresh.isNotEmpty) ...[
                      SectionHead(title: 'New · ${fresh.length}'),
                      for (final n in fresh) ...[_NotifRow(n: n), const SizedBox(height: 8)],
                      const SizedBox(height: 10),
                    ],
                    if (earlier.isNotEmpty) ...[
                      const SectionHead(title: 'Earlier'),
                      for (final n in earlier) ...[_NotifRow(n: n), const SizedBox(height: 8)],
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _NotifRow extends StatelessWidget {
  final Notif n;
  const _NotifRow({required this.n});

  ({String icon, Color fg, Color bg}) _style() {
    switch (n.kind) {
      case 'application': return (icon: 'store', fg: AppColors.blue, bg: AppColors.blueSoft);
      case 'accepted':    return (icon: 'check-circle', fg: AppColors.green, bg: AppColors.greenSoft);
      case 'invite':      return (icon: 'sparkles', fg: AppColors.violet, bg: AppColors.violetSoft);
      case 'info':        return (icon: 'info', fg: AppColors.amber, bg: AppColors.amberSoft);
      default:            return (icon: 'bell', fg: AppColors.text2, bg: AppColors.canvas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final s = _style();
    final tappable = n.eventId != null;
    void goTo() {
      vm.markRead(n.id);
      if (vm.role == Role.organizer && n.eventId != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventManageScreen(eventId: n.eventId!)));
      } else if (n.eventId != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: n.eventId!)));
      }
    }

    return AppCard(
      onTap: tappable ? goTo : null,
      color: n.read ? AppColors.surface : AppColors.blueSofter,
      border: Border.all(color: n.read ? AppColors.border : AppColors.blueLine, width: 1.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: AppIcon(s.icon, size: 21, color: s.fg)),
            ),
            if (!n.read)
              const Positioned(
                top: -3, right: -3,
                child: SizedBox(
                  width: 10, height: 10,
                  child: DecoratedBox(decoration: BoxDecoration(color: AppColors.blue, shape: BoxShape.circle)),
                ),
              ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: n.actor, style: const TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: ' ${n.text}'),
                    if (n.cuisine != null) TextSpan(text: ' · ${n.cuisine}', style: const TextStyle(color: AppColors.text3)),
                  ]),
                  style: const TextStyle(fontSize: 13.5, height: 1.45, color: AppColors.ink, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${n.time}${n.eventName.isNotEmpty && n.kind != 'system' ? ' · ${n.eventName}' : ''}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.text3, fontWeight: FontWeight.w800),
                ),
                if (n.resolved != null) ...[
                  const SizedBox(height: 8),
                  PlainBadge(
                    n.resolved == 'confirmed' ? 'Approved' : n.resolved == 'declined' ? 'Declined' : 'Done',
                    fg: n.resolved == 'confirmed' ? AppColors.green : n.resolved == 'declined' ? AppColors.red : AppColors.bluePress,
                    bg: n.resolved == 'confirmed' ? AppColors.greenSoft : n.resolved == 'declined' ? AppColors.redSoft : AppColors.blueSoft,
                    leading: AppIcon(n.resolved == 'declined' ? 'x-circle' : 'check-circle', size: 12,
                        color: n.resolved == 'confirmed' ? AppColors.green : n.resolved == 'declined' ? AppColors.red : AppColors.bluePress),
                  ),
                ],
                if (n.actionable && n.resolved == null) ...[
                  const SizedBox(height: 11),
                  Row(children: vm.role == Role.organizer
                      ? [
                          Btn(label: 'Approve', size: BtnSize.sm, variant: BtnVariant.success, icon: 'check', onPressed: () async {
                            if (n.stallId != null && n.eventId != null) {
                              await vm.setStallStatus(n.eventId!, n.stallId!, StallStatus.confirmed);
                            }
                            await vm.resolveNotif(n.id, 'confirmed');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${n.actor} confirmed')));
                          }),
                          const SizedBox(width: 8),
                          Btn(label: 'Decline', size: BtnSize.sm, variant: BtnVariant.outline, onPressed: () async {
                            if (n.stallId != null && n.eventId != null) {
                              await vm.setStallStatus(n.eventId!, n.stallId!, StallStatus.declined);
                            }
                            await vm.resolveNotif(n.id, 'declined');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${n.actor} declined')));
                          }),
                          const Spacer(),
                          Btn(label: 'View', size: BtnSize.sm, variant: BtnVariant.ghost, onPressed: goTo),
                        ]
                      : [
                          Btn(label: 'Apply now', size: BtnSize.sm, icon: 'send', onPressed: () async {
                            if (n.eventId != null) await vm.joinEvent(n.eventId!, 'pending');
                            await vm.resolveNotif(n.id, 'done');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application sent')));
                          }),
                          const SizedBox(width: 8),
                          Btn(label: 'View event', size: BtnSize.sm, variant: BtnVariant.outline, onPressed: goTo),
                        ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
