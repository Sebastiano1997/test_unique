import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';



@pragma('vm:entry-point')
class AlarmManager
{
  /// + upgradeable
  Future<void> callBackLocal(int id,Map<String,dynamic> map)
  async {
    // Get the previous cached count and increment it.
    ////final prefs = await SharedPreferences.getInstance();
    ////final currentCount = prefs.getInt(countKey) ?? 0;
    ////await prefs.setInt(countKey, currentCount + 1);


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
 // -

  /// + body

  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;
  int? id;

  // The background
  static SendPort? uiSendPort;
  static List<int> listId=[];
  /// The name associated with the UI isolate's [SendPort].
  static const String isolateName = 'isolate';
  /// A port used to communicate from a background isolate to the UI isolate.
  static ReceivePort port = ReceivePort();

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


/// + config to add
/* AndroidManifest.xml (es. C:\Users\moris\StudioProjects\test_unique\android\app\src\main) ::
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <!-- For apps with targetSDK 31 (Android 12) and newer -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/> //added for vibration
    ...
    <application
        android:label="test_unique"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        ...
      <service
		  	android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmService"
		  	android:permission="android.permission.BIND_JOB_SERVICE"
		  	android:exported="false"/>
		  <receiver
		  	android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver"
		  	android:exported="false"/>
		  <receiver
		  	android:name="dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver"
		  	android:enabled="false"
		  	android:exported="false">
		  	<intent-filter>
		  		<action android:name="android.intent.action.BOOT_COMPLETED" />
		  	</intent-filter>
		  </receiver>


 */