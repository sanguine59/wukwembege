import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/event.dart';
import '../../../models/stall.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';
import 'event_edit_screen.dart';
import 'event_manage_screen.dart';

class OrgHomeScreen extends StatelessWidget {
  const OrgHomeScreen({super.key});

  void _go(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final profile = vm.profile;
    final events = vm.events;
    final active = events.where((e) => e.status != EventStatus.past).toList();
    final past = events.where((e) => e.status == EventStatus.past).toList();
    final totalPending = events.fold<int>(0, (n, e) => n + e.stalls.where((s) => s.status == StallStatus.pending).length);
    final totalConfirmed = events.fold<int>(0, (n, e) => n + e.stalls.where((s) => s.status == StallStatus.confirmed).length);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back', style: TextStyle(color: AppColors.text3, fontWeight: FontWeight.w800, fontSize: 13)),
                        Text(
                          '${profile?.owner.split(' ').first ?? ''} 👋',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.02),
                        ),
                      ],
                    ),
                  ),
                  AvatarInitials(name: profile?.owner ?? 'You', color: profile?.color ?? 'blue', size: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                children: [
                  KpiRow(tiles: [
                    KpiTile(value: '${active.length}', label: 'Active events'),
                    KpiTile(value: '$totalConfirmed', label: 'Confirmed stalls'),
                    KpiTile(
                      value: '$totalPending', label: 'To review',
                      valueColor: totalPending > 0 ? AppColors.amber : AppColors.ink,
                      bg: totalPending > 0 ? AppColors.amberSoft : null,
                      borderColor: totalPending > 0 ? AppColors.amber : null,
                    ),
                  ]),
                  const SizedBox(height: 18),
                  const SectionHead(title: 'Active events'),
                  if (active.isEmpty)
                    EmptyState(
                      icon: 'calendar',
                      title: 'No active events',
                      sub: 'Tap the + button to create your first event.',
                      child: Btn(
                        label: 'New event', icon: 'plus',
                        onPressed: () => _go(context, const EventEditScreen()),
                      ),
                    )
                  else
                    for (final e in active) ...[
                      _OrgEventCard(ev: e, onTap: () => _go(context, EventManageScreen(eventId: e.id))),
                      const SizedBox(height: 10),
                    ],
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const SectionHead(title: 'Archived'),
                    for (final e in past) ...[
                      _PastEventRow(ev: e, onTap: () => _go(context, EventManageScreen(eventId: e.id))),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 18, bottom: 18,
          child: _Fab(onTap: () => _go(context, const EventEditScreen())),
        ),
      ],
    );
  }
}

class _OrgEventCard extends StatelessWidget {
  final Event ev;
  final VoidCallback onTap;
  const _OrgEventCard({required this.ev, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pending = ev.stalls.where((s) => s.status == StallStatus.pending).length;
    final confirmed = ev.stalls.where((s) => s.status == StallStatus.confirmed).length;
    final pct = ev.capacity == 0 ? 0.0 : (confirmed / ev.capacity);
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppThumb(color: ev.color, glyph: ev.glyph, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(ev.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, letterSpacing: -0.01))),
                        const SizedBox(width: 6),
                        StatusBadge.event(ev.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(spacing: 12, runSpacing: 6, children: [
                      Meta(icon: 'calendar', text: ev.dateLabel),
                      Meta(icon: 'map-pin', text: ev.city),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppColors.divider, height: 1)),
          Row(
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$confirmed', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  TextSpan(text: '/${ev.capacity}', style: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
              ),
              const SizedBox(width: 6),
              const Text('stalls filled', style: TextStyle(fontSize: 12.5, color: AppColors.text3, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (pending > 0)
                PlainBadge(
                  '$pending to review',
                  fg: AppColors.amber, bg: AppColors.amberSoft,
                  leading: const AppIcon('hourglass', size: 12, color: AppColors.amber),
                ),
            ],
          ),
          const SizedBox(height: 9),
          ProgressBar(pct: pct),
        ],
      ),
    );
  }
}

class _PastEventRow extends StatelessWidget {
  final Event ev;
  final VoidCallback onTap;
  const _PastEventRow({required this.ev, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppThumb(color: ev.color, glyph: ev.glyph, size: 44),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                const SizedBox(height: 3),
                Meta(icon: 'calendar', text: '${ev.dateLabel} · ${ev.stalls.length} stalls'),
              ],
            ),
          ),
          const AppIcon('chevron-right', size: 18, color: AppColors.text4),
        ],
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.blue,
          ),
          child: const Center(child: AppIcon('plus', size: 26, color: Colors.white)),
        ),
      ),
    );
  }
}
