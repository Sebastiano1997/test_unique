

//import 'dart:collection';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // terminal-> flutter pub add shared_preferences


/// + classico save,load
class SharedPreferencesManager{
  List<String> lsKey=[];
  Object? x;
  late SharedPreferences sharedPreferences;



  void setSharedPreferences(String key,dynamic value)async{ // lo modifica
    sharedPreferences = await SharedPreferences.getInstance();
    await   sharedPreferences.setString(key, value.toString());

    if(!lsKey.contains(key)) {
      lsKey.add(key);
    }


  }

  void setListSharedPreferences(String key,dynamic value)async{ // lo modifica
    sharedPreferences = await SharedPreferences.getInstance();
    await   sharedPreferences.setStringList(key, value);

    if(!lsKey.contains(key)) {
      lsKey.add(key);
    }

  }


  Future<dynamic> getSharedPreferences(String? key)async{ // lo fa vedere tramite x
    sharedPreferences = await SharedPreferences.getInstance();

    if(!(key==null))
    {
      if(sharedPreferences.containsKey(key!)) {
        x = sharedPreferences.getString(key);
        return x;
      }
    }


    x=null;
    return x;

  }

  Future<dynamic> getListSharedPreferences(String? key)async{ // lo fa vedere tramite x
    sharedPreferences = await SharedPreferences.getInstance();

    if(!(key==null))
    {
      if(sharedPreferences.containsKey(key!)) {
        x = sharedPreferences.getStringList(key);
        return x;
      }
    }


    x=null;
    return x;

  }


  void clear()
  {
    sharedPreferences.clear();
  }

}
// -
