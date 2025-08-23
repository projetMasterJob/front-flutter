import 'package:shared_preferences/shared_preferences.dart';

class AccessCompat {
  static const _kAccess = 'access_token';

  static Future<void> set(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, token);
  }

  static Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccess);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
  }
}
