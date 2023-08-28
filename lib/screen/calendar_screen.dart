import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_appointments/model/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../widgets/new_item_form.dart';

class CalendarScreen extends StatefulWidget {
  final String userId;

  CalendarScreen({required this.userId});

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Item> _events = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeEvents();
    _initializeNotifications();
  }

  void _initializeEvents() {
    _firestore
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        List<dynamic> itemsData = data['items'];

        _events = _convertFirestoreItems(itemsData);
      } else {
        print('Document does not exist on Firestore');
      }
    });
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  List<Item> _convertFirestoreItems(List<dynamic> firestoreItems) {
    return firestoreItems.map((itemData) {
      DateTime parsedDate = DateTime.parse(itemData['date']);

      return Item(
        name: itemData['name'],
        time: TimeOfDay.fromDateTime(parsedDate),
        date: parsedDate,
        id: itemData['id'],
      );
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _initializeEvents();
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
      _events.add(item);

      _scheduleNotification(item);

      _updateFirestoreItems();
    });

    Navigator.of(context).pop();
  }

  void _updateFirestoreItems() {
    List<Map<String, dynamic>> itemsData = _events
        .map((item) => {
              'id': item.id,
              'name': item.name,
              'time': item.time.format(context),
              'date': item.date.toIso8601String()
            })
        .toList();

    _firestore.collection('users').doc(widget.userId).update({
      'items': itemsData,
    }).then((_) {
      print('Items updated in Firestore');
    }).catchError((error) {
      print('Error updating items in Firestore: $error');
    });
  }

  Future<void> _scheduleNotification(Item item) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'event_reminder_channel',
      'Event Reminder',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final DateTime date = item.date;
    final TimeOfDay time = item.time;

    final tz.TZDateTime eventDateTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      int.parse(item.id),
      'Event Reminder',
      'You have an upcoming event: ${item.name}',
      eventDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Selected Day: $_selectedDay");
    print("Events:");
    for (var event in _events) {
      print("Name: ${event.name}, Date: ${event.date}, Time: ${event.time}");
    }

    final selectedEvents = _events.where((item) {
      final eventDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(item.date);
      final selectedDate =
          DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDay);
      return eventDate == selectedDate;
    }).toList();

    print("Selected events: $selectedEvents");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              focusedDay: _focusedDay,
              firstDay: DateTime(DateTime.now().year, 1, 1),
              lastDay: DateTime(DateTime.now().year, 12, 31),
              availableCalendarFormats: {CalendarFormat.month: 'Month'},
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
                subtitle: Text('Time: ${event.time.format(context)}'),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showModalForm(context);
              },
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
