import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefHelper {
  static const String _tokenKey = 'auth_token';
  static const String _lng = 'lng';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static late SharedPreferences _prefs;

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<void> saveLng(String val) async {
    await _prefs.setString(_lng, val);
  }

  static String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  static Future<String?> getLng() async {
    return _prefs.getString(_lng);
  }

  static bool isLoggedIn() {
    // return _prefs.getBool(_isLoggedInKey) ?? false;
    return getToken() != null;
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<void> logout() async {
    await clearAll();
  }
}