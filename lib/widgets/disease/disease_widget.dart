import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/disease/disease_controller.dart';

class DiseaseDetectionWidget extends StatelessWidget {
  DiseaseDetectionWidget({Key? key}) : super(key: key);

  final DiseaseController diseaseController = Get.put(DiseaseController());
  final TextEditingController plantNameController = TextEditingController();

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
            // Submit button.
            ElevatedButton(
              onPressed: () {
                // You can process the plant name and image here.
                Get.snackbar('Submitted', 'Plant: ${plantNameController.text}');
              },
              child: const Text('Submit Detection'),
            ),
          ],
        ),
      ),
    );
  }
}
