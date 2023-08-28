import 'package:exam_appointments/screen/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/list_item.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard(this.item, {super.key});

  void _showLocationOnMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => MapScreen(item.location)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('dd-MM-yyyy').format(item.date)}'),
            Text('Time: ${item.time.format(context)}'),
            GestureDetector(
              onTap: () => _showLocationOnMap(context),
              child: Text(
                  'Location: ${item.location.latitude}, ${item.location.longitude}'),
            ),
          ],
        ),
      ),
    );
  }
}
