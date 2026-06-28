import '../api_client.dart';
import '../../models/event.dart';
import '../../models/stall.dart';

class EventRepository {
  final ApiClient _api;
  EventRepository(this._api);

  List<Event> _parse(dynamic list) => (list as List)
      .map((m) => Event.fromMap(m['id'] as String, (m as Map).cast<String, dynamic>()))
      .toList();

  Stream<List<Event>> watchEvents() =>
      pollStream(() async => _parse(await _api.get('/events')));

  Stream<List<Event>> watchBrowseEvents() =>
      pollStream(() async => _parse(await _api.get('/browse-events')));

  Future<Event?> getBrowseEvent(String id) async {
    try {
      final m = await _api.get('/browse-events/$id');
      if (m == null) return null;
      return Event.fromMap(m['id'] as String, (m as Map).cast<String, dynamic>());
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  Future<void> add(Event e) => _api.post('/events', e.toMap()..['id'] = e.id);

  Future<void> update(String id, Map<String, dynamic> patch) =>
      _api.patch('/events/$id', patch);

  Future<void> updateEvent(Event e) =>
      _api.put('/events/${e.id}', e.toMap()..['id'] = e.id);

  Future<void> delete(String id) => _api.delete('/events/$id');

  Future<void> setStalls(String eventId, List<Stall> stalls) =>
      _api.put('/events/$eventId/stalls', {'stalls': stalls.map((s) => s.toMap()).toList()});
}
