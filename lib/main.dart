// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:vibration/vibration.dart';

import 'AlarmManagerExampleApp.dart';
import 'ReorderableListPage.dart';
import 'Wello.dart';

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

Future<void> main() async {

  /*
  WidgetsFlutterBinding.ensureInitialized();

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey(countKey)) {
    await prefs!.setInt(countKey, 0);
  }
  */
  runApp(MyAppReorderableListPage());
}


class MoveItem extends StatelessWidget
{

  List<String> items=["a","b"];
  Wello? weObj;

  void onReorder(int oldIndex, int newIndex) {

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      weObj?.setStateWello();
  }
  @override
  Widget build(BuildContext context) {
    return
      Wello(
        builder: (we){weObj=we;},
        view: (we) { return  ReorderableListView.builder(
        itemCount: items.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            key: ValueKey(index), // chiave stabile = ordine corretto
            title: Text(item),
          );
        },
      ); },);

  }

}

