

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



void main() {

  runApp(

    ChangeNotifierProvider<SettingsData>(

      create: (context) => SettingsData(),

      builder: (context, child) {

        return MaterialApp(

          debugShowCheckedModeBanner: false,

          theme: ThemeData(

            primarySwatch: Colors.deepPurple,

            colorScheme: ColorScheme.fromSwatch(

              primarySwatch: Colors.deepPurple,

            ).copyWith(

              secondary: Colors.blueAccent, // A nice accent color

            ),

            appBarTheme: const AppBarTheme(

              backgroundColor: Colors.deepPurple,

              foregroundColor: Colors.white,

              elevation: 0,

            ),

            cardTheme: CardThemeData(

              elevation: 4,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

            ),

            listTileTheme: const ListTileThemeData(

              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),

              minLeadingWidth: 32,

            ),

          ),

          home: Scaffold(

            appBar: AppBar(

              title: const Text('Time Entry'),

            ),

            body: const MyApp(),

          ),

        );

      },

    ),

  );

}



/// DATA_MODEL

/// Manages the state for settings, including visibility and start time.

class SettingsData extends ChangeNotifier {

  bool _isVisible;

  TimeOfDay? _startTime;



  // Initialize with valid default values

  SettingsData()

      : _isVisible = true,

        _startTime = null;



  bool get isVisible => _isVisible;

  TimeOfDay? get startTime => _startTime;



  String get displayTimeStart {

    if (_startTime == null) {

      return "--:--"; // More visually appealing placeholder for null

    } else {

      return "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";

    }

  }



  void toggleVisibility() {

    _isVisible = !_isVisible;

    notifyListeners();

  }



  void setStartTime(TimeOfDay? newTime) {

    if (newTime != _startTime) {

      _startTime = newTime;

      notifyListeners();

    }

  }

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return Column(

      children: <Widget>[

        Card(

          // Using default CardTheme from MaterialApp for consistency

          child: ListTile(

            leading: Icon(

              Icons.timer_outlined,

              size: 40,

              color: Theme.of(context).colorScheme.primary, // Using theme color

            ),

            title: Row(

              crossAxisAlignment: CrossAxisAlignment.baseline,

              textBaseline: TextBaseline.alphabetic,

              children: <Widget>[

                Text(

                  "09:00",

                  style: Theme.of(context).textTheme.displaySmall?.copyWith(

                    fontWeight: FontWeight.bold,

                    color: Theme.of(context).colorScheme.primary,

                  ),

                ),

                const SizedBox(width: 8),

                Text(

                  "/10:00",

                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(

                    color: Colors.grey[600],

                  ),

                ),

              ],

            ),

            trailing: const RotatingClockIcon(),

          ),

        ),

        const SettingsCard(), // The new, captivating settings UI

      ],

    );

  }

}



/// A dedicated widget for the settings card, replacing the private _getSettings function.

class SettingsCard extends StatelessWidget {

  const SettingsCard({super.key});



  @override

