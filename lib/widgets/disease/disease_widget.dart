import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/disease/disease_controller.dart';
import 'package:lencho/widgets/disease/disease_result.dart';
import 'package:lencho/widgets/home/header_widgets.dart'; // Ensure the path is correct

class DiseaseDetectionWidget extends StatefulWidget {
  DiseaseDetectionWidget({Key? key}) : super(key: key);

  @override
  _DiseaseDetectionWidgetState createState() => _DiseaseDetectionWidgetState();
}

class _DiseaseDetectionWidgetState extends State<DiseaseDetectionWidget> {
  final DiseaseController diseaseController = Get.put(DiseaseController());

  // List of plant types. Update these values as needed.
  final List<String> plantTypes = [
    'Mango', 'Cassava'
  ];

  String? _selectedPlant;

  Future<void> _submitDetection() async {
    if (_selectedPlant == null || _selectedPlant!.trim().isEmpty) {
      Get.snackbar("Error", "Please select a plant type.");
      return;
    }
    try {
      final result = await diseaseController.submitDiseasePrediction(_selectedPlant!.trim());
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
  void initState() {
    super.initState();
    // Optionally, you can set a default plant type.
    _selectedPlant = plantTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 255, 1),
      // Remove the default AppBar and use our custom header.
      body: Column(
        children: [
          // Custom header (shows a back button since isHome is false)
          const HomeHeader(isHome: false),
          // Expanded content that scrolls beneath the fixed header.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Disease Detection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Plant Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedPlant,
                    decoration: const InputDecoration(
                      labelText: 'Select Plant Type',
                      border: OutlineInputBorder(),
                    ),
                    items: plantTypes
                        .map((plant) => DropdownMenuItem(
                              value: plant,
                              child: Text(plant),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPlant = value;
                      });
                    },
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
                  // Display the picked image with a remove button overlay.
                  Obx(() {
                    if (diseaseController.pickedImage.value != null) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            diseaseController.pickedImage.value!,
                            height: 200,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              diseaseController.pickedImage.value = null;
                            },
                          ),
                        ],
                      );
                    } else {
                      return const Text(
                        'No image selected.',
                        textAlign: TextAlign.center,
                      );
                    }
                  }),
                  const SizedBox(height: 16),
                  // Submit Detection Button.
                  ElevatedButton(
                    onPressed: _submitDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFACE268),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Submit Detection',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
