import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

import 'CalendarPageModel.dart'; // For UnmodifiableListView

/// Helper extension to find first element or null
extension _FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class CalendarPageViewModel extends ChangeNotifier {
  final CalendarPageModel _model;
  DateTime _currentMonth; // Represents the first day of the month being viewed.

  CalendarPageViewModel({
    CalendarPageModel? model,
  })  : _model = model ?? CalendarPageModel(),
        _currentMonth = DateTime.now().copyWith(
            day: 1, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  DateTime get currentMonth => _currentMonth;

  // added +-1 of current month
  void currentMonthAdd(int monthAdded) {
    _currentMonth = _addDuration(_currentMonth, month: monthAdded);
    notifyListeners();
  }

  DateTime _addDuration(DateTime date, {Duration? duration, int? month, int? year}) {
    DateTime dateReturned = date;
    if (duration != null) {
      dateReturned = dateReturned.add(duration);
    }
    if (month != null) {
      int monthCurrent = dateReturned.month;
      dateReturned = DateTime(dateReturned.year, monthCurrent + month,
          dateReturned.day, dateReturned.hour, dateReturned.minute, dateReturned.second, dateReturned.millisecond);
    }
    if (year != null) {
      int yearCurrent = dateReturned.year;
      dateReturned = DateTime(yearCurrent + year, dateReturned.month,
          dateReturned.day, dateReturned.hour, dateReturned.minute, dateReturned.second, dateReturned.millisecond);
    }

    return dateReturned;
  }

  // --- Event Management ---

  List<Event> getEventsForDay(DateTime dateOfDay) {
    return _model.listEvent
        .where((Event event) =>
    event.dateTime.year == dateOfDay.year &&
        event.dateTime.month == dateOfDay.month &&
        event.dateTime.day == dateOfDay.day)
        .toList();
  }

  void addEvent(Event event) {
    _model.listEvent.add(event);
    _model.listEvent.sort((Event a, Event b) => a.dateTime.compareTo(b.dateTime)); // Keep sorted
    addEventNameSuggestion(event.name); // Add name to suggestions
    notifyListeners();
  }

  // Helper to check if a name is still used by other events, excluding a specific one
  bool _isEventNameStillUsedExcludingEvent(String name, Event excludedEvent) {
    return _model.listEvent.any((Event e) => e.name == name && e != excludedEvent);
  }

  void updateEvent(Event oldEvent, Event newEvent) {
    final int index = _model.listEvent.indexOf(oldEvent);
    if (index != -1) {
      // If the event name has changed, manage suggestions
      if (oldEvent.name != newEvent.name) {
        // Check if the old name is still used by any other event (excluding the one being updated)
        if (!_isEventNameStillUsedExcludingEvent(oldEvent.name, oldEvent)) {
          _model.listEventName.remove(oldEvent.name);
          _model.listEventName.sort(); // Keep sorted
        }
        // Add the new name to suggestions (it will check for existence internally)
        addEventNameSuggestion(newEvent.name);
      }

      _model.listEvent[index] = newEvent;
      _model.listEvent.sort((Event a, Event b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    }
  }

  void deleteEvent(Event event) {
    final String eventNameToRemove = event.name;
    _model.listEvent.remove(event);

    // After removing the event, check if its name is still present in any other event
    final bool nameStillInUse = _model.listEvent.any((Event e) => e.name == eventNameToRemove);
    if (!nameStillInUse) {
      _model.listEventName.remove(eventNameToRemove);
      _model.listEventName.sort(); // Keep sorted
    }
    notifyListeners();
  }

  // --- Objective Week Management ---

  ObjectiveWeek? getObjectiveWeekForWeek(DateTime dayInWeek) {
    final DateTime startOfWeek = getStartOfWeek(dayInWeek);
    return _model.listObjWeek.firstWhereOrNull(
            (ObjectiveWeek obj) => getStartOfWeek(obj.anyDayOfWeek) == startOfWeek);
  }

  void addObjectiveWeek(ObjectiveWeek obj) {
    // Ensure only one objective per week, update if exists
    final int existingIndex = _model.listObjWeek.indexWhere(
            (ObjectiveWeek e) => getStartOfWeek(e.anyDayOfWeek) == getStartOfWeek(obj.anyDayOfWeek));
    if (existingIndex != -1) {
      _model.listObjWeek[existingIndex] = obj;
    } else {
      _model.listObjWeek.add(obj);
      _model.listObjWeek.sort((ObjectiveWeek a, ObjectiveWeek b) =>
          a.anyDayOfWeek.compareTo(b.anyDayOfWeek)); // Keep sorted
    }
    notifyListeners();
  }

  void updateObjectiveWeek(ObjectiveWeek oldObj, ObjectiveWeek newObj) {
    final int index = _model.listObjWeek.indexOf(oldObj);
    if (index != -1) {
      _model.listObjWeek[index] = newObj;
      _model.listObjWeek.sort((ObjectiveWeek a, ObjectiveWeek b) =>
          a.anyDayOfWeek.compareTo(b.anyDayOfWeek));
      notifyListeners();
    }
  }

  void deleteObjectiveWeek(ObjectiveWeek obj) {
    _model.listObjWeek.remove(obj);
    notifyListeners();
  }

  // Helper to get the start of the week (Monday)
  DateTime getStartOfWeek(DateTime date) {
    int daysToMonday = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToMonday)).copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  // --- Event Name Suggestions ---

  List<String> get eventNameSuggestions =>
      UnmodifiableListView<String>(_model.listEventName);

  void addEventNameSuggestion(String name) {
    if (!_model.listEventName.contains(name) && name.trim().isNotEmpty) {
      _model.listEventName.add(name);
      _model.listEventName.sort(); // Keep sorted
      notifyListeners(); // Only notify if a new suggestion is added
    }
  }

  // --- Calendar Grid Logic ---

  List<List<DateTime?>> getWeeksInMonth() {
    final List<List<DateTime?>> weeks = <List<DateTime?>>[];
    final DateTime firstDayOfMonth = _currentMonth;
    final int daysInMonth =
    DateUtils.getDaysInMonth(firstDayOfMonth.year, firstDayOfMonth.month);

    // Calculate the number of leading empty cells to align with Monday
    // Dart's DateTime.weekday: Monday=1, Sunday=7
    int startWeekday = firstDayOfMonth.weekday; // 1 for Monday, ..., 7 for Sunday
    int daysToPrepend = (startWeekday - 1);

    List<DateTime?> currentWeek = List<DateTime?>.filled(7, null);
    int dayCount = 1;

    // Fill leading empty days
    for (int i = 0; i < daysToPrepend; i++) {
      currentWeek[i] = null;
    }

    // Fill days of the month for the first week
    for (int i = daysToPrepend; i < 7; i++) {
      if (dayCount <= daysInMonth) {
        currentWeek[i] = firstDayOfMonth.copyWith(day: dayCount);
        dayCount++;
      }
    }
    weeks.add(currentWeek);

    // Fill remaining weeks
    while (dayCount <= daysInMonth) {
      currentWeek = List<DateTime?>.filled(7, null);
      for (int i = 0; i < 7; i++) {
        if (dayCount <= daysInMonth) {
          currentWeek[i] = firstDayOfMonth.copyWith(day: dayCount);
          dayCount++;
        } else {
          currentWeek[i] = null; // Fill remaining with nulls
        }
      }
      weeks.add(currentWeek);
    }
    return weeks;
  }
}