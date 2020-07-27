import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<void> setBool(String st, b) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(st, b);
  }

  Future<bool> getBool(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? true;
  }

  Future<void> setString(String st, String b) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(st, b);
  }

  Future<String> getString(String st) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(st) ?? "Nicht festgelegt";
  }

  Future<void> setStringList(String st, List<String> b) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(st, b);
  }

  Future<List<String>> getStringList(String st) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(st) ?? [];
  }

  Future<int> getInt(String st) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(st) ?? 0;
  }

  Future<void> setInt(String st, int newInt) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(st,newInt);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
