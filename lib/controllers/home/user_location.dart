import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';

class UserLocationController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Updates the user's latitude and longitude in Firestore,
  /// finding the document by matching the email with the current user's email,
  /// and then updating the weather.
  Future<void> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    try {
      // Query for documents in 'UserDetails' where the email matches the current user's email.
      final querySnapshot = await _db
          .collection('UserDetails')
          .where('email', isEqualTo: user.email?.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the first matching document.
        final docId = querySnapshot.docs.first.id;
        print("Found document $docId for user email ${user.email}");
        await _db.collection('UserDetails').doc(docId).set({
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        Get.snackbar('Success', 'Location updated successfully.');
        print("User ${user.uid} location updated to: ($latitude, $longitude) in doc: $docId");
      } else {
        // No document found with the matching email, so create a new one using the user's UID.
        print("No document found for email ${user.email}. Creating a new document with UID ${user.uid}");
        await _db.collection('UserDetails').doc(user.uid).set({
          'email': user.email?.trim() ?? '',
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Location updated successfully.');
        print("Created new document for user ${user.uid} with location: ($latitude, $longitude)");
      }
      // After updating Firestore, update the weather.
      final WeatherController weatherController = Get.find<WeatherController>();
      await weatherController.fetchLocationFromUserDetails();
    } catch (e) {
      print("Error updating location for user ${user.uid}: $e");
      Get.snackbar('Error', 'Failed to update location: $e');
    }
  }
}
