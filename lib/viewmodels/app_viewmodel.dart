import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile.dart';
import '../models/event.dart';
import '../models/stall.dart';
import '../models/notif.dart';
import '../models/participation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/user_repository.dart';

class AppViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final EventRepository _eventsRepo;
  final UserRepository _usersRepo;

  AppViewModel({required AuthRepository auth, required EventRepository events, required UserRepository users})
      : _authRepo = auth, _eventsRepo = events, _usersRepo = users {
    _authSub = _authRepo.authChanges().listen(_onAuthChanged);
  }

  late final StreamSubscription _authSub;
  StreamSubscription? _profileSub, _eventsSub, _browseSub, _partSub, _notifsSub;

  User? _user;
  Role _role = Role.organizer;
  Profile? _profile;
  bool _authed = false;
  bool get authed => _authed;
  Role get role => _role;
  Profile? get profile => _profile;
  String? get uid => _user?.uid;

  List<Event> _events = [];
  List<Event> _browse = [];
  List<Participation> _participation = [];
  List<Notif> _notifs = [];

  List<Event> get events => _events;
  List<Event> get browse => _browse;
  List<Participation> get participation => _participation;
  List<Notif> get notifs => _notifs;
  int get unread => _notifs.where((n) => !n.read).length;

  Participation? participationFor(String eventId) {
    for (final p in _participation) {
      if (p.id == eventId) return p;
    }
    return null;
  }

  Future<void> _onAuthChanged(User? u) async {
    _user = u;
    if (u == null) {
      _authed = false;
      _profile = null;
      _events = [];
      _participation = [];
      _notifs = [];
      await _cancelStreams();
      notifyListeners();
      return;
    }
    _authed = true;
    await _attachStreams(u.uid);
    notifyListeners();
  }

  Future<void> _cancelStreams() async {
    await _profileSub?.cancel();
    await _eventsSub?.cancel();
    await _browseSub?.cancel();
    await _partSub?.cancel();
    await _notifsSub?.cancel();
    _profileSub = _eventsSub = _browseSub = _partSub = _notifsSub = null;
  }

  Future<void> _attachStreams(String uid) async {
    await _cancelStreams();
    _profileSub = _usersRepo.watchProfile(uid).listen((p) {
      _profile = p;
      if (p != null) _role = p.role;
      notifyListeners();
    });
    _eventsSub = _eventsRepo.watchEvents().listen((evs) {
      _events = evs;
      notifyListeners();
    });
    _browseSub = _eventsRepo.watchBrowseEvents().listen((evs) {
      _browse = evs;
      notifyListeners();
    });
    _partSub = _usersRepo.watchParticipation(uid).listen((p) {
      _participation = p;
      notifyListeners();
    });
    _notifsSub = _usersRepo.watchNotifs(uid).listen((n) {
      _notifs = n;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password, Role role) async {
    await _authRepo.signIn(email, password);
    final u = _authRepo.current!;
    await _usersRepo.ensureUser(u.uid, role, email: email);
  }

  Future<void> register(Role role, String name, String biz, String email, String password) async {
    await _authRepo.register(email, password);
    final u = _authRepo.current!;
    await _usersRepo.ensureUser(u.uid, role, email: email, name: name, biz: biz);
  }

  Future<void> signOut() => _authRepo.signOut();

  Future<void> sendPasswordReset(String email) => _authRepo.sendPasswordReset(email);

  Future<void> switchRole() async {
    if (_user == null || _profile == null) return;
    final newRole = _role == Role.organizer ? Role.vendor : Role.organizer;
    final updated = _profile!.copyWith(
      role: newRole,
      roleLabel: newRole == Role.organizer ? 'Event organizer' : 'Food vendor',
    );
    await _usersRepo.updateProfile(_user!.uid, updated);
  }

  String _uid(String prefix) => '$prefix${DateTime.now().millisecondsSinceEpoch}';

  Future<void> addEvent(Event base) async {
    final id = _uid('e');
    final ev = Event(
      id: id,
      name: base.name, type: base.type, status: base.status,
      color: base.color, glyph: base.glyph,
      dateLabel: base.dateLabel, time: base.time,
      location: base.location, city: base.city,
      capacity: base.capacity, fee: base.fee,
      desc: base.desc, tags: base.tags,
      stalls: base.stalls,
    );
    await _eventsRepo.add(ev);
  }

  Future<void> updateEvent(Event e) => _eventsRepo.updateEvent(e);
  Future<void> patchEvent(String id, Map<String, dynamic> patch) => _eventsRepo.update(id, patch);
  Future<void> deleteEvent(String id) => _eventsRepo.delete(id);

  String _nextSpot(Event ev) {
    final used = ev.stalls.where((s) => s.spot.isNotEmpty && s.spot != '—').map((s) => s.spot).toSet();
    final firstReal = ev.stalls.firstWhere(
      (s) => s.spot.isNotEmpty && s.spot != '—',
      orElse: () => const Stall(id: '', name: '', cuisine: '', owner: '', status: StallStatus.pending, spot: 'A1', fee: 0),
    );
    final prefix = firstReal.spot.isNotEmpty ? firstReal.spot[0] : 'A';
    var n = 1;
    while (used.contains('$prefix$n')) {
      n++;
    }
    return '$prefix$n';
  }

  Future<void> addStall(String eventId, Stall stall) async {
    final ev = _events.firstWhere((e) => e.id == eventId);
    final spot = stall.status == StallStatus.confirmed
        ? (stall.spot.isNotEmpty && stall.spot != '—' ? stall.spot : _nextSpot(ev))
        : '—';
    final newStall = Stall(
      id: _uid('s'), name: stall.name, cuisine: stall.cuisine, owner: stall.owner,
      status: stall.status, spot: spot, fee: ev.fee,
    );
    await _eventsRepo.setStalls(eventId, [...ev.stalls, newStall]);
  }

  Future<void> updateStall(String eventId, Stall stall) async {
    final ev = _events.firstWhere((e) => e.id == eventId);
    final updated = ev.stalls.map((s) => s.id == stall.id ? stall : s).toList();
    await _eventsRepo.setStalls(eventId, updated);
  }

  Future<void> removeStall(String eventId, String stallId) async {
    final ev = _events.firstWhere((e) => e.id == eventId);
    await _eventsRepo.setStalls(eventId, ev.stalls.where((s) => s.id != stallId).toList());
  }

  Future<void> setStallStatus(String eventId, String stallId, StallStatus status) async {
    final ev = _events.firstWhere((e) => e.id == eventId);
    final updated = ev.stalls.map((s) {
      if (s.id != stallId) return s;
      final spot = status == StallStatus.confirmed
          ? ((s.spot.isEmpty || s.spot == '—') ? _nextSpot(ev) : s.spot)
          : '—';
      return s.copyWith(status: status, spot: spot);
    }).toList();
    await _eventsRepo.setStalls(eventId, updated);
  }

  Future<void> joinEvent(String eventId, String status) async {
    if (_user == null) return;
    final existing = participationFor(eventId);
    if (existing != null) {
      await _usersRepo.upsertParticipation(_user!.uid, Participation(id: eventId, status: status, spot: existing.spot));
    } else {
      await _usersRepo.upsertParticipation(_user!.uid, Participation(id: eventId, status: status));
    }
  }

  Future<void> withdraw(String eventId) async {
    if (_user == null) return;
    await _usersRepo.removeParticipation(_user!.uid, eventId);
  }

  Future<void> markRead(String id) async {
    if (_user == null) return;
    await _usersRepo.markRead(_user!.uid, id);
  }

  Future<void> markAllRead() async {
    if (_user == null) return;
    await _usersRepo.markAllRead(_user!.uid);
  }

  Future<void> resolveNotif(String id, String result) async {
    if (_user == null) return;
    await _usersRepo.resolveNotif(_user!.uid, id, result);
  }

  Future<void> setSetting(String key, bool value) async {
    if (_user == null) return;
    await _usersRepo.setSetting(_user!.uid, key, value);
  }

  Future<void> saveProfile(Profile p) async {
    if (_user == null) return;
    await _usersRepo.updateProfile(_user!.uid, p);
  }

  Stream<Map<String, bool>> settingsStream() =>
      _user == null ? const Stream.empty() : _usersRepo.watchSettings(_user!.uid);

  @override
  void dispose() {
    _authSub.cancel();
    _cancelStreams();
    super.dispose();
  }
}

