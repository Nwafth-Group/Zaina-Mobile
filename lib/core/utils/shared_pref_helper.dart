import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


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

  static Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  static Future<String?> getLng() async {
    return _prefs.getString(_lng);
  }

  // static Future<void> saveUser(UserModel user) async {
  //   await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  //   await _prefs.setBool(_isLoggedInKey, true);
  // }
  //
  // static Future<UserModel?> getUser() async {
  //   final userData = _prefs.getString(_userKey);
  //   if (userData != null) {
  //     return UserModel.fromJson(jsonDecode(userData));
  //   }
  //   return null;
  // }

  static Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }
}