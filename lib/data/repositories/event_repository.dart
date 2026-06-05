import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';
import '../../models/stall.dart';

class EventRepository {
  final FirebaseFirestore _db;
  EventRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('events');
  CollectionReference<Map<String, dynamic>> get _browse => _db.collection('browseEvents');

  Stream<List<Event>> watchEvents() => _col.snapshots().map(
        (s) => s.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
      );

  Stream<List<Event>> watchBrowseEvents() => _browse.snapshots().map(
        (s) => s.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
      );

  Future<Event?> getBrowseEvent(String id) async {
    final d = await _browse.doc(id).get();
    if (!d.exists) return null;
    return Event.fromMap(d.id, d.data()!);
  }

  Future<void> add(Event e) => _col.doc(e.id).set(e.toMap());
  Future<void> update(String id, Map<String, dynamic> patch) => _col.doc(id).update(patch);
  Future<void> updateEvent(Event e) => _col.doc(e.id).set(e.toMap());
  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> setStalls(String eventId, List<Stall> stalls) =>
      _col.doc(eventId).update({'stalls': stalls.map((s) => s.toMap()).toList()});
}
