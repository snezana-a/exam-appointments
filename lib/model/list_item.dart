import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final GeoPoint location;

  Item(
      {required this.id,
      required this.name,
      required this.date,
      required this.time,
      required this.location});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'] as String,
        name: json['name'] as String,
        date: json['date'],
        time: json['time'],
        location: json['location']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'time': time,
      'location': location
    };
  }
}
