import 'package:flutter/material.dart';
import 'package:lencho/widgets/BushCloudPainter.dart';
import 'dart:math' as math;

class BushCloudRotated extends StatelessWidget {
  const BushCloudRotated({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi, // 180 degrees
      child: CustomPaint(
        painter: BushCloudPainter(heightShift: -0.4),
        child: Container(),
      ),
    );
  }
}