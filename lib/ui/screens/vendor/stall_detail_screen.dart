import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/stall.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';

class StallDetailScreen extends StatelessWidget {
  final String eventId;
  final String stallId;
  const StallDetailScreen({super.key, required this.eventId, required this.stallId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final ev = vm.events.where((e) => e.id == eventId).firstOrNull;
    final stall = ev?.stalls.where((s) => s.id == stallId).firstOrNull;
    if (ev == null || stall == null) return const Scaffold(body: Center(child: Text('Stall not found')));
    final bio = '${stall.name} serves ${stall.cuisine.toLowerCase()} — a regular on the local food-stall circuit, known for quick service and a tidy, self-powered setup.';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                HeaderBar(
                  title: 'Vendor', onBack: () => Navigator.of(context).pop(),
                  trailing: [
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message thread opened'))),
                      child: const SizedBox(width: 38, height: 38, child: Center(child: AppIcon('send', size: 19))),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    children: [
                      Column(children: [
                        const AppThumb(color: 'indigo', glyph: 'utensils', size: 84, radius: 24, glyphSize: 40),
                        const SizedBox(height: 12),
                        Text(stall.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: -0.02)),
                        const SizedBox(height: 3),
                        Text(stall.cuisine, style: const TextStyle(fontSize: 13.5, color: AppColors.text3, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        StatusBadge.stall(stall.status),
                      ]),
                      const SizedBox(height: 18),
                      const KpiRow(tiles: [
                        KpiTile(value: '4.8', label: 'Rating'),
                        KpiTile(value: '212', label: 'Reviews'),
                        KpiTile(value: '14', label: 'Events'),
                      ]),
                      const SizedBox(height: 18),
                      const Text('About', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.text2)),
                      const SizedBox(height: 6),
                      Text(bio, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.text2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 18),
                      _kvRow('user', stall.owner, 'Owner & contact'),
                      const SizedBox(height: 8),
                      if (stall.status == StallStatus.confirmed) ...[
                        _kvRow('map-pin', 'Spot ${stall.spot}', 'Assigned pitch at ${ev.name}'),
                        const SizedBox(height: 8),
                      ],
                      _kvRow('dollar', '\$${stall.fee} stall fee',
                          stall.status == StallStatus.confirmed ? 'Paid' : 'Due on approval'),
                    ],
                  ),
                ),
              ],
            ),
            if (stall.status == StallStatus.pending)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 6 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
                  child: Row(children: [
                    Expanded(child: Btn(
                      label: 'Decline', block: true, variant: BtnVariant.danger,
                      onPressed: () async {
                        await vm.setStallStatus(ev.id, stall.id, StallStatus.declined);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${stall.name} declined')));
                          Navigator.of(context).pop();
                        }
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: Btn(
                      label: 'Approve', icon: 'check', block: true, variant: BtnVariant.success,
                      onPressed: () async {
                        await vm.setStallStatus(ev.id, stall.id, StallStatus.confirmed);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${stall.name} confirmed')));
                          Navigator.of(context).pop();
                        }
                      },
                    )),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String icon, String title, String subtitle) {
    return ListRow(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(12)),
        child: Center(child: AppIcon(icon, size: 19, color: AppColors.blue)),
      ),
      title: title, subtitle: subtitle,
    );
  }
}
