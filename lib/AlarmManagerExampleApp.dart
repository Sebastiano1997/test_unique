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

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

Future<void> main() async {
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

  runApp(const AlarmManagerExampleApp());
}

/// Example app for Espresso plugin.
class AlarmManagerExampleApp extends StatelessWidget {
  const AlarmManagerExampleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: const _AlarmHomePage(),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  const _AlarmHomePage();

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}
@pragma('vm:entry-point')
class _AlarmHomePageState extends State<_AlarmHomePage> {
  int _counter = 0;
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
    _checkExactAlarmPermission();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _incrementCounter());
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    if (!mounted) return;
    setState(() {
      _exactAlarmPermissionStatus = currentStatus;
    });
  }

  Future<void> _incrementCounter() async {
    developer.log('Increment counter!');
    // Ensure we've loaded the updated count from the background isolate.
    await prefs?.reload();

    setState(() {
      _counter++;
    });
  }

  // The background
  static SendPort? uiSendPort;

  // The callback for our alarm
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    developer.log('Alarm fired!');
    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(countKey) ?? 0;
    await prefs.setInt(countKey, currentCount + 1);

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
    Vibration.vibrate( pattern: [100, 500, 200, 1000], intensities: [128, 255]);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android alarm manager plus example'),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Alarms fired during this run of the app: $_counter',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Total alarms fired since app installation: ${prefs?.getInt(countKey).toString() ?? ''}',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_exactAlarmPermissionStatus.isDenied)
              Text(
                'SCHEDULE_EXACT_ALARM is denied\n\nAlarms scheduling is not available',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              )
            else
              Text(
                'SCHEDULE_EXACT_ALARM is granted\n\nAlarms scheduling is available',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isDenied
                  ? () async {
                await Permission.scheduleExactAlarm
                    .onGrantedCallback(() => setState(() {
                  _exactAlarmPermissionStatus =
                      PermissionStatus.granted;
                }))
                    .request();
              }
                  : null,
              child: const Text('Request exact alarm permission'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:() {
                setState(() {

                });
              },
              child: const Text('reload!'),
            ),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isGranted
                  ? () async {
                AlarmManager alarm=AlarmManager();
                await alarm.oneShot(Duration(seconds: 1));
              }
                  : null,
              child: const Text('Schedule OneShot Alarm With class (1sec)'),
            ),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isGranted
                  ? () async {
                await AndroidAlarmManager.oneShot(
                Duration(seconds: 1),
                // Ensure we have a unique alarm ID.
                Random().nextInt(pow(2, 31) as int),
                callback,
                exact: true,
                wakeup: true,
              );
              }
                  : null,
              child: const Text('Schedule OneShot Alarm Original (1sec)'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}


@pragma('vm:entry-point')
class AlarmManager
{

  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;
  int? id;

  // The background
  static SendPort? uiSendPort;
  static List<int> listId=[];


  Future<void> callBackLocal(int id,Map<String,dynamic> map)
  async {
    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(countKey) ?? 0;
    await prefs.setInt(countKey, currentCount + 1);


    Vibration.vibrate( pattern: [100, 500, 200, 1000], intensities: [128, 255]);
  }

  Future<int> oneShot(Duration duration)
  async {
    id=_getId();
    listId.add(id!);
    await AndroidAlarmManager.oneShot(
        duration,
        // Ensure we have a unique alarm ID.
        id!,
        callback,
        exact: true,
        wakeup: true,
        params: {
          "0":0,
        }
    );
    return id!;
  }

  @pragma('vm:entry-point')
  static Future<void> callback(int id,Map<String,dynamic> map) async {
    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);

    await AlarmManager().callBackLocal(id,map);

  }

  static Future<void> cancel(int id) async
  {
    await AndroidAlarmManager.cancel(id);
  }

  int _getId()
  {
    int id=-1;
    do{
      id=Random().nextInt(pow(2, 31) as int);
    }while(listId.contains(id));
    return id;
  }

}
