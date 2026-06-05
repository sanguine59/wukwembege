import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../models/participation.dart';
import '../../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';

class BrowseCard extends StatelessWidget {
  final Event ev;
  final Participation? part;
  final VoidCallback onTap;
  const BrowseCard({super.key, required this.ev, this.part, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = kThumb[ev.color] ?? kThumb['blue']!;
    final taken = ev.taken ?? 0;
    final spotsLeft = ev.capacity - taken;
    final full = ev.joinState == 'full' || spotsLeft <= 0;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.r),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.1),
              borderRadius: BorderRadius.circular(AppRadii.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 92,
                  color: palette.bg,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: .13,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(0.6, -0.6),
                                radius: 0.9,
                                colors: [Colors.white, Color(0x00FFFFFF)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 12,
                        child: ev.status == EventStatus.live
                            ? const StatusBadge('live')
                            : PlainBadge(ev.type, bg: const Color(0xE6FFFFFF), fg: AppColors.ink),
                      ),
                      Positioned(
                        right: 14, bottom: 12,
                        child: Opacity(opacity: 0.5, child: AppIcon(ev.glyph, size: 40, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ev.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, letterSpacing: -0.01)),
                      const SizedBox(height: 4),
                      Meta(icon: 'map-pin', text: '${ev.location}, ${ev.city}'),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Meta(icon: 'calendar', text: ev.dateLabel),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: '\$${ev.fee}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    const TextSpan(text: '/stall', style: TextStyle(color: AppColors.text3, fontWeight: FontWeight.w700, fontSize: 12)),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          if (part != null)
                            StatusBadge(part!.status)
                          else if (full)
                            const StatusBadge('full')
                          else
                            PlainBadge('$spotsLeft left', fg: AppColors.green, bg: AppColors.greenSoft),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
