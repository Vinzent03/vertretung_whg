import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<void> setBool(String name, bool b) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(name, b);
  }

  Future<bool> getBool(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? true;
  }

  Future<void> setString(String name, String text) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(name, text);
  }

  Future<String> getString(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(name) ?? "Nicht festgelegt";
  }

  Future<void> setStringList(String name, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(name, list);
  }

  Future<List<String>> getStringList(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(name) ?? [];
  }

  Future<int> getInt(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(name) ?? 0;
  }

  Future<void> setInt(String name, int newInt) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(name, newInt);
  }

  Future<bool> checkIfKeyIsSet(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(name);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
