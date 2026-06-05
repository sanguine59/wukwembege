import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/event.dart';
import '../../models/stall.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;
  const StatusBadge(this.status, {super.key, this.large = false});

  factory StatusBadge.event(EventStatus s) => StatusBadge(s.name);
  factory StatusBadge.stall(StallStatus s) => StatusBadge(s.name);

  ({Color fg, Color bg, String label, bool dot}) _spec() {
    switch (status) {
      case 'live':
        return (fg: AppColors.red, bg: const Color(0xFFFEEAEA), label: 'Live now', dot: true);
      case 'upcoming':
        return (fg: AppColors.bluePress, bg: AppColors.blueSoft, label: 'Upcoming', dot: false);
      case 'past':
        return (fg: AppColors.text3, bg: const Color(0xFFEEF1F5), label: 'Archived', dot: false);
      case 'confirmed':
        return (fg: AppColors.green, bg: AppColors.greenSoft, label: 'Confirmed', dot: false);
      case 'pending':
        return (fg: AppColors.amber, bg: AppColors.amberSoft, label: 'Pending', dot: false);
      case 'declined':
        return (fg: AppColors.red, bg: AppColors.redSoft, label: 'Declined', dot: false);
      case 'full':
        return (fg: AppColors.text3, bg: const Color(0xFFEEF1F5), label: 'Full', dot: false);
      case 'open':
        return (fg: AppColors.green, bg: AppColors.greenSoft, label: 'Spots open', dot: false);
      default:
        return (fg: AppColors.text3, bg: const Color(0xFFEEF1F5), label: status, dot: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _spec();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10 : 8, vertical: large ? 5 : 4),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: s.fg, shape: BoxShape.circle)),
            const SizedBox(width: 5),
          ],
          Text(s.label, style: TextStyle(color: s.fg, fontSize: 11.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PlainBadge extends StatelessWidget {
  final String label;
  final Color? fg;
  final Color? bg;
  final Widget? leading;
  const PlainBadge(this.label, {super.key, this.fg, this.bg, this.leading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? const Color(0xFFEEF1F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: fg ?? AppColors.text2, fontSize: 11.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
