import 'package:exam_appointments/model/list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/new_item_form.dart';

class CalendarScreen extends StatefulWidget {
  final List<Item> items;

  const CalendarScreen({required this.items});

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<Item>> _events = {};

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _showModalForm(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () => {},
          behavior: HitTestBehavior.opaque,
          child: NewItemForm(_addItemToList),
        );
      },
    );
  }

  void _addItemToList(Item item) {
    setState(() {
      widget.items.add(item);
      DateTime date = DateTime.parse(item.date);
      if (!_events.containsKey(date)) {
        _events[date] = [];
      }
      _events[date]!.add(item);
    });
    Navigator.of(context).pop();
  }

  DateTime parseCustomDate(String customDate) {
    final parts = customDate.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day).toUtc();
      }
    }
    return DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      DateTime date = parseCustomDate(item.date);
      if (!_events.containsKey(date)) {
        _events[date] = [];
      }
      _events[date]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _events[_selectedDay] ?? [];
    print('Selected Day: $_selectedDay');
    print('Event Keys: ${_events.keys}');
    print('Selected Events: $selectedEvents');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              focusedDay: _focusedDay,
              firstDay: DateTime(DateTime.now().year, 1, 1),
              lastDay: DateTime(DateTime.now().year, 12, 31),
              calendarFormat: CalendarFormat.month,
            ),
            const SizedBox(height: 16),
            Text(
              'Events for ${DateFormat('dd-MM-yyyy').format(_selectedDay)}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (selectedEvents.isEmpty) const Text('No events for this date.'),
            for (final event in selectedEvents)
              ListTile(
                title: Text(event.name),
                subtitle: Text('Time: ${event.time}'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => {_showModalForm(context)},
              child: const Text('Add event'),
            ),
          ],
        ),
      ),
    );
  }
}
