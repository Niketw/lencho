import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/controllers/home/user_location.dart';
import 'package:lencho/screens/home/home_page.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  // Fallback coordinates.
  LatLng _pickedLocation = LatLng(25.4381, 81.8338);
  final UserLocationController userLocationController = Get.put(UserLocationController());

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Get the current user from Firebase Auth.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Fetch user location details from your controller.
      final userLocation = await userLocationController.getUserLocation();
      if (userLocation != null &&
          userLocation.latitude != null &&
          userLocation.longitude != null) {
        setState(() {
          _pickedLocation = LatLng(userLocation.latitude, userLocation.longitude);
        });
        _mapController.move(_pickedLocation, 12.0);
        return;
      }
    }
    // If no user location details, _pickedLocation remains as fallback.
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _pickedLocation = latlng;
    });
  }

  Future<void> _selectLocation() async {
    // Update the user's location in Firestore.
    await userLocationController.updateUserLocation(
      latitude: _pickedLocation.latitude,
      longitude: _pickedLocation.longitude,
    );
    Get.offAll(() => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _pickedLocation,
              zoom: 12.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _selectLocation,
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}
