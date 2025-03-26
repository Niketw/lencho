import 'package:flutter/material.dart';

class DiseaseResultWidget extends StatelessWidget {
  final String predictedClass;
  final double confidence;

  const DiseaseResultWidget({
    Key? key,
    required this.predictedClass,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Ensure the background is transparent.
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Disease Prediction",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Predicted Class: $predictedClass",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Confidence: ${confidence.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
