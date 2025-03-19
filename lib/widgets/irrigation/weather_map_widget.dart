import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';

class WeatherMapWidget extends StatefulWidget {
  const WeatherMapWidget({Key? key}) : super(key: key);

  @override
  _WeatherMapWidgetState createState() => _WeatherMapWidgetState();
}

class _WeatherMapWidgetState extends State<WeatherMapWidget> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  // Get the WeatherController (ensure it's registered in your app).
  final WeatherController weatherController = Get.find<WeatherController>();

  @override
  void initState() {
    super.initState();
    // Set a default initial location (e.g., San Francisco).
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

  Future<void> _selectLocation() async {
    if (_pickedLocation != null) {
      // Update the WeatherController with the selected coordinates.
      weatherController.latitude.value = _pickedLocation!.latitude;
      weatherController.longitude.value = _pickedLocation!.longitude;
      await weatherController.fetchWeather();
      // Close the map screen.
      Get.back();
    } else {
      Get.snackbar('Error', 'Please tap on the map to select a location.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
      ),
      body: Stack(
        children: [
          // GoogleMap fills the available space.
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
              onPressed: _selectLocation,
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}