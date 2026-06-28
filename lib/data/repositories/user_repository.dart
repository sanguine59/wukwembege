import '../api_client.dart';
import '../../models/profile.dart';
import '../../models/notif.dart';
import '../../models/participation.dart';

class UserRepository {
  final ApiClient _api;
  UserRepository(this._api);

  Future<void> ensureUser(String uid, Role role,
          {String? email, String? name, String? biz}) =>
      _api.post('/auth/ensure', {
        'role': role.name,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (biz != null) 'biz': biz,
      });

  Stream<Profile?> watchProfile(String uid) => pollStream(() async {
        final m = await _api.get('/me/profile');
        if (m == null) return null;
        return Profile.fromMap((m as Map).cast<String, dynamic>());
      });

  Stream<Map<String, bool>> watchSettings(String uid) => pollStream(() async {
        final m = await _api.get('/me/settings');
        if (m == null) return <String, bool>{};
        return (m as Map).map((k, v) => MapEntry(k.toString(), v == true));
      });

  Future<void> setSetting(String uid, String key, bool value) =>
      _api.put('/me/settings/$key', {'value': value});

  Future<void> updateProfile(String uid, Profile p) =>
      _api.put('/me/profile', p.toMap());

  Stream<List<Participation>> watchParticipation(String uid) => pollStream(() async {
        final list = await _api.get('/me/participation') as List;
        return list
            .map((m) => Participation.fromMap((m as Map).cast<String, dynamic>()))
            .toList();
      });

  Future<void> upsertParticipation(String uid, Participation p) =>
      _api.put('/me/participation/${p.id}', p.toMap());

  Future<void> removeParticipation(String uid, String eventId) =>
      _api.delete('/me/participation/$eventId');

  Stream<List<Notif>> watchNotifs(String uid) => pollStream(() async {
        final list = await _api.get('/me/notifs') as List;
        return list
            .map((m) => Notif.fromMap(
                m['id'] as String, (m as Map).cast<String, dynamic>()))
            .toList();
      });

  Future<void> markRead(String uid, String id) => _api.put('/me/notifs/$id/read');

  Future<void> markAllRead(String uid) => _api.put('/me/notifs/read-all');

  Future<void> resolveNotif(String uid, String id, String result) =>
      _api.put('/me/notifs/$id/resolve', {'result': result});
}
