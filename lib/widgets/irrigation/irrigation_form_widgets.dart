import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/irrigation/irrigation_form_controller.dart';

class IrrigationPlanForm extends StatefulWidget {
  const IrrigationPlanForm({Key? key}) : super(key: key);

  @override
  _IrrigationPlanFormState createState() => _IrrigationPlanFormState();
}

class _IrrigationPlanFormState extends State<IrrigationPlanForm> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown options.
  final List<String> cropTypes = ['Wheat', 'Corn', 'Rice', 'Soybean'];
  final List<String> soilTypes = ['Sandy', 'Clay', 'Loamy', 'Silty'];

  String? selectedCrop;
  String? selectedSoil;

  final IrrigationPlanController planController = Get.put(IrrigationPlanController());

  Future<void> submitPlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await planController.submitIrrigationPlan(
          cropType: selectedCrop!,
          soilType: selectedSoil!,
        );
        Get.defaultDialog(
          title: "Irrigation Plan",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Crop Type: ${result['cropType']}"),
              Text("Soil Type: ${result['soilType']}"),
              Text("Region: ${result['region']}"),
              Text("Temperature: ${result['temperature'].toStringAsFixed(1)}°C"),
              Text("Temp Classification: ${result['tempClassification']}"),
              Text("Weather Type: ${result['weatherType']}"),
            ],
          ),
          textConfirm: "OK",
          onConfirm: () {
            Get.back();
          },
        );
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
