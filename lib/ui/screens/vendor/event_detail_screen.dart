import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/event.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/sheet.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final ev = vm.browse.where((e) => e.id == eventId).firstOrNull;
    if (ev == null) return const Scaffold(body: Center(child: Text('Event not found')));
    final palette = kThumb[ev.color] ?? kThumb['blue']!;
    final taken = ev.taken ?? 0;
    final spotsLeft = ev.capacity - taken;
    final full = ev.joinState == 'full' || spotsLeft <= 0;
    final pct = ev.capacity == 0 ? 0.0 : taken / ev.capacity;
    final part = vm.participationFor(ev.id);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 110 + MediaQuery.of(context).padding.bottom),
              children: [
                Container(
                  height: 210,
                  color: palette.bg,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: .14,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(0.5, -0.6),
                                radius: 0.9,
                                colors: [Colors.white, Color(0x00FFFFFF)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10, top: 30,
                        child: AppIcon(ev.glyph, size: 120, color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      Positioned(
                        left: 14, right: 14, top: 8,
                        child: Row(
                          children: [
                            IconBtn(icon: 'arrow-left', onPressed: () => Navigator.of(context).pop()),
                            const Spacer(),
                            IconBtn(icon: 'share', onPressed: () => _toast(context, 'Link copied')),
                            const SizedBox(width: 6),
                            IconBtn(icon: 'bookmark'),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 22, right: 22, bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ev.status == EventStatus.live
                                ? const StatusBadge('live')
                                : PlainBadge(ev.type, bg: const Color(0xE6FFFFFF), fg: AppColors.ink),
                            const SizedBox(height: 8),
                            Text(
                              ev.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.02),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        AvatarInitials(name: ev.organizer ?? 'Org', color: 'blue', size: 36),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Organized by', style: TextStyle(fontSize: 11.5, color: AppColors.text3, fontWeight: FontWeight.w800)),
                            Text(ev.organizer ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 18),
                      _factRow('calendar', ev.dateLabel, ev.time),
                      const SizedBox(height: 8),
                      _factRow('map-pin', ev.location, ev.city),
                      const SizedBox(height: 8),
                      _factRow('dollar', '\$${ev.fee} per stall', 'Paid on confirmation'),
                      const SizedBox(height: 18),
                      AppCard(
                        child: Column(
                          children: [
                            Row(children: [
                              const Expanded(child: Text('Stall availability', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                              PlainBadge(
                                full ? 'Full' : '$spotsLeft of ${ev.capacity} open',
                                fg: full ? AppColors.text3 : AppColors.green,
                                bg: full ? AppColors.canvas : AppColors.greenSoft,
                              ),
                            ]),
                            const SizedBox(height: 11),
                            ProgressBar(pct: pct, fill: full ? AppColors.text4 : AppColors.blue),
                            const SizedBox(height: 7),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('$taken vendors booked so far', style: const TextStyle(fontSize: 12, color: AppColors.text3, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('About this event', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.text2)),
                      const SizedBox(height: 6),
                      Text(ev.desc, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.text2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 7, runSpacing: 6, children: [
                        for (final t in ev.tags) PlainBadge(t),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 6 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
                child: _joinBar(context, ev, part?.status, full, vm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _factRow(String icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(12)),
          child: Center(child: AppIcon(icon, size: 19, color: AppColors.blue)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _joinBar(BuildContext context, Event ev, String? status, bool full, AppViewModel vm) {
    if (status == 'confirmed') {
      final spot = vm.participationFor(ev.id)?.spot ?? '';
      return Row(children: [
        const AppIcon('check-circle', size: 20, color: AppColors.green),
        const SizedBox(width: 8),
        Expanded(child: Text('Confirmed · spot $spot', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800))),
        const SizedBox(width: 10),
        Btn(label: 'Withdraw', variant: BtnVariant.outline, onPressed: () => _withdrawDialog(context, ev, vm)),
      ]);
    }
    if (status == 'pending') {
      return Row(children: [
        Expanded(child: Btn(label: 'Application pending', block: true, variant: BtnVariant.secondary, disabled: true)),
        const SizedBox(width: 10),
        Btn(label: 'Cancel', variant: BtnVariant.outline, onPressed: () => _withdrawDialog(context, ev, vm)),
      ]);
    }
    if (full) {
      return Btn(
        label: 'Join waitlist', block: true, size: BtnSize.lg, variant: BtnVariant.outline,
        onPressed: () async { await vm.joinEvent(ev.id, 'waitlist'); if (context.mounted) _toast(context, 'Added to waitlist'); },
      );
    }
    return Btn(
      label: 'Apply for a stall · \$${ev.fee}', icon: 'store', block: true, size: BtnSize.lg,
      onPressed: () => _applySheet(context, ev, vm),
    );
  }

  void _applySheet(BuildContext ctx, Event ev, AppViewModel vm) {
    final noteCtrl = TextEditingController();
    showAppSheet(
      context: ctx, title: 'Apply for a stall',
      foot: Btn(
        label: 'Send application', icon: 'send', block: true, size: BtnSize.lg,
        onPressed: () async {
          await vm.joinEvent(ev.id, 'pending');
          if (ctx.mounted) { Navigator.of(ctx).pop(); _toast(ctx, 'Application sent to ${ev.organizer}'); }
        },
      ),
      builder: (sheetCtx) {
        final profile = vm.profile;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueSofter,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.blueLine, width: 1.1),
              ),
              child: Row(children: [
                AppThumb(color: profile?.color ?? 'indigo', glyph: profile?.glyph ?? 'utensils', size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                      Text('${profile?.cuisine ?? ''} · applying as you', style: const TextStyle(color: AppColors.text3, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Field(
              label: 'Note to organizer', hint: "Tell them what you'll bring to the event.",
              child: AppTextInput(controller: noteCtrl, placeholder: 'e.g. Hand-folded dumplings & bao, fully self-powered setup…', minLines: 3, maxLines: 6),
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Meta(icon: 'dollar', text: 'Stall fee'),
              const Spacer(),
              Text.rich(TextSpan(children: [
                TextSpan(text: '\$${ev.fee}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const TextSpan(text: ' · on approval', style: TextStyle(color: AppColors.text3, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ])),
            ]),
          ],
        );
      },
    );
  }

  void _withdrawDialog(BuildContext ctx, Event ev, AppViewModel vm) {
    showAppDialog(
      context: ctx, icon: 'alert', iconColor: AppColors.amber, iconBg: AppColors.amberSoft,
      title: 'Withdraw from this event?',
      body: "You'll lose your spot at \"${ev.name}\". You can re-apply while spots remain.",
      actions: Column(children: [
        Btn(label: 'Withdraw', block: true, variant: BtnVariant.danger, onPressed: () async {
          await vm.withdraw(ev.id);
          if (ctx.mounted) { Navigator.of(ctx).pop(); _toast(ctx, 'Withdrawn'); }
        }),
        const SizedBox(height: 8),
        Btn(label: 'Keep my spot', block: true, variant: BtnVariant.ghost, onPressed: () => Navigator.of(ctx).pop()),
      ]),
    );
  }

  void _toast(BuildContext ctx, String m) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(m)));
}
