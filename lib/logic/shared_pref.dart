import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<void> setBool(String name, bool b) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(name, b);
  }

  static Future<bool> getBool(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? true;
  }

  static Future<void> setString(String name, String text) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(name, text);
  }

  static Future<String> getString(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(name) ?? "Nicht festgelegt";
  }

  static Future<void> setStringList(String name, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(name, list);
  }

  static Future<List<String>> getStringList(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(name) ?? [];
  }

  static Future<int> getInt(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(name) ?? 0;
  }

  static Future<void> setInt(String name, int newInt) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(name, newInt);
  }

  static Future<bool> checkIfKeyIsSet(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(name);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
