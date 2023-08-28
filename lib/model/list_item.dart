import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final DateTime date;
  final TimeOfDay time;

  Item({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      date: json['date'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'time': time,
    };
  }
}
