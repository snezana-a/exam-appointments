import 'package:exam_appointments/screen/calendar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/list_item.dart';
import '../widgets/item_card.dart';
import '../widgets/new_item_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        final userItems = userData.data()?['items'] as List<dynamic>;
        _items = _convertFirestoreItems(userItems);
        setState(() {});
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  List<Item> _convertFirestoreItems(List<dynamic> firestoreItems) {
    return firestoreItems.map((itemData) {
      final DateTime itemDate = DateTime.parse(itemData['date']);
      final String timeString = itemData['time'];

      final DateFormat timeFormat = DateFormat('h:mm a');
      final DateTime parsedTime = timeFormat.parse(timeString);

      final TimeOfDay itemTime = TimeOfDay.fromDateTime(parsedTime);
      final GeoPoint location = itemData['location'] as GeoPoint;

      return Item(
          id: itemData['id'],
          name: itemData['name'],
          date: itemDate,
          time: itemTime,
          location: location);
    }).toList();
  }

  Future<void> saveItem(Item item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userDocRef.get();
      if (userData.exists) {
        final userItems = userData.data()?['items'] as List<dynamic>;

        final Map<String, dynamic> itemData = item.toJson();
        itemData['date'] = item.date.toIso8601String();
        itemData['time'] = item.time.format(context);
        itemData['location'] =
            GeoPoint(item.location.latitude, item.location.longitude);

        userItems.add(itemData);

        await userDocRef.update({'items': userItems});
      }
    } catch (e) {
      print('Error saving item: $e');
    }
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
    saveItem(item);
    setState(() {
      _items.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarScreen(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          )));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: GestureDetector(
              onTap: () => _showModalForm(context),
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
              "No elements",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ))
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return ItemCard(
                  _items[index],
                );
              },
              itemCount: _items.length,
            ),
    );
  }
}
