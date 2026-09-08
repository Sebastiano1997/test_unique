import 'dart:convert';

import 'SharedPreferencesManager.dart';


abstract class ISaveLoad<T>
{
  void save();
  Future<T?> load();
}

class SaveLoadJson<T> implements ISaveLoad<T>
{
  SaveLoadJson({required this.keyToSave,required this.toJson, required this.fromJson});

  Map<String, dynamic> Function() toJson;
  T Function(Map<String, dynamic> json) fromJson;
  String keyToSave;

  final String keyGeneral="key";

  @override
  void save([String? key]) {
    key??=keyToSave;
    String json = jsonEncode(toJson()); // da oggetto--> stringa
    SharedPreferencesManager().setSharedPreferences(key, json);
    _saveKeyGeneral(key);
  }

  @override
  Future<T?> load([String? key]) async {
    key??=keyToSave;
    String? json=await SharedPreferencesManager().getSharedPreferences(key);
    if(json==null) return null;

    Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>; // da stringa--> Map

    return fromJson(map); // da Map--> a oggetto
  }

  Future<void> _saveKeyGeneral(String key) async {
    List<String>? listKey=await SharedPreferencesManager().getListSharedPreferences(keyGeneral);
    if(listKey==null || !listKey.contains(key))
    {
      listKey??=[];
      listKey.add(key);
      SharedPreferencesManager().setListSharedPreferences(keyGeneral, listKey);
    }
  }

}

/// Map<String, dynamic> toJson() {
//     return {
//       'isTrue': isTrue.toString(),
//       'X':X.saveLoad.toJson(),
//       'listX': listX.map((value) => value.saveLoad.toJson()).toList(), // di 'X'=> extends ComponentJson<T>
//       'min':min.toString()
//     };
//   }
///ObjectThis fromJson(Map<String, dynamic> json) {
//     ObjectThis objectThis= this;
//
//     objectThis.min=int.parse(json["min"]);
//     objectThis.X=X().fromJson(json["X"]);
//     objectThis.isTrue= (json["isTrue"]=="null")?null:bool.parse(json["isTrue"]);
//     objectThis.listX=List<X>.from(json["listX"].map((i) => X().fromJson(i)).toList());
//
//     return objectThis;
//   }

// -