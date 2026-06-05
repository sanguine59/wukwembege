import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/seed.dart' as seed;
import '../../../models/event.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pills.dart';
import '../../widgets/sheet.dart';
import 'browse_card.dart';
import 'event_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _q = '';
  String _status = 'All';
  final Set<String> _types = {};
  String _city = 'Any city';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final all = vm.browse;
    final cities = ['Any city', ...{for (final e in all) e.city}];

    List<Event> filtered = all.where((e) {
      if (_status == 'Live now' && e.status != EventStatus.live) return false;
      if (_status == 'Upcoming' && e.status != EventStatus.upcoming) return false;
      if (_types.isNotEmpty && !_types.contains(e.type)) return false;
      if (_city != 'Any city' && e.city != _city) return false;
      if (_q.isNotEmpty) {
        final hay = '${e.name} ${e.city} ${e.type} ${e.organizer ?? ''}'.toLowerCase();
        if (!hay.contains(_q.toLowerCase())) return false;
      }
      return true;
    }).toList();

    final activeFilters = _types.length + (_city != 'Any city' ? 1 : 0);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Browse events', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: -0.02)),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              Row(
                children: [
                  Expanded(child: SearchInput(value: _q, onChanged: (v) => setState(() => _q = v), placeholder: 'Search events, cities…')),
                  const SizedBox(width: 10),
                  Stack(clipBehavior: Clip.none, children: [
                    IconBtn(
                      icon: 'sliders', borderColor: activeFilters > 0 ? AppColors.blue : null,
                      color: activeFilters > 0 ? AppColors.blue : null,
                      onPressed: () => _openFilters(cities, filtered.length),
                    ),
                    if (activeFilters > 0)
                      Positioned(
                        top: -5, right: -5,
                        child: Container(
                          width: 17, height: 17,
                          decoration: BoxDecoration(color: AppColors.blue, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                          alignment: Alignment.center,
                          child: Text('$activeFilters', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Pills(items: const ['All', 'Live now', 'Upcoming'], active: _status, onChange: (v) => setState(() => _status = v)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} event${filtered.length == 1 ? '' : 's'}${_city != 'Any city' ? ' in $_city' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text3, fontSize: 13),
                  ),
                  if (activeFilters > 0)
                    GestureDetector(
                      onTap: () => setState(() { _types.clear(); _city = 'Any city'; }),
                      child: const Text('Clear', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                const EmptyState(icon: 'search', title: 'No events match', sub: 'Try clearing a filter or searching a different city.')
              else
                for (final e in filtered) ...[
                  BrowseCard(
                    ev: e, part: vm.participationFor(e.id),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id))),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ],
    );
  }

  void _openFilters(List<String> cities, int currentCount) {
    showAppSheet(
      context: context, title: 'Filters',
      trailing: _types.isNotEmpty || _city != 'Any city'
          ? TextButton(
              onPressed: () { setState(() { _types.clear(); _city = 'Any city'; }); Navigator.of(context).pop(); },
              child: const Text('Reset', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800)),
            )
          : null,
      foot: Btn(label: 'Show $currentCount events', block: true, size: BtnSize.lg, onPressed: () => Navigator.of(context).pop()),
      builder: (ctx) => StatefulBuilder(builder: (c, setSheet) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Event type', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.text2))),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in seed.eventTypes)
                _PillChip(label: t, selected: _types.contains(t), onTap: () {
                  setSheet(() {
                    if (_types.contains(t)) { _types.remove(t); } else { _types.add(t); }
                  });
                  setState(() {});
                }),
            ]),
            const SizedBox(height: 18),
            const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('City', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.text2))),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final ct in cities)
                _PillChip(label: ct, selected: _city == ct, onTap: () { setSheet(() => _city = ct); setState(() {}); }),
            ]),
          ],
        );
      }),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PillChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : AppColors.surface,
          border: Border.all(color: selected ? AppColors.blue : AppColors.border, width: 1.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w800, fontSize: 12.5)),
      ),
    );
  }
}
