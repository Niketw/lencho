import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/disease/disease_controller.dart';
import 'package:lencho/widgets/disease/disease_result.dart';

class DiseaseDetectionWidget extends StatelessWidget {
  DiseaseDetectionWidget({Key? key}) : super(key: key);

  final DiseaseController diseaseController = Get.put(DiseaseController());
  final TextEditingController plantNameController = TextEditingController();

  Future<void> _submitDetection() async {
    if (plantNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a plant name.");
      return;
    }
    try {
      final result = await diseaseController.submitDiseasePrediction(
          plantNameController.text.trim());
      if (result != null) {
        String predictedClass = result["predicted_class"];
        double confidence = (result["confidence"] as num).toDouble();
        // Show the result in a dialog overlay.
        Get.dialog(
          DiseaseResultWidget(
            predictedClass: predictedClass,
            confidence: confidence,
          ),
          barrierDismissible: true,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit detection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Plant Name Field
            TextField(
              controller: plantNameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Buttons for picking image.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await diseaseController.pickImageFromCamera();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await diseaseController.pickImageFromGallery();
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display the picked image.
            Obx(() {
              if (diseaseController.pickedImage.value != null) {
                return Image.file(
                  diseaseController.pickedImage.value!,
                  height: 200,
                );
              } else {
                return const Text('No image selected.');
              }
            }),
            const SizedBox(height: 16),
            // Submit Detection Button.
            ElevatedButton(
              onPressed: _submitDetection,
              child: const Text('Submit Detection'),
            ),
          ],
        ),
      ),
    );
  }
}
