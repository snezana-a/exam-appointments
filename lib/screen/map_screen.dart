import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final GeoPoint geoPoint;

  MapScreen(this.geoPoint);

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = LatLng(geoPoint.latitude, geoPoint.longitude);

    print('GeoPoint: $geoPoint');
    print('Initial Camera Position: $initialCameraPosition');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialCameraPosition,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('marker_1'),
            position: initialCameraPosition,
            infoWindow: const InfoWindow(
              title: 'Marker Title',
              snippet: 'Marker Description',
            ),
          ),
        },
      ),
    );
  }
}
