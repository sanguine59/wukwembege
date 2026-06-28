import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';
import '../shared/inbox_screen.dart';
import 'browse_card.dart';
import 'event_detail_screen.dart';

class VendorHomeScreen extends StatelessWidget {
  final VoidCallback? onBrowseAll;
  const VendorHomeScreen({super.key, this.onBrowseAll});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final profile = vm.profile;
    final partList = vm.participation;
    final byId = {for (final e in vm.browse) e.id: e};
    final mine = [
      for (final p in partList)
        if (byId.containsKey(p.id)) (event: byId[p.id]!, part: p)
    ];
    final confirmed = mine.where((m) => m.part.status == 'confirmed').toList();
    final pending = mine.where((m) => m.part.status == 'pending').toList();
    final joinedIds = partList.map((p) => p.id).toSet();
    final discover = vm.browse.where((e) => !joinedIds.contains(e.id) && e.joinState != 'full').take(4).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 14, 4),
          child: Row(
            children: [
              AppThumb(color: profile?.color ?? 'indigo', glyph: profile?.glyph ?? 'utensils', size: 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile?.name ?? '', style: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w800, fontSize: 13)),
                    const Text('Your stalls', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.02)),
                  ],
                ),
              ),
              Stack(clipBehavior: Clip.none, children: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InboxScreen())),
                  icon: const AppIcon('bell', size: 21),
                ),
                if (vm.unread > 0)
                  const Positioned(
                    right: 10, top: 10,
                    child: SizedBox(
                      width: 10, height: 10,
                      child: DecoratedBox(decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
                    ),
                  ),
              ]),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              KpiRow(tiles: [
                KpiTile(value: '${confirmed.length}', label: 'Confirmed', valueColor: AppColors.green),
                KpiTile(value: '${pending.length}', label: 'Pending', valueColor: AppColors.amber),
                KpiTile(value: '${profile?.events ?? 0}', label: 'Events done'),
              ]),
              if (confirmed.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionHead(title: 'Confirmed'),
                for (final m in confirmed) ...[
                  AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: m.event.id))),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppThumb(color: m.event.color, glyph: m.event.glyph, size: 48),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(m.event.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                                    const SizedBox(width: 6),
                                    const StatusBadge('confirmed'),
                                  ]),
                                  const SizedBox(height: 6),
                                  Wrap(spacing: 12, runSpacing: 4, children: [
                                    Meta(icon: 'calendar', text: m.event.dateLabel),
                                    Meta(icon: 'map-pin', text: m.event.city),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const AppIcon('check-circle', size: 18, color: AppColors.green),
                            const SizedBox(width: 9),
                            Expanded(child: Text("You're in - pitch ${m.part.spot ?? ''}", style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 13))),
                            const AppIcon('qr', size: 18, color: AppColors.green),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (pending.isNotEmpty) ...[
                const SizedBox(height: 10),
                const SectionHead(title: 'Awaiting approval'),
                for (final m in pending) ...[
                  AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: m.event.id))),
                    child: Row(
                      children: [
                        AppThumb(color: m.event.color, glyph: m.event.glyph, size: 44),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.event.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                              const SizedBox(height: 3),
                              const Meta(icon: 'hourglass', text: 'Application under review'),
                            ],
                          ),
                        ),
                        const StatusBadge('pending'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: SectionHead(title: 'Discover events')),
                  GestureDetector(
                    onTap: onBrowseAll,
                    child: const Text('Browse all', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (final ev in discover) ...[
                BrowseCard(
                  ev: ev, part: vm.participationFor(ev.id),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: ev.id))),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
