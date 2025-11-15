import 'dart:async';
import 'dart:convert'; // For JSON serialization
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persistence
import 'package:test_unique/HistoryObj.dart';

import 'SelectItem.dart';



// --- MAIN APPLICATION WIDGETS ---

void main() {
  HistoryObjFather<Obj1> historyObjFather=HistoryObjFather<Obj1>();
  List<Obj1> list=[
    Obj1()..x=1,
    Obj1()..x=2,
    Obj1()..x=3,
  ];

  historyObjFather.addHistory(()=>list[1]);
  list[1]=Obj1()..x=10;

  historyObjFather.addHistory(()=>list[1]);
  list[1]=Obj1()..x=100;

  historyObjFather.addHistory(()=>list[1]);
  list[1]=Obj1()..x=1000; //todo//#ne il primo elemento getItem() ha il riferimento a questo oggetto

  list[1]=historyObjFather.back(list[1])!.item!;
  print("${list[1].x}");
  list[1]=historyObjFather.back(list[1])!.item!;
  print("${list[1].x}");
  list[1]=historyObjFather.back(list[1])!.item!;
  print("${list[1].x}");
  list[1]=historyObjFather.back(list[1])!.item!;
  print("${list[1].x}");

  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized for SharedPreferences
  runApp(const TimerApp());
  //runApp(SelectItem<int>(0));
}

class Obj1 implements ICopyT<Obj1>
{
  int x=0;

  @override
  Obj1 copy(Obj1 item) {
    return Obj1()..x=item.x;
  }

}



// ---------------------------------

// --- DATA MODELS ---

/// Represents an activity with a unique identifier and a name.
class Activity {
  final String id;
  final String name;

  Activity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Converts an Activity object to a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Creates an Activity object from a JSON-compatible Map.
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// Represents a logged work session for an activity.
class DateWork {
  final String activityName;
  final DateTime startTime;
  final DateTime? endTime; // Nullable if session is ongoing or wasn't properly stopped
  final Duration duration;

  DateWork({
    required this.activityName,
    required this.startTime,
    this.endTime,
    required this.duration,
  });

  /// Formats the duration into HH:MM:SS string.
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  /// Formats the start time for display.
  String get formattedStartTime {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${startTime.hour}:${twoDigits(startTime.minute)} on ${startTime.day}/${startTime.month}";
  }

  /// Converts a DateWork object to a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'activityName': activityName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMicroseconds': duration.inMicroseconds,
    };
  }

  /// Creates a DateWork object from a JSON-compatible Map.
  factory DateWork.fromJson(Map<String, dynamic> json) {
    return DateWork(
      activityName: json['activityName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      duration: Duration(microseconds: json['durationMicroseconds'] as int),
    );
  }
}

// --- VIEW MODEL ---

/// Manages the state and logic for the activity timer.
class ActivityViewModel extends ChangeNotifier {
  // --- Private Properties ---
  List<Activity> _activities; // Made non-final to allow modification after load
  Activity? _selectedActivity;
  bool _isPlaying;
  Duration _currentPlayDuration;
  Duration _currentPauseDuration;
  int _minPauseVibrationSeconds;
  int _minPlayVibrationSeconds;
  final List<DateWork> _listDateWork; // Still final, modifications done via add/remove
  Timer? _timer;
  DateTime? _lastTickTime;
  DateTime? _sessionStartTime;
  bool _hasVibratedForPlayThreshold;
  bool _hasVibratedForPauseThreshold;

  // --- SharedPreferences Keys ---
  static const String _activitiesKey = 'activities';
  static const String _selectedActivityIdKey = 'selectedActivityId';
  static const String _minPauseVibrationSecondsKey = 'minPauseVibrationSeconds';
  static const String _minPlayVibrationSecondsKey = 'minPlayVibrationSeconds';
  static const String _dateWorkListKey = 'dateWorkList';

  // --- Constructor and Initializer List ---
  ActivityViewModel()
      : _activities = [], // Initialize empty, will load from prefs or use defaults
        _selectedActivity = null,
        _isPlaying = false,
        _currentPlayDuration = Duration.zero,
        _currentPauseDuration = Duration.zero,
        _minPauseVibrationSeconds = 1 * 60, // Default 1 minute
        _minPlayVibrationSeconds = 5 * 60, // Default 5 minutes
        _listDateWork = [],
        _hasVibratedForPlayThreshold = false,
        _hasVibratedForPauseThreshold = false {
    _loadData(); // Load data asynchronously after initial setup
  }

