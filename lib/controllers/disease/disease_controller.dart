import 'dart:io';
import 'package:get/get.dart';
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
}
