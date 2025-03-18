import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    // Set a default initial location (for example, San Francisco).
    _pickedLocation = const LatLng(37.7749, -122.4194);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
      ),
      body: Stack(
        children: [
          // Ensure the GoogleMap fills the available space.
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onMapTap,
              initialCameraPosition: CameraPosition(
                target: _pickedLocation!,
                zoom: 12,
              ),
              markers: _pickedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('pickedLocation'),
                        position: _pickedLocation!,
                      )
                    }
                  : {},
            ),
          ),
          // Positioned button at the bottom.
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (_pickedLocation != null) {
                  // Return the selected location.
                  Get.back(result: _pickedLocation);
                } else {
                  Get.snackbar('Error', 'Please tap on the map to select a location.');
                }
              },
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}
