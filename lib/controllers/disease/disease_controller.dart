import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class DiseaseController extends GetxController {
  var pickedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Camera permission is required');
    }
  }

  Future<void> requestGalleryPermission() async {
    // For Android, you may need to request storage permission.
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Gallery permission is required');
    }
  }

  Future<void> pickImageFromCamera() async {
    await requestCameraPermission();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedImage.value = File(image.path);
    }
  }

  Future<void> pickImageFromGallery() async {
    await requestGalleryPermission();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = File(image.path);
    }
  }
  /// Sends the image file and plant name to the prediction API.
  /// Returns a map with keys "predicted_class" and "confidence" on success.
  Future<Map<String, dynamic>?> submitDiseasePrediction(String plant) async {
    if (pickedImage.value == null) {
      Get.snackbar("Error", "No image selected");
      return null;
    }
    final url = Uri.parse("https://lencho2-plant-disease-classification.hf.space/predict-image");
    try {
      var request = http.MultipartRequest("POST", url);
      request.fields['plant'] = plant;
      request.files.add(
        await http.MultipartFile.fromPath('image', pickedImage.value!.path),
      );
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        Get.snackbar("Error", "Prediction API returned: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Error during prediction: $e");
      return null;
    }
  }
}


