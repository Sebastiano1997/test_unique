import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';

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
}

// --- VIEW MODEL ---

/// Manages the state and logic for the activity timer.
class ActivityViewModel extends ChangeNotifier {
  // --- Private Properties ---
  final List<Activity> _activities;
  Activity? _selectedActivity;
  bool _isPlaying;
  Duration _currentPlayDuration;
  Duration _currentPauseDuration;
  int _minPauseVibrationSeconds;
  int _minPlayVibrationSeconds;
  final List<DateWork> _listDateWork;
  Timer? _timer;
  DateTime? _lastTickTime;
  DateTime? _sessionStartTime;
  bool _hasVibratedForPlayThreshold;
  bool _hasVibratedForPauseThreshold;

  // --- Constructor and Initializer List ---
  ActivityViewModel()
      : _activities = [
    Activity(id: '1', name: 'Work'),
    Activity(id: '2', name: 'Break'),
    Activity(id: '3', name: 'Study'),
  ],
        _selectedActivity = null, // Will be set to _activities.first in body
        _isPlaying = false,
        _currentPlayDuration = Duration.zero,
        _currentPauseDuration = Duration.zero,
        _minPauseVibrationSeconds = 1 * 60, // Default 1 minute
        _minPlayVibrationSeconds = 5 * 60, // Default 5 minutes
        _listDateWork = [],
        _hasVibratedForPlayThreshold = false,
        _hasVibratedForPauseThreshold = false {
    _selectedActivity = _activities.first; // Set a default selected activity
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
      // If a session was active (either playing or paused),
      // stop it and log it as if 'Stop' was clicked for the old activity.
      if (_sessionStartTime != null) {
        _stopAndLogCurrentSession();
      }
      // Then, reset all timer-related state variables for the new activity.
      // This also ensures _isPlaying is false and durations are zero.
      _resetCurrentSession();

      _selectedActivity = item; // Set the new selected activity
      notifyListeners(); // Notify listeners about the change.
    }
  }

  /// Toggles the play/pause state of the timer.
  void clickPlayOrPause() {
    if (_selectedActivity == null) {
      // Should not happen with default selection, but as a safeguard.
      return;
    }

    _isPlaying = !_isPlaying;

    if (_isPlaying) {
      // Switched to Play
      _startTimer(); // Ensure timer is running to increment duration
      _lastTickTime = DateTime.now();
      _sessionStartTime ??= DateTime.now(); // Set session start time if not already set
      _hasVibratedForPauseThreshold = false; // Reset pause vibration flag for new segment

      // Reset play and pause durations when re-clicking play, as per request.
      _currentPlayDuration = Duration.zero;
      _currentPauseDuration = Duration.zero;
      _hasVibratedForPlayThreshold = false; // Reset play vibration flag to allow re-vibration for new segment
    } else {
      // Switched to Pause
      // Timer should continue running, but will now accumulate _currentPauseDuration
      if (_lastTickTime != null) {
        // Capture any elapsed play time before switching to pause
        _currentPlayDuration += DateTime.now().difference(_lastTickTime!);
      }
      _lastTickTime = DateTime.now(); // Update lastTickTime for pause duration calculation
      _hasVibratedForPlayThreshold = false; // Reset play vibration flag for new segment
    }
    notifyListeners();
  }

  /// Sets the minimum pause duration in minutes before a vibration alert occurs.
  void onChangedMinPauseVibration(int min) {
    _minPauseVibrationSeconds = min * 60;
    _hasVibratedForPauseThreshold = false; // Allow re-vibration if threshold changes
    notifyListeners();
  }

  /// Sets the minimum play duration in minutes before a vibration alert occurs.
  void onChangedMinPlayVibration(int min) {
    _minPlayVibrationSeconds = min * 60;
    _hasVibratedForPlayThreshold = false; // Allow re-vibration if threshold changes
    notifyListeners();
  }

  /// Stops the current timer session and logs it.
  void stop() {
    if (_sessionStartTime != null && _selectedActivity != null) {
      _stopAndLogCurrentSession();
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
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final now = DateTime.now();
      if (_lastTickTime != null) {
        final elapsed = now.difference(_lastTickTime!);
        if (_isPlaying) {
          _currentPlayDuration += elapsed;
          _checkVibration(_currentPlayDuration, _minPlayVibrationSeconds, true);
        } else {
          // This block now correctly executes when _isPlaying is false (paused)
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
        HapticFeedback.heavyImpact(); // Strong vibration
        if (isPlay) {
          _hasVibratedForPlayThreshold = true;
        } else {
          _hasVibratedForPauseThreshold = true;
        }
      }
    } else {
      // Reset vibration flags if duration drops below threshold (e.g., threshold changed to higher)
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
    // Calculate final duration based on current state
    if (_lastTickTime != null) {
      final elapsedSinceLastTick = DateTime.now().difference(_lastTickTime!);
      // Ensure the correct duration is added before logging,
      // regardless of whether it was currently playing or paused when stopped.
      if (_isPlaying) {
        _currentPlayDuration += elapsedSinceLastTick;
      } else {
        _currentPauseDuration += elapsedSinceLastTick; // Also account for pause time if stopped while paused.
      }
    }

    if (_sessionStartTime != null && _selectedActivity != null) {
      _listDateWork.add(
        DateWork(
          activityName: _selectedActivity!.name,
          startTime: _sessionStartTime!,
          endTime: DateTime.now(),
          duration: _currentPlayDuration, // Log the total play duration for the session
        ),
      );
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
    notifyListeners();
  }

  /// Removes an activity from the list. Ensures at least one activity remains.
  void removeActivity(Activity activity) {
    if (_activities.length > 1) {
      // Ensure at least one activity remains
      _activities.remove(activity);
      if (_selectedActivity == activity) {
        _selectedActivity = _activities.first;
        _resetCurrentSession(); // Reset if the removed activity was selected
      }
      notifyListeners();
    }
  }
}

// --- MAIN APPLICATION WIDGETS ---

void main() {
  runApp(const TimerApp());
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
          return const MainTimerScreen();
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