import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => 'ApiException($status): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _http;
  String? token;

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? kApiBaseUrl,
        _http = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) =>
      _send(() => _http.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, [Object? body]) => _send(
      () => _http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> put(String path, [Object? body]) => _send(
      () => _http.put(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> patch(String path, [Object? body]) => _send(
      () => _http.patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() run) async {
    final res = await run();
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (!ok) {
      final msg = body is Map && body['error'] != null
          ? body['error'].toString()
          : 'request failed';
      throw ApiException(res.statusCode, msg);
    }
    return body;
  }
}

Stream<T> pollStream<T>(
  Future<T> Function() fetch, {
  Duration interval = kPollInterval,
}) {
  late StreamController<T> ctrl;
  Timer? timer;
  var busy = false;

  Future<void> tick() async {
    if (busy) return;
    busy = true;
    try {
      final value = await fetch();
      if (!ctrl.isClosed) ctrl.add(value);
    } catch (e) {
      if (!ctrl.isClosed) ctrl.addError(e);
    } finally {
      busy = false;
    }
  }

  ctrl = StreamController<T>(
    onListen: () {
      tick();
      timer = Timer.periodic(interval, (_) => tick());
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );
  return ctrl.stream;
}
