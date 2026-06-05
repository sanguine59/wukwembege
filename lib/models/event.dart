import 'stall.dart';

enum EventStatus { live, upcoming, past }

EventStatus eventStatusFromString(String s) =>
    EventStatus.values.firstWhere((e) => e.name == s, orElse: () => EventStatus.upcoming);

class Event {
  final String id;
  final String name;
  final String type;
  final EventStatus status;
  final String color;
  final String glyph;
  final String dateLabel;
  final String time;
  final String location;
  final String city;
  final int capacity;
  final int fee;
  final String attendees;
  final String desc;
  final List<String> tags;
  final List<Stall> stalls;

  final String? organizer;
  final int? taken;
  final String? joinState;

  const Event({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.color,
    required this.glyph,
    required this.dateLabel,
    required this.time,
    required this.location,
    required this.city,
    required this.capacity,
    required this.fee,
    this.attendees = '',
    required this.desc,
    this.tags = const [],
    this.stalls = const [],
    this.organizer,
    this.taken,
    this.joinState,
  });

  Event copyWith({
    String? name,
    String? type,
    EventStatus? status,
    String? color,
    String? glyph,
    String? dateLabel,
    String? time,
    String? location,
    String? city,
    int? capacity,
    int? fee,
    String? desc,
    List<String>? tags,
    List<Stall>? stalls,
  }) =>
      Event(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        status: status ?? this.status,
        color: color ?? this.color,
        glyph: glyph ?? this.glyph,
        dateLabel: dateLabel ?? this.dateLabel,
        time: time ?? this.time,
        location: location ?? this.location,
        city: city ?? this.city,
        capacity: capacity ?? this.capacity,
        fee: fee ?? this.fee,
        attendees: attendees,
        desc: desc ?? this.desc,
        tags: tags ?? this.tags,
        stalls: stalls ?? this.stalls,
        organizer: organizer,
        taken: taken,
        joinState: joinState,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'status': status.name,
        'color': color,
        'glyph': glyph,
        'dateLabel': dateLabel,
        'time': time,
        'location': location,
        'city': city,
        'capacity': capacity,
        'fee': fee,
        'attendees': attendees,
        'desc': desc,
        'tags': tags,
        'stalls': stalls.map((s) => s.toMap()).toList(),
        if (organizer != null) 'organizer': organizer,
        if (taken != null) 'taken': taken,
        if (joinState != null) 'joinState': joinState,
      };

  factory Event.fromMap(String id, Map<String, dynamic> m) => Event(
        id: id,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? '') as String,
        status: eventStatusFromString((m['status'] ?? 'upcoming') as String),
        color: (m['color'] ?? 'blue') as String,
        glyph: (m['glyph'] ?? 'store') as String,
        dateLabel: (m['dateLabel'] ?? '') as String,
        time: (m['time'] ?? '') as String,
        location: (m['location'] ?? '') as String,
        city: (m['city'] ?? '') as String,
        capacity: (m['capacity'] ?? 0) as int,
        fee: (m['fee'] ?? 0) as int,
        attendees: (m['attendees'] ?? '') as String,
        desc: (m['desc'] ?? '') as String,
        tags: ((m['tags'] ?? const []) as List).cast<String>(),
        stalls: ((m['stalls'] ?? const []) as List)
            .map((e) => Stall.fromMap((e as Map).cast<String, dynamic>()))
            .toList(),
        organizer: m['organizer'] as String?,
        taken: m['taken'] as int?,
        joinState: m['joinState'] as String?,
      );
}
