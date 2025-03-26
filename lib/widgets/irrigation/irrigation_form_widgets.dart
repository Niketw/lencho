import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/irrigation/irrigation_form_controller.dart';
import 'package:lencho/widgets/irrigation/irrigation_result_widget.dart';

class IrrigationPlanForm extends StatefulWidget {
  const IrrigationPlanForm({Key? key}) : super(key: key);

  @override
  _IrrigationPlanFormState createState() => _IrrigationPlanFormState();
}

class _IrrigationPlanFormState extends State<IrrigationPlanForm> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown options.
  final List<String> cropTypes = [
    'BANANA',
    'BEAN',
    'CABBAGE',
    'CITRUS',
    'COTTON',
    'MAIZE',
    'MELON',
    'MUSTARD',
    'ONION',
    'POTATO',
    'RICE',
    'SOYABEAN',
    'SUGARCANE',
    'TOMATO',
    'WHEAT'
  ];
  final List<String> soilTypes = ['DRY', 'HUMID', 'WET'];

  String? selectedCrop;
  String? selectedSoil;

  final IrrigationPlanController planController = Get.put(IrrigationPlanController());

  Future<void> submitPlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        double? prediction = await planController.predictIrrigationPlan(
          cropType: selectedCrop!,
          soilType: selectedSoil!,
        );
        if (prediction != null) {
          // Display the prediction using a floating widget.
          Get.dialog(
            IrrigationResultWidget(prediction: prediction),
            barrierDismissible: true,
          );
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to submit irrigation plan: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Irrigation Plan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Crop Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedCrop,
                items: cropTypes.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCrop = value;
                  });
                },
                validator: (value) => value == null ? "Please select a crop type" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Soil Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedSoil,
                items: soilTypes.map((soil) {
                  return DropdownMenuItem(
                    value: soil,
                    child: Text(soil),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSoil = value;
                  });
                },
                validator: (value) => value == null ? "Please select a soil type" : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: submitPlan,
                child: const Text("Submit Irrigation Plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
