import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/seed.dart' as seed;
import '../../../models/event.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/pills.dart';

class EventEditScreen extends StatefulWidget {
  final String? eventId;
  const EventEditScreen({super.key, this.eventId});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late final AppViewModel _vm = context.read<AppViewModel>();
  Event? _editing;
  final _name = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _location = TextEditingController();
  final _city = TextEditingController();
  final _capacity = TextEditingController(text: '30');
  final _fee = TextEditingController(text: '100');
  final _desc = TextEditingController();
  String _type = 'Night market';
  String _color = 'blue';
  String _glyph = 'store';

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _editing = _vm.events.firstWhere((e) => e.id == widget.eventId, orElse: () => _vm.events.first);
      final e = _editing!;
      _name.text = e.name; _date.text = e.dateLabel; _time.text = e.time;
      _location.text = e.location; _city.text = e.city;
      _capacity.text = '${e.capacity}'; _fee.text = '${e.fee}';
      _desc.text = e.desc; _type = e.type; _color = e.color; _glyph = e.glyph;
    }
  }

  bool get _valid => _name.text.isNotEmpty && _date.text.isNotEmpty && _location.text.isNotEmpty;

  Future<void> _save() async {
    final patch = {
      'name': _name.text, 'type': _type, 'dateLabel': _date.text, 'time': _time.text,
      'location': _location.text, 'city': _city.text,
      'capacity': int.tryParse(_capacity.text) ?? 0, 'fee': int.tryParse(_fee.text) ?? 0,
      'desc': _desc.text, 'color': _color, 'glyph': _glyph,
    };
    if (_editing != null) {
      await _vm.patchEvent(_editing!.id, patch);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated')));
    } else {
      final ev = Event(
        id: 'tmp', name: _name.text, type: _type, status: EventStatus.upcoming,
        color: _color, glyph: _glyph,
        dateLabel: _date.text, time: _time.text,
        location: _location.text, city: _city.text,
        capacity: int.tryParse(_capacity.text) ?? 0, fee: int.tryParse(_fee.text) ?? 0,
        desc: _desc.text,
      );
      await _vm.addEvent(ev);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created — start inviting vendors')));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const colors = ['blue', 'indigo', 'teal', 'amber', 'rose', 'violet', 'green', 'slate'];
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(title: _editing != null ? 'Edit event' : 'New event', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                children: [
                  Field(label: 'Event name', child: AppTextInput(controller: _name, placeholder: 'e.g. Riverside Night Market', onChanged: (_) => setState(() {}))),
                  const SizedBox(height: 14),
                  Field(label: 'Event type', child: Pills(items: seed.eventTypes, active: _type, onChange: (v) => setState(() => _type = v), wrap: true)),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Field(label: 'When', child: AppTextInput(controller: _date, placeholder: 'Sat, Oct 18', onChanged: (_) => setState(() {})))),
                      const SizedBox(width: 12),
                      Expanded(child: Field(label: 'Time', child: AppTextInput(controller: _time, placeholder: '5–11 PM'))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Field(label: 'Location', child: AppTextInput(controller: _location, leadIcon: 'map-pin', placeholder: 'Venue or address', onChanged: (_) => setState(() {}))),
                  const SizedBox(height: 14),
                  Field(label: 'City', child: AppTextInput(controller: _city, placeholder: 'City')),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Field(label: 'Stall capacity', child: AppTextInput(controller: _capacity, keyboardType: TextInputType.number))),
                      const SizedBox(width: 12),
                      Expanded(child: Field(label: 'Stall fee', child: AppTextInput(controller: _fee, leadIcon: 'dollar', keyboardType: TextInputType.number))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Field(
                    label: 'Description',
                    child: AppTextInput(controller: _desc, placeholder: 'Tell vendors what makes this event worth joining…', minLines: 3, maxLines: 6),
                  ),
                  const SizedBox(height: 14),
                  Field(
                    label: 'Cover colour',
                    child: Wrap(
                      spacing: 9, runSpacing: 9,
                      children: [
                        for (final c in colors) GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: kThumb[c]!.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _color == c ? AppColors.ink : Colors.transparent, width: 2.5,
                              ),
                              boxShadow: _color == c ? const [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: -2, offset: Offset(0, 0))] : null,
                            ),
                            child: _color == c ? const Center(child: AppIcon('check', size: 16, color: Colors.white)) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 6 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
              child: Btn(
                label: _editing != null ? 'Save changes' : 'Create event',
                block: true, size: BtnSize.lg,
                disabled: !_valid, onPressed: _valid ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
