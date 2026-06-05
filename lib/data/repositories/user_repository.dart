import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/profile.dart';
import '../../models/notif.dart';
import '../../models/participation.dart';

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  Future<void> ensureUser(String uid, Role role, {String? email, String? name, String? biz}) async {
    final doc = _user(uid);
    final snap = await doc.get();
    if (snap.exists) return;
    final profile = Profile(
      name: biz ?? '',
      owner: name ?? '',
      role: role,
      roleLabel: role == Role.organizer ? 'Event organizer' : 'Food vendor',
      bio: '',
      color: role == Role.organizer ? 'blue' : 'indigo',
      glyph: role == Role.organizer ? 'calendar' : 'store',
      email: email ?? '',
      phone: '',
    );
    await doc.set({
      'profile': profile.toMap(),
      'settings': {
        'pushApps': true, 'pushUpdates': true, 'email': false, 'visible': true, 'location': true,
      },
    });
  }

  Stream<Profile?> watchProfile(String uid) => _user(uid).snapshots().map((d) {
        final data = d.data();
        if (data == null || data['profile'] == null) return null;
        return Profile.fromMap((data['profile'] as Map).cast<String, dynamic>());
      });

  Stream<Map<String, bool>> watchSettings(String uid) => _user(uid).snapshots().map((d) {
        final s = d.data()?['settings'];
        if (s == null) return const {};
        return (s as Map).map((k, v) => MapEntry(k.toString(), v == true));
      });

  Future<void> setSetting(String uid, String key, bool value) =>
      _user(uid).update({'settings.$key': value});

  Future<void> updateProfile(String uid, Profile p) =>
      _user(uid).update({'profile': p.toMap()});

  Stream<List<Participation>> watchParticipation(String uid) =>
      _user(uid).collection('participation').snapshots().map(
            (s) => s.docs.map((d) => Participation.fromMap(d.data())).toList(),
          );

  Future<void> upsertParticipation(String uid, Participation p) =>
      _user(uid).collection('participation').doc(p.id).set(p.toMap());

  Future<void> removeParticipation(String uid, String eventId) =>
      _user(uid).collection('participation').doc(eventId).delete();

  Stream<List<Notif>> watchNotifs(String uid) =>
      _user(uid).collection('notifs').snapshots().map(
            (s) => s.docs.map((d) => Notif.fromMap(d.id, d.data())).toList(),
          );

  Future<void> markRead(String uid, String id) =>
      _user(uid).collection('notifs').doc(id).update({'read': true});

  Future<void> markAllRead(String uid) async {
    final col = _user(uid).collection('notifs');
    final snap = await col.get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> resolveNotif(String uid, String id, String result) =>
      _user(uid).collection('notifs').doc(id).update({
        'read': true,
        'actionable': false,
        'resolved': result,
      });
}