  // --- Public Getters ---
  List<Activity> get activities => List.unmodifiable(_activities);
  Activity? get selectedActivity => _selectedActivity;
  bool get isPlaying => _isPlaying;
  Duration get currentPlayDuration => _currentPlayDuration;
  Duration get currentPauseDuration => _currentPauseDuration;
  int get minPauseVibrationMinutes => (_minPauseVibrationSeconds / 60).round();
  int get minPlayVibrationMinutes => (_minPlayVibrationSeconds / 60).round();
  List<DateWork> get listDateWork => List.unmodifiable(_listDateWork);

  // Formatted duration for display
  String get formattedCurrentPlayDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = _currentPlayDuration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String twoDigitSeconds = _currentPlayDuration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "${_currentPlayDuration.inHours.toString().padLeft(2, "0")}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String get formattedCurrentPauseDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = _currentPauseDuration.inMinutes.remainder(60).toString().padLeft(2, "0");
    String twoDigitSeconds = _currentPauseDuration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "${_currentPauseDuration.inHours.toString().padLeft(2, "0")}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // --- Public Methods (from requirements) ---

  /// Selects a new activity. If a timer session was in progress (playing or paused),
  /// it stops and logs the current session as if the 'Stop' button was clicked.
  void selectActivity(Activity item) {
    if (_selectedActivity != item) {
      if (_sessionStartTime != null) {
        _stopAndLogCurrentSession();
      }
      _resetCurrentSession();
      _selectedActivity = item;
      _saveData(); // Save selected activity change
      notifyListeners();
    }
  }

  /// Toggles the play/pause state of the timer.
  void clickPlayOrPause() {
    if (_selectedActivity == null) {
      return;
    }

    _isPlaying = !_isPlaying;

    if (_isPlaying) {
      _startTimer();
      _lastTickTime = DateTime.now();
      _sessionStartTime ??= DateTime.now();
      _hasVibratedForPauseThreshold = false;

      // Reset play and pause durations when re-clicking play, as per existing logic.
      _currentPlayDuration = Duration.zero;
      _currentPauseDuration = Duration.zero;
      _hasVibratedForPlayThreshold = false;
    } else {
      if (_lastTickTime != null) {
        _currentPlayDuration += DateTime.now().difference(_lastTickTime!);
      }
      _lastTickTime = DateTime.now();
      _hasVibratedForPlayThreshold = false;
    }
    notifyListeners();
  }

  /// Sets the minimum pause duration in minutes before a vibration alert occurs.
  void onChangedMinPauseVibration(int min) {
    _minPauseVibrationSeconds = min * 60;
    _hasVibratedForPauseThreshold = false;
    _saveData(); // Save settings change
    notifyListeners();
  }

  /// Sets the minimum play duration in minutes before a vibration alert occurs.
  void onChangedMinPlayVibration(int min) {
    _minPlayVibrationSeconds = min * 60;
    _hasVibratedForPlayThreshold = false;
    _saveData(); // Save settings change
    notifyListeners();
  }

  /// Stops the current timer session and logs it.
  void stop() {
    if (_sessionStartTime != null && _selectedActivity != null) {
      _stopAndLogCurrentSession(); // This will call _saveData() internally
    }
    _resetCurrentSession();
    notifyListeners();
  }

  /// Resets the current timer session to zero without logging it.
  void zero() {
    _resetCurrentSession();
    notifyListeners();
  }

  // --- Internal Helper Methods ---

