import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _userIdKey = 'userId';

  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Adjust this key according to how you've saved the userId
    // Remove other user-specific data as needed
  }
}

