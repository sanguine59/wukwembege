import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/seed.dart' as seed;
import '../../../models/event.dart';
import '../../../models/stall.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pills.dart';
import '../../widgets/sheet.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/thumb.dart';
import '../vendor/stall_detail_screen.dart';
import 'event_edit_screen.dart';

class EventManageScreen extends StatefulWidget {
  final String eventId;
  const EventManageScreen({super.key, required this.eventId});

  @override
  State<EventManageScreen> createState() => _EventManageScreenState();
}

class _EventManageScreenState extends State<EventManageScreen> {
  String _tab = 'Confirmed';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final ev = vm.events.where((e) => e.id == widget.eventId).firstOrNull;
    if (ev == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }
    final confirmed = ev.stalls.where((s) => s.status == StallStatus.confirmed).toList();
    final pending = ev.stalls.where((s) => s.status == StallStatus.pending).toList();
    final filtered = _tab == 'Confirmed' ? confirmed : _tab == 'Pending' ? pending : ev.stalls;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                HeaderBar(
                  title: ev.name,
                  subtitle: '${ev.dateLabel} · ${ev.city}',
                  onBack: () => Navigator.of(context).pop(),
                  trailing: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _eventMenu(context, ev, vm),
                      child: const SizedBox(width: 38, height: 38, child: Center(child: AppIcon('more', size: 20))),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    children: [
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppThumb(color: ev.color, glyph: ev.glyph, size: 56),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        StatusBadge.event(ev.status),
                                        const SizedBox(width: 8),
                                        PlainBadge(ev.type, fg: AppColors.bluePress, bg: AppColors.blueSoft),
                                      ]),
                                      const SizedBox(height: 8),
                                      Meta(icon: 'clock', text: ev.time),
                                      const SizedBox(height: 5),
                                      Meta(icon: 'map-pin', text: ev.location),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Divider(color: AppColors.divider, height: 1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statBlock('${confirmed.length} / ${ev.capacity}', 'Stalls filled'),
                                Container(width: 1, height: 32, color: AppColors.divider),
                                _statBlock('${pending.length}', 'Pending', color: pending.isNotEmpty ? AppColors.amber : null),
                                Container(width: 1, height: 32, color: AppColors.divider),
                                _statBlock('\$${ev.fee}', 'Stall fee'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: SectionHead(title: 'Food stalls')),
                          GestureDetector(
                            onTap: () => _stallForm(context, ev, vm, null),
                            child: const Text('+ Add stall', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SegmentedControl(
                        items: const ['Confirmed', 'Pending', 'All'],
                        active: _tab,
                        onChange: (v) => setState(() => _tab = v),
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        EmptyState(
                          icon: 'store',
                          title: _tab == 'Pending' ? 'No applications waiting' : 'No stalls yet',
                          sub: _tab == 'Pending' ? "You're all caught up." : 'Add a vendor manually or wait for applications.',
                        )
                      else
                        for (final s in filtered) ...[
                          _StallRow(
                            stall: s,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => StallDetailScreen(eventId: ev.id, stallId: s.id))),
                            onApprove: () { vm.setStallStatus(ev.id, s.id, StallStatus.confirmed); _toast('${s.name} confirmed'); },
                            onDecline: () { vm.setStallStatus(ev.id, s.id, StallStatus.declined); _toast('${s.name} declined'); },
                            onMenu: () => _stallMenu(context, ev, s, vm),
                          ),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 18, bottom: 18,
              child: _Fab(onTap: () => _stallForm(context, ev, vm, null)),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _statBlock(String value, String label, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: color ?? AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }

  void _eventMenu(BuildContext ctx, Event ev, AppViewModel vm) {
    showAppSheet(
      context: ctx, title: 'Event options',
      builder: (sheetCtx) => Column(
        children: [
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('pencil'))),
            title: 'Edit event details',
            onTap: () { Navigator.of(sheetCtx).pop(); Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => EventEditScreen(eventId: ev.id))); },
          ),
          const SizedBox(height: 8),
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('share'))),
            title: 'Share event link',
            onTap: () { Navigator.of(sheetCtx).pop(); _toast('Share link copied'); },
          ),
          const SizedBox(height: 8),
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('trash', color: AppColors.red))),
            title: 'Delete event', titleColor: AppColors.red, borderColor: AppColors.redSoft,
            onTap: () { Navigator.of(sheetCtx).pop(); _confirmDelete(ctx, ev, vm); },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Event ev, AppViewModel vm) {
    showAppDialog(
      context: ctx, icon: 'alert', iconColor: AppColors.red, iconBg: AppColors.redSoft,
      title: 'Delete this event?',
      body: '"${ev.name}" and all ${ev.stalls.length} stall records will be permanently removed.',
      actions: Column(children: [
        Btn(label: 'Delete event', block: true, variant: BtnVariant.danger, onPressed: () async {
          await vm.deleteEvent(ev.id);
          if (ctx.mounted) { Navigator.of(ctx).pop(); Navigator.of(ctx).pop(); }
          if (mounted) _toast('Event deleted');
        }),
        const SizedBox(height: 8),
        Btn(label: 'Cancel', block: true, variant: BtnVariant.ghost, onPressed: () => Navigator.of(ctx).pop()),
      ]),
    );
  }

  void _stallMenu(BuildContext ctx, Event ev, Stall s, AppViewModel vm) {
    showAppSheet(
      context: ctx, title: s.name,
      builder: (sheetCtx) => Column(
        children: [
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('pencil'))),
            title: 'Edit stall details',
            onTap: () { Navigator.of(sheetCtx).pop(); _stallForm(ctx, ev, vm, s); },
          ),
          const SizedBox(height: 8),
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('user'))),
            title: 'View vendor profile',
            onTap: () { Navigator.of(sheetCtx).pop(); Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => StallDetailScreen(eventId: ev.id, stallId: s.id))); },
          ),
          const SizedBox(height: 8),
          ListRow(
            leading: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('trash', color: AppColors.red))),
            title: 'Remove from event', titleColor: AppColors.red, borderColor: AppColors.redSoft,
            onTap: () async { Navigator.of(sheetCtx).pop(); await vm.removeStall(ev.id, s.id); _toast('${s.name} removed'); },
          ),
        ],
      ),
    );
  }

  void _stallForm(BuildContext ctx, Event ev, AppViewModel vm, Stall? editing) {
    final name = TextEditingController(text: editing?.name ?? '');
    final owner = TextEditingController(text: editing?.owner ?? '');
    final spot = TextEditingController(text: editing?.spot == '—' ? '' : (editing?.spot ?? ''));
    String cuisine = editing?.cuisine ?? 'Street food';
    StallStatus status = editing?.status ?? StallStatus.confirmed;

    showAppSheet(
      context: ctx,
      title: editing != null ? 'Edit stall' : 'Add a stall',
      builder: (sheetCtx) => StatefulBuilder(builder: (c, setSheet) {
        bool valid() => name.text.isNotEmpty && owner.text.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Field(label: 'Stall / business name', child: AppTextInput(controller: name, leadIcon: 'store', placeholder: 'e.g. Smokehouse Lane', onChanged: (_) => setSheet(() {}))),
            const SizedBox(height: 14),
            Field(label: 'Owner / contact', child: AppTextInput(controller: owner, leadIcon: 'user', placeholder: 'Vendor name', onChanged: (_) => setSheet(() {}))),
            const SizedBox(height: 14),
            Field(label: 'Cuisine', child: Pills(items: seed.cuisines, active: cuisine, onChange: (v) => setSheet(() => cuisine = v), wrap: true)),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Field(label: 'Spot / pitch', child: AppTextInput(controller: spot, placeholder: 'A1'))),
                const SizedBox(width: 12),
                Expanded(
                  child: Field(
                    label: 'Status',
                    child: SegmentedControl(
                      items: const ['Confirmed', 'Pending'],
                      active: status == StallStatus.confirmed ? 'Confirmed' : 'Pending',
                      onChange: (v) => setSheet(() => status = v == 'Confirmed' ? StallStatus.confirmed : StallStatus.pending),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Btn(
              label: editing != null ? 'Save changes' : 'Add stall',
              block: true, size: BtnSize.lg, disabled: !valid(),
              onPressed: !valid() ? null : () async {
                final s = Stall(
                  id: editing?.id ?? 's',
                  name: name.text, cuisine: cuisine, owner: owner.text,
                  status: status, spot: spot.text.isEmpty ? '—' : spot.text, fee: ev.fee,
                );
                if (editing != null) {
                  await vm.updateStall(ev.id, s);
                  if (mounted) _toast('Stall updated');
                } else {
                  await vm.addStall(ev.id, s);
                  if (mounted) _toast('${s.name} added');
                }
                if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
              },
            ),
          ],
        );
      }),
    );
  }
}

class _StallRow extends StatelessWidget {
  final Stall stall;
  final VoidCallback? onTap;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onMenu;
  const _StallRow({required this.stall, this.onTap, required this.onApprove, required this.onDecline, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return ListRow(
      onTap: onTap,
      leading: AvatarInitials(name: stall.owner, color: 'slate', size: 42),
      title: stall.name,
      subtitle: stall.status == StallStatus.confirmed ? '${stall.cuisine} · Spot ${stall.spot}' : '${stall.cuisine} · ${stall.owner}',
      trailing: stall.status == StallStatus.pending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBtn(icon: 'x', color: AppColors.red, bg: AppColors.redSoft, borderColor: AppColors.redSoft, onPressed: onDecline),
                const SizedBox(width: 7),
                IconBtn(icon: 'check', color: Colors.white, bg: AppColors.green, borderColor: AppColors.green, onPressed: onApprove),
              ],
            )
          : IconBtn(icon: 'more', ghost: true, onPressed: onMenu),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 58, height: 58,
        decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.blue),
        child: const Center(child: AppIcon('plus', size: 26, color: Colors.white)),
      ),
    );
  }
}
