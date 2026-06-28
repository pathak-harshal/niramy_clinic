import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentCalendar extends StatefulWidget {
  final DateTime? initialSelectedDay;
  final Function(DateTime)? onDaySelected;

  const AppointmentCalendar({
    super.key,
    this.initialSelectedDay,
    this.onDaySelected,
  });

  @override
  State<AppointmentCalendar> createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialSelectedDay ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2024),
        lastDay: DateTime.utc(2035),
        focusedDay: selectedDay,
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        onDaySelected: (selected, focused) {
          setState(() {
            selectedDay = selected;
          });
          widget.onDaySelected?.call(selected);
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}