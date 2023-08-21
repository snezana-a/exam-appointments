import 'package:flutter/material.dart';

import '../model/list_item.dart';
import '../widgets/item_card.dart';
import '../widgets/new_item_form.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Item> _items = [
    Item(id: "0", name: "Exam 1", date: "12-04-2023", time: "12:00"),
    Item(id: "1", name: "Exam 2", date: "13-04-2023", time: "12:00"),
    Item(id: "2", name: "Exam 3", date: "14-04-2023", time: "12:00"),
  ];

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
      _items.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
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