  Widget build(BuildContext context) {

    return Consumer<SettingsData>(

      builder: (context, settingsData, child) {

        // Local function to handle time picking, which requires BuildContext.

        // This keeps the ChangeNotifier clean from UI-specific context dependencies.

        Future<void> selectTime(BuildContext ctx) async {

          final TimeOfDay? picked = await showTimePicker(

            context: ctx,

            initialTime: settingsData.startTime ?? TimeOfDay.now(),

            builder: (BuildContext context, Widget? child) {

              return Theme(

                data: ThemeData.light().copyWith(

                  colorScheme: ColorScheme.light(

                    primary: Theme.of(context).colorScheme.primary, // Header background color

                    onPrimary: Colors.white, // Header text color

                    surface: Colors.white, // Body background color

                    onSurface: Colors.black, // Body text color

                  ),

                  textButtonTheme: TextButtonThemeData(

                    style: TextButton.styleFrom(

                      foregroundColor: Theme.of(context).colorScheme.primary, // Button text color

                    ),

                  ),

                ),

                child: child!,

              );

            },

          );



          if (picked != null) {

            settingsData.setStartTime(picked); // Update the data model via provider

          }

        }



        return Card(

          // Using default CardTheme from MaterialApp for consistency

          child: Column(

            children: <Widget>[

              ListTile(

                leading: Icon(

                  Icons.settings,

                  color: Theme.of(context).colorScheme.primary,

                ),

                title: Text(

                  "App Settings",

                  style: Theme.of(context).textTheme.titleMedium?.copyWith(

                    fontWeight: FontWeight.bold,

                    color: Colors.black87,

                  ),

                ),

                trailing: IconButton(

                  onPressed: settingsData.toggleVisibility, // Calls method on data model

                  icon: Icon(

                    settingsData.isVisible

                        ? Icons.keyboard_arrow_up

                        : Icons.keyboard_arrow_down, // Modern arrow icons

                    color: Theme.of(context).colorScheme.primary,

                  ),

                ),

              ),

              // AnimatedSize provides a smooth expansion/collapse effect for the visibility

              AnimatedSize(

                duration: const Duration(milliseconds: 300),

                curve: Curves.easeInOut,

                alignment: Alignment.topCenter,

                child: Visibility(

                  visible: settingsData.isVisible,

                  child: Column(

                    children: <Widget>[

                      Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey[300]), // Visual separator

                      ListTile(

                        leading: Icon(

                          Icons.access_time_filled,

                          color: Theme.of(context).colorScheme.secondary,

                        ),

                        title: GestureDetector(

                          onTap: () => selectTime(context), // Tapping the text area also triggers time picker

                          child: Padding(

                            padding: const EdgeInsets.symmetric(vertical: 8.0),

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: <Widget>[

                                Text(

                                  "Start Time",

                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(

                                    color: Colors.grey[700],

                                    fontWeight: FontWeight.w500,

                                  ),

                                ),

                                Text(

                                  settingsData.displayTimeStart,

                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(

                                    color: Theme.of(context).colorScheme.secondary,

                                    fontWeight: FontWeight.w600,

                                  ),

                                ),

                              ],

                            ),

                          ),

                        ),

                        trailing: IconButton(

                          icon: Icon(

                            Icons.edit,

                            color: Theme.of(context).colorScheme.secondary,

                          ),

                          onPressed: () => selectTime(context), // Explicit button to select time

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ],

          ),

        );

      },

    );

  }

}



/// A [StatefulWidget] that displays a clock icon that rotates continuously.

class RotatingClockIcon extends StatefulWidget {

  const RotatingClockIcon({super.key});



  @override

  State<RotatingClockIcon> createState() => _RotatingClockIconState();

}



class _RotatingClockIconState extends State<RotatingClockIcon> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  late final Animation<double> _animation;



  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      duration: const Duration(

        seconds: 3,

      ), // Completes a full rotation every 3 seconds

      vsync: this,

    );

    _animation = CurvedAnimation(

      parent: _controller,

      curve: Curves.linear, // Linear curve for constant rotation speed

    );



    // Start the animation to repeat indefinitely

    _controller.repeat();

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return RotationTransition(

      turns: _animation,

      child: Icon(

        Icons.access_time,

        color: Theme.of(context).colorScheme.secondary, // Use theme color

        size: 30, // Adjusted size for better visual balance

      ),

    );

  }

  // +



  bool isVisible = true;



  TimeOfDay?  vm_timeStart;



  String get timeStart=>_getTime(vm_timeStart);





  // Il metodo per selezionare il tempo

  Future<void> _selectTime(BuildContext context) async {

    final TimeOfDay? picked = await showTimePicker(

      context: context,

      initialTime: vm_timeStart??TimeOfDay.now(),

    );



    if (picked != null && picked != vm_timeStart) {



      setState((){

        vm_timeStart=picked;

      });



    }

  }



  String _getTime(TimeOfDay? time)

  {

    if(time==null) return "-";

    else return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";



  }



  // *



  Widget getSettings(BuildContext context)
  {

    Function(Function f) setState=(f){

      super.setState( f() );

    };

    return Card(

      child: Column(

        children: <Widget>[

          ListTile(

            leading: const Icon(Icons.settings),

            title: const Text("Settings"),

            trailing: IconButton(

              onPressed: () {

                setState(() {

                  isVisible = !(isVisible);

                });

              },

              icon: Icon(!isVisible ? Icons.arrow_right : Icons.expand_less),

            ),

          ),

          Visibility(

            visible: isVisible,

            child: ListTile(

              leading: const Icon(Icons.access_time),

              title: Builder(

                builder: (context2) {

                  return TextButton(

                    onPressed: () {

                      _selectTime(context2);

                    },

                    child: Text(timeStart),

                  );

                },

              ),

              subtitle: const Text("Start!"),

            ),

          ),

        ],

      ),

    );

  }



// -
}
