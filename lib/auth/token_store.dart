import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;
  TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> j) =>
      TokenPair(accessToken: j['accessToken'], refreshToken: j['refreshToken']);
}

class TokenStore {
  // iOS: Keychain ; Android: EncryptedSharedPreferences
  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(TokenPair pair) async {
    await Future.wait([
      _storage.write(key: _kAccess, value: pair.accessToken),
      _storage.write(key: _kRefresh, value: pair.refreshToken),
    ]);
  }

  Future<String?> readAccess() => _storage.read(key: _kAccess);
  Future<String?> readRefresh() => _storage.read(key: _kRefresh);

  Future<void> updateAccess(String accessToken) =>
      _storage.write(key: _kAccess, value: accessToken);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
