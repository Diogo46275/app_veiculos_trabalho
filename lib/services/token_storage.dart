import 'package:shared_preferences/shared_preferences.dart';

abstract final class TokenStorage {
  static const _tokenKey = 'jwt_token';

  static SharedPreferencesWithCache? _prefs;

  static Future<SharedPreferencesWithCache> _instance() async {
    return _prefs ??= await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _instance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await _instance();
    await prefs.remove(_tokenKey);
  }
}
