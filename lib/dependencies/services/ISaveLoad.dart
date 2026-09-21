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
    final json = jsonEncode(toJson(value));
    final manager = SharedPreferencesManager();

    await manager.setSharedPreferences(keyToSave, json);
    await _saveKeyGeneral(keyToSave);
  }

  @override
  Future<T?> load() async {
    final manager = SharedPreferencesManager();
    final raw = await manager.getSharedPreferences(keyToSave);

    if (raw == null) {
      return null;
    }

    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return fromJson(decoded);
  }

  Future<void> _saveKeyGeneral(String key) async {
    final manager = SharedPreferencesManager();
    final listKey = await manager.getListSharedPreferences(keyGeneral);
    final current = listKey is List ? List<String>.from(listKey) : <String>[];

    if (!current.contains(key)) {
      current.add(key);
      await manager.setListSharedPreferences(keyGeneral, current);
    }
  }
}