  /// Starts or restarts the periodic timer.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final now = DateTime.now();
      if (_lastTickTime != null) {
        final elapsed = now.difference(_lastTickTime!);
        if (_isPlaying) {
          _currentPlayDuration += elapsed;
          _checkVibration(_currentPlayDuration, _minPlayVibrationSeconds, true);
        } else {
          _currentPauseDuration += elapsed;
          _checkVibration(_currentPauseDuration, _minPauseVibrationSeconds, false);
        }
      }
      _lastTickTime = now;
      notifyListeners();
    });
  }

  /// Stops the periodic timer.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Checks if vibration thresholds are met and triggers haptic feedback.
  void _checkVibration(Duration currentDuration, int thresholdSeconds, bool isPlay) {
    if (currentDuration.inSeconds >= thresholdSeconds) {
      if ((isPlay && !_hasVibratedForPlayThreshold) || (!isPlay && !_hasVibratedForPauseThreshold)) {
        HapticFeedback.heavyImpact();
        if (isPlay) {
          _hasVibratedForPlayThreshold = true;
        } else {
          _hasVibratedForPauseThreshold = true;
        }
      }
    } else {
      if (isPlay) {
        _hasVibratedForPlayThreshold = false;
      } else {
        _hasVibratedForPauseThreshold = false;
      }
    }
  }

  /// Stops the timer and logs the current session to `_listDateWork`.
  void _stopAndLogCurrentSession() {
    _stopTimer();
    if (_lastTickTime != null) {
      final elapsedSinceLastTick = DateTime.now().difference(_lastTickTime!);
      if (_isPlaying) {
        _currentPlayDuration += elapsedSinceLastTick;
      } else {
        _currentPauseDuration += elapsedSinceLastTick;
      }
    }

    if (_sessionStartTime != null && _selectedActivity != null) {
      _listDateWork.add(
        DateWork(
          activityName: _selectedActivity!.name,
          startTime: _sessionStartTime!,
          endTime: DateTime.now(),
          duration: _currentPlayDuration, // Log the total play duration for this segment
        ),
      );
      _saveData(); // Save logged sessions
    }
  }

  /// Resets all timer-related properties for the current session.
  void _resetCurrentSession() {
    _stopTimer();
    _isPlaying = false;
    _currentPlayDuration = Duration.zero;
    _currentPauseDuration = Duration.zero;
    _lastTickTime = null;
    _sessionStartTime = null;
    _hasVibratedForPlayThreshold = false;
    _hasVibratedForPauseThreshold = false;
  }

  // --- Persistence Methods ---

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load activities
    final List<String>? activitiesJsonStrings = prefs.getStringList(_activitiesKey);
    if (activitiesJsonStrings != null && activitiesJsonStrings.isNotEmpty) {
      _activities = activitiesJsonStrings
          .map<Activity>((jsonString) => Activity.fromJson(json.decode(jsonString) as Map<String, dynamic>))
          .toList();
    } else {
      // If no activities saved, initialize with defaults
      _activities = [
        Activity(id: '1', name: 'Work'),
        Activity(id: '2', name: 'Break'),
        Activity(id: '3', name: 'Study'),
      ];
    }

    // Load selected activity
    final String? selectedActivityId = prefs.getString(_selectedActivityIdKey);
    if (selectedActivityId != null && _activities.any((activity) => activity.id == selectedActivityId)) {
      _selectedActivity = _activities.firstWhere(
            (activity) => activity.id == selectedActivityId,
      );
    } else {
      _selectedActivity = _activities.first; // Default if nothing saved or ID not found
    }

    // Load vibration settings
    _minPauseVibrationSeconds = prefs.getInt(_minPauseVibrationSecondsKey) ?? (1 * 60);
    _minPlayVibrationSeconds = prefs.getInt(_minPlayVibrationSecondsKey) ?? (5 * 60);

    // Load logged work sessions
    final List<String>? dateWorkJsonStrings = prefs.getStringList(_dateWorkListKey);
    if (dateWorkJsonStrings != null && dateWorkJsonStrings.isNotEmpty) {
      _listDateWork.addAll(dateWorkJsonStrings
          .map<DateWork>((jsonString) => DateWork.fromJson(json.decode(jsonString) as Map<String, dynamic>))
          .toList());
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save activities
    final List<String> activitiesJsonStrings = _activities
        .map<String>((activity) => json.encode(activity.toJson()))
        .toList();
    await prefs.setStringList(_activitiesKey, activitiesJsonStrings);

    // Save selected activity ID
    await prefs.setString(_selectedActivityIdKey, _selectedActivity?.id ?? '');

    // Save vibration settings
    await prefs.setInt(_minPauseVibrationSecondsKey, _minPauseVibrationSeconds);
    await prefs.setInt(_minPlayVibrationSecondsKey, _minPlayVibrationSeconds);

    // Save logged work sessions
    final List<String> dateWorkJsonStrings = _listDateWork
        .map<String>((dateWork) => json.encode(dateWork.toJson()))
        .toList();
    await prefs.setStringList(_dateWorkListKey, dateWorkJsonStrings);
  }

  // --- Dispose ---
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // --- Activity Management (Add/Remove) ---

  /// Adds a new activity to the list.
  void addActivity(String name) {
    final newActivity = Activity(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    _activities.add(newActivity);
    _saveData(); // Save activities list change
    notifyListeners();
  }

  /// Removes an activity from the list. Ensures at least one activity remains.
  void removeActivity(Activity activity) {
    if (_activities.length > 1) {
      _activities.remove(activity);
      if (_selectedActivity == activity) {
        _selectedActivity = _activities.first;
        _resetCurrentSession();
      }
      _saveData(); // Save activities list change
      notifyListeners();
    }
  }
}



