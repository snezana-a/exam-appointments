import 'package:exam_appointments/screen/calendar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        _items = userItems.map((itemData) => Item.fromJson(itemData)).toList();
        setState(() {});
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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

        userItems.add(item.toJson());

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
                            items: _items,
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
