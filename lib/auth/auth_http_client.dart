import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'token_store.dart';
import 'auth_api.dart';

class AuthHttpClient {
  final http.Client _inner;
  final TokenStore _store;
  final AuthApi _authApi;

  String? _access;                   // cache mémoire
  Future<void>? _refreshing;         // mutualise les refresh concurrents

  AuthHttpClient(this._inner, this._store, this._authApi);

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
      _send('GET', url, headers: headers);

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _send('DELETE', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _send('POST', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _send('PUT', url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> _send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final token = await _ensureValidAccessToken();

    final h = <String, String>{
      if (headers != null) ...headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    var res = await _dispatch(method, url, headers: h, body: body, encoding: encoding);

    if (res.statusCode == 401 || res.statusCode == 403) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final h2 = <String, String>{
          if (headers != null) ...headers,
          'Authorization': 'Bearer ${_access!}',
        };
        res = await _dispatch(method, url, headers: h2, body: body, encoding: encoding);
      }
    }
    return res;
  }

  Future<http.Response> _dispatch(String method, Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    switch (method) {
      case 'GET': return _inner.get(url, headers: headers);
      case 'DELETE': return _inner.delete(url, headers: headers, body: body, encoding: encoding);
      case 'POST': return _inner.post(url, headers: headers, body: body, encoding: encoding);
      case 'PUT': return _inner.put(url, headers: headers, body: body, encoding: encoding);
      default: throw UnsupportedError('HTTP $method not implemented');
    }
  }

  Future<String?> _ensureValidAccessToken() async {
    _access ??= await _store.readAccess();
    if (_access == null) return null;

    // Refresh proactif si expiration < 60s
    if (_isExpiringSoon(_access!)) {
      final ok = await _tryRefresh();
      if (!ok) return null;
    }
    return _access;
  }

  bool _isExpiringSoon(String jwt) {
    try {
      final exp = JwtDecoder.getExpirationDate(jwt);
      return DateTime.now().add(const Duration(seconds: 60)).isAfter(exp);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryRefresh() async {
    if (_refreshing != null) {
      await _refreshing;
      return _access != null;
    }

    final c = Completer<void>();
    _refreshing = c.future;

    try {
      final refresh = await _store.readRefresh();
      if (refresh == null) {
        await logout();
        c.complete();
        return false;
      }
      final pair = await _authApi.refresh(refresh);
      _access = pair.accessToken;
      await _store.save(pair); // remplace aussi le refresh
      c.complete();
      return true;
    } catch (_) {
      await logout();
      c.complete();
      return false;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> primeWithAccess(String accessToken) async {
    _access = accessToken;
    await _store.updateAccess(accessToken);
  }

  Future<void> logout() async {
    _access = null;
    await _store.clear();
  }
}