class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Timer',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider<ActivityViewModel>(
        create: (context) => ActivityViewModel(),
        builder: (context, child) {
          //return const MainTimerScreen();
          //return SelectItem<int>(0);
          //return SelectItem<String>("-",list: ["a","b","c","d","e","f"],);
          //return SelectItem<int>(65,onGetItem: (i)=>String.fromCharCode(i),);
          return SelectItem<int>(65,onGetItem: (i)=>String.fromCharCode(i),);
        },
      ),
    );
  }
}

class MainTimerScreen extends StatefulWidget {
  const MainTimerScreen({super.key});

  @override
  State<MainTimerScreen> createState() => _MainTimerScreenState();
}

class _MainTimerScreenState extends State<MainTimerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Timer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.timer), text: 'Timer'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          TimerTabContent(),
          HistoryTabContent(),
        ],
      ),
    );
  }
}

/// Content for the Timer tab, containing activity selection, timer display, controls, and vibration settings.
class TimerTabContent extends StatelessWidget {
  const TimerTabContent({super.key});

  void _showAddActivityDialog(BuildContext context, ActivityViewModel viewModel) {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Activity'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Activity Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  viewModel.addActivity(controller.text.trim());
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActivityViewModel>(); // Watch for changes

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Activity Selector
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Activity:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  DropdownButton<Activity>(
                    isExpanded: true,
                    value: viewModel.selectedActivity,
                    items: viewModel.activities.map<DropdownMenuItem<Activity>>((Activity activity) {
                      return DropdownMenuItem<Activity>(
                        value: activity,
                        child: Text(activity.name),
                      );
                    }).toList(),
                    onChanged: (Activity? newActivity) {
                      if (newActivity != null) {
                        context.read<ActivityViewModel>().selectActivity(newActivity);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Activity'),
                        onPressed: () => _showAddActivityDialog(context, viewModel),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove Selected'),
                        onPressed: viewModel.activities.length > 1 && viewModel.selectedActivity != null
                            ? () {
                          context.read<ActivityViewModel>().removeActivity(viewModel.selectedActivity!);
                        }
                            : null, // Disable if only one activity or no activity selected
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Timer Display
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Current Play Duration:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    viewModel.formattedCurrentPlayDuration,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Current Pause Duration:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    viewModel.formattedCurrentPauseDuration,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controls
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: Icon(viewModel.isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(viewModel.isPlaying ? 'Pause' : 'Play'),
                    onPressed: () => context.read<ActivityViewModel>().clickPlayOrPause(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    onPressed: () => context.read<ActivityViewModel>().stop(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Zero'),
                    onPressed: () => context.read<ActivityViewModel>().zero(),
                  ),
                ],
              ),
            ),
          ),

          // Vibration Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Vibration Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  Text(
                      'Vibrate after ${viewModel.minPlayVibrationMinutes} minutes of Play'),
                  Slider(
                    value: viewModel.minPlayVibrationMinutes.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${viewModel.minPlayVibrationMinutes} min',
                    onChanged: (double value) {
                      context.read<ActivityViewModel>().onChangedMinPlayVibration(value.toInt());
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                      'Vibrate after ${viewModel.minPauseVibrationMinutes} minutes of Pause'),
                  Slider(
                    value: viewModel.minPauseVibrationMinutes.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${viewModel.minPauseVibrationMinutes} min',
                    onChanged: (double value) {
                      context.read<ActivityViewModel>().onChangedMinPauseVibration(value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Content for the History tab, displaying a list of logged work sessions.
class HistoryTabContent extends StatelessWidget {
  const HistoryTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActivityViewModel>(); // Watch for changes

    if (viewModel.listDateWork.isEmpty) {
      return const Center(
        child: Text(
          'No activity sessions logged yet.',
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.listDateWork.length,
      itemBuilder: (BuildContext context, int index) {
        final dateWork = viewModel.listDateWork[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(dateWork.activityName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Started: ${dateWork.formattedStartTime}\nDuration: ${dateWork.formattedDuration}',
            ),
            trailing: dateWork.endTime != null
                ? Text(
              'Ended: ${dateWork.endTime!.hour}:${dateWork.endTime!.minute.toString().padLeft(2, "0")}',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            )
                : null,
            isThreeLine: true, // Allow multiple lines for subtitle
          ),
        );
      },
    );
  }
}