import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  List<String> lsKey = [];
  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get _preferences async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setSharedPreferences(String key, dynamic value) async {
    final preferences = await _preferences;
    await preferences.setString(key, value.toString());
    if (!lsKey.contains(key)) lsKey.add(key);
  }

  Future<void> setListSharedPreferences(
    String key,
    List<String> value,
  ) async {
    final preferences = await _preferences;
    await preferences.setStringList(key, value);
    if (!lsKey.contains(key)) lsKey.add(key);
  }

  Future<String?> getSharedPreferences(String? key) async {
    if (key == null) return null;
    final preferences = await _preferences;
    return preferences.getString(key);
  }

  Future<List<String>?> getListSharedPreferences(String? key) async {
    if (key == null) return null;
    final preferences = await _preferences;
    return preferences.getStringList(key);
  }

  Future<bool> clear() async {
    final preferences = await _preferences;
    lsKey.clear();
    return preferences.clear();
  }
}
