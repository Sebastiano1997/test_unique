import 'dart:convert';

import 'SharedPreferencesManager.dart';

abstract class ISaveLoad<T> {
  Future<void> save(T value);
  Future<T?> load();
}

class SaveLoadJson<T> implements ISaveLoad<T> {
  SaveLoadJson({
    required this.keyToSave,
    required this.toJson,
    required this.fromJson,
  });

  final String keyToSave;
  final Map<String, dynamic> Function(T value) toJson;
  final T Function(Map<String, dynamic> json) fromJson;
  final String keyGeneral = 'key';

  @override
  Future<void> save(T value) async {
    final manager = SharedPreferencesManager();
    final json = jsonEncode(toJson(value));
    await manager.setSharedPreferences(keyToSave, json);
    await _saveKeyGeneral(keyToSave);
  }

  @override
  Future<T?> load() async {
    final manager = SharedPreferencesManager();
    final raw = await manager.getSharedPreferences(keyToSave);
    if (raw is! String) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;

    return fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> _saveKeyGeneral(String key) async {
    final manager = SharedPreferencesManager();
    final savedKeys = await manager.getListSharedPreferences(keyGeneral);
    final keys = savedKeys == null ? <String>[] : List<String>.from(savedKeys);

    if (!keys.contains(key)) {
      keys.add(key);
      await manager.setListSharedPreferences(keyGeneral, keys);
    }
  }
}
