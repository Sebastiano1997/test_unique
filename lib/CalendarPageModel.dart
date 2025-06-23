import 'package:flutter/material.dart';

@immutable
class Event {
  final DateTime dateTime;
  final String name;
  final String description;
  final int color; // ARGB integer value

  const Event({
    required this.dateTime,
    required this.name,
    required this.description,
    required this.color,
  });

  Event copyWith({
    DateTime? dateTime,
    String? name,
    String? description,
    int? color,
  }) {
    return Event(
      dateTime: dateTime ?? this.dateTime,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Event &&
              runtimeType == other.runtimeType &&
              dateTime == other.dateTime &&
              name == other.name &&
              description == other.description &&
              color == other.color;

  @override
  int get hashCode => Object.hash(dateTime, name, description, color);
}

/// Represents an objective for a specific week.
@immutable
class ObjectiveWeek {
  // anyDayOfWeek is used to identify the week. It should typically be
  // the first day of the week (e.g., Monday).
  final DateTime anyDayOfWeek;
  final String objective;
  final String realization;

  const ObjectiveWeek({
    required this.anyDayOfWeek,
    required this.objective,
    required this.realization,
  });

  ObjectiveWeek copyWith({
    DateTime? anyDayOfWeek,
    String? objective,
    String? realization,
  }) {
    return ObjectiveWeek(
      anyDayOfWeek: anyDayOfWeek ?? this.anyDayOfWeek,
      objective: objective ?? this.objective,
      realization: realization ?? this.realization,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ObjectiveWeek &&
              runtimeType == other.runtimeType &&
              anyDayOfWeek == other.anyDayOfWeek &&
              objective == other.objective &&
              realization == other.realization;

  @override
  int get hashCode => Object.hash(anyDayOfWeek, objective, realization);
}

/// Holds the raw data for the calendar.
class CalendarPageModel {
  List<Event> listEvent;
  List<String> listEventName;
  List<ObjectiveWeek> listObjWeek;

  CalendarPageModel({
    List<Event>? initialEvents,
    List<ObjectiveWeek>? initialObjectiveWeeks,
    List<String>? initialEventNames,
  })  : listEvent = initialEvents ?? <Event>[],
        listObjWeek = initialObjectiveWeeks ?? <ObjectiveWeek>[],
        listEventName = initialEventNames ?? <String>[
          "Meeting",
          "Appointment",
          "Workout",
          "Study Session",
          "Project Deadline"
        ];
}
