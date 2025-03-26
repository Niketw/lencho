import 'package:flutter/material.dart';

class IrrigationResultWidget extends StatelessWidget {
  final double prediction;

  const IrrigationResultWidget({Key? key, required this.prediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100, // Adjust the position as needed.
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          "Irrigation Prediction: ${prediction.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
