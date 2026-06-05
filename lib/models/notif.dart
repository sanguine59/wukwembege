class Notif {
  final String id;
  final String kind;
  final bool read;
  final String time;
  final String actor;
  final String? cuisine;
  final String? eventId;
  final String eventName;
  final String text;
  final bool actionable;
  final String? stallId;
  final String? resolved;

  const Notif({
    required this.id,
    required this.kind,
    required this.read,
    required this.time,
    required this.actor,
    this.cuisine,
    this.eventId,
    required this.eventName,
    required this.text,
    this.actionable = false,
    this.stallId,
    this.resolved,
  });

  Notif copyWith({bool? read, bool? actionable, String? resolved}) => Notif(
        id: id,
        kind: kind,
        read: read ?? this.read,
        time: time,
        actor: actor,
        cuisine: cuisine,
        eventId: eventId,
        eventName: eventName,
        text: text,
        actionable: actionable ?? this.actionable,
        stallId: stallId,
        resolved: resolved ?? this.resolved,
      );

  Map<String, dynamic> toMap() => {
        'kind': kind,
        'read': read,
        'time': time,
        'actor': actor,
        'cuisine': cuisine,
        'eventId': eventId,
        'eventName': eventName,
        'text': text,
        'actionable': actionable,
        'stallId': stallId,
        'resolved': resolved,
      };

  factory Notif.fromMap(String id, Map<String, dynamic> m) => Notif(
        id: id,
        kind: (m['kind'] ?? 'system') as String,
        read: (m['read'] ?? false) as bool,
        time: (m['time'] ?? '') as String,
        actor: (m['actor'] ?? '') as String,
        cuisine: m['cuisine'] as String?,
        eventId: m['eventId'] as String?,
        eventName: (m['eventName'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        actionable: (m['actionable'] ?? false) as bool,
        stallId: m['stallId'] as String?,
        resolved: m['resolved'] as String?,
      );
}
