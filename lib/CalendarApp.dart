import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

import 'CalendarPageModel.dart';
import 'CalendarPageViewModel.dart'; // For UnmodifiableListView

class CalendarPageView extends StatelessWidget {
  const CalendarPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CalendarPageViewModel>(
          builder: (BuildContext context, CalendarPageViewModel viewModel, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    viewModel.currentMonthAdd(-1);
                  },
                ),
                Text(
                  '${_getMonthName(viewModel.currentMonth.month)} ${viewModel.currentMonth.year}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    viewModel.currentMonthAdd(1);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<CalendarPageViewModel>(
        builder: (BuildContext context, CalendarPageViewModel viewModel, Widget? child) {
          final List<List<DateTime?>> weeks = viewModel.getWeeksInMonth();
          final DateTime today = DateTime.now();

          return Column(
            children: <Widget>[
              _buildWeekDaysHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: weeks.length,
                  itemBuilder: (BuildContext context, int weekIndex) {
                    final List<DateTime?> week = weeks[weekIndex];
                    final DateTime? firstDayInWeek =
                    week.firstWhere((DateTime? day) => day != null);
                    // Determine the start of the current calendar week for ObjectiveWeek
                    final DateTime startOfWeek = firstDayInWeek != null
                        ? viewModel.getStartOfWeek(firstDayInWeek)
                        : DateTime.now().copyWith(
                        hour: 0,
                        minute: 0,
                        second: 0,
                        millisecond: 0,
                        microsecond: 0); // Fallback

                    final ObjectiveWeek? weeklyObjective =
                    viewModel.getObjectiveWeekForWeek(startOfWeek);

                    IconData objectiveIcon;
                    Color objectiveIconColor;
                    String objectiveTooltip;

                    if (weeklyObjective != null && weeklyObjective.objective.isNotEmpty) {
                      if (weeklyObjective.realization.isNotEmpty) {
                        objectiveIcon = Icons.check_circle;
                        objectiveIconColor = Colors.green.shade700;
                        objectiveTooltip =
                        'Weekly Objective Realized: ${weeklyObjective.objective}\nRealization: ${weeklyObjective.realization}';
                      } else {
                        objectiveIcon = Icons.edit_note;
                        objectiveIconColor = Colors.orange.shade700;
                        objectiveTooltip =
                        'Weekly Objective Pending: ${weeklyObjective.objective}';
                      }
                    } else {
                      objectiveIcon = Icons.edit_note;
                      objectiveIconColor = Colors.grey;
                      objectiveTooltip = 'Set Weekly Objective';
                    }

                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ...week.map<Widget>((DateTime? day) {
                              return Expanded(
                                child: DayTile(
                                  day: day,
                                  isToday: day != null &&
                                      day.year == today.year &&
                                      day.month == today.month &&
                                      day.day == today.day,
                                  events: day != null ? viewModel.getEventsForDay(day) : <Event>[],
                                  onTap: (DateTime? selectedDay) {
                                    if (selectedDay != null) {
                                      final List<Event> eventsForSelectedDay =
                                      viewModel.getEventsForDay(selectedDay);
                                      if (eventsForSelectedDay.isEmpty) {
                                        _showEventManagementDialog(
                                            context, viewModel, selectedDay);
                                      } else {
                                        _showDayEventsOverviewBottomSheet(
                                            context, viewModel, selectedDay);
                                      }
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                            // Objective Week Button
                            SizedBox(
                              width: 48.0, // Fixed width for the button column
                              child: IconButton(
                                icon: Icon(objectiveIcon, color: objectiveIconColor),
                                tooltip: objectiveTooltip,
                                onPressed: firstDayInWeek != null
                                    ? () {
                                  _showObjectiveWeekManagementDialog(
                                      context, viewModel, startOfWeek);
                                }
                                    : null, // Disable if no valid days in week
                              ),
                            ),
                          ],
                        ),
                        // Add a subtle divider between weeks for visual separation
                        if (weekIndex < weeks.length - 1)
                          const Divider(height: 1, thickness: 0.5, indent: 8, endIndent: 8),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventManagementDialog(
            context, context.read<CalendarPageViewModel>(), DateTime.now()),
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final List<String> weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          ...weekdays.map<Widget>((String day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
          const SizedBox(width: 48.0), // Space for Objective Week Button
        ],
      ),
    );
  }

  static String _getMonthName(int month) {
    const List<String> monthNames = <String>[
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month];
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.toLocal().hour.toString().padLeft(2, '0')}:${dateTime.toLocal().minute.toString().padLeft(2, '0')}';
  }

  void _showEventManagementDialog(BuildContext context, CalendarPageViewModel viewModel,
      DateTime initialDate, {Event? eventToEdit}) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController nameController =
        TextEditingController(text: eventToEdit?.name ?? '');
        final TextEditingController descriptionController = TextEditingController(text: eventToEdit?.description ?? '');
        DateTime selectedDate = eventToEdit?.dateTime ?? initialDate;
        TimeOfDay selectedTime = eventToEdit != null
            ? TimeOfDay.fromDateTime(eventToEdit.dateTime)
            : TimeOfDay.fromDateTime(initialDate);
        int selectedColor = eventToEdit?.color ?? Colors.blue.value;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(eventToEdit == null ? 'Add Event' : 'Edit Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        // Keep the external nameController in sync with Autocomplete's internal TextField input.
                        // This ensures `nameController.text` always holds the current displayed value.
                        nameController.text = textEditingValue.text;

                        if (textEditingValue.text.isEmpty) {
                          // Show all suggestions when the input is empty
                          return viewModel.eventNameSuggestions;
                        }
                        return viewModel.eventNameSuggestions.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        // When a suggestion is selected, update the external nameController.
                        nameController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          void Function() onFieldSubmitted) {
                        // Ensure the Autocomplete's internal controller displays the initial value
                        // from `nameController` when the dialog first appears for editing.
                        // This check prevents an infinite loop if the values are already in sync.
                        if (textEditingController.text != nameController.text) {
                          textEditingController.text = nameController.text;
                        }

                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onSubmitted: (String value) => onFieldSubmitted(),
                          decoration: const InputDecoration(labelText: 'Event Name'),
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 200.0, // Fixed height for the dropdown
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                      // Ensure nameController is updated here too, in case onSelected doesn't trigger a rebuild
                                      nameController.text = option;
                                    },
                                    child: ListTile(
                                      title: Text(option),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    ListTile(
                      title: Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Time: ${selectedTime.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                    _ColorPicker(
                      selectedColor: selectedColor,
                      onColorSelected: (int color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (eventToEdit != null)
                  TextButton(
                    onPressed: () {
                      viewModel.deleteEvent(eventToEdit);
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event name cannot be empty')),
                      );
                      return;
                    }
                    final Event newEvent = Event(
                      dateTime: selectedDate.copyWith(
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                        second: 0,
                        millisecond: 0,
                        microsecond: 0,
                      ),
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      color: selectedColor,
                    );
                    if (eventToEdit == null) {
                      viewModel.addEvent(newEvent);
                    } else {
                      viewModel.updateEvent(eventToEdit, newEvent);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(eventToEdit == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDayEventsOverviewBottomSheet(
      BuildContext context, CalendarPageViewModel viewModel, DateTime selectedDate) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Allow the sheet to take more than 50% height
      builder: (BuildContext sheetContext) {
        // Provide the existing viewModel instance to this new route's context
        return ChangeNotifierProvider<CalendarPageViewModel>.value(
          value: viewModel, // Use the viewModel instance passed to the function
          builder: (BuildContext context, Widget? child) => // Use builder for correct context
          Padding(
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom), // Adjust for keyboard
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.75, // 75% of screen height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Events on ${selectedDate.day} ${CalendarPageView._getMonthName(selectedDate.month)} ${selectedDate.year}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          tooltip: 'Add New Event',
                          onPressed: () {
                            Navigator.of(sheetContext).pop(); // Close current sheet
                            _showEventManagementDialog(context, viewModel,
                                selectedDate); // Use the new context from builder
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    // Now this Consumer will find the provider from ChangeNotifierProvider.value
                    child: Consumer<CalendarPageViewModel>(
                      builder: (BuildContext consumerContext,
                          CalendarPageViewModel vm,
                          Widget? consumerChild) {
                        final List<Event> dailyEvents = vm.getEventsForDay(selectedDate);
                        if (dailyEvents.isEmpty) {
                          return const Center(child: Text('No events for this day.'));
                        }
                        return ListView.builder(
                          itemCount: dailyEvents.length,
                          itemBuilder: (BuildContext listContext, int index) {
                            final Event event = dailyEvents[index];
                            return Card(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(event.color),
                                  radius: 12, // Slightly larger avatar
                                ),
                                title: Text(event.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (event.description.isNotEmpty) Text(event.description),
                                    Text(
                                      'Time: ${_formatTime(event.dateTime)}',
                                      style:
                                      const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop(); // Close the bottom sheet
                                  _showEventManagementDialog(consumerContext, viewModel,
                                      selectedDate,
                                      eventToEdit: event);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showObjectiveWeekManagementDialog(
      BuildContext context, CalendarPageViewModel viewModel, DateTime weekStartDate) {
    ObjectiveWeek? existingObjective = viewModel.getObjectiveWeekForWeek(weekStartDate);
    final TextEditingController objectiveController =
    TextEditingController(text: existingObjective?.objective ?? '');
    final TextEditingController realizationController =
    TextEditingController(text: existingObjective?.realization ?? '');

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(existingObjective == null ? 'Add Weekly Objective' : 'Edit Weekly Objective'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('For week starting: ${weekStartDate.toLocal().toString().split(' ')[0]}'),
                TextField(
                  controller: objectiveController,
                  decoration: const InputDecoration(labelText: 'Objective'),
                  maxLines: 3,
                ),
                TextField(
                  controller: realizationController,
                  decoration: const InputDecoration(labelText: 'Realization/Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            if (existingObjective != null)
              TextButton(
                onPressed: () {
                  viewModel.deleteObjectiveWeek(existingObjective);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final ObjectiveWeek newObjectiveWeek = ObjectiveWeek(
                  anyDayOfWeek: weekStartDate,
                  objective: objectiveController.text.trim(),
                  realization: realizationController.text.trim(),
                );
                viewModel.addObjectiveWeek(newObjectiveWeek); // This method handles add/update
                Navigator.of(dialogContext).pop();
              },
              child: Text(existingObjective == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}

class DayTile extends StatelessWidget {
  final DateTime? day;
  final bool isToday;
  final List<Event> events;
  final ValueChanged<DateTime?> onTap;

  const DayTile({
    super.key,
    required this.day,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // This context.read is correct because DayTile is built within the Consumer in CalendarPageView's body.
    final bool isCurrentMonth =
        day != null && day!.month == context.read<CalendarPageViewModel>().currentMonth.month;

    return GestureDetector(
      onTap: () => onTap(day),
      child: Container(
        height: 80, // Fixed height for each day tile
        decoration: BoxDecoration(
          color: isToday ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0, top: 4.0),
                child: Text(
                  day?.day.toString() ?? '',
                  style: TextStyle(
                    color: isCurrentMonth ? Colors.black : Colors.grey,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                // Allow scrolling if too many events
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(2).map<Widget>((Event event) {
                    // Show up to 2 events directly
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.5),
                      child: Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(event.color).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          event.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (events.length > 2) // Indicate more events
              const Text(
                '+more',
                style: TextStyle(fontSize: 8, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatefulWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late int _currentSelectedColor;

  final List<Color> _availableColors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _currentSelectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _availableColors.map<Widget>((Color color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentSelectedColor = color.value;
                });
                widget.onColorSelected(color.value);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: _currentSelectedColor == color.value
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: _currentSelectedColor == color.value
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: ChangeNotifierProvider<CalendarPageViewModel>(
        create: (BuildContext context) => CalendarPageViewModel(),
        builder: (BuildContext context, Widget? child) => const CalendarPageView(),
      ),
    );
  }
}